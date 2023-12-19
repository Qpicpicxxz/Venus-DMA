module dma_fsm
  import axi_pkg::*;
  import dma_pkg::*;
(
  input                                     clk,
  input                                     rst,
  // From/To CSRs
  input   logic                             dma_go_i,
  input   s_dma_desc_t                      dma_desc_i,
  output  s_dma_status_t                    dma_stats_o,
  // From/To AXI I/F
  input                                     axi_pend_txn_i,
  input   s_dma_error_t                     axi_txn_err_i,
  output  s_dma_error_t                     dma_error_o,
  output  logic                             clear_dma_o,
  output  logic                             dma_active_o,
  // To/From streamers
  output  s_dma_str_in_t                    dma_stream_rd_o,
  input   s_dma_str_out_t                   dma_stream_rd_i,
  output  s_dma_str_in_t                    dma_stream_wr_o,
  input   s_dma_str_out_t                   dma_stream_wr_i
);
  // [dma_st_t] DMA status: IDLE ｜ CFG ｜ RUN ｜ DONE
  // _ff: flip-flop 触发器
  // _rd_: read
  // _txn_: transaction
  // _mosi_: master out slave in
  dma_st_t cur_st_ff, next_st;
  logic rd_desc_done_ff, next_rd_desc_done;
  logic wr_desc_done_ff, next_wr_desc_done;

  logic pending_desc; // Gets set when there are pending descriptors to process
  logic pending_rd_desc, pending_wr_desc;

  // DMA的状态机逻辑
  always_comb begin : fsm_dma_ctrl
    next_st = DMA_ST_IDLE;
    pending_desc = pending_rd_desc || pending_wr_desc;

    case (cur_st_ff)
      DMA_ST_IDLE: begin
        if (dma_go_i) begin
          next_st = DMA_ST_RUN;
        end
      end
      DMA_ST_RUN: begin
        if (pending_desc || axi_pend_txn_i) begin
          next_st = DMA_ST_RUN;
        end
        else begin
          next_st = DMA_ST_DONE;
        end
      end
      DMA_ST_DONE: begin
        if(dma_go_i) begin
          next_st = DMA_ST_DONE;
        end
      end
    endcase
  end : fsm_dma_ctrl

  // rd 和 wr 是 DMA Streamer的读写逻辑
  always_comb begin : rd_streamer
    // interface between DMA FSM and DMA Streamer
    dma_stream_rd_o   = s_dma_str_in_t'('0);  // 使用该类型的默认值进行初始化
    next_rd_desc_done = rd_desc_done_ff;
    pending_rd_desc   = 1'b0;
    dma_active_o      = (cur_st_ff == DMA_ST_RUN);

    if (cur_st_ff == DMA_ST_RUN) begin
      if((|dma_desc_i.num_bytes) && (~rd_desc_done_ff)) begin
        dma_stream_rd_o.idx = 0;
        dma_stream_rd_o.valid = 1'b1;
      end

      if (dma_stream_rd_i.done) begin
        next_rd_desc_done = 1'b1;
      end

      pending_rd_desc = dma_stream_rd_o.valid;
    end

    if (cur_st_ff == DMA_ST_DONE) begin
      next_rd_desc_done = '0;
    end
  end : rd_streamer

  always_comb begin : wr_streamer
    dma_stream_wr_o   = s_dma_str_in_t'('0);
    next_wr_desc_done = wr_desc_done_ff;
    pending_wr_desc   = 1'b0;

    if (cur_st_ff == DMA_ST_RUN) begin
      if((|dma_desc_i.num_bytes) && (~wr_desc_done_ff)) begin
        dma_stream_wr_o.idx = 0;
        dma_stream_wr_o.valid = 1'b1;
      end

      if (dma_stream_wr_i.done) begin
        next_wr_desc_done = 1'b1;
      end

      pending_wr_desc = dma_stream_wr_o.valid;
    end

    if (cur_st_ff == DMA_ST_DONE) begin
      next_wr_desc_done = '0;
    end
  end : wr_streamer

  // DMA 状态的更新和错误信息的处理
  always_comb begin : dma_status
    dma_error_o = s_dma_error_t'('0);

    if (axi_txn_err_i.valid) begin
      dma_error_o.addr     = axi_txn_err_i.addr;
      dma_error_o.type_err = DMA_ERR_OPE;
      dma_error_o.src      = axi_txn_err_i.src;
      dma_error_o.valid    = 1'b1;
    end
    dma_stats_o.error = axi_txn_err_i.valid;
    dma_stats_o.done  = (cur_st_ff == DMA_ST_DONE);
    clear_dma_o       = (cur_st_ff == DMA_ST_DONE) && (next_st == DMA_ST_IDLE);
  end : dma_status

  always_ff @ (posedge clk) begin
    if (rst) begin
      cur_st_ff       <= dma_st_t'('0);
      rd_desc_done_ff <= '0;
      wr_desc_done_ff <= '0;
    end
    else begin
      cur_st_ff       <= next_st;
      rd_desc_done_ff <= next_rd_desc_done;
      wr_desc_done_ff <= next_wr_desc_done;
    end
  end
endmodule
