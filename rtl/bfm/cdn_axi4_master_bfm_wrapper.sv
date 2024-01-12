//Copyright 2023 ACE-Lab, Shanghai University
//Create time:2023.2.14 19:54
//
`include "cdn_axi4_master_bfm.vh"
module cdn_axi4_master_bfm_wrapper import venus_soc_pkg::*; #(
   parameter NAME = "MASTER_0",
   parameter DATA_BUS_WIDTH = 512,
   parameter ADDRESS_BUS_WIDTH = 32,
   parameter ID_BUS_WIDTH = 8,
   parameter AWUSER_BUS_WIDTH = 1,
   parameter ARUSER_BUS_WIDTH = 1,
   parameter RUSER_BUS_WIDTH  = 1,
   parameter WUSER_BUS_WIDTH  = 1,
   parameter BUSER_BUS_WIDTH  = 1,
   parameter SLAVE_ADDRESS = 0,
   parameter SLAVE_MEM_SIZE = 4,
   parameter MAX_OUTSTANDING_TRANSACTIONS = 8,
   parameter MEMORY_MODEL_MODE = 0,
   parameter EXCLUSIVE_ACCESS_SUPPORTED = 1
  ) (
    input  logic      aclk,
    input  logic      aresetn,

    output axi_req_t  axi_req_o,
    input  axi_resp_t axi_resp_i
  );

cdn_axi4_master_bfm
#(
    .NAME(NAME),
    .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
    .ADDRESS_BUS_WIDTH(ADDRESS_BUS_WIDTH),
    .ID_BUS_WIDTH(ID_BUS_WIDTH),
    .AWUSER_BUS_WIDTH(AWUSER_BUS_WIDTH),
    .ARUSER_BUS_WIDTH(ARUSER_BUS_WIDTH),
    .RUSER_BUS_WIDTH(RUSER_BUS_WIDTH),
    .WUSER_BUS_WIDTH(WUSER_BUS_WIDTH),
    .BUSER_BUS_WIDTH(BUSER_BUS_WIDTH),
    .MAX_OUTSTANDING_TRANSACTIONS(MAX_OUTSTANDING_TRANSACTIONS),
    .EXCLUSIVE_ACCESS_SUPPORTED(EXCLUSIVE_ACCESS_SUPPORTED)
)
u_bfm(
    .ACLK    (aclk),
    .ARESETn (aresetn),

    .AWID    (axi_req_o.aw.awid[ID_BUS_WIDTH-1:0]      ),
    .AWADDR  (axi_req_o.aw.awaddr    ),
    .AWLEN   (axi_req_o.aw.awlen     ),
    .AWSIZE  (axi_req_o.aw.awsize    ),
    .AWBURST (axi_req_o.aw.awburst   ),
    .AWLOCK  (axi_req_o.aw.awlock    ),
    .AWCACHE (axi_req_o.aw.awcache   ),
    .AWPROT  (axi_req_o.aw.awprot    ),
    .AWREGION(                       ),
    .AWQOS   (                       ),
    .AWUSER  (                       ),
    .AWVALID (axi_req_o.awvalid      ),
    .AWREADY (axi_resp_i.awready     ),

    .WDATA   (axi_req_o.w.wdata      ),
    .WSTRB   (axi_req_o.w.wstrb      ),
    .WLAST   (axi_req_o.w.wlast      ),
    .WUSER   (                       ),
    .WVALID  (axi_req_o.wvalid       ),
    .WREADY  (axi_resp_i.wready      ),

    .BID     (axi_resp_i.b.bid[ID_BUS_WIDTH-1:0]       ),
    .BRESP   (axi_resp_i.b.bresp     ),
    .BUSER   ({BUSER_BUS_WIDTH{1'd0}}),
    .BVALID  (axi_resp_i.bvalid      ),
    .BREADY  (axi_req_o.bready       ),

    .ARID    (axi_req_o.ar.arid[ID_BUS_WIDTH-1:0]      ),
    .ARADDR  (axi_req_o.ar.araddr    ),
    .ARLEN   (axi_req_o.ar.arlen     ),
    .ARSIZE  (axi_req_o.ar.arsize    ),
    .ARBURST (axi_req_o.ar.arburst   ),
    .ARLOCK  (axi_req_o.ar.arlock    ),
    .ARCACHE (axi_req_o.ar.arcache   ),
    .ARPROT  (axi_req_o.ar.arprot    ),
    .ARREGION(                       ),
    .ARQOS   (                       ),
    .ARUSER  (                       ),
    .ARVALID (axi_req_o.arvalid      ),
    .ARREADY (axi_resp_i.arready     ),

    .RID     (axi_resp_i.r.rid[ID_BUS_WIDTH-1:0]       ),
    .RDATA   (axi_resp_i.r.rdata     ),
    .RRESP   (axi_resp_i.r.rresp     ),
    .RLAST   (axi_resp_i.r.rlast     ),
    .RUSER   ({RUSER_BUS_WIDTH{1'd0}}),
    .RVALID  (axi_resp_i.rvalid      ),
    .RREADY  (axi_req_o.rready       )
);





integer ID = 0;
integer OFFSET;
integer BURST_LENGTH = 0;
integer CACHE_TYPE = 4'b0000;
integer PROT_TYPE = 3'b000;
integer QOS_TYPE = 0;
integer AWUSER_TYPE = 0;
integer WUSER_TYPE = 0;
integer ARUSER_TYPE = 0;
integer REGION_TYPE = 0;
logic current_function_level_info = 1'd1;
logic resp;
logic buser;
logic ruser;

`ifndef SURPRESS_MESSAGE
	`define SURPRESS_MESSAGE 1'd0
	`define ENABLE_MESSAGE 1'd1
`endif

task BFM_WRITE_BURST1;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input integer WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_1_BYTE, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                1, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST1;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [31:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_1_BYTE, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST2;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input integer WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_2_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                2, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST2;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [31:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_2_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST4;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input integer WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_4_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                4, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST4;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [31:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_4_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST8;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [63:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_8_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                8, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST8;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [63:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_8_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST16;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [127:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_16_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                16, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST16;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [127:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_16_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST32;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [255:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_32_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                32, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST32;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [255:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_32_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST64;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [511:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                0, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                64, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST64;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [511:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               0, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST128;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [1023:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                1, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                128, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST128;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [1023:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               1, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST256;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [2047:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                3, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                256, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST256;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [2047:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               3, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST512;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [4095:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                7, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                512, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST512;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [4095:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               7, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST1024;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [8191:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                15, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                1024, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST1024;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [8191:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               15, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST2048;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [16383:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                31, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                2048, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST2048;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [16383:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               31, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST4096;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [32767:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                63, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                4096, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST4096;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [32767:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               63, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST8192;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [65535:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                127, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                8192, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST8192;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [65535:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               127, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask

task BFM_WRITE_BURST16384;
    input integer WRITE_BURST_BASE_ADDRESS;
    input integer WRITE_BURST_OFFSET;
    input [137071:0]  WRITE_BURST_WDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.WRITE_BURST(ID, //ID: Write ID tag
                                WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, //ADDR: Write Address
                                255, //LEN: Burst Length
                                `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                                `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                                `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                                CACHE_TYPE, //CACHE: Cache Type
                                PROT_TYPE, //PROT: Protection Type
                                WRITE_BURST_WDATA, //DATA: Data to send
                                16384, //DATASIZE: The size in bytes of the valid data contained in the input data vector
                                REGION_TYPE,//REGION: Region Identifier
                                QOS_TYPE,//QOS: Quality of Service Signals
                                AWUSER_TYPE,//AWUSER: Address Write User Defined Signals
                                WUSER_TYPE,//WUSER: This is a vector that is created by concatenating all write transfer user signal data together
                                resp,//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]
                                buser);//BUSER: Write Response Channel User Defined Signals

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, WADDR: %h, WDATA: %h", $time, resp, WRITE_BURST_BASE_ADDRESS+WRITE_BURST_OFFSET, WRITE_BURST_WDATA);
          end
    end
endtask

task BFM_READ_BURST16384;
    input integer READ_BURST_BASE_ADDRESS;
    input integer READ_BURST_OFFSET;
    output [1317071:0] READDATA;
    input         function_level_info;
    begin
        u_bfm.set_function_level_info(function_level_info);

        u_bfm.READ_BURST(ID, //ID: Read ID tag
                               READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, //ADDR: Read Address
                               255, //LEN: Burst Length
                               `AXI4_BURST_SIZE_64_BYTES, //SIZE: Burst Size
                               `AXI4_BURST_TYPE_INCR, //BURST: Burst Type
                               `AXI4_LOCK_TYPE_NORMAL, //LOCK: Lock Type
                               CACHE_TYPE, //CACHE: Cache Type
                               PROT_TYPE, //PROT: Protection Type
                               REGION_TYPE,//REGION: Region Identifier
                               QOS_TYPE,//QOS: Quality of Service Signals
                               ARUSER_TYPE,//ARUSER: Address Read User Defined Signals
                               READDATA, //DATA: Valid data transferred by the slave
                               resp,//RESPONSE: This is a vector that is created by concatenating all slave read responses together
                               ruser);//RUSER: This is a vector that is created by concatenating all slave read user signal data together

        if(function_level_info==1'd1)
          begin
            $display("[%0t] [Hardware] VENUS_SoC_CPU: Transaction response: %b, RADDR: %h, RDATA: %h", $time, resp, READ_BURST_BASE_ADDRESS+READ_BURST_OFFSET, READDATA);
          end
    end
endtask






endmodule
