/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

// `resetall
`timescale 1ns / 1ps
// `default_nettype none

/*
 * AXI4 RAM
 */
module axi_ram_if #
(
    // Handshake logic with venus VRFs
    parameter VENUS_HANDSHAKE = 0,
	// Only the following region does `VENUS_HANDSHAKE` apply to
	parameter VENUS_VRF_START_ADDR = 0,
	parameter VENUS_VRF_END_ADDR = 0,
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 16,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of ID signal
    parameter ID_WIDTH = 8,
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0,
    parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH)
)
(
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic [ID_WIDTH-1:0]    s_axi_awid,
    input  logic [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic [7:0]             s_axi_awlen,
    input  logic [2:0]             s_axi_awsize,
    input  logic [1:0]             s_axi_awburst,
    input  logic                   s_axi_awlock,
    input  logic [3:0]             s_axi_awcache,
    input  logic [2:0]             s_axi_awprot,
    input  logic                   s_axi_awvalid,
    output logic                   s_axi_awready,
    input  logic [DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic [STRB_WIDTH-1:0]  s_axi_wstrb,
    input  logic                   s_axi_wlast,
    input  logic                   s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic [ID_WIDTH-1:0]    s_axi_bid,
    output logic [1:0]             s_axi_bresp,
    output logic                   s_axi_bvalid,
    input  logic                   s_axi_bready,
    input  logic [ID_WIDTH-1:0]    s_axi_arid,
    input  logic [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  logic [7:0]             s_axi_arlen,
    input  logic [2:0]             s_axi_arsize,
    input  logic [1:0]             s_axi_arburst,
    input  logic                   s_axi_arlock,
    input  logic [3:0]             s_axi_arcache,
    input  logic [2:0]             s_axi_arprot,
    input  logic                   s_axi_arvalid,
    output logic                   s_axi_arready,
    output logic [ID_WIDTH-1:0]    s_axi_rid,
    output logic [DATA_WIDTH-1:0]  s_axi_rdata,
    output logic [1:0]             s_axi_rresp,
    output logic                   s_axi_rlast,
    output logic                   s_axi_rvalid,
    input  logic                   s_axi_rready,

    output logic                        mem_wr_en,
    output logic [STRB_WIDTH-1:0]       mem_wstrb,
    output logic [VALID_ADDR_WIDTH-1:0] mem_waddr,
    output logic [DATA_WIDTH-1:0]       mem_wdata,
    output logic                        mem_rd_en,
    output logic [VALID_ADDR_WIDTH-1:0] mem_raddr,
    input  logic [DATA_WIDTH-1:0]       mem_rdata,
    input  logic                        mem_ready
);

parameter WORD_WIDTH = STRB_WIDTH;
parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH;

// bus width assertions
initial begin
    if (WORD_SIZE * STRB_WIDTH != DATA_WIDTH) begin
        $error("Error: AXI data width not evenly divisble (instance %m)");
        $finish;
    end

    if (2**$clog2(WORD_WIDTH) != WORD_WIDTH) begin
        $error("Error: AXI word width must be even power of two (instance %m)");
        $finish;
    end
end

localparam [0:0]
    READ_STATE_IDLE = 1'd0,
    READ_STATE_BURST = 1'd1;

logic [0:0] read_state_reg, read_state_next;

localparam [1:0]
    WRITE_STATE_IDLE = 2'd0,
    WRITE_STATE_BURST = 2'd1,
    WRITE_STATE_RESP = 2'd2;

logic [1:0] write_state_reg, write_state_next;

//logic mem_wr_en;
//logic mem_rd_en;

logic [ID_WIDTH-1:0] read_id_reg, read_id_next;
logic [ADDR_WIDTH-1:0] read_addr_reg, read_addr_next;
logic [7:0] read_count_reg, read_count_next;
logic [2:0] read_size_reg, read_size_next;
logic [1:0] read_burst_reg, read_burst_next;
logic [ID_WIDTH-1:0] write_id_reg, write_id_next;
logic [ADDR_WIDTH-1:0] write_addr_reg, write_addr_next;
logic [7:0] write_count_reg, write_count_next;
logic [2:0] write_size_reg, write_size_next;
logic [1:0] write_burst_reg, write_burst_next;

logic s_axi_awready_reg, s_axi_awready_next;
logic s_axi_wready_reg, s_axi_wready_next;
logic [ID_WIDTH-1:0] s_axi_bid_reg, s_axi_bid_next;
logic s_axi_bvalid_reg, s_axi_bvalid_next;
logic s_axi_arready_reg, s_axi_arready_next;
logic [ID_WIDTH-1:0] s_axi_rid_reg, s_axi_rid_next;
logic [DATA_WIDTH-1:0] s_axi_rdata_reg;// = {DATA_WIDTH{1'b0}}, s_axi_rdata_next;
logic s_axi_rlast_reg, s_axi_rlast_next;
logic s_axi_rvalid_reg, s_axi_rvalid_next;
logic [ID_WIDTH-1:0] s_axi_rid_pipe_reg;
logic [DATA_WIDTH-1:0] s_axi_rdata_pipe_reg;
logic s_axi_rlast_pipe_reg;
logic s_axi_rvalid_pipe_reg;

// (* RAM_STYLE="BLOCK" *)
//logic [DATA_WIDTH-1:0] mem[(2**VALID_ADDR_WIDTH)-1:0];
`ifndef SNPS_HAPS_UNSYNABLE
logic [DATA_WIDTH-1:0] mem[bit[ADDR_WIDTH-1:0]];
`endif

logic [VALID_ADDR_WIDTH-1:0] s_axi_awaddr_valid;
assign s_axi_awaddr_valid = s_axi_awaddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
logic [VALID_ADDR_WIDTH-1:0] s_axi_araddr_valid;
assign s_axi_araddr_valid = s_axi_araddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
logic [VALID_ADDR_WIDTH-1:0] read_addr_valid;
assign read_addr_valid = read_addr_reg >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
logic [VALID_ADDR_WIDTH-1:0] write_addr_valid;
assign write_addr_valid = write_addr_reg >> (ADDR_WIDTH - VALID_ADDR_WIDTH);

assign s_axi_awready = s_axi_awready_reg;
assign s_axi_wready = s_axi_wready_reg;
assign s_axi_bid = s_axi_bid_reg;
assign s_axi_bresp = 2'b00;
assign s_axi_bvalid = s_axi_bvalid_reg;
assign s_axi_arready = s_axi_arready_reg;
assign s_axi_rid = PIPELINE_OUTPUT ? s_axi_rid_pipe_reg : s_axi_rid_reg;
assign s_axi_rdata = PIPELINE_OUTPUT ? s_axi_rdata_pipe_reg : s_axi_rdata_reg;
assign s_axi_rresp = 2'b00;
assign s_axi_rlast = PIPELINE_OUTPUT ? s_axi_rlast_pipe_reg : s_axi_rlast_reg;
assign s_axi_rvalid = PIPELINE_OUTPUT ? s_axi_rvalid_pipe_reg : s_axi_rvalid_reg;

integer i, j;

//initial begin
//    // two nested loops for smaller number of iterations per loop
//    // workaround for synthesizer complaints about large loop counts
//    for (i = 0; i < 2**VALID_ADDR_WIDTH; i = i + 2**(VALID_ADDR_WIDTH/2)) begin
//        for (j = i; j < i + 2**(VALID_ADDR_WIDTH/2); j = j + 1) begin
//            mem[j] = 0;
//        end
//    end
//end

logic write_size_sel;
logic [2:0] strb_width_clog2;
assign strb_width_clog2 = $clog2(STRB_WIDTH);
assign write_size_sel = (s_axi_awsize < strb_width_clog2);

always_comb begin
    write_state_next = WRITE_STATE_IDLE;

    mem_wr_en = 1'b0;

    write_id_next = write_id_reg;
    write_addr_next = write_addr_reg;
    write_count_next = write_count_reg;
    write_size_next = write_size_reg;
    write_burst_next = write_burst_reg;

    s_axi_awready_next = 1'b0;
    s_axi_wready_next = 1'b0;
    s_axi_bid_next = s_axi_bid_reg;
    s_axi_bvalid_next = s_axi_bvalid_reg && !s_axi_bready;

    case (write_state_reg)
        WRITE_STATE_IDLE: begin
            s_axi_awready_next = 1'b1;

            if (s_axi_awready && s_axi_awvalid) begin
                write_id_next = s_axi_awid;
                write_addr_next = s_axi_awaddr;
                write_count_next = s_axi_awlen;
                write_size_next = (write_size_sel) ? s_axi_awsize : strb_width_clog2;
                write_burst_next = s_axi_awburst;

                s_axi_awready_next = 1'b0;
                s_axi_wready_next = 1'b1;
                write_state_next = WRITE_STATE_BURST;
            end else begin
                write_state_next = WRITE_STATE_IDLE;
            end
        end
        WRITE_STATE_BURST: begin
        	if (VENUS_HANDSHAKE) begin
				if ((write_addr_next[ADDR_WIDTH-1:12] >= VENUS_VRF_START_ADDR[ADDR_WIDTH-1:12]) &&
					(write_addr_next[ADDR_WIDTH-1:12] <  VENUS_VRF_END_ADDR[ADDR_WIDTH-1:12]))
					s_axi_wready_next = !s_axi_wready_reg & mem_ready;
				else
					s_axi_wready_next = 1'b1;
			end else begin
				s_axi_wready_next = 1'b1;
			end

            if (s_axi_wready && s_axi_wvalid) begin
                mem_wr_en = 1'b1;
                if (write_burst_reg != 2'b00) begin
                    write_addr_next = write_addr_reg + (1 << write_size_reg);
                end
                write_count_next = write_count_reg - 1;
                if (write_count_reg > 0) begin
                    write_state_next = WRITE_STATE_BURST;
                end else begin
                    s_axi_wready_next = 1'b0;
                    if (s_axi_bready || !s_axi_bvalid) begin
                        s_axi_bid_next = write_id_reg;
                        s_axi_bvalid_next = 1'b1;
                        s_axi_awready_next = 1'b1;
                        write_state_next = WRITE_STATE_IDLE;
                    end else begin
                        write_state_next = WRITE_STATE_RESP;
                    end
                end
            end else begin
                write_state_next = WRITE_STATE_BURST;
            end
        end
        WRITE_STATE_RESP: begin
            if (s_axi_bready || !s_axi_bvalid) begin
                s_axi_bid_next = write_id_reg;
                s_axi_bvalid_next = 1'b1;
                s_axi_awready_next = 1'b1;
                write_state_next = WRITE_STATE_IDLE;
            end else begin
                write_state_next = WRITE_STATE_RESP;
            end
        end
    endcase
end


assign mem_wstrb = s_axi_wstrb;
assign mem_waddr = write_addr_valid;
assign mem_wdata = s_axi_wdata;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_state_reg <= WRITE_STATE_IDLE;

        // `ifdef SNPS_HAPS_UNSYNABLE
        write_id_reg <= {ID_WIDTH{1'b0}};
        write_addr_reg <= {ADDR_WIDTH{1'b0}};
        write_count_reg <= 8'd0;
        write_size_reg <= 3'd0;
        write_burst_reg <= 2'd0;

        s_axi_bid_reg <= {ID_WIDTH{1'b0}};
        // `endif

        s_axi_awready_reg <= 1'b0;
        s_axi_wready_reg <= 1'b0;
        s_axi_bvalid_reg <= 1'b0;
    end else begin
        write_state_reg <= write_state_next;

        write_id_reg <= write_id_next;
        write_addr_reg <= write_addr_next;
        write_count_reg <= write_count_next;
        write_size_reg <= write_size_next;
        write_burst_reg <= write_burst_next;

        s_axi_awready_reg <= s_axi_awready_next;
        s_axi_wready_reg <= s_axi_wready_next;
        s_axi_bid_reg <= s_axi_bid_next;
        s_axi_bvalid_reg <= s_axi_bvalid_next;

        //for (i = 0; i < WORD_WIDTH; i = i + 1) begin
        //    if (mem_wr_en & s_axi_wstrb[i]) begin
        //        mem[write_addr_valid][WORD_SIZE*i +: WORD_SIZE] = s_axi_wdata[WORD_SIZE*i +: WORD_SIZE];
        //    end
        //end
    end
end

logic read_size_sel;
assign read_size_sel = (s_axi_arsize < strb_width_clog2);
logic venus_read_sel;

always_comb begin
    mem_rd_en = 1'b0;

    s_axi_rid_next = s_axi_rid_reg;
    s_axi_rlast_next = s_axi_rlast_reg;
    s_axi_rvalid_next = s_axi_rvalid_reg && !(s_axi_rready || (PIPELINE_OUTPUT && !s_axi_rvalid_pipe_reg));

    read_id_next = read_id_reg;
    read_addr_next = read_addr_reg;
    read_count_next = read_count_reg;
    read_size_next = read_size_reg;
    read_burst_next = read_burst_reg;

    s_axi_arready_next = 1'b0;
    
	if (VENUS_HANDSHAKE) begin
		read_state_next = read_state_reg;
		if ((read_addr_next[ADDR_WIDTH-1:12] >= VENUS_VRF_START_ADDR[ADDR_WIDTH-1:12]) &&
		    (read_addr_next[ADDR_WIDTH-1:12] <  VENUS_VRF_END_ADDR[ADDR_WIDTH-1:12]))
		    venus_read_sel = !s_axi_rvalid_reg & mem_ready;
		else
			venus_read_sel = 1'b1;
	end else begin
		read_state_next = READ_STATE_IDLE;
		venus_read_sel = 1'b1;
	end

    case (read_state_reg)
        READ_STATE_IDLE: begin
            s_axi_arready_next = 1'b1;

            if (s_axi_arready && s_axi_arvalid) begin
                read_id_next = s_axi_arid;
                read_addr_next = s_axi_araddr;
                read_count_next = s_axi_arlen;
                read_size_next = (read_size_sel) ? s_axi_arsize : strb_width_clog2;
                read_burst_next = s_axi_arburst;

                s_axi_arready_next = 1'b0;
                read_state_next = READ_STATE_BURST;
            end else begin
                read_state_next = READ_STATE_IDLE;
            end
        end
        READ_STATE_BURST: begin
            if (s_axi_rready || (PIPELINE_OUTPUT && !s_axi_rvalid_pipe_reg) || !s_axi_rvalid_reg) begin
                mem_rd_en = 1'b1;
                s_axi_rvalid_next = venus_read_sel;
                s_axi_rid_next = read_id_reg;
                s_axi_rlast_next = read_count_reg == 0;
                if (venus_read_sel) begin
                    if (read_burst_reg != 2'b00) begin
                        read_addr_next = read_addr_reg + (1 << read_size_reg);
                    end
                    read_count_next = read_count_reg - 1;
                    if (read_count_reg > 0) begin
                        read_state_next = READ_STATE_BURST;
                    end else begin
                        s_axi_arready_next = 1'b1;
                        read_state_next = READ_STATE_IDLE;
                    end
                end
            end else begin
                read_state_next = READ_STATE_BURST;
            end
        end
    endcase
end

assign s_axi_rdata_reg = mem_rdata;
assign mem_raddr = read_addr_valid;

always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        read_state_reg <= READ_STATE_IDLE;

        // `ifdef SNPS_HAPS_UNSYNABLE
        read_id_reg <= {ID_WIDTH{1'b0}};
        read_addr_reg <= {ADDR_WIDTH{1'b0}};
        read_count_reg <= 8'd0;
        read_size_reg <= 3'd0;
        read_burst_reg <= 2'd0;

        s_axi_rid_reg <= {ID_WIDTH{1'b0}};
        s_axi_rlast_reg <= 1'b0;

        s_axi_rid_pipe_reg <= {ID_WIDTH{1'b0}};
        s_axi_rdata_pipe_reg <= {DATA_WIDTH{1'b0}};
        s_axi_rlast_pipe_reg <= 1'b0;
        // `endif

        s_axi_arready_reg <= 1'b0;
        s_axi_rvalid_reg <= 1'b0;
        s_axi_rvalid_pipe_reg <= 1'b0;
    end else begin
        read_state_reg <= read_state_next;

        read_id_reg <= read_id_next;
        read_addr_reg <= read_addr_next;
        read_count_reg <= read_count_next;
        read_size_reg <= read_size_next;
        read_burst_reg <= read_burst_next;

        s_axi_arready_reg <= s_axi_arready_next;
        s_axi_rid_reg <= s_axi_rid_next;
        s_axi_rlast_reg <= s_axi_rlast_next;
        s_axi_rvalid_reg <= s_axi_rvalid_next;

        //if (mem_rd_en) begin
        //    s_axi_rdata_reg <= mem[read_addr_valid];
        //end

        if (!s_axi_rvalid_pipe_reg || s_axi_rready) begin
            s_axi_rid_pipe_reg <= s_axi_rid_reg;
            s_axi_rdata_pipe_reg <= s_axi_rdata_reg;
            s_axi_rlast_pipe_reg <= s_axi_rlast_reg;
            s_axi_rvalid_pipe_reg <= s_axi_rvalid_reg;
        end
    end
end

endmodule

// `resetall
