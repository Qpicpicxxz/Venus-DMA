// Streamder：DMA操作中数据流控制，处理数据的读写操作
module dma_streamer
  import axi_pkg::*;
  import dma_pkg::*;
#(
  parameter bit STREAM_TYPE = 0 // 0 - Read, 1 - Write
) (
  input                                     clk,
  input                                     rst,
  // From/To CSRs
  input   s_dma_desc_t                      dma_desc_i,
  // From/To AXI I/F
  output  s_dma_axi_req_t                   dma_axi_req_o,
  input   s_dma_axi_resp_t                  dma_axi_resp_i,
  // To/From DMA FSM
  input   s_dma_str_in_t                    dma_stream_i,
  output  s_dma_str_out_t                   dma_stream_o
);
  localparam bytes_p_burst = (`DMA_DATA_WIDTH/8); // bytes_p_burst = 512bit / 8 = 64byte 一次突发传输64byte的数据
  localparam max_txn_width = $clog2(`DMA_MAX_BEAT_BURST*(`DMA_DATA_WIDTH/8));

  dma_sm_t    cur_st_ff,      next_st;
  axi_addr_t  desc_addr_ff,   next_desc_addr;
  desc_num_t  desc_bytes_ff,  next_desc_bytes;

  typedef logic [max_txn_width:0] max_bytes_t;

  s_dma_axi_req_t dma_req_ff, next_dma_req;
  max_bytes_t     txn_bytes;

  logic last_txn_ff, next_last_txn;
  logic [3:0] num_unalign_bytes;
  logic       last_txn_proc;

  function automatic logic burst_r4KB(axi_addr_t base, axi_addr_t fut);
    if (fut[31:12] < base[31:12]) begin // Overflow
      return 0; // Boundary hit
    end
    else begin
      if (fut[31:12] > base[31:12]) begin
        return (fut[11:0] == '0); // Base + burst fits exactly 4KB boundary, np
      end
      else begin
        return 1; //No leakage
      end
    end
  endfunction

  // `addr`: 起始地址  ｜  `bytes`: 要传输的字节数（512bits）
  function automatic axi_len_t great_alen(axi_addr_t addr, desc_num_t bytes);
    axi_addr_t fut_addr;  // 存储next(future)地址
    axi_len_t alen = 0;   // 单个数据包突发(single beat-burst)「存储最终算出来的burst长度」
    desc_num_t txn_sz;    // transaction size
    for (int i=`DMA_MAX_BEAT_BURST; i>0; i--) begin
      // 检查是否有足够的字节数来满足「alen」
      fut_addr = addr+(i*bytes_p_burst);
      txn_sz = (i*bytes_p_burst); // 256 × 64byte = 16384bytes
      // bytes是否支持当前迭代的传输大小 ｜ 是否满足最大burst长度的配置要求 ｜ 是否满足特定传输模式下有效突发要求
      if (bytes >= txn_sz) begin
        // Check if we respect the 4KB boundary per burst
        if (burst_r4KB(addr, fut_addr)) begin
          // 将`i-1`的结果转换为类型`axi_len_t`并赋值给变量`alen`
          alen = axi_len_t'(i-1);
          return alen;
        end
      end
    end
  endfunction

  always_comb begin : streamer_dma_ctrl
    next_st = DMA_ST_SM_IDLE;
    case (cur_st_ff)
      DMA_ST_SM_IDLE: begin
        if (dma_stream_i.valid) begin
          next_st = DMA_ST_SM_RUN;
        end
      end
      DMA_ST_SM_RUN: begin
        if (desc_bytes_ff > 0) begin
          next_st = DMA_ST_SM_RUN;
        end
        else if (last_txn_ff && ~dma_axi_resp_i.ready) begin
          next_st = DMA_ST_SM_RUN;
        end
      end
    endcase
  end : streamer_dma_ctrl

  always_comb begin : burst_calc
    dma_stream_o      = s_dma_str_out_t'('0);
    next_dma_req      = dma_req_ff;
    next_desc_addr    = desc_addr_ff;
    next_desc_bytes   = desc_bytes_ff;
    dma_axi_req_o     = dma_req_ff;
    next_last_txn     = last_txn_ff;
    last_txn_proc     = 1'b0;
    num_unalign_bytes = '0;

    // Initialize Stream operation
    if ((cur_st_ff == DMA_ST_SM_IDLE) && (next_st == DMA_ST_SM_RUN)) begin
      next_desc_bytes =  dma_desc_i.num_bytes;

      if (STREAM_TYPE) begin
        next_desc_addr = dma_desc_i.dst_addr;
      end
      else begin
        next_desc_addr = dma_desc_i.src_addr;
      end
    end

    txn_bytes = max_bytes_t'('0);

    // Burst computation
    if (cur_st_ff == DMA_ST_SM_RUN) begin
      // Send the request when:
      // - Request not sent yet (First request)
      // - Next one
      // - Not the last one
      if ((~dma_req_ff.valid || (dma_req_ff.valid && dma_axi_resp_i.ready)) && ~last_txn_ff) begin
        // Best case, send as much as possible through a single txn
        // respecting the 4KB boundary and burst type INCR/FIXED
        next_dma_req.addr = desc_addr_ff;    // TODO: 在这里可以进行地址对齐
        next_dma_req.size = axi_size_t'(6);  // TODO: 在这里可以配置size

        next_dma_req.alen = great_alen(desc_addr_ff, desc_bytes_ff);
        next_dma_req.strb = '1;              // TODO: 在这里可以配置strb

        txn_bytes = max_bytes_t'((next_dma_req.alen+8'd1)*bytes_p_burst);
        next_desc_bytes = desc_bytes_ff - desc_num_t'(txn_bytes);
        next_last_txn   = (next_desc_bytes == '0);
        next_desc_addr = desc_addr_ff + axi_addr_t'(txn_bytes);  // TODO: 在这里可以配置自增步长

        next_dma_req.valid = 1'b1;
      end
      else if (last_txn_ff && dma_axi_resp_i.ready) begin
        next_dma_req = s_dma_axi_req_t'('0);
        next_last_txn = 1'b0;
      end
      else begin
        if (dma_req_ff.valid && ~dma_axi_resp_i.ready) begin
          last_txn_proc = 'b1;
        end
        else begin
          next_dma_req = s_dma_axi_req_t'('0);
        end
      end
    end

    dma_stream_o.done = ((cur_st_ff == DMA_ST_SM_RUN) && (next_st == DMA_ST_SM_IDLE));
  end : burst_calc

  always_ff @ (posedge clk) begin
    if (rst) begin
      cur_st_ff     <= dma_sm_t'('0);
      desc_addr_ff  <= axi_addr_t'('0);
      desc_bytes_ff <= desc_num_t'('0);
      last_txn_ff   <= 1'b0;
      dma_req_ff    <= '0;
    end
    else begin
      cur_st_ff     <= next_st;
      desc_addr_ff  <= next_desc_addr;
      desc_bytes_ff <= next_desc_bytes;
      last_txn_ff   <= next_last_txn;
      dma_req_ff    <= next_dma_req;
    end
  end
endmodule
