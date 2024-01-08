module dma_fifo
  import axi_pkg::*;
  import dma_pkg::*;
#(
  parameter int SLOTS = `DMA_FIFO_DEPTH,  // 槽的深度
  parameter int WIDTH = `DMA_DATA_WIDTH   // fifo中存储的东西位宽
)(
  input                           clk,
  input                           rstn,
  input                           clear_i,
  input                           write_i, // 写入或读取fifo
  input                           read_i,
  input         [WIDTH-1:0]       data_i,
  output  logic [WIDTH-1:0]       data_o,
  output  logic                   full_o, // 是否满了
  output  logic                   empty_o // 是否空了
);
  // `MSB`: Most Significant Bit 最高有效位
  `define MSB_SLOT  $clog2(SLOTS>1?SLOTS:2)
  typedef logic [`MSB_SLOT:0] msb_t;  // 定义一个能装下SLOT最大数字并空闲一位的结构

  // 真正FIFO中存放数据的寄存器
  logic [SLOTS-1:0] [WIDTH-1:0] fifo_ff;

  msb_t                         write_ptr_ff;      // 读指针寄存器
  msb_t                         read_ptr_ff;       // 写指针寄存器
  msb_t                         next_write_ptr;
  msb_t                         next_read_ptr;

  always_comb begin
    next_read_ptr = read_ptr_ff;
    next_write_ptr = write_ptr_ff;
    if (SLOTS == 1) begin  // 深度 = 1的话装一个就满了
      empty_o = (write_ptr_ff == read_ptr_ff);
      full_o  = (write_ptr_ff[0] != read_ptr_ff[0]);
      data_o  = empty_o ? '0 : fifo_ff[0];
    end
    else begin
      empty_o = (write_ptr_ff == read_ptr_ff);
      full_o  = (write_ptr_ff[`MSB_SLOT-1:0] == read_ptr_ff[`MSB_SLOT-1:0]) &&
                (write_ptr_ff[`MSB_SLOT] != read_ptr_ff[`MSB_SLOT]);
      data_o  = empty_o ? '0 : fifo_ff[read_ptr_ff[`MSB_SLOT-1:0]];
    end

    // 往fifo里面写入数据
    if (write_i && ~full_o)
      next_write_ptr = write_ptr_ff + 'd1;

    // 从fifo里面读出数据
    if (read_i && ~empty_o)
      next_read_ptr = read_ptr_ff + 'd1;

  end

  always_ff @ (posedge clk) begin
    if (~rstn) begin
      write_ptr_ff <= '0;
      read_ptr_ff  <= '0;
    end
    else begin
      if (clear_i) begin
        write_ptr_ff <= '0;
        read_ptr_ff  <= '0;
      end
      else begin
        write_ptr_ff <= next_write_ptr;
        read_ptr_ff <= next_read_ptr;
        if (write_i && ~full_o) begin
          if (SLOTS == 1) begin
            fifo_ff[0] <= data_i;
          end
          else begin
            fifo_ff[write_ptr_ff[`MSB_SLOT-1:0]] <= data_i;
          end
        end
      end
    end
  end

`ifndef NO_ASSERTIONS
  initial begin
    illegal_fifo_slot : assert (2**$clog2(SLOTS) == SLOTS)
    else $error("FIFO Slots must be power of 2");

    min_fifo_size : assert (SLOTS >= 1)
    else $error("FIFO size of SLOTS defined is illegal!");
  end
`endif

endmodule
