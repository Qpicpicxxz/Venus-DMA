
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
 * |    ERRORSRC   |  0x30  |
 * +---------------+--------+
 *
 * CFGREG[0]: 启动DMA，产生dma_ctrl_go_o信号(后续应该改为让fifo推入一次传输块信息的信号)
 * CFGREG[1]: 告诉DMA这是此次散列传输的最后一个块，让DMA在传输完成这个块之后拉高L1 sheduler的中断(先不管)
 *
 * STATREG[0]: 查看DMA拉高中断的原因: 0b0 - 正常散列传输完毕 ｜ 0b1 - 发生异常报错
 * 【待定！！！】1. DMA支持在某轮散列传输还没完成(fifo里还有东西)的时候，接收新的传输请求
 *                - 这样需要L1在接收到DMA interrupt的时候正确的拿到当初传输的数据信息(可能也需要一个fifo来维系)
 *                - 1.1 要么把fifo开的足够大，保证DMA消耗速度 > L1产生速度(这样确保的话就需要较大的硬件资源or其实fifo也没太多硬件资源)
 *                - 1.2 要么设置一个STATREG，当fifo满的时候L1 hold住(这样有个坏处就是每次L1在往寄存器里面写东西的时候，都需要先lw一下，有开销)
 *             2. DMA在某一轮散列传输的进行时不支持新的传输请求(不太合理...因为这样L1会因为没有DMA通道而一直卡住)
 * STATREG[1]: 指示当前DMA是否被占用(正在进行某次散列传输)
 *             CPU需要的行为: 启动某轮散列传输时拉高, DMA传完之后清零
 */
module dma_ctrls
  import venus_soc_pkg::*;
  import dma_pkg::*;
(
  input  logic        clk,
  input  logic        rstn,

  input  csr_req_t    dma_csr_req_i,
  output csr_resp_t   dma_csr_resp_o,

  output logic        dma_ctrl_go_o,
  output logic        dma_ctrl_last_o,
  output desc_addr_t  dma_desc_src_o,
  output desc_addr_t  dma_desc_dst_o,
  output desc_num_t   dma_desc_len_o,
  input  logic        dma_status_done_i,
  input  logic        dma_status_error_i,
  input  desc_addr_t  dma_error_addr_i,
  input  err_src_t    dma_error_src_i
);

logic [31:0]  venusdma_cfg_ff;
logic [31:0]  venusdma_src_ff;
logic [31:0]  venusdma_dst_ff;
logic [31:0]  venusdma_len_ff;
logic [31:0]  venusdma_stat_ff;
logic [31:0]  venusdma_erraddr_ff;
logic [31:0]  venusdma_errsrc_ff;

logic [511:0] venusdma_csr_rdata;

logic dma_cfgreg_l1_wr_selected;
logic dma_srcreg_l1_wr_selected;
logic dma_dstreg_l1_wr_selected;
logic dma_lenreg_l1_wr_selected;

assign dma_cfgreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_CFGREG_OFFSET);
assign dma_srcreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_SRCREG_OFFSET);
assign dma_dstreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_DSTREG_OFFSET);
assign dma_lenreg_l1_wr_selected  = dma_csr_req_i.csr_wr_en && (dma_csr_req_i.csr_waddr[5:0] == `VENUSDMA_LENREG_OFFSET);
assign dma_allcsr_l1_rd_selsected = dma_csr_req_i.csr_rd_en;

assign dma_ctrl_go_o   = venusdma_cfg_ff[0];
assign dma_ctrl_last_o = venusdma_cfg_ff[1];

always_comb begin
  dma_desc_src_o = '0;
  if (dma_ctrl_go_o) begin
    dma_desc_src_o = desc_addr_t'(venusdma_src_ff);
    dma_desc_dst_o = desc_addr_t'(venusdma_dst_ff);
    dma_desc_len_o = desc_num_t'(venusdma_len_ff);
  end
end

always_comb begin
  venusdma_csr_rdata = dma_csr_req_i.csr_rd_en ? {288'h0, venusdma_errsrc_ff,venusdma_erraddr_ff,venusdma_stat_ff,venusdma_len_ff,venusdma_dst_ff,venusdma_src_ff,venusdma_cfg_ff} : 512'h0;
end

always_ff @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    venusdma_cfg_ff     <= '0;
    venusdma_src_ff     <= '0;
    venusdma_dst_ff     <= '0;
    venusdma_len_ff     <= '0;
    venusdma_stat_ff    <= '0;
    venusdma_erraddr_ff <= '0;
    venusdma_errsrc_ff  <= '0;
  end else begin
    if (dma_cfgreg_l1_wr_selected) begin
      venusdma_cfg_ff <= dma_csr_req_i.csr_wdata;
    end else if (dma_srcreg_l1_wr_selected) begin
      venusdma_src_ff <= dma_csr_req_i.csr_wdata;
    end else if (dma_dstreg_l1_wr_selected) begin
      venusdma_dst_ff <= dma_csr_req_i.csr_wdata;
    end else if (dma_lenreg_l1_wr_selected) begin
      venusdma_len_ff <= dma_csr_req_i.csr_wdata;
    end else if (dma_status_done_i) begin
      venusdma_stat_ff[0] <= dma_status_error_i;  // normal - 0, error - 1
      venusdma_erraddr_ff <= dma_error_addr_i;
    end
  end
end

always_ff @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    dma_csr_resp_o.csr_rdata = '0;
  end else begin
    dma_csr_resp_o.csr_rdata = venusdma_csr_rdata;
  end
end
endmodule