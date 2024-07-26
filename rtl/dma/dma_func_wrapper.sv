module dma_func_wrapper
  import dma_pkg::*;
  import venus_soc_pkg::*;
(
  input                      clk,
  input                      rstn,
  // From/To CSRs
  input   logic              dma_go_i,
  input   s_dma_desc_t       dma_desc_i,   // src_addr | dst_addr    | num_bytes
  output  s_dma_error_t      dma_error_o,  // addr     | src (RD/WR) | valid
  output  s_dma_status_t     dma_stats_o,  // error    | done        | active
  // Master AXI I/F
  output  axi_req_t          axi_req_o,
  input   axi_resp_t         axi_resp_i
);

  // 「Streamer - FSM」
  logic dma_stream_rd_valid_o;
  logic dma_stream_rd_done_i;
  logic dma_stream_wr_valid_o;
  logic dma_stream_wr_done_i;

  //「Streamer - AXI IF」
  s_dma_stream_req_t   dma_stream_rd_req;
  s_dma_stream_resp_t  dma_stream_rd_resp;
  s_dma_stream_req_t   dma_stream_wr_req;
  s_dma_stream_resp_t  dma_stream_wr_resp;

  //「Streamer - Shift Aligner」
  s_dma_align_req_t dma_stream_src_info;
  s_dma_align_req_t dma_stream_dst_info;

  // 「AXI IF - Shift Aligner」
  s_dma_axi_req_t  dma_axi_if_req;
  s_dma_axi_resp_t dma_axi_if_resp;

  s_dma_error_t  axi_dma_err;
  s_dma_error_t  dma_stream_rd_err;
  s_dma_error_t  dma_stream_wr_err;

  logic axi_pend_txn;
  logic dma_clear;   // DMA从 DONE 下一拍即将转为 IDLE 的时候拉高此信号 -> 用于清空所有的fifo
  logic dma_active;

  dma_fsm u_dma_fsm(
    .clk                    (clk),
    .rstn                   (rstn),
    // 启动控制 ｜ 事物描述 | 总体状态[error/done]
    .dma_go_i               (dma_go_i),
    .dma_stats_o            (dma_stats_o),
    .dma_error_o            (dma_error_o),
    // From/To AXI I/F
    .axi_pend_txn_i         (axi_pend_txn),
    .axi_txn_err_i          (axi_dma_err),
    .dma_active_o           (dma_active),
    // From/To Shift Aligner
    .dma_clear_o            (dma_clear),
    // From/To Streamer
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
    .dma_stream_req_o       (dma_stream_rd_req),
    .dma_stream_resp_i      (dma_stream_rd_resp),
    // From/To Shift Aligner
    .dma_align_req_o        (dma_stream_src_info),
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
    .dma_stream_req_o       (dma_stream_wr_req),
    .dma_stream_resp_i      (dma_stream_wr_resp),
    // From/To Shift Aligner
    .dma_align_req_o        (dma_stream_dst_info),
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
    .clk                    (clk),
    .rstn                   (rstn),
    .dma_go_i               (dma_go_i),
    .dma_desc_i             (dma_desc_i),
    // From/To FSM
    .dma_clear_i            (dma_clear),
    // From/To Streamer
    .dma_src_info_i         (dma_stream_src_info),
    .dma_dst_info_i         (dma_stream_dst_info),
    // From/To AXI IF
    .dma_axi_if_req_i       (dma_axi_if_req),
    .dma_axi_if_resp_o      (dma_axi_if_resp)
  );

  dma_axi_if u_dma_axi_if (
    .clk                         (clk),
    .rstn                        (rstn),
    // From/To Streamers
    .dma_stream_rd_req_i         (dma_stream_rd_req),
    .dma_stream_rd_resp_o        (dma_stream_rd_resp),
    .dma_stream_wr_req_i         (dma_stream_wr_req),
    .dma_stream_wr_resp_o        (dma_stream_wr_resp),
    // From/To AXI4 Master
    .axi_req_o                   (axi_req_o),
    .axi_resp_i                  (axi_resp_i),
    // From/To Shift Aligner
    .dma_axi_req_o               (dma_axi_if_req),
    .dma_axi_resp_i              (dma_axi_if_resp),
    // From/To DMA FSM
    .axi_pend_txn_o              (axi_pend_txn),
    .axi_dma_err_o               (axi_dma_err),
    .dma_active_i                (dma_active)
  );

  `define DUMP_DMA_TRANS_INFO
  `ifdef DUMP_DMA_TRANS_INFO
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
      $stop;
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
  `endif
endmodule
