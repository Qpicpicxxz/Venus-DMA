module dma_tb ();
`include  "test_data_generator.svh"
parameter RAM_START_ADDR   = 32'h8000_0000;
parameter RAM_END_ADDR     = 32'h8fff_ffff;
parameter RAM_SIZE         = 32'h8000_0000;
parameter NARROW_SRC       = 32'h8100_011b;
parameter NARROW_DST       = 32'h8400_0127;
parameter TRANSFER_SRC     = 32'h8100_0100;
parameter TRANSFER_DST     = 32'h8400_0100;

import venus_soc_pkg::*;
import dma_pkg::*;

logic          clk;
logic          reset_n_mem;
logic          reset_n;

logic          dma_done;
logic          dma_error;

logic          master_ctrl;
axi_req_t      axi_req_o_dma;
axi_req_t      axi_req_o_bfm;
axi_req_t      axi_req_o;
axi_req_t      axi_req_csr;
axi_resp_t     axi_resp_i_dma;
axi_resp_t     axi_resp_i_bfm;
axi_resp_t     axi_resp_i;
axi_resp_t     axi_resp_csr;

dma_axi_wrapper u_dma (
  .clk  (clk),
  .rstn (reset_n),
  // CSR DMA I/F
  .axi_req_i      (axi_req_csr),
  .axi_resp_o     (axi_resp_csr),
  // Master AXI I/F
  .axi_req_o      (axi_req_o_dma ),
  .axi_resp_i     (axi_resp_i_dma),
  // Triggers IRQs
  .dma_done_o     (dma_done),
  .dma_error_o    (dma_error)
);

cdn_cpu_master_bfm_wrapper#(
  .NAME({"CPU_0"}),
  .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
  .ADDRESS_BUS_WIDTH(32),
  .ID_BUS_WIDTH(ID_BUS_WIDTH_M)
) u_cpu_bfm (
  .clk        (clk),
  .rstn       (reset_n),
  .axi_req_o  (axi_req_csr),
  .axi_resp_i (axi_resp_csr)
);

cdn_axi4_master_bfm_wrapper#(
  .NAME({"MASTER_BFM"}),
  .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
  .ADDRESS_BUS_WIDTH(32),
  .ID_BUS_WIDTH(ID_BUS_WIDTH_M),
  .MAX_OUTSTANDING_TRANSACTIONS(8)
) u_axi4_master_bfm (
  .aclk       (clk           ),
  .aresetn    (reset_n       ),
  .axi_req_o  (axi_req_o_bfm ),
  .axi_resp_i (axi_resp_i_bfm)
);

axi4_memory_wrapper#(
  .useSMICModel           (0),
  .MEMORY_NAME            ("RAM_MODEL"),
  .DATA_WIDTH             (DATA_BUS_WIDTH),
  .ADDRESS_WIDTH          (32),
  .ID_WIDTH               (ID_BUS_WIDTH_M),
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
  .master_ctrl    (master_ctrl   ),  // 0 - BFM | 1 - DMA
  .axi_req_o_dma  (axi_req_o_dma ),
  .axi_req_o_bfm  (axi_req_o_bfm ),
  .axi_resp_i     (axi_resp_i    ),
  .axi_req_o      (axi_req_o     ),
  .axi_resp_i_dma (axi_resp_i_dma),
  .axi_resp_i_bfm (axi_resp_i_bfm)
);

// 时钟生成
always begin
  #10 clk = ~clk;
end

// 测试激励
initial begin
  $display("[%0t]: Reseting all module...", $time);
  clk = 1'b1;
  reset_n_mem = 1'b0;
  repeat(10) @(posedge clk);
  reset_n     = 1'b0;
  repeat(50) @(posedge clk);
  $display("[%0t]: Stop reseting...", $time);
  reset_n_mem = 1'b1;
  reset_n     = 1'b1;

  master_ctrl = 1'b0; // change to BFM
  $display("[%0t]: Start initializing memory..", $time);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_0000,32'h0000_0000,TESTDATA16384bits_1,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_0800,32'h0000_0000,TESTDATA16384bits_2,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_1000,32'h0000_0000,TESTDATA16384bits_3,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_1800,32'h0000_0000,TESTDATA16384bits_4,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_2000,32'h0000_0000,TESTDATA16384bits_1,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_2800,32'h0000_0000,TESTDATA16384bits_2,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_3000,32'h0000_0000,TESTDATA16384bits_3,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h8100_3800,32'h0000_0000,TESTDATA16384bits_4,`ENABLE_MESSAGE);
  master_ctrl = 1'b1; // change to DMA

  $display("[%0t]: Start writing DMA control registers...", $time);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8100_0000,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8230_8000,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_1000,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0001,`ENABLE_MESSAGE);

  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8100_2000,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8230_A000,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0200,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0003,`ENABLE_MESSAGE); // last

  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8100_2009,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8230_A000,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0800,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0001,`ENABLE_MESSAGE); // unaligned

  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h1100_10fc,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h1400_1100,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0038,`ENABLE_MESSAGE);
  // u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0001,`ENABLE_MESSAGE); // cross boundary

  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8100_2800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8230_A800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0003,`ENABLE_MESSAGE); // last

  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8100_3800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h8230_B800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0800,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0003,`ENABLE_MESSAGE); // last

  repeat(5000) @(posedge clk);

  master_ctrl = 1'b0; // change to BFM
  $display("[%0t]: ==========================original data===========================", $time);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_0000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_0800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_1000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_1800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_2000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_2800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_3000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8100_3800,32'h0,response2048,`ENABLE_MESSAGE);

  $display("[%0t]: ==========================target data===========================", $time);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_8000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_8800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_9000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_9800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_A000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_A800,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_B000,32'h0,response2048,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST2048(32'h8230_B800,32'h0,response2048,`ENABLE_MESSAGE);
  $stop;
end

always@(posedge clk or negedge reset_n)begin
  if (dma_error) begin
    $display("[%0t]: DMA transmit error...", $time);
    u_cpu_bfm.CPU_READ_BURST64(32'h0000_0000,`VENUSDMA_CTRLREG_OFFSET,response512,`ENABLE_MESSAGE);
    $stop;
  end else if(dma_done) begin
    $display("[%0t]: DMA transmit done...", $time);
    repeat(20) @(posedge clk);
    u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0004,`ENABLE_MESSAGE); // clear irq
  end
end


initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb
