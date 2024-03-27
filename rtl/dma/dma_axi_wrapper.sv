module dma_axi_wrapper
  import venus_soc_pkg::*;
  import dma_pkg::*;
(
  input                  clk,
  input                  rstn,
  // CSR DMA I/F
  input   axi_req_t      axi_req_i,
  output  axi_resp_t     axi_resp_o,
  // Master DMA I/F
  output  axi_req_t      axi_req_o,
  input   axi_resp_t     axi_resp_i,
  // Triggers - IRQs
  output  logic          dma_done_o,
  output  logic          dma_error_o
);

  axi2mem_req_t  mem_req;
  axi2mem_resp_t mem_resp;

  axi_ram_if_wrapper #(
      .DATA_WIDTH(DATA_BUS_WIDTH),
      .ADDR_WIDTH(ADDRESS_BUS_WIDTH),
      .ID_WIDTH(ID_BUS_WIDTH_M),
      .PIPELINE_OUTPUT(0)
  ) u_cpu_axi_mem_if_wrapper (
      .aclk             (clk),
      .aresetn          (rstn),
      .axi_req_i        (axi_req_i),
      .axi_resp_o       (axi_resp_o),
      .axi2mem_req_o    (mem_req),
      .axi2mem_resp_i   (mem_resp)
  );

  s_dma_desc_t      dma_csr2fifo_desc;   // csr out, fifo in
  logic             dma_csr2fifo_write;  // csr out, fifo in
  logic             dma_csr2fifo_last;   // csr out, fifo in

  s_dma_desc_t      dma_fifo2func_desc;  // fifo out, func in
  logic             dma_trans_last;      // fifo out

  logic             dma_fifo_read;  // fifo in
  logic             dma_fifo_full;  // fifo out
  logic             dma_fifo_empty; // fifo out

  logic             dma_go;     // func in
  s_dma_status_t    dma_stats;  // func out
  s_dma_error_t     dma_error;  // func out

  csr_req_t         dma_csr_req;  // csr in
  csr_resp_t        dma_csr_resp; // csr out
  logic             dma_csr_rd_en;

  logic             dma_clear_irq; // csr out
  logic             dma_trans_done; // func out

  logic last_dma_active;  // stores the previous value of dma_active
  logic next_dma_fifo_read_hpn, dma_fifo_read_hpn_ff;
  logic dma_trans_last_ff;
  logic [3:0] next_dma_trans_done_counter, dma_trans_done_counter_ff;

  assign dma_fifo_read = ~(dma_stats.active | last_dma_active | dma_fifo_empty | dma_go);
  // assign dma_go        = ~(dma_stats.active | last_dma_active | dma_fifo_empty);
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      dma_go <= '0;
    end else begin
      dma_go <= dma_fifo_read;
    end
  end

  always_comb begin
    next_dma_fifo_read_hpn = dma_fifo_read;
    // fifo读取延迟一拍: 读出当前dma请求是否是最后一个请求块
    if (dma_fifo_read_hpn_ff) begin
      dma_trans_last_ff = dma_trans_last;
    end
  end

  always_comb begin
    dma_trans_done   = dma_stats.done & dma_trans_last_ff & (~dma_stats.error);
    dma_error_o      = dma_stats.error;
    next_dma_trans_done_counter = dma_trans_done_counter_ff + (dma_trans_done ? 'd1 : 'd0) - (dma_clear_irq ? 'd1 : 'd0);
    dma_done_o = (|dma_trans_done_counter_ff); // 如果counter！=0，那么就一直产生中断
  end

  // 这里控制查看memory access是否在访问DMA的寄存器
  assign dma_csr_req.csr_wr_en = mem_req.mem_wr_en && ({mem_req.mem_waddr[31:6], 6'h0} == VENUS_L1_DMAC_CFG_ADDR);
  assign dma_csr_req.csr_waddr = axiwaddr_512to32_converter(mem_req.mem_waddr, mem_req.mem_wstrb);
  assign dma_csr_req.csr_wdata = axiwdata_512to32_converter(mem_req.mem_wstrb, mem_req.mem_wdata);
  assign dma_csr_req.csr_rd_en = mem_req.mem_rd_en && ({mem_req.mem_raddr[31:6], 6'h0} == VENUS_L1_DMAC_CFG_ADDR);

  assign mem_resp.mem_rdata = dma_csr_rd_en ? dma_csr_resp.csr_rdata : 512'h0;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      dma_csr_rd_en        <= 1'b0;
      last_dma_active      <= 1'b0;
      dma_fifo_read_hpn_ff <= 1'b0;
      dma_trans_done_counter_ff <= '0;
    end else begin
      dma_csr_rd_en        <= dma_csr_req.csr_rd_en;
      last_dma_active      <= dma_stats.active;
      dma_fifo_read_hpn_ff <= next_dma_fifo_read_hpn;
      dma_trans_done_counter_ff <= next_dma_trans_done_counter;
    end
  end

  dma_func_wrapper #(
    .is_L2_scheduler_dma(1),
    .NUM_TILE(10)
  ) u_dma_func (
    .clk              (clk),
    .rstn             (rstn),
    .dma_go_i         (dma_go),
    .dma_desc_i       (dma_fifo2func_desc),
    .dma_stats_o      (dma_stats),
    .dma_error_o      (dma_error),
    // Master AXI I/F
    .axi_req_o        (axi_req_o),
    .axi_resp_i       (axi_resp_i),

    .tile_hardware_info_i ({{2{4'd0,4'd3,1'd1,1'd1,1'd1,16'd0}},{8{4'd0,4'd4,1'd1,1'd1,1'd1,16'd0}}})
  );

  logic [96:0] data_i;
  logic [96:0] data_o;
  assign data_i             = {dma_csr2fifo_desc,dma_csr2fifo_last};         // 97bit
  assign dma_fifo2func_desc = data_o[96:1];
  assign dma_trans_last     = data_o[0];

  fifo_model #(
    .OUTPUT_DELAY(1),
    .SLOTS(32),
    .WIDTH(97)
  ) u_dma_csr_fifo (
    .clk        (clk),
    .rstn       (rstn),
    .clear_i    (),
    .write_i    (dma_csr2fifo_write),
    .read_i     (dma_fifo_read),
    .data_i     (data_i),
    .data_o     (data_o),
    .full_o     (dma_fifo_full),
    .empty_o    (dma_fifo_empty)
  );

  dma_ctrls u_dma_csr (
    .clk                  (clk),
    .rstn                 (rstn),
    // CSR AXI I/F
    .dma_csr_req_i        (dma_csr_req),
    .dma_csr_resp_o       (dma_csr_resp),
    // CSR DMA I/F
    .dma_ctrl_write_o     (dma_csr2fifo_write),
    .dma_ctrl_last_o      (dma_csr2fifo_last),
    .dma_clear_irq_o      (dma_clear_irq),
    .dma_desc_src_o       (dma_csr2fifo_desc.src_addr),
    .dma_desc_dst_o       (dma_csr2fifo_desc.dst_addr),
    .dma_desc_len_o       (dma_csr2fifo_desc.num_bytes),
    // .dma_status_done_i    (dma_stats.done),
    .dma_status_error_i   (dma_stats.error),
    .dma_csr_fifo_full_i  (dma_fifo_full),
    .dma_error_addr_i     (dma_error.addr),
    .dma_error_src_i      (dma_error.src)
  );

  function logic [31:0] axiwaddr_512to32_converter(input logic [31:0] addr, input logic [63:0] strb); //dma write to registers
    begin
      priority case(1)
        strb[ 3: 0] != 4'd0 : return addr;
        strb[ 7: 4] != 4'd0 : return addr + 32'd4;
        strb[11: 8] != 4'd0 : return addr + 32'd8;
        strb[15:12] != 4'd0 : return addr + 32'd12;
        strb[19:16] != 4'd0 : return addr + 32'd16;
        strb[23:20] != 4'd0 : return addr + 32'd20;
        strb[27:24] != 4'd0 : return addr + 32'd24;
        strb[31:28] != 4'd0 : return addr + 32'd28;
        strb[35:32] != 4'd0 : return addr + 32'd32;
        strb[39:36] != 4'd0 : return addr + 32'd36;
        strb[43:40] != 4'd0 : return addr + 32'd40;
        strb[47:44] != 4'd0 : return addr + 32'd44;
        strb[51:48] != 4'd0 : return addr + 32'd48;
        strb[55:52] != 4'd0 : return addr + 32'd52;
        strb[59:56] != 4'd0 : return addr + 32'd56;
        strb[63:60] != 4'd0 : return addr + 32'd60;
        default : return 32'd0;
      endcase
    end
  endfunction

  function logic [31:0] axiwdata_512to32_converter(input logic [63:0] strb, input logic [511:0] data); //dma write to registers
    begin
      priority case(1)
        strb[ 3: 0] != 4'd0 : return data[ 0*32+31: 0*32];
        strb[ 7: 4] != 4'd0 : return data[ 1*32+31: 1*32];
        strb[11: 8] != 4'd0 : return data[ 2*32+31: 2*32];
        strb[15:12] != 4'd0 : return data[ 3*32+31: 3*32];
        strb[19:16] != 4'd0 : return data[ 4*32+31: 4*32];
        strb[23:20] != 4'd0 : return data[ 5*32+31: 5*32];
        strb[27:24] != 4'd0 : return data[ 6*32+31: 6*32];
        strb[31:28] != 4'd0 : return data[ 7*32+31: 7*32];
        strb[35:32] != 4'd0 : return data[ 8*32+31: 8*32];
        strb[39:36] != 4'd0 : return data[ 9*32+31: 9*32];
        strb[43:40] != 4'd0 : return data[10*32+31:10*32];
        strb[47:44] != 4'd0 : return data[11*32+31:11*32];
        strb[51:48] != 4'd0 : return data[12*32+31:12*32];
        strb[55:52] != 4'd0 : return data[13*32+31:13*32];
        strb[59:56] != 4'd0 : return data[14*32+31:14*32];
        strb[63:60] != 4'd0 : return data[15*32+31:15*32];
        default : return 32'd0;
      endcase
    end
  endfunction

endmodule
