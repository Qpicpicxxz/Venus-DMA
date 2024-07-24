module dma_tb ();

import venus_soc_pkg::*;
import dma_pkg::*;

logic clk;
logic rstn;
logic valid;
s_dma_aligner_req_t src_info;
s_dma_aligner_req_t dst_info;
axi_data_t read_data;
axi_data_t fifo_data;
logic strb_valid;
s_dma_strb_req_t strb;

dma_shift_aligner u_sa (
  .clk(clk),
  .rstn(rstn),
  .valid_i(valid),
  .src_info_i(src_info),
  .dst_info_i(dst_info),
  .read_data_i(read_data),
  .fifo_data_o(fifo_data),
  .strb_valid_o(strb_valid),
  .strb_o(strb)
);

always begin
  #10 clk = ~clk;
end

// 测试激励
initial begin
  $display("[%0t]: Reseting all module...", $time);
  clk = 1'b1;
  repeat(10) @(posedge clk);
  rstn     = 1'b0;
  repeat(50) @(posedge clk);
  $display("[%0t]: Stop reseting...", $time);
  rstn = 1'b1;
  repeat(50) @(posedge clk);
  valid = 1'b1;
  src_info.head = 3;
  src_info.tail = 7;
  src_info.alen = 3;
  dst_info.head = 13;
  dst_info.tail = 13;
  dst_info.alen = 4;
read_data = {32{16'hFFFF}};
@(posedge clk);
read_data = {32{16'heeee}};
@(posedge clk);
read_data = {32{16'h8888}};
@(posedge clk);
read_data = {32{16'h3333}};
  repeat(100) @(posedge clk);

  $stop;
end

initial begin
  $vcdplusfile("dma_tb.vpd");
  $vcdpluson;
end // Dump waveforms

endmodule: dma_tb