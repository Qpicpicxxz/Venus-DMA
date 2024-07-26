module fifo_model
  import venus_soc_pkg::*;
#(
  parameter int SLOTS = 128,  // 槽的深度
  parameter int WIDTH = 128,  // fifo中存储的东西位宽
  parameter int OUTPUT_DELAY = 1,

  parameter useSMICModel = 0
)(
  input                      clk,
  input                      rstn,
  input                      clear_i,
  input                      write_i, // 写入或读取fifo
  input                      read_i,
  input         [WIDTH-1:0]  data_i,
  output  logic [WIDTH-1:0]  data_o,
  output  logic              full_o, // 是否满了
  output  logic              empty_o // 是否空了
);

generate
  if(useSMICModel == 1)
    begin
      parameter MANUAL_CONFIG = (WIDTH == 512 && SLOTS == 256) ? "SRAMdpw512d256" :
                                "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
      commonclkBRAMfifo_to_asicfifo_wrapper
      #(
          .WIDTH        (WIDTH),
          .DEPTH        (SLOTS),
          .OUTPUT_DELAY (1),
          .MANUAL_CONFIG(MANUAL_CONFIG)
      )u_sram_w512d256_fifo(
          .clk(clk),
          .srst(~rstn),
          .din(data_i),
          .wr_en(write_i),
          .rd_en(read_i),
          .dout(data_o),
          .full(full_o),
          .empty(empty_o),
          .data_count(),
          .almost_full(),
          .almost_empty(),
          .half_full()
      );
    end
  else
    begin
      logic [WIDTH-1:0]       data_z[OUTPUT_DELAY:0];

      // `MSB`: Most Significant Bit 最高有效位
      `define MSB_SLOT  $clog2(SLOTS>1?SLOTS:2)
      typedef logic [`MSB_SLOT:0] msb_t;  // 定义一个能装下SLOT最大数字并空闲一位的结构

      // 真正FIFO中存放数据的寄存器
      logic [SLOTS-1:0] [WIDTH-1:0] fifo_ff;

      msb_t write_ptr_ff;      // 读指针寄存器
      msb_t read_ptr_ff;       // 写指针寄存器
      msb_t next_write_ptr;
      msb_t next_read_ptr;

      always_comb begin
        next_read_ptr  = read_ptr_ff;
        next_write_ptr = write_ptr_ff;
        if (SLOTS == 1) begin  // 深度 = 1的话装一个就满了
          empty_o   = (write_ptr_ff == read_ptr_ff);
          full_o    = (write_ptr_ff[0] != read_ptr_ff[0]);
          data_z[0] = empty_o ? '0 : fifo_ff[0];
        end
        else begin
          empty_o   = (write_ptr_ff == read_ptr_ff);
          full_o    = (write_ptr_ff[`MSB_SLOT-1:0] == read_ptr_ff[`MSB_SLOT-1:0]) &&
                      (write_ptr_ff[`MSB_SLOT] != read_ptr_ff[`MSB_SLOT]);
          data_z[0] = empty_o ? '0 : fifo_ff[read_ptr_ff[`MSB_SLOT-1:0]];
        end
        // 往fifo里面写入数据
        if (write_i && ~full_o)
          next_write_ptr = write_ptr_ff + 'd1;
        // 从fifo里面读出数据
        if (read_i && ~empty_o)
          next_read_ptr = read_ptr_ff + 'd1;
      end

      always_ff @ (posedge clk or negedge rstn) begin
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
            read_ptr_ff  <= next_read_ptr;
            if (write_i && ~full_o) begin
                fifo_ff[write_ptr_ff[`MSB_SLOT-1:0]] <= data_i;
            end
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
    end
endgenerate

endmodule
