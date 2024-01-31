module dma_tb ();
`include  "test_data_generator.svh"
parameter RAM_START_ADDR   = 32'h1000_0000;
parameter RAM_END_ADDR     = 32'h1fff_ffff;
parameter RAM_SIZE         = 32'h1000_0000;
parameter NARROW_SRC       = 32'h1100_011b;
parameter NARROW_DST       = 32'h1400_0127;
parameter TRANSFER_SRC     = 32'h1100_0100;
parameter TRANSFER_DST     = 32'h1400_0100;

import venus_soc_pkg::*;
import dma_pkg::*;

logic          clk;
logic          reset_n_mem;
logic          reset_n;

axi2mem_req_t  mem_req;
axi2mem_resp_t mem_resp;
logic          dma_done;
logic          dma_error;

logic          master_ctrl;
axi_req_t      axi_req_o_dma;
axi_req_t      axi_req_o_bfm;
axi_req_t      axi_req_o;
axi_resp_t     axi_resp_i_dma;
axi_resp_t     axi_resp_i_bfm;
axi_resp_t     axi_resp_i;

dma_axi_wrapper u_dma (
  .clk (clk),
  .rstn (reset_n),
  // CSR DMA I/F
  .axi2mem_req_i  (mem_req),
  .axi2mem_resp_o (mem_resp),
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
  .ID_BUS_WIDTH(ID_BUS_WIDTH)
) u_cpu_bfm (
  .clk (clk),
  .rstn (reset_n),
  .axi2mem_req_o (mem_req),
  .axi2mem_resp_i (mem_resp)
);

cdn_axi4_master_bfm_wrapper#(
  .NAME({"MASTER_BFM"}),
  .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
  .ADDRESS_BUS_WIDTH(32),
  .ID_BUS_WIDTH(ID_BUS_WIDTH),
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
  u_axi4_master_bfm.BFM_WRITE_BURST64(32'h1100_0100,32'h0000_0000,TESTDATA512bits_1,`ENABLE_MESSAGE);
  master_ctrl = 1'b1; // change to DMA

  $display("[%0t]: Start writing DMA control registers...", $time);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_SRCREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h1100_0100,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_DSTREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h1400_0100,`ENABLE_MESSAGE);
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_LENREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0040,`ENABLE_MESSAGE);  // 64byte
  u_cpu_bfm.CPU_WRITE_BURST4(`VENUSDMA_CFGREG_OFFSET,`VENUSDMA_CTRLREG_OFFSET,32'h0000_0001,`ENABLE_MESSAGE);
  repeat(50) @(posedge clk) begin
    if (dma_done) begin
      $display("[%0t]: DMA transmit done...", $time);
      break;
    end
  end
  u_cpu_bfm.CPU_READ_BURST64(32'h0000_0000,`VENUSDMA_CTRLREG_OFFSET,response512,`ENABLE_MESSAGE);
  master_ctrl = 1'b0; // change to BFM
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1400_0100,32'h0,response512,`ENABLE_MESSAGE);
  $stop;
end

initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb
