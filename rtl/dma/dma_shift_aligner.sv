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
  input   logic                dma_go_i,
  input   s_dma_desc_t         dma_desc_i,
  input                        dma_clear_i,
  input   s_dma_align_req_t    dma_src_info_i,       // head | tail | alen | valid
  input   s_dma_align_req_t    dma_dst_info_i,       // head | tail | alen | valid
  input   s_dma_axi_req_t      dma_axi_if_req_i,     // wr | rd | data_wr | rvalid | rlast | beat_counter
  output  s_dma_axi_resp_t     dma_axi_if_resp_o     // data_rd | strb | full | empty
);

  axi_strb_t  strb_z[OUTPUT_DELAY:0];

  localparam StrbWidth = DATA_WIDTH / 8;      // 64
  localparam OffsetWidth = $clog2(StrbWidth); // 6

  /* |  iiiivvvv|vvvvvvvv|vvvvvvvv|vvvvviii  |
   * | head mask|----full mask----|tail mask | */
  axi_strb_t next_r_head_mask, r_head_mask_ff;
  axi_strb_t next_r_tail_mask, r_tail_mask_ff;
  axi_strb_t next_w_head_mask, w_head_mask_ff;
  axi_strb_t next_w_tail_mask, w_tail_mask_ff;
  axi_len_t  next_awlen, awlen_ff;
  bytes_offset_t next_shift_bytes, shift_bytes_ff;

  logic  next_middle_rd_trans, middle_rd_trans_ff;
  logic  next_middle_wr_trans, middle_wr_trans_ff;

  axi_strb_t  cur_read_mask;
  axi_strb_t  in_mask;
  axi_strb_t  out_mask;

  axi_strb_t fifo_wr;
  axi_strb_t fifo_rd;
  axi_strb_t fifo_full;
  axi_strb_t fifo_empty;

  logic  axi_rready;
  logic  axi_wvalid;
  logic  is_first_w;
  logic  is_last_w;
  logic  wr_hpn;
  logic  first_w_ready;

  logic [StrbWidth-1:0][7:0] fifo_in;
  logic [StrbWidth-1:0][7:0] fifo_out;
  assign fifo_in   = {dma_axi_if_req_i.data_wr, dma_axi_if_req_i.data_wr} >> (shift_bytes_ff * 8);

  always_comb begin: req_reg
    next_r_head_mask = r_head_mask_ff;
    next_r_tail_mask = r_tail_mask_ff;
    next_w_head_mask = w_head_mask_ff;
    next_w_tail_mask = w_tail_mask_ff;
    next_shift_bytes = shift_bytes_ff;
    next_awlen = awlen_ff;

    if (dma_src_info_i.valid) begin
      next_r_head_mask = '1 << dma_src_info_i.head;
      next_r_tail_mask = '1 >> dma_src_info_i.tail;
    end
    if (dma_dst_info_i.valid) begin
      next_w_head_mask = '1 << dma_dst_info_i.head;
      next_w_tail_mask = '1 >> dma_dst_info_i.tail;
      next_awlen       = dma_dst_info_i.alen;
    end
    if(dma_go_i) begin
      next_shift_bytes = dma_desc_i.src_addr[OffsetWidth-1:0] - dma_desc_i.dst_addr[OffsetWidth-1:0];
    end

  end: req_reg

  always_comb begin: mask_generate
    cur_read_mask = '1;
    out_mask = '1;

    if ((r_head_mask_ff != '0) && (~middle_rd_trans_ff)) begin
      cur_read_mask = r_head_mask_ff;
    end
    if ((r_tail_mask_ff != '0) && dma_axi_if_req_i.rlast) begin
      cur_read_mask = cur_read_mask & r_tail_mask_ff;
    end
    in_mask   = {cur_read_mask, cur_read_mask} >> shift_bytes_ff;

    if ((w_head_mask_ff != '0) && (is_first_w)) begin
      out_mask = w_head_mask_ff;
    end
    if ((w_tail_mask_ff != '0) && (is_last_w)) begin
      out_mask = out_mask & w_tail_mask_ff;
    end
  end: mask_generate

  always_comb begin: read_proc
    next_middle_rd_trans = middle_rd_trans_ff;

    if (dma_axi_if_req_i.rvalid & !dma_axi_if_req_i.rlast) begin
      next_middle_rd_trans = 1'b1; // new transfer has started
    end else if (dma_axi_if_req_i.rvalid & dma_axi_if_req_i.rlast) begin
      next_middle_rd_trans = 1'b0; // finish read
    end

    dma_axi_if_resp_o.full = |(fifo_full & in_mask);
    axi_rready = dma_axi_if_req_i.rvalid && ~dma_axi_if_resp_o.full;
    fifo_wr = axi_rready ? in_mask : '0;
  end: read_proc

  always_comb begin
    next_middle_wr_trans      = middle_wr_trans_ff;
    fifo_rd                   = 1'b0;
    wr_hpn                    = 1'b0;
    axi_wvalid                = 1'b0;
    first_w_ready             = 1'b0;
    is_first_w                = 1'b0;
    is_last_w                 = 1'b0;
    strb_z[0]                 = '0;
    dma_axi_if_resp_o.empty   = '0;
    dma_axi_if_resp_o.data_rd = '0;

    // all elements needed (defined by the mask) are in the buffer and the buffer is non-empty
    axi_wvalid              = ((~fifo_empty & out_mask) == out_mask) && (fifo_empty != '1);
    first_w_ready           = ((~fifo_empty & w_head_mask_ff) == w_head_mask_ff) && (fifo_empty != '1);
    wr_hpn                  = axi_wvalid & dma_axi_if_req_i.rd;
    fifo_rd                 = wr_hpn ? out_mask : '0;
    dma_axi_if_resp_o.empty = ~axi_wvalid;

    strb_z[0] = out_mask;
    for (int i = 0; i < StrbWidth; i++) begin
      dma_axi_if_resp_o.data_rd[i*8 +: 8] = strb_z[OUTPUT_DELAY][i] ? fifo_out[i] : 8'b0;
    end
    if (awlen_ff == '0) begin
      is_first_w = 1'b1;
      is_last_w  = 1'b1;
    end else begin
      is_first_w = first_w_ready & ~middle_wr_trans_ff;
      is_last_w  = middle_wr_trans_ff & (dma_axi_if_req_i.beat_counter == awlen_ff - OUTPUT_DELAY);
      if (is_first_w && wr_hpn) begin
        next_middle_wr_trans = 1'b1;
      end
      if (is_last_w && wr_hpn) begin
        next_middle_wr_trans = 1'b0;
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
      .clk         (clk),
      .rstn        (rstn),
      .clear_i     (dma_clear_i),
      .write_i     (fifo_wr[i]),
      .read_i      (fifo_rd[i]),
      .data_i      (fifo_in[i]),
      .data_o      (fifo_out[i]),
      .full_o      (fifo_full[i]),
      .empty_o     (fifo_empty[i])
    );
  end

  always_ff @ (posedge clk or negedge rstn) begin
    if (~rstn) begin
      r_head_mask_ff      <= '0;
      r_tail_mask_ff      <= '0;
      w_head_mask_ff      <= '0;
      w_tail_mask_ff      <= '0;
      shift_bytes_ff      <= '0;
      awlen_ff            <= '0;
      middle_rd_trans_ff  <= '0;
      middle_wr_trans_ff  <= '0;
    end else begin
      r_head_mask_ff     <= next_r_head_mask;
      r_tail_mask_ff     <= next_r_tail_mask;
      w_head_mask_ff     <= next_w_head_mask;
      w_tail_mask_ff     <= next_w_tail_mask;
      shift_bytes_ff     <= next_shift_bytes;
      awlen_ff           <= next_awlen;
      middle_rd_trans_ff <= next_middle_rd_trans;
      middle_wr_trans_ff <= next_middle_wr_trans;
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
  assign dma_axi_if_resp_o.strb = strb_z[OUTPUT_DELAY];

endmodule
