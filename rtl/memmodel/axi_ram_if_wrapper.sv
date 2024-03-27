//Copyright 2023 ACE-Lab, Shanghai University
//Create time:2023.3.30 18:53
//

module axi_ram_if_wrapper import venus_soc_pkg::*; #(
    parameter VENUS_HANDSHAKE = 0,
	parameter VENUS_VRF_START_ADDR = 0,
	parameter VENUS_VRF_END_ADDR = 0,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 8,
    parameter PIPELINE_OUTPUT = 0,
    parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH)
  ) (
    input logic aclk,
    input logic aresetn,

    input  axi_req_t  axi_req_i,
    output axi_resp_t axi_resp_o,

    output axi2mem_req_t  axi2mem_req_o,
    input  axi2mem_resp_t axi2mem_resp_i,
    input  logic          axi2mem_resp_ready_i
  );
      


axi_ram_if #
(
    // Handshake logic with venus VRFs
    .VENUS_HANDSHAKE(VENUS_HANDSHAKE),
    // Only the following region does `VENUS_HANDSHAKE` apply to
    .VENUS_VRF_START_ADDR(VENUS_VRF_START_ADDR),
    .VENUS_VRF_END_ADDR(VENUS_VRF_END_ADDR),
    // Width of data bus in bits
    .DATA_WIDTH(DATA_WIDTH),
    // Width of address bus in bits
    .ADDR_WIDTH(ADDR_WIDTH),
    // Width of wstrb (width of data bus in words)
    //parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    .ID_WIDTH(ID_WIDTH),
    // Extra pipeline register on output
    .PIPELINE_OUTPUT(0)
) u_axi_ram_if (
    .clk                 (aclk   ),
    .rst_n               (aresetn),
    .s_axi_awid          (axi_req_i.aw.awid[ID_WIDTH-1:0]   ),//input  wire [ID_WIDTH-1:0]    
    .s_axi_awaddr        (axi_req_i.aw.awaddr ),//input  wire [ADDR_WIDTH-1:0]  
    .s_axi_awlen         (axi_req_i.aw.awlen  ),//input  wire [7:0]             
    .s_axi_awsize        (axi_req_i.aw.awsize ),//input  wire [2:0]             
    .s_axi_awburst       (axi_req_i.aw.awburst),//input  wire [1:0]             
    .s_axi_awlock        (axi_req_i.aw.awlock ),//input  wire                   
    .s_axi_awcache       (axi_req_i.aw.awcache),//input  wire [3:0]             
    .s_axi_awprot        (axi_req_i.aw.awprot ),//input  wire [2:0]             
    .s_axi_awvalid       (axi_req_i.awvalid   ),//input  wire                   
    .s_axi_awready       (axi_resp_o.awready  ),//output wire                   
    .s_axi_wdata         (axi_req_i.w.wdata   ),//input  wire [DATA_WIDTH-1:0]  
    .s_axi_wstrb         (axi_req_i.w.wstrb   ),//input  wire [STRB_WIDTH-1:0]  
    .s_axi_wlast         (axi_req_i.w.wlast   ),//input  wire                   
    .s_axi_wvalid        (axi_req_i.wvalid    ),//input  wire                   
    .s_axi_wready        (axi_resp_o.wready   ),//output wire                   
    .s_axi_bid           (axi_resp_o.b.bid[ID_WIDTH-1:0]    ),//output wire [ID_WIDTH-1:0]    
    .s_axi_bresp         (axi_resp_o.b.bresp  ),//output wire [1:0]             
    .s_axi_bvalid        (axi_resp_o.bvalid   ),//output wire                   
    .s_axi_bready        (axi_req_i.bready    ),//input  wire                   
    .s_axi_arid          (axi_req_i.ar.arid[ID_WIDTH-1:0]   ),//input  wire [ID_WIDTH-1:0]    
    .s_axi_araddr        (axi_req_i.ar.araddr ),//input  wire [ADDR_WIDTH-1:0]  
    .s_axi_arlen         (axi_req_i.ar.arlen  ),//input  wire [7:0]             
    .s_axi_arsize        (axi_req_i.ar.arsize ),//input  wire [2:0]             
    .s_axi_arburst       (axi_req_i.ar.arburst),//input  wire [1:0]             
    .s_axi_arlock        (axi_req_i.ar.arlock ),//input  wire                   
    .s_axi_arcache       (axi_req_i.ar.arcache),//input  wire [3:0]             
    .s_axi_arprot        (axi_req_i.ar.arprot ),//input  wire [2:0]             
    .s_axi_arvalid       (axi_req_i.arvalid   ),//input  wire                   
    .s_axi_arready       (axi_resp_o.arready  ),//output wire                   
    .s_axi_rid           (axi_resp_o.r.rid[ID_WIDTH-1:0]    ),//output wire [ID_WIDTH-1:0]    
    .s_axi_rdata         (axi_resp_o.r.rdata  ),//output wire [DATA_WIDTH-1:0]  
    .s_axi_rresp         (axi_resp_o.r.rresp  ),//output wire [1:0]             
    .s_axi_rlast         (axi_resp_o.r.rlast  ),//output wire                   
    .s_axi_rvalid        (axi_resp_o.rvalid   ),//output wire                   
    .s_axi_rready        (axi_req_i.rready    ),//input  wire  
    .mem_wr_en           (axi2mem_req_o.mem_wr_en                                 ),//output logic                        
    .mem_wstrb           (axi2mem_req_o.mem_wstrb                                 ),//output logic [STRB_WIDTH-1:0]       
    .mem_waddr           (axi2mem_req_o.mem_waddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)]),//output logic [VALID_ADDR_WIDTH-1:0] 
    .mem_wdata           (axi2mem_req_o.mem_wdata                                 ),//output logic [DATA_WIDTH-1:0]       
    .mem_rd_en           (axi2mem_req_o.mem_rd_en                                 ),//output logic                        
    .mem_raddr           (axi2mem_req_o.mem_raddr[ADDR_WIDTH-1:$clog2(STRB_WIDTH)]),//output logic [VALID_ADDR_WIDTH-1:0] 
    .mem_rdata           (axi2mem_resp_i.mem_rdata                                ),//input  wire  [DATA_WIDTH-1:0]
    .mem_ready           (axi2mem_resp_ready_i)       
);
assign axi2mem_req_o.mem_waddr[$clog2(STRB_WIDTH)-1:0] = '0;
assign axi2mem_req_o.mem_raddr[$clog2(STRB_WIDTH)-1:0] = '0;
endmodule
