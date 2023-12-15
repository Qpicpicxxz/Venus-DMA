//Copyright 2023 ACE-Lab, Shanghai University
//Create time:2023.3.30 15:12
//

module ram_model import axi_pkg::*; #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH = 8,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH),

    parameter IS_ROM = 1'b0,
    parameter [300*8-1:0]ROM_INIT_PATH = "",

    parameter useSMICModel = 1,
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
localparam WORD_SIZE  = DATA_WIDTH/WORD_WIDTH;

generate
    if(IS_ROM==1'd0)
      begin
        logic [DATA_WIDTH-1:0] mem[bit[ADDR_WIDTH-1:0]];

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                axi2mem_resp_o.mem_rdata <= 64'd0;
            end else begin
                for (int i = 0; i < WORD_WIDTH; i = i + 1) begin
                    if (axi2mem_req_i.mem_wr_en & axi2mem_req_i.mem_wstrb[i]) begin
                        mem[(axi2mem_req_i.mem_waddr>>3)-(MEMORY_SPACE_START_ADDR>>3)][WORD_SIZE*i +: WORD_SIZE] = axi2mem_req_i.mem_wdata[WORD_SIZE*i +: WORD_SIZE];
                    end
                end
                if (axi2mem_req_i.mem_rd_en) begin
                    axi2mem_resp_o.mem_rdata <= mem[(axi2mem_req_i.mem_raddr>>3)-(MEMORY_SPACE_START_ADDR>>3)];
                end
            end
        end
      end
    else
      begin
        bit [DATA_WIDTH-1:0] mem[0:(MEMORY_BYTE_SIZE>>3)-1];

        integer FILE;
        integer RET;
        initial begin
            FILE = $fopen(ROM_INIT_PATH,"rb");
            if(FILE == 0)
                begin
                $display ("can not open the file!");
                $stop;
                end
            RET = $fread(mem,FILE,0);
            $fclose(FILE);

            for(int i = (MEMORY_SPACE_START_ADDR>>3);i <= (MEMORY_SPACE_START_ADDR>>3) + (MEMORY_BYTE_SIZE>>3)-1;i++) begin
                mem[i-(MEMORY_SPACE_START_ADDR>>3)] = {mem[i-(MEMORY_SPACE_START_ADDR>>3)][7:0],mem[i-(MEMORY_SPACE_START_ADDR>>3)][15:8],mem[i-(MEMORY_SPACE_START_ADDR>>3)][23:16],mem[i-(MEMORY_SPACE_START_ADDR>>3)][31:24],mem[i-(MEMORY_SPACE_START_ADDR>>3)][39:32],mem[i-(MEMORY_SPACE_START_ADDR>>3)][47:40],mem[i-(MEMORY_SPACE_START_ADDR>>3)][55:48],mem[i-(MEMORY_SPACE_START_ADDR>>3)][63:56]};
                //$display("rom_model_init: %8x : %8x",i<<3,mem[i-(MEMORY_SPACE_START_ADDR>>3)][31:0]);
                //$display("rom_model_init: %8x : %8x",(i<<3)+4,mem[i-(MEMORY_SPACE_START_ADDR>>3)][63:32]);
            end
        end

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                axi2mem_resp_o.mem_rdata <= 64'd0;
            end else begin
                //for (int i = 0; i < WORD_WIDTH; i = i + 1) begin
                //    if (axi2mem_req_i.mem_wr_en & axi2mem_req_i.mem_wstrb[i]) begin
                //        mem[(axi2mem_req_i.mem_waddr>>3)-(MEMORY_SPACE_START_ADDR>>3)][WORD_SIZE*i +: WORD_SIZE] = axi2mem_req_i.mem_wdata[WORD_SIZE*i +: WORD_SIZE];
                //    end
                //end
                if (axi2mem_req_i.mem_rd_en) begin
                    axi2mem_resp_o.mem_rdata <= mem[(axi2mem_req_i.mem_raddr>>3)-(MEMORY_SPACE_START_ADDR>>3)];
                end
            end
        end
      end
endgenerate

endmodule
