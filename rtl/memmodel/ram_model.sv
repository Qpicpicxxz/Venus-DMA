//Copyright 2023 ACE-Lab, Shanghai University
//Create time:2023.3.30 15:12
//

module ram_model import venus_soc_pkg::*; #(
    parameter DATA_WIDTH = 512,
    parameter ACTUAL_DATA_WIDTH = DATA_WIDTH,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH = 8,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    
    parameter IS_ROM = 1'b0,
    parameter [300*8-1:0]ROM_INIT_PATH = "",
    parameter useSMICModel = 0,
    parameter MEMORY_SPACE_START_ADDR = 32'h0000_0000,
    parameter MEMORY_SPACE_END_ADDR   = 32'h0000_FFFF,
    parameter MEMORY_BYTE_SIZE = 32'h0001_0000 //64K -> 16
  ) (
    input  logic clk,
    input  logic rst_n,

    input  axi2mem_req_t  axi2mem_req_i,
    output axi2mem_resp_t axi2mem_resp_o
  );

localparam WORD_WIDTH = STRB_WIDTH;
// localparam WORD_WIDTH = 64;
localparam WORD_SIZE  = DATA_WIDTH/WORD_WIDTH;
// localparam MEMORY_BYTE_SIZE_temp = 4096;
localparam ACTUAL_ADDR_WIDTH = $clog2(MEMORY_BYTE_SIZE/WORD_WIDTH);
// localparam ACTUAL_ADDR_WIDTH = $clog2(MEMORY_BYTE_SIZE_temp/WORD_WIDTH);
// localparam ACTUAL_ADDR_WIDTH = 32;
genvar haps_i;
generate 
    if(IS_ROM==1'd0)
      begin: is_rom_0
        if(useSMICModel == 1)
          begin : use_smic_model_1
            parameter MANUAL_CONFIG = (ACTUAL_DATA_WIDTH == 310 && MEMORY_BYTE_SIZE/WORD_WIDTH == 64) ? "RGFw310d64" : 
                                      (ACTUAL_DATA_WIDTH == 512 && MEMORY_BYTE_SIZE/WORD_WIDTH == 512) ? "RGFw512d512mask" : 
                                      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

            simpledpBRAM_to_asicspRAM_wrapper
            #(
                .WIDTH(ACTUAL_DATA_WIDTH),
                .DEPTH(MEMORY_BYTE_SIZE/WORD_WIDTH),
                .OUTPUT_DELAY(1),
                
                .MANUAL_CONFIG(MANUAL_CONFIG)
            ) simpledpBRAM_to_asicspRAM_wrapper (
                .rst(~rstn),
                
                .clka(clk), 
                .ena(axi2mem_req_i.mem_wr_en), 
                .wea(axi2mem_req_i.mem_wr_en), 
                .strba(axi2mem_req_i.mem_wstrb[ACTUAL_DATA_WIDTH/8-1:0]),
                .addra((ACTUAL_ADDR_WIDTH)'((axi2mem_req_i.mem_waddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH)))), 
                .dina(axi2mem_req_i.mem_wdata[ACTUAL_DATA_WIDTH-1:0]), 
                                        
                .clkb(clk), 
                .enb(axi2mem_req_i.mem_rd_en), 
                .addrb((ACTUAL_ADDR_WIDTH)'((axi2mem_req_i.mem_raddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH)))), 
                .doutb(axi2mem_resp_o.mem_rdata[ACTUAL_DATA_WIDTH-1:0])
            );
          end
        else
          begin : use_smic_model_0
            `ifndef SNPS_HAPS_UNSYNABLE
            logic [DATA_WIDTH-1:0] mem[bit[ADDR_WIDTH-1:0]];
            //logic [7:0] debug_memory_slot [0:63];
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    mem[0] <= $urandom;
                    axi2mem_resp_o.mem_rdata <= 512'd0;
                end else begin
                    for (int i = 0; i < WORD_WIDTH; i = i + 1) begin
                        if (axi2mem_req_i.mem_wr_en & axi2mem_req_i.mem_wstrb[i]) begin
                            mem[(axi2mem_req_i.mem_waddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][WORD_SIZE*i +: WORD_SIZE] = axi2mem_req_i.mem_wdata[WORD_SIZE*i +: WORD_SIZE];
                            //if(axi2mem_req_i.mem_waddr == 32'h8000_c780) begin
                            //    $display("axi2mem_req_i.mem_waddr is %0x , axi2mem_req_i.mem_wdata is %0x , axi2mem_req_i.mem_wstrb is %0x",axi2mem_req_i.mem_waddr,axi2mem_req_i.mem_wdata,axi2mem_req_i.mem_wstrb);
                            //    for(int i=0; i<64;i=i+1) begin
                            //        debug_memory_slot[i] = mem[(axi2mem_req_i.mem_waddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][i*8+:8];
                            //    end
                            //end
                        end
                    end
                    if (axi2mem_req_i.mem_rd_en) begin
                        axi2mem_resp_o.mem_rdata <= mem[(axi2mem_req_i.mem_raddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))];
                    end
                end
            end
            `else
            logic [ACTUAL_ADDR_WIDTH-1:0] haps_rd_addr, haps_wr_addr;
            assign haps_rd_addr = (axi2mem_req_i.mem_raddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH));
            assign haps_wr_addr = (axi2mem_req_i.mem_waddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH));
            for (haps_i = 0; haps_i < WORD_WIDTH; haps_i = haps_i + 1) begin: gen_haps_sdp
                hapsram_singledualport #(
                    .DATA_WIDTH(WORD_SIZE),
                    .ADDR_WIDTH(ACTUAL_ADDR_WIDTH)
                ) u_haps_sdp (
                    .clk    (clk),
                    .rd_en  (axi2mem_req_i.mem_rd_en),
                    .rd_addr(haps_rd_addr),
                    .rd_data(axi2mem_resp_o.mem_rdata[WORD_SIZE*haps_i +: WORD_SIZE]),
                    .wr_en  (axi2mem_req_i.mem_wr_en & axi2mem_req_i.mem_wstrb[haps_i]),
                    .wr_addr(haps_wr_addr),
                    .wr_data(axi2mem_req_i.mem_wdata[WORD_SIZE*haps_i +: WORD_SIZE])
                );
            end: gen_haps_sdp
            `endif
          end
      end
    else
      begin    
        `ifndef SNPS_SYN_UNSYNABLE
        bit [31:0] mem1 [0:(MEMORY_BYTE_SIZE>>2)-1];
        bit [DATA_WIDTH-1:0] mem[0:(MEMORY_BYTE_SIZE>>$clog2(STRB_WIDTH))-1];

        integer FILE;
        integer RET;
        initial begin
            FILE = $fopen(ROM_INIT_PATH,"rb");
            if(FILE == 0)
                begin 
                $display ("can not open the file!"); 
                $stop;
                end
            else
                begin
                RET = $fread(mem1,FILE,0);
                $fclose(FILE);
                end
            for(int i = (MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH));i <= (MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH)) + (MEMORY_BYTE_SIZE>>$clog2(STRB_WIDTH))-1;i++) begin
                mem[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))] = {mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 15][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 15][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 15][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 15][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 14][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 14][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 14][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 14][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 13][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 13][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 13][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 13][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 12][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 12][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 12][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 12][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 11][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 11][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 11][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 11][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 10][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 10][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 10][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 + 10][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  9][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  9][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  9][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  9][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  8][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  8][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  8][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  8][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  7][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  7][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  7][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  7][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  6][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  6][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  6][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  6][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  5][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  5][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  5][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  5][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  4][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  4][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  4][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  4][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  3][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  3][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  3][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  3][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  2][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  2][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  2][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  2][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  1][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  1][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  1][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  1][31:24],
                                                                        mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  0][7:0],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  0][15:8],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  0][23:16],mem1[(i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))) * 16 +  0][31:24]};
                    
                                                      //{mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 0 * 8 + 7 :  0 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 1 * 8 + 7 :  1 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 2 * 8 + 7 :  2 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 3 * 8 + 7 :  3 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 4 * 8 + 7 :  4 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 5 * 8 + 7 :  5 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 6 * 8 + 7 :  6 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 7 * 8 + 7 :  7 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 8 * 8 + 7 :  8 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][ 9 * 8 + 7 :  9 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][10 * 8 + 7 : 10 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][11 * 8 + 7 : 11 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][12 * 8 + 7 : 12 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][13 * 8 + 7 : 13 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][14 * 8 + 7 : 14 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][15 * 8 + 7 : 15 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][16 * 8 + 7 : 16 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][17 * 8 + 7 : 17 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][18 * 8 + 7 : 18 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][19 * 8 + 7 : 19 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][20 * 8 + 7 : 20 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][21 * 8 + 7 : 21 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][22 * 8 + 7 : 22 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][23 * 8 + 7 : 23 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][24 * 8 + 7 : 24 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][25 * 8 + 7 : 25 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][26 * 8 + 7 : 26 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][27 * 8 + 7 : 27 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][28 * 8 + 7 : 28 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][29 * 8 + 7 : 29 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][30 * 8 + 7 : 30 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][31 * 8 + 7 : 31 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][32 * 8 + 7 : 32 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][33 * 8 + 7 : 33 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][34 * 8 + 7 : 34 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][35 * 8 + 7 : 35 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][36 * 8 + 7 : 36 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][37 * 8 + 7 : 37 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][38 * 8 + 7 : 38 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][39 * 8 + 7 : 39 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][40 * 8 + 7 : 40 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][41 * 8 + 7 : 41 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][42 * 8 + 7 : 42 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][43 * 8 + 7 : 43 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][44 * 8 + 7 : 44 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][45 * 8 + 7 : 45 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][46 * 8 + 7 : 46 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][47 * 8 + 7 : 47 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][48 * 8 + 7 : 48 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][49 * 8 + 7 : 49 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][50 * 8 + 7 : 50 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][51 * 8 + 7 : 51 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][52 * 8 + 7 : 52 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][53 * 8 + 7 : 53 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][54 * 8 + 7 : 54 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][55 * 8 + 7 : 55 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][56 * 8 + 7 : 56 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][57 * 8 + 7 : 57 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][58 * 8 + 7 : 58 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][59 * 8 + 7 : 59 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][60 * 8 + 7 : 60 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][61 * 8 + 7 : 61 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][62 * 8 + 7 : 62 * 8],
                                                      // mem1[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][63 * 8 + 7 : 63 * 8]};
                //$display("rom_model_init: %8x : %8x",i<<$clog2(512),mem[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))]);
                //$display("rom_model_init: %8x : %8x",(i<<3)+4,mem[i-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][63:32]);
            end
        end

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                axi2mem_resp_o.mem_rdata <= 512'd0;
            end else begin
                //for (int i = 0; i < WORD_WIDTH; i = i + 1) begin
                //    if (axi2mem_req_i.mem_wr_en & axi2mem_req_i.mem_wstrb[i]) begin
                //        mem[(axi2mem_req_i.mem_waddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))][WORD_SIZE*i +: WORD_SIZE] = axi2mem_req_i.mem_wdata[WORD_SIZE*i +: WORD_SIZE];
                //    end
                //end
                if (axi2mem_req_i.mem_rd_en) begin
                    axi2mem_resp_o.mem_rdata <= mem[(axi2mem_req_i.mem_raddr>>$clog2(STRB_WIDTH))-(MEMORY_SPACE_START_ADDR>>$clog2(STRB_WIDTH))];
                end
            end
        end
        `endif
      end
endgenerate

endmodule
