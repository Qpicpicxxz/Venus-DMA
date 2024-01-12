//Copyright 2023 ACE-Lab, Shanghai University
//Create time:2023.2.18 14:21
//

module axi4_memory_wrapper import venus_soc_pkg::*; #(
    parameter useSMICModel = 1,
    parameter DATA_WIDTH = 64,   // data bus width in bits, default = 64
    parameter ADDRESS_WIDTH = 32,
    // Define the number of channel ID bits required
    parameter ID_WIDTH   = 4,    // ID width in bits, default = 4
    // Define if the module is to include a wait state for reads
    parameter NUM_RD_WS = 1'b0,  // set to number of wait states required
    // Define if the module is to interface to RAM or ROM
    parameter IS_ROM = 1'b0,     // set to 1'b1 to interface to ROM,
                                // set to 1'b0 to interface to RAM
    parameter [300*8-1:0]ROM_INIT_PATH = "",
    parameter MEMORY_NAME = "MEMORY",
    parameter MEMORY_SPACE_START_ADDR = 32'h0000_0000,
    parameter MEMORY_SPACE_END_ADDR   = 32'h0000_FFFF,
    parameter MEMORY_BYTE_SIZE = 32'h0001_0000 //64K -> 16

  ) (
    input logic aclk,
    input logic aresetn,

    input  axi_req_t  axi_req_i ,
    output axi_resp_t axi_resp_o
  );

parameter MEMORY_WIDTH = $clog2(MEMORY_BYTE_SIZE);
parameter ALLOC_WIDTH = $clog2(MEMORY_BYTE_SIZE/(DATA_WIDTH/8));


generate
    if(useSMICModel == 0)
        begin
            /*logic        memory_cen;
            logic [(DATA_WIDTH / 8 - 1) : 0] memory_wen;
            logic [ADDRESS_WIDTH - 1 : 0] memory_addr;

            IntMemAxi #(.DATA_WIDTH (DATA_WIDTH), .ID_WIDTH (ID_WIDTH), .NUM_RD_WS (NUM_RD_WS), .IS_ROM (IS_ROM))
            u_memctl (
                .ACLK    (aclk),
                .ARESETn (aresetn),

                .AWID    (axi_req_i.aw.awid[ID_WIDTH-1:0]    ),
                .AWADDR  (axi_req_i.aw.awaddr                ),
                .AWLEN   (axi_req_i.aw.awlen[3:0]            ),
                .AWSIZE  (axi_req_i.aw.awsize                ),
                .AWBURST (axi_req_i.aw.awburst               ),
                .AWVALID (axi_req_i.awvalid                  ),
                .AWREADY (axi_resp_o.awready                 ),

                .WSTRB   (axi_req_i.w.wstrb                  ),
                .WLAST   (axi_req_i.w.wlast                  ),
                .WVALID  (axi_req_i.wvalid                   ),
                .WREADY  (axi_resp_o.wready                  ),

                .BID     (axi_resp_o.b.bid[ID_WIDTH-1:0]     ),
                .BRESP   (axi_resp_o.b.bresp                 ),
                .BVALID  (axi_resp_o.bvalid                  ),
                .BREADY  (axi_req_i.bready                   ),

                .ARID    (axi_req_i.ar.arid[ID_WIDTH-1:0]    ),
                .ARADDR  (axi_req_i.ar.araddr                ),
                .ARLEN   (axi_req_i.ar.arlen[3:0]            ),
                .ARSIZE  (axi_req_i.ar.arsize                ),
                .ARBURST (axi_req_i.ar.arburst               ),
                .ARVALID (axi_req_i.arvalid                  ),
                .ARREADY (axi_resp_o.arready                 ),

                .RID     (axi_resp_o.r.rid[ID_WIDTH-1:0]     ),
                .RRESP   (axi_resp_o.r.rresp                 ),
                .RLAST   (axi_resp_o.r.rlast                 ),
                .RVALID  (axi_resp_o.rvalid                  ),
                .RREADY  (axi_req_i.rready                   ),

                .MEMCEn                     (memory_cen),
                .MEMWEn                     (memory_wen[(DATA_WIDTH / 8 - 1) : 0]),
                .MEMADDR                    (memory_addr[ADDRESS_WIDTH - 1 : 0]),
                .SCANOUTACLK                (), // scan chain output (ACLK domain)
                .SCANENABLE                 (1'b0), // scan test mode enable
                .SCANINACLK                 (1'b0) // scan chain input (ACLK domain)
            );

            memory #(.MemoryName   (MEMORY_NAME),
                    .ZeroWriteWait (1),
                    .InitMem       (0),
                    .DataWidth     (DATA_WIDTH),
                    .AllocWidth    (ALLOC_WIDTH),  //16-3
                    .MemBase       (MEMORY_SPACE_START_ADDR),
                    .MemTop        (MEMORY_SPACE_END_ADDR)
                    )
            u_memory_rom (.clk   (aclk),
                          .clken (1'd1),
                          .nCS   (memory_cen),
                          .nWE   (memory_wen[(DATA_WIDTH / 8 - 1) : 0]),
                          .A     (memory_addr[ADDRESS_WIDTH - 1 : MEMORY_WIDTH - ALLOC_WIDTH]),
                          .Din   (axi_req_i.w.wdata[DATA_WIDTH - 1 : 0]),
                          .Dout  (axi_resp_o.r.rdata[DATA_WIDTH - 1 : 0])
                    );*/

            axi2mem_req_t  axi2mem_req;
            axi2mem_resp_t axi2mem_resp;

            axi_ram_if_wrapper #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDRESS_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .PIPELINE_OUTPUT(0)
            ) u_axi_ram_if_wrapper (
                .aclk                 (aclk      ),
                .aresetn              (aresetn   ),

                .axi_req_i            (axi_req_i ),
                .axi_resp_o           (axi_resp_o),

                .axi2mem_req_o        (axi2mem_req ),
                .axi2mem_resp_i       (axi2mem_resp)
            );

            ram_model #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDRESS_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .IS_ROM(IS_ROM),
                .ROM_INIT_PATH(ROM_INIT_PATH),

                .useSMICModel(useSMICModel),
                .MEMORY_SPACE_START_ADDR(MEMORY_SPACE_START_ADDR),
                .MEMORY_SPACE_END_ADDR(MEMORY_SPACE_END_ADDR),
                .MEMORY_BYTE_SIZE(MEMORY_BYTE_SIZE) //64K -> 16
            ) u_ram_model (
                .clk                  (aclk     ),
                .rst_n                (aresetn  ),

                .axi2mem_req_i        (axi2mem_req ),
                .axi2mem_resp_o       (axi2mem_resp)
            );

        end
endgenerate

if(ADDRESS_WIDTH != 32)
    $error("IP IntMemAxi does not support any address width except 32!");


endmodule:axi4_memory_wrapper
