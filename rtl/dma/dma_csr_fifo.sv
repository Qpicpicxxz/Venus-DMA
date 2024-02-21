module dma_csr_fifo
  import venus_soc_pkg::*;
  import dma_pkg::*;
#(
  parameter int DEPTH = 32,
  // data input = {SRC,DST,LEN,last}, length = 32bit * 3 + 1 = 97bit
  parameter int WIDTH = 97,
  parameter int OUTPUT_DELAY = 1
)(
  input                 clk,
  input                 rstn,
  input                 dma_fifo_write_i,
  input                 dma_fifo_read_i,
  input                 dma_fifo_last_i,
  input  s_dma_desc_t   dma_fifo_desc_i,
  output s_dma_desc_t   dma_fifo_desc_o,
  output logic          dma_fifo_last_o,
  output logic          dma_fifo_full_o,
  output logic          dma_fifo_empty_o
);

  logic [DEPTH-1:0] [WIDTH-1:0] fifo_ff;

  logic [WIDTH-1:0]    data_i;
  logic [WIDTH-1:0]    data_z[OUTPUT_DELAY:0];

  assign data_i = {dma_fifo_desc_i,dma_fifo_last_i};
  assign dma_fifo_desc_o = data_z[OUTPUT_DELAY][WIDTH-1:1];
  assign dma_fifo_last_o = data_z[OUTPUT_DELAY][0];

  `define MSB_DEPTH  $clog2(DEPTH)

  logic [`MSB_DEPTH:0]  write_ptr_ff;
  logic [`MSB_DEPTH:0]  read_ptr_ff;
  logic [`MSB_DEPTH:0]  next_write_ptr;
  logic [`MSB_DEPTH:0]  next_read_ptr;

  always_comb begin
    next_read_ptr    = read_ptr_ff;
    next_write_ptr   = write_ptr_ff;
    dma_fifo_empty_o = (write_ptr_ff == read_ptr_ff);
    dma_fifo_full_o  = (write_ptr_ff[`MSB_DEPTH-1:0] == read_ptr_ff[`MSB_DEPTH-1:0]) && (write_ptr_ff[`MSB_DEPTH] != read_ptr_ff[`MSB_DEPTH]);
    data_z[0]        = dma_fifo_empty_o ? '0 : fifo_ff[read_ptr_ff[`MSB_DEPTH-1:0]];

    // 往fifo里面写入数据
    if (dma_fifo_write_i && ~dma_fifo_full_o)
      next_write_ptr = write_ptr_ff + 'd1;

    // 从fifo里面读出数据
    if (dma_fifo_read_i && ~dma_fifo_empty_o)
      next_read_ptr = read_ptr_ff + 'd1;
  end

  always_ff @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      write_ptr_ff <= '0;
      read_ptr_ff  <= '0;
    end
    else begin
      write_ptr_ff <= next_write_ptr;
      read_ptr_ff  <= next_read_ptr;
      if (dma_fifo_write_i && ~dma_fifo_full_o) begin
          fifo_ff[write_ptr_ff[`MSB_DEPTH-1:0]] <= data_i;
      end
    end
  end

for(genvar i = 0; i < OUTPUT_DELAY; i++)
  begin
    always_ff @ (posedge clk or negedge rstn) begin
      if(~rstn) begin
        data_z[i + 1] <= '0;
      end
      else begin
        data_z[i + 1] <= data_z[i];
      end
    end
  end
assign data_o = data_z[OUTPUT_DELAY];

`ifndef NO_ASSERTIONS
  initial begin
    illegal_fifo_slot : assert (2**$clog2(DEPTH) == DEPTH)
    else $error("FIFO DEPTH must be power of 2");

    min_fifo_size : assert (DEPTH >= 1)
    else $error("FIFO size of DEPTH defined is illegal!");
  end
`endif

endmodule