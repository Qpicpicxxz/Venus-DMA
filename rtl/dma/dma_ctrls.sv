
/*
 * +---------------+--------+
 * | Register Name | Offset |
 * +---------------+--------+
 * |    CFGREG     |  0x00  |
 * +---------------+--------+
 * |    SRCREG     |  0x08  |
 * +---------------+--------+
 * |    DSTREG     |  0x10  |
 * +---------------+--------+
 * |    LENREG     |  0x18  |
 * +---------------+--------+
 * |    STATREG    |  0x20  |
 * +---------------+--------+
 * |    ERRORADDR  |  0x28  |
 * +---------------+--------+
 *
 * CFGREG[0]: 启动DMA，产生dma_ctrl_write_o信号
 * CFGREG[1]: 告诉DMA这是此次散列传输的最后一个块，让DMA在传输完成这个块之后拉高L1 sheduler的中断
 *
 * STATREG[0]: 查看DMA拉高中断的原因: 0b0 - 正常散列传输完毕 ｜ 0b1 - 发生异常报错
 * STATREG[1]: 指示当前DMA的csr fifo是否满
 *             CPU需要的行为: 如果DMA的csr_fifo满了, 就while住, 等待DMA的csr_fifo空闲
 * STATREG[2][3]: 00[RD_ERR] | 01[WR_ERR] | 10[UNALIGNED_ERR] | 11[NARROW_CROSS_ERROR]
 */
module dma_ctrls
  import venus_soc_pkg::*;
  import dma_pkg::*;
(
  input  logic        clk,
  input  logic        rstn,

  input  csr_req_t    dma_csr_req_i,
  output csr_resp_t   dma_csr_resp_o,

  output logic        dma_ctrl_write_o,
  output logic        dma_ctrl_last_o,
  output desc_addr_t  dma_desc_src_o,
  output desc_addr_t  dma_desc_dst_o,
  output desc_num_t   dma_desc_len_o,
  input  logic        dma_status_error_i,
  input  logic        dma_csr_fifo_full_i,
  input  desc_addr_t  dma_error_addr_i,
  input  err_src_t    dma_error_src_i
);

  logic [31:0]  venusdma_cfg_ff;
  logic [31:0]  venusdma_src_ff;
  logic [31:0]  venusdma_dst_ff;
  logic [31:0]  venusdma_len_ff;
  logic [31:0]  venusdma_stat_ff;
  logic [31:0]  venusdma_erraddr_ff;

  logic [511:0] venusdma_csr_rdata;

  logic dma_cfgreg_l1_wr_selected;
  logic dma_srcreg_l1_wr_selected;
  logic dma_dstreg_l1_wr_selected;
  logic dma_lenreg_l1_wr_selected;

  logic dma_ctrl_fifo_recoded;

  assign dma_cfgreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_CFGREG_OFFSET);
  assign dma_srcreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_SRCREG_OFFSET);
  assign dma_dstreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_DSTREG_OFFSET);
  assign dma_lenreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_LENREG_OFFSET);
  assign dma_allcsr_l1_rd_selsected = dma_csr_req_i.csr_rd_en;

  assign dma_ctrl_fifo_recoded = venusdma_cfg_ff[0];
  assign dma_ctrl_write_o      = venusdma_cfg_ff[0];
  assign dma_ctrl_last_o       = venusdma_cfg_ff[1];

  always_comb begin: push_csr_data_to_fifo
    dma_desc_src_o = '0;
    if (dma_ctrl_write_o) begin
      dma_desc_src_o = desc_addr_t'(venusdma_src_ff);
      dma_desc_dst_o = desc_addr_t'(venusdma_dst_ff);
      dma_desc_len_o = desc_num_t'(venusdma_len_ff);
    end
  end: push_csr_data_to_fifo

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      venusdma_cfg_ff <= '0;
      venusdma_src_ff <= '0;
      venusdma_dst_ff <= '0;
      venusdma_len_ff <= '0;
    end else begin
      // parallel relationship, only one condition will occur at a time
      if (dma_cfgreg_l1_wr_selected) begin
        venusdma_cfg_ff <= dma_csr_req_i.csr_wdata;
      end else if (dma_srcreg_l1_wr_selected) begin
        venusdma_src_ff <= dma_csr_req_i.csr_wdata;
      end else if (dma_dstreg_l1_wr_selected) begin
        venusdma_dst_ff <= dma_csr_req_i.csr_wdata;
      end else if (dma_lenreg_l1_wr_selected) begin
        venusdma_len_ff <= dma_csr_req_i.csr_wdata;
      end else if (dma_ctrl_fifo_recoded) begin
        venusdma_cfg_ff <= '0;
      end
    end
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      venusdma_stat_ff    <= '0;
      venusdma_erraddr_ff <= '0;
    end else begin
      if (dma_status_error_i) begin
        venusdma_stat_ff[0]   <= 1'b1; // normal - 0, error - 1
        venusdma_erraddr_ff   <= dma_error_addr_i;
        venusdma_stat_ff[3:2] <= dma_error_src_i;
      end
      venusdma_stat_ff[1] <= dma_csr_fifo_full_i;
    end
  end

  assign venusdma_csr_rdata = dma_csr_req_i.csr_rd_en ? {320'h0,venusdma_erraddr_ff,venusdma_stat_ff,venusdma_len_ff,venusdma_dst_ff,venusdma_src_ff,venusdma_cfg_ff} : 512'h0;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      dma_csr_resp_o.csr_rdata <= '0;
    end else begin
      dma_csr_resp_o.csr_rdata <= venusdma_csr_rdata;
    end
  end
endmodule