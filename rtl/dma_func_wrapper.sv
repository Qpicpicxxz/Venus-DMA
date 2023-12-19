module dma_func_wrapper
  import dma_pkg::*;
  import axi_pkg::*;
(
  input                                     clk,
  input                                     rst,
  // From/To CSRs
  input   logic                             dma_go_i,
  // `s_dma_dest_t`是DMA某一路的配置信息 src | dst | bytes | wr/rd_mode | enable
  input   s_dma_desc_t                      dma_desc_i,
  // `s_dma_error_t`是DMA的错误信息 addr | type_err (CFG/OPE) | src (RD/WR) | valid
  output  s_dma_error_t                     dma_error_o,
  output  s_dma_status_t                    dma_stats_o,
  // Master AXI I/F
  output  axi_req_t                         dma_axi_req_o,
  input   axi_resp_t                        dma_axi_resp_i
);

  // `s_dma_str_in_t`: valid ｜ idx
  // `s_dma_str_out_t`: done
  s_dma_str_in_t    dma_rd_stream_in;
  s_dma_str_out_t   dma_rd_stream_out;
  s_dma_str_in_t    dma_wr_stream_in;
  s_dma_str_out_t   dma_wr_stream_out;

  //「DMA Streamer - DMA AXI」
  // `s_dma_axi_req_t` : addr | alen | size | strb | mode | valid
  // `s_dma_axi_resp_t`: ready
  s_dma_axi_req_t   dma_axi_rd_req;
  s_dma_axi_resp_t  dma_axi_rd_resp;
  s_dma_axi_req_t   dma_axi_wr_req;
  s_dma_axi_resp_t  dma_axi_wr_resp;

  //「DMA FIFOs - DMA AXI」
  // `s_dma_fifo_req_t` : wr | rd | data_wr[511:0]
  // `s_dma_fifo_resp_t`: data_rd | ocup[fifo_width-1:0] | space[fifo_width-1:0] | full | empty
  s_dma_fifo_req_t  dma_fifo_req;
  s_dma_fifo_resp_t dma_fifo_resp;

  s_dma_error_t     axi_dma_err;

  logic             axi_pend_txn;
  logic             clear_dma;
  logic             dma_active;

  //
  dma_fsm u_dma_fsm(
    .clk              (clk),
    .rst              (rst),
    // From/To CSRs
    .dma_go_i         (dma_go_i),
    .dma_desc_i       (dma_desc_i),
    // From/To AXI I/F
    .axi_pend_txn_i   (axi_pend_txn),
    .axi_txn_err_i    (axi_dma_err),
    .dma_error_o      (dma_error_o),
    .clear_dma_o      (clear_dma),
    .dma_active_o     (dma_active),
    // To/From streamers
    .dma_stats_o      (dma_stats_o),
    .dma_stream_rd_o  (dma_rd_stream_in),
    .dma_stream_rd_i  (dma_rd_stream_out),
    .dma_stream_wr_o  (dma_wr_stream_in),
    .dma_stream_wr_i  (dma_wr_stream_out)
  );

  // Read
  dma_streamer #(
    .STREAM_TYPE(0)
  ) u_dma_rd_streamer (
    .clk              (clk),
    .rst              (rst),
    // From/To CSRs
    .dma_desc_i       (dma_desc_i),
    // From/To AXI I/F
    .dma_axi_req_o    (dma_axi_rd_req),
    .dma_axi_resp_i   (dma_axi_rd_resp),
    // To/From DMA FSM
    .dma_stream_i     (dma_rd_stream_in),
    .dma_stream_o     (dma_rd_stream_out)
  );

  // Write
  dma_streamer #(
    .STREAM_TYPE(1)
  ) u_dma_wr_streamer (
    .clk              (clk),
    .rst              (rst),
    // From/To CSRs
    .dma_desc_i       (dma_desc_i),
    // From/To AXI I/F
    .dma_axi_req_o    (dma_axi_wr_req),
    .dma_axi_resp_i   (dma_axi_wr_resp),
    // To/From DMA FSM
    .dma_stream_i     (dma_wr_stream_in),
    .dma_stream_o     (dma_wr_stream_out)
  );

  dma_fifo u_dma_fifo(
    .clk              (clk),
    .rst              (rst),
    .clear_i          (clear_dma),
    .write_i          (dma_fifo_req.wr),
    .read_i           (dma_fifo_req.rd),
    .data_i           (dma_fifo_req.data_wr),
    .data_o           (dma_fifo_resp.data_rd),
    .error_o          (),
    .full_o           (dma_fifo_resp.full),
    .empty_o          (dma_fifo_resp.empty),
    .ocup_o           (dma_fifo_resp.ocup),
    .free_o           (dma_fifo_resp.space)
  );

  dma_axi_if u_dma_axi_if (
    .clk              (clk),
    .rst              (rst),
    // From/To Streamers
    .dma_axi_rd_req_i (dma_axi_rd_req),
    .dma_axi_rd_resp_o(dma_axi_rd_resp),
    .dma_axi_wr_req_i (dma_axi_wr_req),
    .dma_axi_wr_resp_o(dma_axi_wr_resp),
    // Master AXI I/F
    .dma_axi_req_o        (dma_axi_req_o),
    .dma_axi_resp_i       (dma_axi_resp_i),
    // From/To FIFOs interface
    .dma_fifo_req_o   (dma_fifo_req),
    .dma_fifo_resp_i  (dma_fifo_resp),
    // From/To DMA FSM
    .axi_pend_txn_o   (axi_pend_txn),
    .axi_dma_err_o    (axi_dma_err),
    .clear_dma_i      (clear_dma),
    .dma_active_i     (dma_active)
  );
endmodule
