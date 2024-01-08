module dma_fsm
  import axi_pkg::*;
  import dma_pkg::*;
(
  input                                     clk,
  input                                     rstn,

  // 启动控制 ｜ 事物描述 | 总体状态[error/done]
  input   logic                             dma_go_i,
  input   s_dma_desc_t                      dma_desc_i,
  output  s_dma_status_t                    dma_stats_o,
  output  s_dma_error_t                     dma_error_o,

  // From/To AXI I/F
  input                                     axi_pend_txn_i,
  input   s_dma_error_t                     axi_txn_err_i,
  output  logic                             clear_dma_o,
  output  logic                             dma_active_o,

  // To/From streamers
  output  logic                             dma_stream_rd_valid_o,
  input   logic                             dma_stream_rd_done_i,
  input   s_dma_error_t                     dma_stream_rd_err_i,
  output  logic                             dma_stream_wr_valid_o,
  input   logic                             dma_stream_wr_done_i,
  input   s_dma_error_t                     dma_stream_wr_err_i
);
  // _ff   : flip-flop 触发器「寄存器」
  // _rd_  : read
  // _wr_  : write
  // _txn_ : transaction
  // _mosi_: master out slave in
  // _desc_: descriptor
  // _hpn  : happen

  // [dma_st_t] DMA status: IDLE ｜ RUN ｜ DONE
  dma_st_t cur_st_ff, next_st;
  // done是streamer传过来的，用来指示当前解读control信号已经完成了，使用done_ff来存储streamer传来的done信号状态
  logic             rd_desc_done_ff, next_rd_desc_done;
  logic             wr_desc_done_ff, next_wr_desc_done;

  logic             pending_desc;  // 当有待处理的descriptor时该标识符会被置位
  logic             pending_rd_desc, pending_wr_desc;

  logic             dma_err_hpn;
  logic             err_lock_ff, next_err_lock;
  s_dma_error_t     dma_error_ff, next_dma_error;

  // DMA的状态机逻辑
  always_comb begin : dma_fsm
    next_st = DMA_ST_IDLE;
    pending_desc = pending_rd_desc || pending_wr_desc;

    case (cur_st_ff)
      DMA_ST_IDLE: begin
        if (dma_go_i) begin
          next_st = DMA_ST_RUN;
        end
      end
      DMA_ST_RUN: begin
        // 要么是streamer在工作，要么是axi interface在工作[读地址握手-写事物有效]
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

    dma_stats_o.done  = (cur_st_ff == DMA_ST_DONE);
    clear_dma_o       = (cur_st_ff == DMA_ST_DONE) && (next_st == DMA_ST_IDLE);
  end : dma_fsm

  // Read streamer
  always_comb begin : rd_streamer
    dma_stream_rd_valid_o = 1'b0;
    next_rd_desc_done     = rd_desc_done_ff;  // 默认保持上一拍的状态
    pending_rd_desc       = 1'b0;
    dma_active_o          = (cur_st_ff == DMA_ST_RUN);

    if (cur_st_ff == DMA_ST_RUN) begin
      // 如果传输的bytes不为 0 和 `rd_desc_done_ff` = 0
      if((|dma_desc_i.num_bytes) && (~rd_desc_done_ff)) begin
        dma_stream_rd_valid_o = 1'b1; // 告诉streamer Read操作valid
      end

      // streamer告诉fsm Read操作done
      if (dma_stream_rd_done_i) begin
        next_rd_desc_done = 1'b1; // 标记Read操作完成
      end

      // pending_rd_desc = dma_stream_rd_o.valid;
      pending_rd_desc = dma_stream_rd_valid_o;
    end

    // 如果DMA运行完了，则复位desc_done
    if (cur_st_ff == DMA_ST_DONE) begin
      next_rd_desc_done = '0;
    end
  end : rd_streamer

  always_comb begin : wr_streamer
    dma_stream_wr_valid_o  = 1'b0;
    next_wr_desc_done    = wr_desc_done_ff;
    pending_wr_desc      = 1'b0;

    if (cur_st_ff == DMA_ST_RUN) begin
      if((|dma_desc_i.num_bytes) && (~wr_desc_done_ff)) begin
        dma_stream_wr_valid_o = 1'b1;
      end

      if (dma_stream_wr_done_i) begin
        next_wr_desc_done = 1'b1;
      end

      pending_wr_desc = dma_stream_wr_valid_o;
    end

    if (cur_st_ff == DMA_ST_DONE) begin
      next_wr_desc_done = '0;
    end
  end : wr_streamer

  // DMA 状态的更新和错误信息的处理 addr | src[RD/WR] | valid
  always_comb begin : dma_err_handler
    next_err_lock   = err_lock_ff;
    next_dma_error  = dma_error_ff;
    dma_error_o     = dma_error_ff;
    dma_err_hpn     = axi_txn_err_i.valid || dma_stream_rd_err_i.valid || dma_stream_wr_err_i.valid;

    if (cur_st_ff != DMA_ST_RUN) begin
      next_err_lock = 1'b0;
    end else begin
      next_err_lock = dma_err_hpn;
    end

    if (~err_lock_ff) begin
      if (axi_txn_err_i.valid) begin
        next_dma_error.valid = 1'b1;
        next_dma_error.src   = axi_txn_err_i.src;
        next_dma_error.addr  = axi_txn_err_i.addr;
      end
      else if (dma_stream_rd_err_i.valid) begin
        next_dma_error.valid = 1'b1;
        next_dma_error.src   = dma_stream_rd_err_i.src;
        next_dma_error.addr  = dma_stream_rd_err_i.addr;
      end
      else if (dma_stream_wr_err_i) begin
        next_dma_error.valid = 1'b1;
        next_dma_error.src   = dma_stream_wr_err_i.src;
        next_dma_error.addr  = dma_stream_wr_err_i.addr;
      end
    end
    dma_stats_o.error = dma_err_hpn;
  end : dma_err_handler

  always_ff @ (posedge clk) begin
    if (~rstn) begin
      cur_st_ff       <= dma_st_t'('0);
      rd_desc_done_ff <= '0;
      wr_desc_done_ff <= '0;
      err_lock_ff     <= 1'b0;
      dma_error_ff    <= s_dma_error_t'('0);
    end
    else begin
      cur_st_ff       <= next_st;
      rd_desc_done_ff <= next_rd_desc_done;
      wr_desc_done_ff <= next_wr_desc_done;
      dma_error_ff    <= next_dma_error;
    end
  end
endmodule
