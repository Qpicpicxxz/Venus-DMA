package venus_soc_pkg;

parameter DATA_BUS_WIDTH = 512;
parameter ID_BUS_WIDTH = 7;  // 可配置「与L2设置齐平」

// ------ AXI interface ------ //
typedef logic [31:0]                        axi_addr_t;
typedef logic [ID_BUS_WIDTH - 1 :0]         axi_id_t;
typedef logic [7:0]                         axi_len_t;
typedef logic [2:0]                         axi_size_t;
typedef logic [1:0]                         axi_burst_t;
typedef logic [3:0]                         axi_cache_t;
typedef logic [2:0]                         axi_prot_t;
typedef logic [DATA_BUS_WIDTH - 1:0]        axi_data_t;
typedef logic [(DATA_BUS_WIDTH / 8) - 1:0]  axi_strb_t;
typedef logic [1:0]                         axi_response_t;
typedef logic [3:0]                         axi_qos_t;
typedef logic [3:0]                         axi_region_t;
typedef logic [5:0]                         axi_atop_t;
typedef logic [3:0]                         axi_nsaid_t;
typedef logic [0:0]                         axi_user_t;

// ------ Write Address Channel ------ //
typedef struct packed {
    axi_addr_t        awaddr;
    axi_id_t          awid;
    axi_len_t         awlen;
    axi_size_t        awsize;
    axi_burst_t       awburst;
    logic             awlock;
    axi_cache_t       awcache;
    axi_prot_t        awprot;
    //axi_qos_t         awqos;
    //axi_region_t      awregion;
    //axi_atop_t        aweatop;
    //axi_user_t        awuser;
} axi_aw_chan_t;  // master output

// ------ Write Data Channel ------ //
typedef struct packed {
    axi_data_t        wdata;
    axi_strb_t        wstrb;
    logic             wlast;
    //axi_user_t        wuser;
} axi_w_chan_t;  // master output

// ------ Write Response Channel ------ //
typedef struct packed {
    axi_id_t          bid;
    axi_response_t    bresp;
    //axi_user_t        buser;
} axi_b_chan_t;  // master input

// ------ Read Address Channel ------ //
typedef struct packed {
    axi_id_t          arid;
    axi_addr_t        araddr;
    axi_len_t         arlen;
    axi_size_t        arsize;
    axi_burst_t       arburst;
    logic             arlock;
    axi_cache_t       arcache;
    axi_prot_t        arprot;
    //axi_qos_t         arqos;
    //axi_region_t      arregion;
    //axi_user_t        aruser;
} axi_ar_chan_t;  // master output

// ------  Read Data Channel ------ //
typedef struct packed {
    axi_id_t          rid;
    axi_data_t        rdata;
    logic             rlast;
    axi_response_t    rresp;
    //axi_user_t        ruser;
} axi_r_chan_t;  // master input

// ------ Master Output ------ //
typedef struct packed {
    axi_aw_chan_t aw;
    logic     awvalid;
    axi_w_chan_t  w;
    logic     wvalid;
    logic     bready;
    axi_ar_chan_t ar;
    logic     arvalid;
    logic     rready;
} axi_req_t;  // master output


// ------ Master Input ------ //
typedef struct packed {
    logic     awready;
    logic     arready;
    logic     wready;
    logic     bvalid;
    axi_b_chan_t  b;
    logic     rvalid;
    axi_r_chan_t  r;
} axi_resp_t;  // master input

// ------ AXI_MEMORY interface ------ //
typedef logic [(DATA_BUS_WIDTH / 8) - 1:0]  axi2mem_strb_t;
typedef logic [31:0]                        axi2mem_addr_t;
typedef logic [DATA_BUS_WIDTH - 1:0]        axi2mem_data_t;

// ------ Interface Output Signal ------ //
typedef struct packed {
  logic          mem_wr_en;
  axi2mem_strb_t mem_wstrb;
  axi2mem_addr_t mem_waddr;
  axi2mem_data_t mem_wdata;
  logic          mem_rd_en;
  axi2mem_addr_t mem_raddr;
} axi2mem_req_t;  // intf output


// ------ Interface Input Signal ------ //
typedef struct packed {
  axi2mem_data_t   mem_rdata;
} axi2mem_resp_t;  // intf input

endpackage