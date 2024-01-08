module dma_tb ();
`include  "test_data_generator.svh"
parameter RAM_START_ADDR   = 32'h1000_0000;
parameter RAM_END_ADDR     = 32'h1fff_ffff;
parameter RAM_SIZE         = 32'h1000_0000;
parameter NARROW_SRC       = 32'h1100_011b;
parameter NARROW_DST       = 32'h1400_0127;
parameter TRANSFER_SRC     = 32'h1100_0100;
parameter TRANSFER_DST     = 32'h1400_0100;

import axi_pkg::*;
import dma_pkg::*;

logic clk;
logic reset_n_mem;
logic reset_n_bfm;
logic reset_dma;

logic                             dma_go_i;
s_dma_desc_t                      dma_desc;
s_dma_error_t                     dma_error;
s_dma_status_t                    dma_stats;

logic      master_ctrl;
axi_req_t  axi_req_o_dma;
axi_req_t  axi_req_o_bfm;
axi_req_t  axi_req_o;
axi_resp_t axi_resp_i_dma;
axi_resp_t axi_resp_i_bfm;
axi_resp_t axi_resp_i;

dma_func_wrapper u_dma (
  .clk              (clk           ),
  .rst              (reset_dma     ),
  // From/To CSRs
  .dma_go_i         (dma_go_i      ),
  .dma_desc_i       (dma_desc      ),
  .dma_stats_o      (dma_stats     ),
  .dma_error_o      (dma_error     ),
  // Master AXI I/F
  .axi_req_o        (axi_req_o_dma ),
  .axi_resp_i       (axi_resp_i_dma)
);

cdn_axi4_master_bfm_wrapper#(
  .NAME({"MASTER_BFM"}),
  .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
  .ADDRESS_BUS_WIDTH(32),
  .ID_BUS_WIDTH(ID_BUS_WIDTH),
  .MAX_OUTSTANDING_TRANSACTIONS(8)
) u_axi4_master_bfm (
  .aclk       (clk           ),
  .aresetn    (reset_n_bfm   ),
  .axi_req_o  (axi_req_o_bfm ),
  .axi_resp_i (axi_resp_i_bfm)
);

axi4_memory_wrapper#(
  .useSMICModel           (0),
  .MEMORY_NAME            ("RAM_MODEL"),
  .DATA_WIDTH             (DATA_BUS_WIDTH),
  .ADDRESS_WIDTH          (32),
  .ID_WIDTH               (ID_BUS_WIDTH),
  .MEMORY_SPACE_START_ADDR(RAM_START_ADDR),
  .MEMORY_SPACE_END_ADDR  (RAM_END_ADDR),
  .MEMORY_BYTE_SIZE       (RAM_SIZE)
) u_ram_memmodel (
  .aclk       (clk        ),
  .aresetn    (reset_n_mem),
  .axi_req_i  (axi_req_o  ),
  .axi_resp_o (axi_resp_i )
);

Multiplexer u_multiplexer (
  .master_ctrl    (master_ctrl   ),
  .axi_req_o_dma  (axi_req_o_dma ),
  .axi_req_o_bfm  (axi_req_o_bfm ),
  .axi_resp_i     (axi_resp_i    ),
  .axi_req_o      (axi_req_o     ),
  .axi_resp_i_dma (axi_resp_i_dma),
  .axi_resp_i_bfm (axi_resp_i_bfm)
);

// 时钟生成
always begin
  #1 clk = ~clk;
end

// 测试激励
initial begin
  $display("[%0t]: Reseting all module...", $time);
  clk = 1'b1;
  reset_n_mem = 1'b0;
  repeat(10) @(posedge clk);
  reset_n_bfm = 1'b0;
  reset_dma   = 1'b1;
  repeat(50) @(posedge clk);
  $display("[%0t]: Stop reseting...", $time);
  reset_n_mem = 1'b1;
  reset_n_bfm = 1'b1;
  reset_dma   = 1'b0;

  repeat(10) @(posedge clk);
  $display("[%0t]: Memory initializing...", $time);
  master_ctrl = 1'b0;
  u_axi4_master_bfm.BFM_WRITE_BURST64(TRANSFER_SRC,32'h0000_0000,TESTDATA512bits_1,`ENABLE_MESSAGE);
  $display("[%0t]: Memory initialization done.", $time);

  repeat(50) @(posedge clk);
  $display("[%0t]: Change memory control source to DMA...", $time);
  master_ctrl           = 1'b1;
  dma_desc.src_addr     = NARROW_SRC;
  dma_desc.dst_addr     = NARROW_DST;
  dma_desc.num_bytes    = 32'hb; // 11byte
  // dma_desc.num_bytes    = 32'h39; // cross 64byte-boundary
  // dma_desc.num_bytes    = 32'h800; // not narrow transfer, address unaligned

  $display("[%0t]: Enable DMA to transfer data...", $time);
  dma_go_i       = 1'b1;
  repeat(1) @(posedge clk);
  dma_go_i       = 1'b0;
  repeat(50) begin
  @(posedge clk);
  if (dma_stats.error == 1'b1) begin
    $display("[%0t]: DMA transfer error...", $time);
    break;
  end
  else if (dma_stats.done == 1'b1) begin
      $display("[%0t]: DMA transfer completed...", $time);
      break;
    end
  end
  repeat(10) @(posedge clk);
  // $stop;

  $display("[%0t]: Change memory control source to BFM...", $time);
  master_ctrl = 1'b0;
  u_axi4_master_bfm.BFM_READ_BURST64(TRANSFER_DST,32'h0000_0000,response512,`ENABLE_MESSAGE);
  repeat(50) @(posedge clk);
  $finish;
end

initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb
