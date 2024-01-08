package dma_pkg;
import axi_pkg::*;
`define DMA_DATA_WIDTH        DATA_BUS_WIDTH
`define DMA_NUM_DESC          2
// 记录需要DMA传输数据比特长度的容器宽度
`define DMA_BYTES_WIDTH       32
// FIFO size in bytes = (DMA_FIFO_DEPTH*(AXI_DATA_WIDTH/8))
`define DMA_FIFO_DEPTH        16 // Must be power of 2
`define DMA_ID_WIDTH          `AXI_TXN_ID_WIDTH
`define DMA_MAX_BEAT_BURST    256 // 1 up to 256
`define DMA_MAX_BURST_EN      1

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
  desc_addr_t dst_addr;
  desc_num_t  num_bytes;
} s_dma_desc_t;

typedef struct packed {
  desc_addr_t addr;
  err_src_t   src;
  logic       valid;
} s_dma_error_t;

typedef struct packed {
  logic       error;
  logic       done;
} s_dma_status_t;

// Interface between DMA Streamer and DMA AXI
typedef struct packed {
  axi_addr_t    addr;
  axi_len_t     alen;
  axi_size_t    size;
  axi_strb_t    strb;
  logic         valid;
} s_dma_axi_req_t;

typedef struct packed {
  logic       ready;
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
} s_rd_req_t;

typedef struct packed {
  axi_addr_t   waddr;
  axi_len_t    awlen;
  axi_strb_t   wstrb;
} s_wr_req_t;

endpackage