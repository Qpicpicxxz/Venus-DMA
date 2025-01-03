// Streamder：DMA操作中数据流控制，处理数据的读写操作
module dma_streamer
  import venus_soc_pkg::*;
  import dma_pkg::*;
#(
  parameter bit STREAM_TYPE = 0 // 0 - Read, 1 - Write
) (
  input                                     clk,
  input                                     rstn,
  // From/To CSRs
  input   s_dma_desc_t                      dma_desc_i,
  // From/To AXI I/F
  output  s_dma_axi_req_t                   dma_axi_req_o,
  input   s_dma_axi_resp_t                  dma_axi_resp_i,
  // To/From DMA FSM
  input   logic                             dma_stream_valid_i,
  output  logic                             dma_stream_done_o,
  output  s_dma_error_t                     dma_stream_err_o
);
  // bytes_p_burst = 512bit / 8 = 64byte 一次突发传输64byte的数据
  localparam        bytes_p_burst = (`DMA_DATA_WIDTH/8);

  // 每次突发事物最多可能传输16384bytes的数据，计算`txn_bytes`需要的位宽
  // 256 * (512 / 8) = 16384 = 128^2
  localparam        max_txn_width = $clog2(`DMA_MAX_BEAT_BURST*(`DMA_DATA_WIDTH/8));
  typedef           logic [max_txn_width:0] max_bytes_t;
  max_bytes_t       txn_bytes;

  dma_sm_t          cur_st_ff,      next_st;          // DMA_ST_SM_IDLE ｜ DMA_ST_SM_RUN
  axi_addr_t        desc_addr_ff,   next_desc_addr;   // [511:0]
  desc_num_t        desc_bytes_ff,  next_desc_bytes;  // [31:0]

  s_dma_axi_req_t   dma_req_ff, next_dma_req;  // Stream - AXI IF | addr | alen | size | strb | valid

  logic             last_txn_ff, next_last_txn;
  logic             last_txn_proc;

  logic             addr_unaligned_err, addr_cross_bound_err;
  logic             err_lock_ff, next_err_lock;
  s_dma_error_t     dma_error_ff, next_dma_error;

  // 检查源地址与目的地址是否4kB越界 ｜ [0 - 越界] [1 - 未越界]
  function automatic logic burst_r4KB(axi_addr_t base, axi_addr_t fut);
    if (fut[31:12] < base[31:12]) begin
      return 0;
    end
    else begin
      if (fut[31:12] > base[31:12]) begin
        return (fut[11:0] == '0);
      end
      else begin
        return 1;
      end
    end
  endfunction

  // 检查源地址与目的地址是否64byte越界 ｜ [0 - 越界] [1 - 未越界]
  // 看后6位是否相等，相等则未越界，不相等时x000_0000 ~ x100_0000这种形式的也没有越界，且须保证x0<x1
  function automatic logic cross_64byte_bound(axi_addr_t base, axi_addr_t fut);
    // furture地址比base地址小 - 越界
    if (fut[31:6] < base[31:6]) begin
      return 0;
    end
    else begin
      if ((fut[31:6] > base[31:6])) begin
        return (fut[5:0] == '0);
      end
      else begin
        return 1;
      end
    end
  endfunction

  // `addr`: 起始地址  ｜  `bytes`: 要传输的字节数[需确保64byte对齐] | `alen`: 在保证不4kB越界的情况下，最大可能的传输次数
  function automatic axi_len_t great_alen(axi_addr_t addr, desc_num_t bytes);
    axi_addr_t fut_addr;   // 存储next(future)地址
    axi_len_t  alen = 0;   // 单个数据包突发(single beat-burst)「存储最终算出来的burst长度」
    desc_num_t txn_sz;     // 当前burst的次数可以用来传输的bytes量
    for (int i=`DMA_MAX_BEAT_BURST; i>0; i--) begin
      fut_addr = addr+(i*bytes_p_burst); // 当前burst传输完之后的新burst地址
      txn_sz   = (i*bytes_p_burst);      // 256 × 64byte = 16384bytes
      // 找到一个符合小于等于传输数据比特的最大
      if (bytes >= txn_sz) begin
        if (burst_r4KB(addr, fut_addr)) begin
          // 将`i-1`的结果转换为类型`axi_len_t`并赋值给变量`alen`
          alen = axi_len_t'(i-1);
          return alen;
        end
      end
    end
  endfunction

  function automatic desc_num_t celi_align64_bytes(desc_num_t bytes);
    logic [5:0] remainder;  // 能装下64的位宽
    desc_num_t aligned_bytes;
    remainder = bytes % 64;
    if (remainder != 0) begin
      aligned_bytes = bytes + (64 - remainder);
    end else begin
      aligned_bytes = bytes;
    end
    return aligned_bytes;
  endfunction

  function automatic desc_num_t floor_align64_addr(axi_addr_t addr);
    logic [5:0] remainder;  // 能装下64的位宽
    axi_addr_t aligned_addr;
    remainder = addr % 64;
    if (remainder != 0) begin
      aligned_addr = addr - remainder;
    end else begin
      aligned_addr = addr;
    end
    return aligned_addr;
  endfunction

  function automatic logic is_addr_aligned(axi_addr_t addr);
      return (addr[5:0] == '0);
  endfunction

  function automatic logic enough_for_burst(desc_num_t bytes);
      return (bytes >= 'd64);
  endfunction

  function automatic axi_strb_t get_strb(axi_addr_t base, desc_num_t bytes);
    axi_strb_t strobe;
    strobe = (1 << bytes) - 1;
    return (strobe << (base % 64));
  endfunction

  always_comb begin: err_handler
    next_err_lock        = err_lock_ff;
    next_dma_error       = dma_error_ff;
    // 把错误信号输出给FSM，FSM传出去
    dma_stream_err_o     = dma_error_ff;

    // Streamer没有valid的时候不处理error
    if (~dma_stream_valid_i) begin
      next_err_lock = 1'b0;
    end
    else begin
      next_err_lock = addr_unaligned_err || addr_cross_bound_err;
    end

    if (~err_lock_ff) begin
      if (addr_unaligned_err) begin
        next_dma_error.valid    = 1'b1;
        next_dma_error.src      = DMA_UNALIGNED_ERR;
        next_dma_error.addr     = desc_addr_ff;
      end
      else if (addr_cross_bound_err) begin
        next_dma_error.valid    = 1'b1;
        next_dma_error.src      = DMA_NARROW_CROSS_ERR;
        next_dma_error.addr     = desc_addr_ff;
      end
    end
  end: err_handler

  always_comb begin : streamer_status
    next_st = DMA_ST_SM_IDLE;
    case (cur_st_ff)
      DMA_ST_SM_IDLE: begin
        if(dma_stream_valid_i) begin
          next_st = DMA_ST_SM_RUN;
        end
      end
      DMA_ST_SM_RUN: begin
        if (desc_bytes_ff > 0) begin
          next_st = DMA_ST_SM_RUN;
        end
        // 是最后一个事物但是slave还没有ready
        else if (last_txn_ff && ~dma_axi_resp_i.ready) begin
          next_st = DMA_ST_SM_RUN;
        end
      end
    endcase
  end : streamer_status

  // Streamer负责计算突发次数等
  always_comb begin : burst_calc
    // 负责捕捉错误信号
    addr_unaligned_err   = 1'b0;
    addr_cross_bound_err = 1'b0;
    dma_stream_done_o    = 1'b0;
    next_dma_req         = dma_req_ff;
    next_desc_addr       = desc_addr_ff;
    next_desc_bytes      = desc_bytes_ff;  // 默认下一拍保持不变
    dma_axi_req_o        = dma_req_ff;
    next_last_txn        = last_txn_ff;
    last_txn_proc        = 1'b0;

    // FSM valid进来的那一拍 / dma_go_i的下一拍
    if ((cur_st_ff == DMA_ST_SM_IDLE) && (next_st == DMA_ST_SM_RUN)) begin
      // 如果传输长度 < 64bytes, 则保留原值 ｜ 如果传输长度 >= 64bytes, 则传输长度64byte向上对齐
      next_desc_bytes = enough_for_burst(dma_desc_i.num_bytes) ? celi_align64_bytes(dma_desc_i.num_bytes) : dma_desc_i.num_bytes;

      // 读模块 or 写模块
      if (STREAM_TYPE) begin
        next_desc_addr = dma_desc_i.dst_addr;
      end
      else begin
        next_desc_addr = dma_desc_i.src_addr;
      end
    end

    txn_bytes = max_bytes_t'('0);  // 初始化每次INCR传输最多可以传输的比特数：256 * 64

    // 对给AXI IF 的突发信息进行计算
    if (cur_st_ff == DMA_ST_SM_RUN) begin
      // 请求未发出(first request) - [~dma_req_ff.valid] 或 请求已发出且收到ready[是slave的arready] 且 不是最后一个request - [~last_txn_ff]
      if ((~dma_req_ff.valid || (dma_req_ff.valid && dma_axi_resp_i.ready)) && ~last_txn_ff) begin
        // 3种情况：1. 地址对齐+传输长度>=64bytes | 2. 地址未对齐+传输长度>=64bytes ｜ 3. 传输长度<64bytes

        // 1. 常规情况：地址对齐 + 传输长度 >= 64bytes
        if(is_addr_aligned(desc_addr_ff) && enough_for_burst(desc_bytes_ff)) begin
          // 在一次事物中传输尽可能多的数据
          next_dma_req.addr = desc_addr_ff;    // TODO: 在这里可以进行地址对齐
          next_dma_req.size = axi_size_t'(6);  // TODO: 在这里可以配置size/数据位宽

          next_dma_req.alen = great_alen(desc_addr_ff, desc_bytes_ff);
          next_dma_req.strb = '1;              // TODO: 在这里可以配置strb

          txn_bytes         = max_bytes_t'((next_dma_req.alen+8'd1)*bytes_p_burst);  // 计算本次burst传输的实际比特数
          next_desc_bytes   = desc_bytes_ff - desc_num_t'(txn_bytes);
          next_last_txn     = (next_desc_bytes == '0);
          next_desc_addr    = desc_addr_ff + axi_addr_t'(txn_bytes);  // TODO: 在这里可以配置自增步长

          next_dma_req.valid = 1'b1;
        end
        // 2. 异常情况：地址未对齐 + 传输长度 >= 64bytes
        else if(enough_for_burst(desc_bytes_ff)) begin
          addr_unaligned_err = 1'b1;
        end
        // 3. narrow transfer情况：传输长度 <= 64bytes
        else begin
          // 3.1. 判断是否会跨越64byte边界 | 0 - 越界 ｜ 1 - 未越界
          if(~cross_64byte_bound(desc_addr_ff, desc_addr_ff+desc_bytes_ff)) begin
            addr_cross_bound_err = 1'b1;
          end
          else begin
            next_dma_req.addr = floor_align64_addr(desc_addr_ff);
            next_dma_req.size = axi_size_t'(6);
            next_dma_req.alen = '0;
            next_dma_req.strb = get_strb(desc_addr_ff, desc_bytes_ff);
            next_desc_bytes   = '0;
            next_last_txn = 1'b1;
            next_dma_req.valid = 1'b1;
          end
        end
      end
      // 如果此时已经是最后一次数据突发请求，置位给AXI IF对
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

    dma_stream_done_o = ((cur_st_ff == DMA_ST_SM_RUN) && (next_st == DMA_ST_SM_IDLE));
  end : burst_calc

  always_ff @ (posedge clk) begin
    if (~rstn) begin
      cur_st_ff     <= dma_sm_t'('0);
      desc_addr_ff  <= axi_addr_t'('0);
      desc_bytes_ff <= desc_num_t'('0);
      last_txn_ff   <= 1'b0;
      dma_req_ff    <= s_dma_axi_req_t'(0);
      err_lock_ff   <= 1'b0;
      dma_error_ff  <= s_dma_error_t'('0);
    end
    else begin
      cur_st_ff     <= next_st;
      desc_addr_ff  <= next_desc_addr;
      desc_bytes_ff <= next_desc_bytes;
      last_txn_ff   <= next_last_txn;
      dma_req_ff    <= next_dma_req;
      err_lock_ff   <= next_err_lock;
      dma_error_ff  <= next_dma_error;
    end
  end
endmodule
