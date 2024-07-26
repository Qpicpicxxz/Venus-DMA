/* DMA to AXI Interface */
module dma_axi_if
  import venus_soc_pkg::*;
  import dma_pkg::*;
(
  input                     clk,
  input                     rstn,
  // From/To Streamers
  input   s_dma_stream_req_t   dma_stream_rd_req_i,
  output  s_dma_stream_resp_t  dma_stream_rd_resp_o,
  input   s_dma_stream_req_t   dma_stream_wr_req_i,
  output  s_dma_stream_resp_t  dma_stream_wr_resp_o,
  // Master AXI I/F
  output  axi_req_t            axi_req_o,
  input   axi_resp_t           axi_resp_i,
  // From/To Shift Aligner
  output  s_dma_axi_req_t     dma_axi_req_o,
  input   s_dma_axi_resp_t    dma_axi_resp_i,
  // From/To DMA FSM
  output  logic               axi_pend_txn_o,
  output  s_dma_error_t       axi_dma_err_o,
  input                       dma_active_i
);
  /*
   * [arvalid] - master要读的地址有效
   * [arready] - slave准备好接收master要读的地址
   * [rvalid]  - slave要被读的地址数据有效
   * [r.rlast] - slave发出的表示最后一拍读数据的操作
   * [rready]  - master准备好接收slave发来的读的数据
   * [awvalid] - master要写的地址有效
   * [awready] - slave准备好接收master要写的地址
   * [wvalid]  - master要写的数据有效
   * [w.wlast] - master发出的表示最后一拍写数据的操作
   * [wready]  - slave准备好接收master写过来的数据
   * [bvalid]  - 写入slave的数据有效
   * [bready]  - 要写入slave的master数据已经准备好
   */

  /* 统计 + 寄存 Read or Write streamer传来的事物个数与请求 */
  logic [3:0]   rd_counter_ff, next_rd_counter;
  logic [3:0]   wr_counter_ff, next_wr_counter;
  axi_addr_t    next_rd_addr,  rd_addr_ff;
  axi_addr_t    next_wr_addr,  wr_addr_ff; // 存下来为了定位错误
  axi_len_t     next_awlen,    awlen_ff;
  /* 握手交互信号 */
  logic         rd_txn_hpn;  // Read地址握手成功[开始读]  | arvalid && arready
  logic         rd_resp_hpn; // Read事物响应成功[读完了]  | rvalid && r.rlast && rready
  logic         wr_txn_hpn;  // Write事物握手成功[开始写] | awvalid && awready
  logic         wr_resp_hpn; // Write事物响应成功[写成功] | bvalid && bready
  /* 错误发生相关 */
  logic         rd_err_hpn;
  logic         wr_err_hpn;
  logic         err_lock_ff,  next_err_lock;
  s_dma_error_t dma_error_ff, next_dma_error;
  /* 记录写打拍，决定什么时候拉高w.wlast */
  logic         rd_beat_hpn;
  logic         wr_beat_hpn;
  logic         wr_beat_finish;
  //logic         wr_beat_finish;
  axi_len_t     beat_counter_ff, next_beat_count;
  /* 寄存写事物传输状态[如果slave的awready消失了] */
  logic         aw_txn_started_ff, next_aw_txn;
  /* fifo是同步取数的 */
  logic         fifo_r_hpn_ff, next_fifo_r_hpn;
  logic         fifo_r_end;
  /* 暂存fifo中read出来的数据 */
  axi_data_t last_fifo_data_rd, fifo_data_rd;
  axi_data_t last_fifo_data_strb, fifo_data_strb;
  logic      axi_w_valid;

  always_comb begin: err_handler
    next_err_lock   = err_lock_ff;
    next_dma_error  = dma_error_ff;
    // 把错误信号输出给FSM，FSM传出去
    axi_dma_err_o   = dma_error_ff;

    // DMA没有RUN的时候不处理error
    if (~dma_active_i) begin
      next_err_lock = 1'b0;
    end
    else begin
      // 如果有错误发生，那么需要把错误锁住，以免多个错误导致error_o跳变
      next_err_lock = rd_err_hpn || wr_err_hpn;
    end

    // 记录错误原因
    if (~err_lock_ff) begin
      if (rd_err_hpn) begin
        next_dma_error.valid    = 1'b1;
        next_dma_error.src      = DMA_AXI_RD_ERR;
        next_dma_error.addr     = rd_addr_ff;
      end
      else if (wr_err_hpn) begin
        next_dma_error.valid    = 1'b1;
        next_dma_error.src      = DMA_AXI_WR_ERR;
        next_dma_error.addr     = wr_addr_ff;
      end
    end
  end : err_handler

  always_comb begin
    // 告诉 FSM DMA正在运行
    axi_pend_txn_o  = (|rd_counter_ff) || (|wr_counter_ff);
    next_rd_counter = rd_counter_ff;
    next_wr_counter = wr_counter_ff;  // 是不是没用了??
    next_rd_addr   = rd_addr_ff;
    next_wr_addr   = wr_addr_ff;
    next_awlen      = awlen_ff;
    // next_rd_txn_req = rd_txn_req_ff;
    // next_wr_txn_req = wr_txn_req_ff;
    next_beat_count = beat_counter_ff;

    // 握手 / 响应
    rd_txn_hpn      = axi_req_o.arvalid && axi_resp_i.arready;
    rd_beat_hpn     = axi_resp_i.rvalid && axi_req_o.rready;
    rd_resp_hpn     = axi_resp_i.rvalid && axi_resp_i.r.rlast  && axi_req_o.rready;
    wr_txn_hpn      = axi_req_o.awvalid && axi_resp_i.awready;
    wr_beat_hpn     = axi_req_o.wvalid  && axi_resp_i.wready;
    wr_beat_finish  = axi_req_o.wvalid  && axi_req_o.w.wlast   && axi_resp_i.wready;
    wr_resp_hpn     = axi_resp_i.bvalid && axi_req_o.bready;

    if (dma_active_i) begin
      if (rd_txn_hpn || rd_resp_hpn) begin
        next_rd_counter = rd_counter_ff + (rd_txn_hpn ? 'd1 : 'd0) - (rd_resp_hpn ? 'd1 : 'd0);
      end

      if (wr_txn_hpn || wr_resp_hpn) begin
        next_wr_counter = wr_counter_ff + (wr_txn_hpn ? 'd1 : 'd0) - (wr_resp_hpn ? 'd1 : 'd0);
      end
    end else begin
      next_rd_counter = 'd0;
      next_wr_counter = 'd0;
    end

    // 一旦read握手成功，将stream传过来的读信息寄存下来，将输出给FSM的pend拉高
    if(rd_txn_hpn) begin
      next_rd_addr = dma_stream_rd_req_i.addr;
    end

    // 一旦write握手成功，将stream传过来的写信息寄存下来
    if(wr_txn_hpn) begin
      next_wr_addr = dma_stream_wr_req_i.addr;
      next_awlen    = dma_stream_wr_req_i.alen;
    end

    // 写打拍
    if (wr_beat_hpn) begin
      next_beat_count = beat_counter_ff + 'd1;
    end

    // 写打拍复位
    if (wr_beat_finish) begin
      next_beat_count = 0;
    end

  end

  always_comb begin: realignment_buffer

  end: realignment_buffer

  always_comb begin : axi4_master
    // 负责捕捉错误信号
    rd_err_hpn           = 1'b0;
    wr_err_hpn           = 1'b0;
    fifo_r_end           = 1'b0;
    next_fifo_r_hpn      = 1'b0;
    axi_req_o            = axi_req_t'('0);         // 给AXI总线的信号
    dma_axi_req_o        = '0;
    dma_stream_rd_resp_o = s_dma_stream_resp_t'('0);  // ready信号是去告诉valid源可以拉低了[已经握手成功]
    dma_stream_wr_resp_o = s_dma_stream_resp_t'('0);  // ready
    next_aw_txn          = aw_txn_started_ff;
    fifo_data_rd         = (fifo_r_hpn_ff) ? dma_axi_resp_i.data_rd : last_fifo_data_rd;  // 没有读需要保持输出信号(fifo ip不一定能保证)
    fifo_data_strb       = (fifo_r_hpn_ff) ? dma_axi_resp_i.strb : last_fifo_data_strb;

    // FSM中RUN的时候，dma_active_i就会被拉高
    if (dma_active_i) begin
      /* 读slave操作 */
      axi_req_o.ar.arprot = 3'b010;        // Unprivileged | Non-Secure | Data
      axi_req_o.ar.arid   = axi_id_t'(0);  // DMA保持id始终为零即可
      // [给slave读地址 arvalid] - Streamder传过来的valid
      axi_req_o.arvalid = dma_stream_rd_req_i.valid;
      if (axi_req_o.arvalid) begin
        dma_stream_rd_resp_o.ready = axi_resp_i.arready;
        axi_req_o.ar.araddr        = dma_stream_rd_req_i.addr;
        axi_req_o.ar.arlen         = dma_stream_rd_req_i.alen;
        axi_req_o.ar.arsize        = dma_stream_rd_req_i.size;
        axi_req_o.ar.arburst       = 2'b01;  // INCR传输
      end
      // [给slave读数据 rready] - 如果FIFO没有满，那就准备好读数据
      axi_req_o.rready = (~dma_axi_resp_i.full);
      // 等待slave的valid...
      if (axi_resp_i.rvalid && (~dma_axi_resp_i.full)) begin
        dma_axi_req_o.wr      = 1'b1;
        dma_axi_req_o.data_wr = axi_resp_i.r.rdata;
        dma_axi_req_o.rvalid  = 1'b1;
        dma_axi_req_o.rlast   = axi_resp_i.r.rlast;
        if (axi_resp_i.r.rlast && axi_req_o.rready) begin
          // 10 - SLVERR「Slave错误」 | 10 - DECERR「总线解码错误」
          rd_err_hpn = (axi_resp_i.r.rresp == 2'b10) || (axi_resp_i.r.rresp == 2'b11);
        end
      end


      /* 写slave操作 */
      axi_req_o.aw.awprot = 3'b010;
      axi_req_o.aw.awid   = axi_id_t'(0);
      // [给slave写地址 awvalid] - Streamer传过来的valid 或 写操作已经开始但是awready消失
      axi_req_o.awvalid = ((dma_stream_wr_req_i.valid && (~dma_axi_resp_i.empty)) || aw_txn_started_ff);
      if (axi_req_o.awvalid) begin
        dma_stream_wr_resp_o.ready  = axi_resp_i.awready;
        axi_req_o.aw.awaddr         = dma_stream_wr_req_i.addr;
        axi_req_o.aw.awlen          = dma_stream_wr_req_i.alen;
        axi_req_o.aw.awsize         = dma_stream_wr_req_i.size;
        axi_req_o.aw.awburst        = 2'b01;  // INCR传输
        next_aw_txn                 = ~axi_resp_i.awready; // 让valid保持住
      end
      if (axi_w_valid) begin
        fifo_r_end                  = (beat_counter_ff == awlen_ff);
        axi_req_o.w.wdata           = fifo_data_rd;
        axi_req_o.w.wstrb           = dma_axi_resp_i.strb;
        axi_req_o.w.wlast           = fifo_r_end;
        axi_req_o.wvalid            = 1'b1;
        dma_stream_wr_resp_o.finish = fifo_r_end;
        dma_axi_req_o.beat_counter  = beat_counter_ff;
      end
      // [给slave写数据 w] - 如果FIFO没有空&slave的写ready信号存在，那么就一直读fifo里面的东西然后输出写给slave
      if(~dma_axi_resp_i.empty) begin
        dma_axi_req_o.rd     = axi_resp_i.wready && (~fifo_r_end);
        next_fifo_r_hpn      = axi_resp_i.wready && (~fifo_r_end);
      end
      axi_req_o.bready = 1'b1;
      if (axi_resp_i.bvalid) begin
        // 10 - SLVERR「Slave错误」 | 10 - DECERR「总线解码错误」
        wr_err_hpn  = (axi_resp_i.b.bresp == 2'b10) || (axi_resp_i.b.bresp == 2'b11);
      end
      if (rd_resp_hpn) begin
        dma_stream_rd_resp_o.finish = 1'b1;
      end
    end
  end : axi4_master

  always_ff @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      rd_counter_ff       <= '0;
      wr_counter_ff       <= '0;
      rd_addr_ff          <= '0;
      wr_addr_ff          <= '0;
      awlen_ff            <= '0;
      err_lock_ff         <= '0;
      dma_error_ff        <= '0;
      beat_counter_ff     <= '0;
      aw_txn_started_ff   <= '0;
      fifo_r_hpn_ff       <= '0;
      last_fifo_data_rd   <= '0;
      last_fifo_data_strb <= '0;
      axi_w_valid         <= '0;
    end
    else begin
      rd_counter_ff     <= next_rd_counter;
      wr_counter_ff     <= next_wr_counter;
      rd_addr_ff        <= next_rd_addr;
      wr_addr_ff        <= next_wr_addr;
      awlen_ff          <= next_awlen;
      err_lock_ff       <= next_err_lock;
      dma_error_ff      <= next_dma_error;
      beat_counter_ff   <= next_beat_count;
      aw_txn_started_ff <= next_aw_txn;
      fifo_r_hpn_ff     <= next_fifo_r_hpn;
      if (axi_resp_i.wready) begin
        axi_w_valid     <= next_fifo_r_hpn;
      end
      if (fifo_r_hpn_ff) begin
        last_fifo_data_rd  <= dma_axi_resp_i.data_rd;
        last_fifo_data_strb <= dma_axi_resp_i.strb;
      end
    end
  end

endmodule
