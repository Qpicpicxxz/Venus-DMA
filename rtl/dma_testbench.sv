module dma_tb ();
parameter RAM_START_ADDR = 32'h1000_0000;
parameter RAM_END_ADDR   = 32'h1fff_ffff;
parameter RAM_SIZE       = 32'h1000_0000;
parameter TRANSFER_SRC   = 32'h1100_0000;
parameter TRANSFER_DST   = 32'h1200_0000;

import axi_pkg::*;
import dma_pkg::*;

logic clk;
logic reset_n_mem;
logic reset_n_bfm;
logic reset_dma;

s_dma_control_t                   dma_ctrl;
s_dma_desc_t [`DMA_NUM_DESC-1:0]  dma_desc;
s_dma_error_t                     dma_error;
s_dma_status_t                    dma_stats;

logic      master_ctrl;
axi_req_t  axi_req_o_dma;
axi_req_t  axi_req_o_bfm;
axi_req_t  axi_req_o;
axi_resp_t axi_resp_i_dma;
axi_resp_t axi_resp_i_bfm;
axi_resp_t axi_resp_i;

logic [511:0] response512;

dma_func_wrapper u_dma (
  .clk              (clk           ),
  .rst              (reset_dma     ),
  // From/To CSRs
  .dma_ctrl_i       (dma_ctrl      ),
  .dma_desc_i       (dma_desc      ),
  .dma_stats_o      (dma_stats     ),
  .dma_error_o      (dma_error     ),
  // Master AXI I/F
  .dma_axi_req_o    (axi_req_o_dma ),
  .dma_axi_resp_i   (axi_resp_i_dma)
);

cdn_axi4_master_bfm_wrapper#(
  .NAME({"MASTER_BFM"}),
  .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
  .ADDRESS_BUS_WIDTH(ADDRESS_BUS_WIDTH),
  .ID_BUS_WIDTH(ID_BUS_WIDTH),
  .MAX_OUTSTANDING_TRANSACTIONS(MAX_OUTSTANDING_TRANSACTIONS)
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
  .ADDRESS_WIDTH          (ADDRESS_BUS_WIDTH),
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
  #10
  reset_n_bfm = 1'b0;
  reset_dma   = 1'b1;
  #50
  $display("[%0t]: Stop reseting...", $time);
  reset_n_mem = 1'b1;
  reset_n_bfm = 1'b1;
  reset_dma   = 1'b0;

  #10
  $display("[%0t]: Memory initializing...", $time);
  master_ctrl = 1'b0;
  // 64byte = 512bit
  u_axi4_master_bfm.BFM_WRITE_BURST64(TRANSFER_SRC,32'h0000_0000,{2{256'h5724_3542_3524_5245_2452_5542_5763_0157_9175_6418_5541_2318_4543_6873_5629_5890}},`ENABLE_MESSAGE);
  $display("[%0t]: Memory initialization done.", $time);

  #50
  $display("[%0t]: Change memory control source to DMA...", $time);
  // reset_n_bfm           = 1'b0;
  master_ctrl           = 1'b1;
  dma_ctrl.abort_req    = 0;
  dma_ctrl.max_burst    = 8'hff;
  dma_desc[0].src_addr  = TRANSFER_SRC;
  dma_desc[0].dst_addr  = TRANSFER_DST;
  dma_desc[0].num_bytes = 32'h40; // 64byte
  dma_desc[0].wr_mode   = DMA_MODE_INCR;
  dma_desc[0].rd_mode   = DMA_MODE_INCR;
  dma_desc[0].enable    = 1'b1;

  #10
  $display("[%0t]: Enable DMA to transfer data...", $time);
  dma_ctrl.go = 1'b1;

  repeat(50) begin
  @(posedge clk);
  if (dma_stats.done == 1'b1) begin
      $display("[%0t]: DMA transfer completed...", $time);
      break;
    end
  end

  $display("[%0t]: Change memory control source to BFM...", $time);
  // reset_n_bfm = 1'b1;
  master_ctrl = 1'b0;
  u_axi4_master_bfm.BFM_READ_BURST64(TRANSFER_DST,32'h0000_0000,response512,`ENABLE_MESSAGE);

  #50
  $finish;
end

initial begin
    `ifdef DUMP_VCD
      $vcdplusfile("dma_test.vpd");
      $vcdpluson;
    `endif
end // Dump waveforms

endmodule: dma_tb
