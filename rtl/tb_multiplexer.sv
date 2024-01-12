module Multiplexer import venus_soc_pkg::*; #(
)(
  input             master_ctrl,
  input  axi_req_t  axi_req_o_dma,
  input  axi_req_t  axi_req_o_bfm,
  input  axi_resp_t axi_resp_i,
  output axi_req_t  axi_req_o,
  output axi_resp_t axi_resp_i_dma,
  output axi_resp_t axi_resp_i_bfm
);
  always @* begin
      if (master_ctrl == 1'b1) begin
        axi_req_o = axi_req_o_dma; // DMA操控
        axi_resp_i_dma = axi_resp_i;
        axi_resp_i_bfm = '0;
      end else begin
        axi_req_o = axi_req_o_bfm; // BFM操控
        axi_resp_i_bfm = axi_resp_i;
        axi_resp_i_dma = '0;
      end
  end
endmodule