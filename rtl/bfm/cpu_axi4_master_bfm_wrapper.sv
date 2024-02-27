module cdn_cpu_master_bfm_wrapper
  // import dma_cpu_pkg::*;
  import venus_soc_pkg::*;
#(
   parameter NAME = "CPU_BFM",
   parameter DATA_BUS_WIDTH = 512,
   parameter ADDRESS_BUS_WIDTH = 32,
   parameter ID_BUS_WIDTH = 7
)(
  input  logic          clk,
  input  logic          rstn,
  output axi_req_t      axi_req_o,
  input  axi_resp_t     axi_resp_i
);

  axi_req_t  axi_req;
  axi_resp_t axi_resp;

  cdn_axi4_master_bfm_wrapper#(
    .NAME(NAME),
    .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
    .ADDRESS_BUS_WIDTH(ADDRESS_BUS_WIDTH),
    .ID_BUS_WIDTH(ID_BUS_WIDTH),
    .MAX_OUTSTANDING_TRANSACTIONS(8)
  ) u_cpu_axi4_master_bfm (
    .aclk       (clk),
    .aresetn    (rstn),
    .axi_req_o  (axi_req_o),
    .axi_resp_i (axi_resp_i)
  );

task CPU_WRITE_BURST4;
  input integer WRITE_BURST_BASE_ADDRESS;
  input integer WRITE_BURST_OFFSET;
  input [31:0]  WRITEDATA;
  input         function_level_info;
  begin
    u_cpu_axi4_master_bfm.BFM_WRITE_BURST4(WRITE_BURST_BASE_ADDRESS, WRITE_BURST_OFFSET, WRITEDATA, function_level_info);
  end
endtask

task CPU_READ_BURST64;
  input integer  READ_BURST_BASE_ADDRESS;
  input integer  READ_BURST_OFFSET;
  output [511:0] READDATA;
  input          function_level_info;
  begin
    u_cpu_axi4_master_bfm.BFM_READ_BURST64(READ_BURST_BASE_ADDRESS, READ_BURST_OFFSET, READDATA, function_level_info);
  end
endtask

endmodule