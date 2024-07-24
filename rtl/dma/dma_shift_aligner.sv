// Streamder：DMA操作中数据流控制，处理数据的读写操作
module dma_shift_aligner
  import venus_soc_pkg::*;
  import dma_pkg::*;
#(
  parameter int DATA_WIDTH = -1,
  parameter int FIFO_DEPTH = -1,
  parameter int OUTPUT_DELAY = -1
) (
  input                        clk,
  input                        rstn,
  input                        clear_i,
  input   logic                dma_go_i,
  input   s_dma_desc_t         dma_desc_i,
  input   s_dma_aligner_req_t  src_info_i,       // head | tail | alen | valid
  input   s_dma_aligner_req_t  dst_info_i,       // head | tail | alen | valid
  input   s_dma_fifo_req_t     axi_if_req_i,   // wr | rd | data_wr | rvalid | rlast | wlast
  output  s_dma_fifo_resp_t    axi_if_resp_o   // data_rd | strb | full | empty
);

  axi_strb_t  strb_z[OUTPUT_DELAY:0];

  localparam StrbWidth = DATA_WIDTH / 8;      // 64
  localparam OffsetWidth = $clog2(StrbWidth); // 6
  // |  iiiivvvv|vvvvvvvv|vvvvvvvv|vvvvviii  |
  // | head mask|----full mask----|tail mask |
  axi_strb_t next_r_head_mask, r_head_mask_ff;
  axi_strb_t next_r_tail_mask, r_tail_mask_ff;
  axi_strb_t next_w_head_mask, w_head_mask_ff;
  axi_strb_t next_w_tail_mask, w_tail_mask_ff;
  bytes_offset_t next_shift_bytes, shift_bytes_ff;

  axi_len_t  next_awlen, awlen_ff;

  always_comb begin: req_reg
    next_r_head_mask = r_head_mask_ff;
    next_r_tail_mask = r_tail_mask_ff;
    next_w_head_mask = w_head_mask_ff;
    next_w_tail_mask = w_tail_mask_ff;
    next_shift_bytes = shift_bytes_ff;
    next_awlen = awlen_ff;

    if (src_info_i.valid) begin
      next_r_head_mask = '1 << src_info_i.head;
      next_r_tail_mask = '1 >> src_info_i.tail;
    end
    if (dst_info_i.valid) begin
      next_w_head_mask = '1 << dst_info_i.head;
      next_w_tail_mask = '1 >> dst_info_i.tail;
      next_awlen = dst_info_i.alen;
    end
    if(dma_go_i) begin
      next_shift_bytes = dma_desc_i.src_addr[OffsetWidth-1:0] - dma_desc_i.dst_addr[OffsetWidth-1:0];
    end

  end: req_reg

  // fifo_in
  // fifo_push
  // fifo_out
  // fifo_pop



  // axi_strb_t data_shift;

  logic [StrbWidth-1:0][7:0] fifo_in;
  axi_strb_t  read_aligned_in_mask;
  axi_strb_t  in_mask;
  logic next_middle_trans, middle_trans_ff;

  assign fifo_in   = {axi_if_req_i.data_wr, axi_if_req_i.data_wr} >> (shift_bytes_ff * 8);
  assign in_mask   = {read_aligned_in_mask, read_aligned_in_mask} >> shift_bytes_ff;

  always_comb begin
    read_aligned_in_mask = '1;
    if ((r_head_mask_ff != '0) && (~middle_trans_ff)) begin
      read_aligned_in_mask = r_head_mask_ff;
    end
    if ((r_tail_mask_ff != '0) && axi_if_req_i.rlast) begin
      read_aligned_in_mask = read_aligned_in_mask & r_tail_mask_ff;
    end
  end

  axi_strb_t fifo_full;
  axi_strb_t fifo_push;
  // logic full;
  logic read;
  always_comb begin
    next_middle_trans = middle_trans_ff;
    // new transfer has started
    if (axi_if_req_i.rvalid & !axi_if_req_i.rlast) begin
      next_middle_trans = 1'b1;
    end else if (axi_if_req_i.rvalid & axi_if_req_i.rlast) begin
      next_middle_trans = 1'b0; // finish read
    end

    axi_if_resp_o.full = |(fifo_full & in_mask);
    read = axi_if_req_i.rvalid && ~axi_if_resp_o.full;
    fifo_push = read ? in_mask : '0;
  end

  axi_strb_t out_mask;
  logic is_first_w;
  logic is_last_w;
  always_comb begin
    out_mask = '1;
    if ((w_head_mask_ff != '0) && (is_first_w)) begin
      out_mask = w_head_mask_ff;
    end
    if ((w_tail_mask_ff != '0) && (is_last_w)) begin
      out_mask = out_mask & w_tail_mask_ff;
    end
  end

  logic [StrbWidth-1:0][7:0] fifo_out;
  axi_strb_t fifo_empty;
  axi_strb_t fifo_pop;
  logic      next_w_cnt_valid, w_cnt_valid_ff;
  logic      pop;
  logic      write_happening;
  logic      ready_to_write;
  logic      first_possible;
  logic      fifo_clean;

  always_comb begin
    next_w_cnt_valid = w_cnt_valid_ff;
    pop = 1'b0;
    fifo_pop = 1'b0;
    write_happening = 1'b0;
    ready_to_write  = 1'b0;
    first_possible  = 1'b0;
    axi_if_resp_o.empty = '0;
    axi_if_resp_o.data_rd = '0;
    is_first_w = 1'b0;
    is_last_w  = 1'b0;
    strb_z[0]  = '0;

    // all elements needed (defined by the mask) are in the buffer and the buffer is non-empty
    ready_to_write = ((~fifo_empty & out_mask) == out_mask) && (fifo_empty != '1);
    first_possible  = ((~fifo_empty & w_head_mask_ff) == w_head_mask_ff) && (fifo_empty != '1);
    fifo_clean = &(fifo_empty);
    write_happening = ready_to_write & axi_if_req_i.rd;
    pop = write_happening;
    fifo_pop = write_happening ? out_mask : '0;
    axi_if_resp_o.empty = ~ready_to_write;
    // if (ready_to_write == 1'b1) begin
    for (int i = 0; i < StrbWidth; i++) begin
      axi_if_resp_o.data_rd[i*8 +: 8] = out_mask[i] ? fifo_out[i] : 8'b0;
    end
    strb_z[0] = out_mask;  // 跟着fifo的延时走？
    // end
    if (awlen_ff == '0) begin
      is_first_w = 1'b1;
      is_last_w  = 1'b1;
    end else begin
      is_first_w = first_possible & ~w_cnt_valid_ff;
      // is_last_w = w_cnt_valid_ff & axi_if_req_i.wlast;
      is_last_w = w_cnt_valid_ff & (axi_if_req_i.beat_counter == awlen_ff - OUTPUT_DELAY);
      if (is_first_w && write_happening) begin
        next_w_cnt_valid = 1'b1;
      end
      if (is_last_w && write_happening) begin
        next_w_cnt_valid = 1'b0;
      end
    end
  end

  for (genvar i = 0; i < StrbWidth; i++) begin : dma_fifo
  fifo_model #(
    .OUTPUT_DELAY(OUTPUT_DELAY),
    .SLOTS(FIFO_DEPTH),
    .WIDTH(8),
    .useSMICModel(0)
  ) u_dma_fifo(
    .clk              (clk),
    .rstn             (rstn),
    .clear_i          (clear_i),
    .write_i          (fifo_push[i]),
    .read_i           (fifo_pop[i]),
    .data_i           (fifo_in[i]),
    .data_o           (fifo_out[i]),
    .full_o           (fifo_full[i]),
    .empty_o          (fifo_empty[i])
  );
  end

  always_ff @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
 r_head_mask_ff  <= '0;
 r_tail_mask_ff  <= '0;
 w_head_mask_ff  <= '0;
 w_tail_mask_ff  <= '0;
 shift_bytes_ff  <= '0;
       awlen_ff  <= '0;
middle_trans_ff  <= '0;
 w_cnt_valid_ff  <= '0;
    end else begin

 r_head_mask_ff <= next_r_head_mask;
 r_tail_mask_ff <= next_r_tail_mask;
 w_head_mask_ff <= next_w_head_mask;
 w_tail_mask_ff <= next_w_tail_mask;
 shift_bytes_ff <= next_shift_bytes;
       awlen_ff <= next_awlen;
middle_trans_ff <= next_middle_trans;
 w_cnt_valid_ff <= next_w_cnt_valid;

    end
  end

 for(genvar i = 0; i < OUTPUT_DELAY; i++)
  begin
    always_ff @ (posedge clk or negedge rstn) begin
      if(~rstn) begin
        strb_z[i + 1] <= '0;
      end
      else begin
        strb_z[i + 1] <= strb_z[i];
      end
    end
  end
  assign axi_if_resp_o.strb = strb_z[OUTPUT_DELAY];


  int dma_debug_data_file;
  initial begin
    dma_debug_data_file = $fopen("./dma_debug_data_file.txt", "wb");
    if (dma_debug_data_file == 0) begin
      $display("Error opening dma_debug_data_file!");
      $stop;//$finish;
    end
  end
  always_ff @(posedge clk or negedge rstn) begin
    if (fifo_push != '0) begin
      $fwrite(dma_debug_data_file, "fifo_in:  %h", fifo_in);
    end
    if (fifo_pop != '0) begin
      $fwrite(dma_debug_data_file, "fifo_out: %h", fifo_out);
    end
  end

endmodule
