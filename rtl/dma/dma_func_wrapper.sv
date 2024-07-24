module dma_func_wrapper
  import dma_pkg::*;
  import venus_soc_pkg::*;
(
  input                                     clk,
  input                                     rstn,
  // From/To CSRs
  input   logic                             dma_go_i,
  // `s_dma_dest_t`是DMA某一路的配置信息 src | dst | bytes
  input   s_dma_desc_t                      dma_desc_i,
  // `s_dma_error_t`是DMA的错误信息 addr | src (RD/WR) | valid
  output  s_dma_error_t                     dma_error_o,
  output  s_dma_status_t                    dma_stats_o,
  // Master AXI I/F
  output  axi_req_t                         axi_req_o,
  input   axi_resp_t                        axi_resp_i
);

  // 「Streamer - FSM」
  logic dma_stream_rd_valid_o;
  logic dma_stream_rd_done_i;
  logic dma_stream_wr_valid_o;
  logic dma_stream_wr_done_i;

  //「Streamer - AXI IF」
  // `s_dma_axi_req_t` : addr | alen | size | strb | mode | valid
  // `s_dma_axi_resp_t`: ready
  s_dma_axi_req_t   dma_axi_rd_req;
  s_dma_axi_resp_t  dma_axi_rd_resp;
  s_dma_axi_req_t   dma_axi_wr_req;
  s_dma_axi_resp_t  dma_axi_wr_resp;

  //「FIFO - AXI IF」
  // `s_dma_fifo_req_t` : wr | rd | data_wr[511:0]
  // `s_dma_fifo_resp_t`: data_rd | ocup[fifo_width-1:0] | space[fifo_width-1:0] | full | empty
  // s_dma_fifo_req_t  dma_fifo_req;
  // s_dma_fifo_resp_t dma_fifo_resp;
  // [Streamer - FIFO - AXI IF]
  s_dma_aligner_req_t streamer_src_info;
  s_dma_aligner_req_t streamer_dst_info;
  s_dma_shifter_req_t trans_req_info;
  s_dma_fifo_req_t    axi_if_req;
  s_dma_fifo_resp_t   axi_if_resp;

  s_dma_error_t     axi_dma_err;
  s_dma_error_t     dma_stream_rd_err;
  s_dma_error_t     dma_stream_wr_err;

  logic             axi_pend_txn;
  logic             clear_dma;   // DMA从 DONE 下一拍即将转为 IDLE 的时候拉高此信号 -> 用于清空所有的fifo
  logic             dma_active;

  dma_fsm u_dma_fsm(
    .clk                    (clk),
    .rstn                   (rstn),

    // 启动控制 ｜ 事物描述 | 总体状态[error/done]
    .dma_go_i               (dma_go_i),
    .dma_desc_i             (dma_desc_i),
    .dma_stats_o            (dma_stats_o),
    .dma_error_o            (dma_error_o),

    // From/To AXI I/F
    .axi_pend_txn_i         (axi_pend_txn),
    .axi_txn_err_i          (axi_dma_err),
    .clear_dma_o            (clear_dma),
    .dma_active_o           (dma_active),
    // Streamer的接口 ｜ [valid/done]
    .dma_stream_rd_valid_o  (dma_stream_rd_valid_o),
    .dma_stream_rd_done_i   (dma_stream_rd_done_i),
    .dma_stream_rd_err_i    (dma_stream_rd_err),
    .dma_stream_wr_valid_o  (dma_stream_wr_valid_o),
    .dma_stream_wr_done_i   (dma_stream_wr_done_i),
    .dma_stream_wr_err_i    (dma_stream_wr_err)
  );

  // Read
  dma_streamer #(
    .STREAM_TYPE(0)
  ) u_dma_rd_streamer (
    .clk                    (clk),
    .rstn                   (rstn),
    .dma_go_i               (dma_go_i),
    .dma_desc_i             (dma_desc_i),
    // From/To AXI I/F
    .dma_axi_req_o          (dma_axi_rd_req),
    .dma_axi_resp_i         (dma_axi_rd_resp),
    // From/To Shift Aligner
    .dma_aligner_req_o      (streamer_src_info),
    // To/From DMA FSM
    .dma_stream_valid_i     (dma_stream_rd_valid_o),
    .dma_stream_done_o      (dma_stream_rd_done_i),
    .dma_stream_err_o       (dma_stream_rd_err)
  );

  // Write
  dma_streamer #(
    .STREAM_TYPE(1)
  ) u_dma_wr_streamer (
    .clk                    (clk),
    .rstn                   (rstn),
    .dma_go_i               (dma_go_i),
    .dma_desc_i             (dma_desc_i),
    // From/To AXI I/F
    .dma_axi_req_o          (dma_axi_wr_req),
    .dma_axi_resp_i         (dma_axi_wr_resp),
    // From/To Shift Aligner
    .dma_aligner_req_o      (streamer_dst_info),
    // To/From DMA FSM
    .dma_stream_valid_i     (dma_stream_wr_valid_o),
    .dma_stream_done_o      (dma_stream_wr_done_i),
    .dma_stream_err_o       (dma_stream_wr_err)
  );

  dma_shift_aligner # (
    .OUTPUT_DELAY(1),
    .DATA_WIDTH(`DMA_DATA_WIDTH),
    .FIFO_DEPTH(16)
  ) u_dma_shift_aligner (
    .clk (clk),
    .rstn (rstn),
    .clear_i (clear_dma),
    .dma_go_i               (dma_go_i),
    .dma_desc_i             (dma_desc_i),
    .src_info_i (streamer_src_info),
    .dst_info_i (streamer_dst_info),
    .axi_if_req_i (axi_if_req),
    .axi_if_resp_o (axi_if_resp)
  );

  // fifo_model #(
  //   .OUTPUT_DELAY(1),
  //   .SLOTS(`DMA_FIFO_DEPTH),
  //   .WIDTH(`DMA_DATA_WIDTH),
  //   .useSMICModel(1)
  // ) u_dma_fifo(
  //   .clk              (clk),
  //   .rstn             (rstn),
  //   .clear_i          (clear_dma),
  //   .write_i          (dma_fifo_req.wr),
  //   .read_i           (dma_fifo_req.rd),
  //   .data_i           (dma_fifo_req.data_wr),
  //   .data_o           (dma_fifo_resp.data_rd),
  //   .full_o           (dma_fifo_resp.full),
  //   .empty_o          (dma_fifo_resp.empty)
  // );

  dma_axi_if u_dma_axi_if (
    .clk                  (clk),
    .rstn                 (rstn),
    // From/To Streamers
    .dma_axi_rd_req_i     (dma_axi_rd_req),
    .dma_axi_rd_resp_o    (dma_axi_rd_resp),
    .dma_axi_wr_req_i     (dma_axi_wr_req),
    .dma_axi_wr_resp_o    (dma_axi_wr_resp),
    // Master AXI I/F
    .axi_req_o            (axi_req_o),
    .axi_resp_i           (axi_resp_i),
    // From/To Aligner interface
    .dma_aligner_req_o     (axi_if_req),
    .dma_aligner_resp_i    (axi_if_resp),
    // From/To DMA FSM
    .axi_pend_txn_o       (axi_pend_txn),
    .axi_dma_err_o        (axi_dma_err),
    .clear_dma_i          (clear_dma),
    .dma_active_i         (dma_active)
  );

  task write_data_to_file;
        input logic [511:0] wdata;
        input logic [63:0] wstrb;
        input integer file;
        integer i;
        reg [7:0] wdata_byte;
        reg [511:0] wstrb_masked_data;
    begin
        wstrb_masked_data = 512'b0;
        for (i = 0; i < 64; i = i + 1) begin
            wdata_byte = wdata[i*8 +: 8];
            if (wstrb[i]) begin
                wstrb_masked_data[i*8 +: 8] = wdata_byte;
            end else begin
                wstrb_masked_data[i*8 +: 8] = 8'hXX;
            end
        end
        $fwrite(file, "%h\n", wstrb_masked_data);
    end
  endtask

  int dma_read_data_file;
  initial begin
    dma_read_data_file = $fopen("./dma_read_data_file.txt", "wb");
    if (dma_read_data_file == 0) begin
      $display("Error opening dma_read_data_file!");
      $stop;//$finish;
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (dma_go_i) begin
      $fwrite(dma_read_data_file, "\nsrc: %h | dst: %h | len: %h\ndata:\n", dma_desc_i.src_addr, dma_desc_i.dst_addr, dma_desc_i.num_bytes);
    end
    if (dma_stats_o.active & axi_req_o.wvalid) begin
      write_data_to_file(axi_req_o.w.wdata, axi_req_o.w.wstrb, dma_read_data_file);
    end
  end
endmodule
