package dma_pkg;
import venus_soc_pkg::*;
`define DMA_DATA_WIDTH        DATA_BUS_WIDTH
`define DMA_NUM_DESC          2
// 记录需要DMA传输数据比特长度的容器宽度
`define DMA_BYTES_WIDTH       32
// FIFO size in bytes = (DMA_FIFO_DEPTH*(AXI_DATA_WIDTH/8))
`define DMA_FIFO_DEPTH        256 // Must be power of 2
`define DMA_ID_WIDTH          `AXI_TXN_ID_WIDTH
`define DMA_MAX_BEAT_BURST    256 // 1 up to 256
`define DMA_MAX_BURST_EN      1

`define VENUSDMA_CTRLREG_OFFSET   32'h1ffe_0000
`define VENUSDMA_CFGREG_OFFSET    6'h0
`define VENUSDMA_SRCREG_OFFSET    6'h8
`define VENUSDMA_DSTREG_OFFSET    6'h10
`define VENUSDMA_LENREG_OFFSET    6'h18
`define VENUSDMA_STATREG_OFFSET   6'h20
`define VENUSDMA_ERRORADDR_OFFSET 6'h28
`define VENUSDMA_ERRORSRC_OFFSET  6'h30

// DMA_FIFO_DEPTH = 16 | FIFO_WIDTH = 4
localparam FIFO_WIDTH = $clog2(`DMA_FIFO_DEPTH>1?`DMA_FIFO_DEPTH:2);
typedef logic [31:0]                        desc_addr_t;
typedef logic [`DMA_BYTES_WIDTH-1:0]        desc_num_t;
typedef logic [FIFO_WIDTH:0]                fifo_sz_t;

typedef enum logic [1:0] {
  // slave传来的read error
  DMA_AXI_RD_ERR,
  // slave传来的write error
  DMA_AXI_WR_ERR,
  // 非narrow transfer，源/目的地址未对齐
  DMA_UNALIGNED_ERR,
  // narrow transfer，地址64byte越界
  DMA_NARROW_CROSS_ERR
} err_src_t;

typedef enum logic {
  DMA_ST_SM_IDLE,
  DMA_ST_SM_RUN
} dma_sm_t;

typedef enum logic [1:0] {
  DMA_ST_IDLE,
  DMA_ST_RUN,
  DMA_ST_DONE
} dma_st_t;

// Interface between DMA FSM / Streamer and DMA CSR
typedef struct packed {
  desc_addr_t src_addr;
  desc_num_t  num_bytes;
  desc_addr_t dst_addr;
} s_dma_desc_t;

typedef struct packed {
  desc_addr_t addr;
  err_src_t   src;
  logic       valid;
} s_dma_error_t;

typedef struct packed {
  logic       error;
  logic       done;
  logic       active;
} s_dma_status_t;

// Interface between DMA Streamer and DMA AXI
typedef struct packed {
  axi_addr_t    addr;
  axi_len_t     alen;
  axi_size_t    size;
  axi_strb_t    strb;
  logic         valid;
  logic         half_trans_valid;
} s_dma_axi_req_t;

typedef struct packed {
  logic       ready;
  logic       finish;
} s_dma_axi_resp_t;

// Interface between DMA FIFOs and DMA AXI
typedef struct packed {
  logic       wr;
  logic       rd;
  axi_data_t  data_wr;
} s_dma_fifo_req_t;

typedef struct packed {
  axi_data_t  data_rd;
  // fifo_sz_t   ocup;
  // fifo_sz_t   space;
  logic       full;
  logic       empty;
} s_dma_fifo_resp_t;

// Streamer - AXI IF 之间寄存传输信息
typedef struct packed {
  axi_addr_t   raddr;
  axi_strb_t   rstrb;   // 备用[原本用来应对地址unligned情况的]
  logic       half_trans_valid;
} s_rd_req_t;

typedef struct packed {
  axi_addr_t   waddr;
  axi_len_t    awlen;
  axi_strb_t   wstrb;
  logic        half_trans_valid;
} s_wr_req_t;

typedef struct packed {
  logic csr_wr_en;
  // 不传递wstrb意味着：每次都会写整个[31:0]的范围！！！
  // logic [3:0] csr_wstrb;
  logic [31:0] csr_waddr;
  logic [31:0] csr_wdata;
  logic csr_rd_en;
  // 目前csr的范围没有超过64byte，所以默认只要读的是VENUSDMA_CTRLREG_OFFSET~VENUSDMA_CTRLREG_OFFSET+0x40范围的地方，都会统一返回相应数据
  // logic csr_raddr;
} csr_req_t;

typedef struct packed {
  // 读64byte的数据(所有的csr范围)
  logic [511:0] csr_rdata;
} csr_resp_t;

endpackage