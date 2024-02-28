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

task automatic dma_transfer;
  input [31:0] src;
  input [31:0] dst;
  input [31:0] bytes;
  dma_desc.src_addr  = src;
  dma_desc.dst_addr  = dst;
  dma_desc.num_bytes = bytes;
  dma_go_i           = 1'b1;
  while(!dma_stats.active) @(posedge clk);
  dma_go_i           = 1'b0;
  dma_desc.src_addr  = '0;
  dma_desc.dst_addr  = '0;
  dma_desc.num_bytes = '0;
  while(!dma_stats.done && dma_stats.active) @(posedge clk) begin
    if(dma_stats.error == 1) begin
      $display("[%0t]: DMA error is %d", $time, dma_error.src);
    end
  end
endtask

task automatic ram_init;
  for (int i = 0; i < 16384; i++)begin
    data64.randomize();
    ddr_model[(RAM_START_ADDR+(32'h40 * i))] = data64.data;
    u_axi4_master_bfm.BFM_WRITE_BURST64(RAM_START_ADDR, (32'h40 * i), data64.data, `ENABLE_MESSAGE);
  end
endtask

task automatic transfer_test;
input int repeat_num;
input int byte_num;
int num = byte_num / 64;
  repeat(repeat_num) begin
    desc.randomize();
    $display("[%0t] testing %d-bytes transfer, src = %h, dst = %h", $time, byte_num, desc.src, desc.dst);
    for (int i = 0; i < num; i++) begin
      ddr_model[desc.dst + (32'h40 * i)]=ddr_model[desc.src + (32'h40 * i)];
    end
    dma_transfer(desc.src, desc.dst, (32'h40 * num));
  end
endtask

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

	desc        = new();
  data64      = new();
  master_ctrl = 1'b0;
  ram_init();
  master_ctrl = 1'b1;
  transfer_test(5,256);  // (repeat num, transfer bytes)
  transfer_test(5,512);
  transfer_test(50,1024);
  transfer_test(5,2048);
  transfer_test(5,4096);
  transfer_test(5,8192);

  master_ctrl = 1'b0;
  foreach(ddr_model[j])begin
     u_axi4_master_bfm.BFM_READ_BURST64(j, 0, response512, `ENABLE_MESSAGE);
     if((response512 != ddr_model[j]) || (response512 === 'dx)) begin
         $display("DMA error at %0h, write data is:%0h, read data is:%0h.",j ,ddr_model[j], response512);
         $stop;
     end
  end
  $display("DMA test done!");
  $stop;
end

initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb
