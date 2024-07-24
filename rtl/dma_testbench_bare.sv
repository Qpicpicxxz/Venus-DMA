module dma_tb ();
`include  "test_data_generator.svh"
parameter RAM_START_ADDR   = 32'h0000_0000;
parameter RAM_END_ADDR     = 32'hffff_fffe;
parameter RAM_SIZE         = 32'hffff_ffff;

import venus_soc_pkg::*;
import dma_pkg::*;

logic clk;
logic reset_n_mem;
logic reset_n;

logic            dma_go_i;
s_dma_desc_t     dma_desc;
s_dma_error_t    dma_error;
s_dma_status_t   dma_stats;

logic            master_ctrl;
axi_req_t        axi_req_o_dma;
axi_req_t        axi_req_o_bfm;
axi_req_t        axi_req_o;
axi_resp_t       axi_resp_i_dma;
axi_resp_t       axi_resp_i_bfm;
axi_resp_t       axi_resp_i;

dma_func_wrapper u_dma (
  .clk              (clk           ),
  .rstn             (reset_n       ),
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

// task automatic ram_init;
//   for (int i = 0; i < 512; i++)begin
//     data64.randomize();
//     u_axi4_master_bfm.BFM_WRITE_BURST2048(RAM_START_ADDR, (32'h800 * i), {32{data64.data}}, `ENABLE_MESSAGE);
//   end
// endtask

// 时钟生成
always begin
  #10 clk = ~clk;
end

task start_dma_transfer;
  input logic [31:0] src_addr;
  input logic [31:0] dst_addr;
  input logic [31:0] num_bytes;
  begin
    $display("Starts transfer: %h to %h, len is %h\n", src_addr, dst_addr, num_bytes);
    @(posedge clk)begin
      dma_desc.src_addr  = src_addr;
      dma_desc.dst_addr  = dst_addr;
      dma_desc.num_bytes = num_bytes;
      dma_go_i = 1'b1;
    end
    @(posedge clk)begin
      dma_desc = '0;
      dma_go_i = 1'b0;
    end
  end
endtask


// 测试激励
initial begin
  $display("[%0t]: Reseting all module...", $time);
  clk = 1'b1;
  reset_n_mem = 1'b0;
  dma_go_i = 1'b0;
  dma_desc = '0;
  repeat(10) @(posedge clk);
  reset_n     = 1'b0;
  repeat(50) @(posedge clk);
  $display("[%0t]: Stop reseting...", $time);
  reset_n_mem = 1'b1;
  reset_n     = 1'b1;
  master_ctrl = 1'b0; // change to BFM
  $display("[%0t]: Start initializing memory..", $time);
  u_axi4_master_bfm.BFM_WRITE_BURST64(32'h0000_0000,32'h0000_0000,TESTDATA512bits_block_0,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST64(32'h0000_0040,32'h0000_0000,TESTDATA512bits_block_1,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST64(32'h0000_0080,32'h0000_0000,TESTDATA512bits_block_2,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_WRITE_BURST64(32'h0000_00c0,32'h0000_0000,TESTDATA512bits_block_3,`ENABLE_MESSAGE);
  // u_axi4_master_bfm.BFM_WRITE_BURST2048(32'h0100_0800,32'h0000_0000,TESTDATA16384bits_2,`ENABLE_MESSAGE);
  // data64 = new();
  // ram_init();


  // 8836 - 0x2284
  // 0x81

  master_ctrl = 1'b1; // change to DMA

  start_dma_transfer(32'h0000_000c,32'h1000_0034,216);
  // @(posedge dma_stats.done);
  // start_dma_transfer(32'h0000_0000,32'h2100_0000,32'h320);
  // @(posedge dma_stats.done);
  // start_dma_transfer(32'h0001_0000,32'h4100_0000,32'h600);
  // @(posedge dma_stats.done);
  // start_dma_transfer(32'h0000_0100,32'h3100_0000,32'h1000);
  // @(posedge dma_stats.done);
  // start_dma_transfer(32'h0000_1900,32'h1100_0000,32'h22c0);
  // @(posedge dma_stats.done);
  // start_dma_transfer(32'h0000_0008,32'h1100_0000,32'h24);

  // dma_desc.src_addr  = 32'h0000_0000;
  // dma_desc.dst_addr  = 32'h1100_0000;
  // dma_desc.num_bytes = 32'h30;
  // @(posedge clk);
  // dma_go_i = 1'b1;
  // @(posedge clk);
  // dma_go_i = 1'b0;

  // dma_desc.src_addr  = 32'h0000_0000;
  // dma_desc.dst_addr  = 32'h2100_0000;
  // dma_desc.num_bytes = 32'h320;
  // @(posedge clk);
  // dma_go_i = 1'b1;
  // @(posedge clk);
  // dma_go_i = 1'b0;


  repeat(1000) @(posedge clk);
  master_ctrl = 1'b0;
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1000_0000,32'h0000_0000,response512,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1000_0040,32'h0000_0000,response512,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1000_0080,32'h0000_0000,response512,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1000_00c0,32'h0000_0000,response512,`ENABLE_MESSAGE);
  u_axi4_master_bfm.BFM_READ_BURST64(32'h1000_0100,32'h0000_0000,response512,`ENABLE_MESSAGE);
  $finish;
end

always@(posedge clk or negedge reset_n)begin
  if (dma_error) begin
    $display("[%0t]: DMA transmit error...", $time);
    $stop;
  end else if(dma_stats.done) begin
    $display("[%0t]: DMA transmit done...", $time);
    repeat(20) @(posedge clk);
  end
end

initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb