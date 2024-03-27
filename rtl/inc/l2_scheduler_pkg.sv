package l2_scheduler_pkg; import venus_soc_pkg::*;
  `ifdef VIVADO_SYN_ATTR
    `define VIVADO_SYN
  `endif
localparam int unsigned TASK_CRC_BITS = 16;
  typedef struct packed{
    logic [3:0] spm_size; //0=4k 1=8k 2=16k 3=32k 4=64k 5=128k 6=256k 7=512k
    logic [3:0] num_lane; //0=0lane 1=1lane 2=2lane 3=4lane 4=8lane 5=16lane 6=32lane 7=64lane
    logic [0:0] has_bitalu;
    logic [0:0] has_serdiv;
    logic [0:0] has_complexunit;
    logic [TASK_CRC_BITS-1:0]last_crc;
} task_hardware_requirement_t;

  typedef struct packed{
    logic [3:0] spm_size; //0=4k 1=8k 2=16k 3=32k 4=64k 5=128k 6=256k 7=512k
    logic [3:0] num_lane; //0=0lane 1=1lane 2=2lane 3=4lane 4=8lane 5=16lane 6=32lane 7=64lane
    logic [0:0] has_bitalu;
    logic [0:0] has_serdiv;
    logic [0:0] has_complexunit;
  } task_hardware_requirement_task_container_t;

typedef task_hardware_requirement_t tile_hardware_info_t;

localparam int unsigned TASK_CODE_ADDR_BITS = 32;
localparam int unsigned TASK_CODE_LENGTH_BITS = 12;
localparam int unsigned TASK_DATA_ADDR_BITS = 32;
localparam int unsigned TASK_DATA_LENGTH_BITS = 12;

localparam int unsigned MAX_TASK_INPUT_NUM = 4;
localparam int unsigned MAX_TASK_NUM_PER_DAG = 64;
localparam int unsigned MAX_OUTPUT_NUM_PER_TASK = 16;
localparam int unsigned TASK_INPUT_NUM_BITS = $clog2(MAX_TASK_INPUT_NUM)+1;
localparam int unsigned TASK_ID_BITS = $clog2(MAX_TASK_NUM_PER_DAG);
localparam int unsigned TASK_OUTPUT_ID_BITS = $clog2(MAX_OUTPUT_NUM_PER_TASK);
localparam int unsigned TASK_INPUT_SRC_ADDR_BITS = 32; 
localparam int unsigned TASK_INPUT_LEN_BITS = 12; 
localparam int unsigned TASK_INPUT_DES_ADDR_BITS = 32; 
localparam int unsigned MAX_OUTPUT_NUM_PER_DAG = 8; 
// localparam int unsigned NUM_TILE = 16; 
localparam int unsigned NUM_DAG_DUPLICATION = 4; 
localparam int unsigned NUM_MAXIMUM_TASK_RET_DATA = MAX_OUTPUT_NUM_PER_TASK;
localparam int unsigned TASK_INPUT_TYPE_NUM = 4; //GLOBAL CONSTANT DFE TEMP
localparam int unsigned TASK_INPUT_TYPE_BITS = $clog2(TASK_INPUT_TYPE_NUM);
typedef struct packed{
    logic [TASK_CRC_BITS-1:0] task_crc;
    logic [TASK_CODE_ADDR_BITS-1:0] task_addr; 
    logic [TASK_CODE_LENGTH_BITS-1:0] task_len;
    logic [TASK_DATA_ADDR_BITS-1:0] data_addr;
    logic [TASK_DATA_LENGTH_BITS-1:0] data_length;
    task_hardware_requirement_task_container_t task_hardware_requirement;
    logic [TASK_INPUT_NUM_BITS-1:0] task_input_num;
    logic [MAX_TASK_INPUT_NUM-1:0][(TASK_INPUT_TYPE_BITS + TASK_ID_BITS + TASK_OUTPUT_ID_BITS + TASK_INPUT_DES_ADDR_BITS)-1:0] task_descriptor;
} task_container_content;
localparam int unsigned TASK_CONTAINER_BITS = $bits(task_container_content);
localparam int unsigned TASK_CONTAINER_PHYSICAL_BITS = 44; // WARNING: this number should be the nearest 2^n to TASK_CONTAINER_BITS

typedef struct packed{
    logic [TASK_INPUT_SRC_ADDR_BITS-1:0] input_src_addr;
    // logic [TASK_INPUT_DES_ADDR_BITS-1:0] input_des_addr;
    logic [TASK_INPUT_LEN_BITS-1:0] input_len;
} data_management_content;
localparam int unsigned DATA_MANAGEMENT_BITS = $bits(data_management_content);

// typedef struct packed{
//     logic [TASK_INPUT_SRC_ADDR_BITS-1:0] input_src_addr;
//     logic [TASK_INPUT_DES_ADDR_BITS-1:0] input_des_addr;
//     logic [TASK_INPUT_LEN_BITS-1:0] input_len;
// } data_management_content;
// parameter DATA_BUS_WIDTH = 512;
// parameter ADDRESS_BUS_WIDTH = 32;
// parameter ID_BUS_WIDTH_M = 7;
// parameter ID_BUS_WIDTH_S = 10;
// parameter CLUSTER_ID_BUS_WIDTH_M = 10;
// parameter CLUSTER_ID_BUS_WIDTH_S = 12;
parameter NUM_MAXIMUM_DAG = 4;
parameter NUM_MAXIMUM_TASK = 128;
localparam int unsigned MAX_DAG_NUM = NUM_MAXIMUM_DAG; 

localparam int unsigned TASK_CONTAINER_SRAM_NUM = DATA_BUS_WIDTH/TASK_CONTAINER_PHYSICAL_BITS; 


typedef struct packed{
    logic [$clog2(MAX_DAG_NUM)-1:0] dag_id;
    logic [$clog2(MAX_TASK_NUM_PER_DAG)-1:0] task_id;
    logic                           no_ret_data;
    logic                           watchdog_error;
    logic [ADDRESS_BUS_WIDTH - 1:0] src_addr;
    logic [ADDRESS_BUS_WIDTH - 1:0] src_size;
    //logic [ADDRESS_BUS_WIDTH - 1:0] dst_addr;
} tile_manager_req_t;
typedef struct packed{
    logic task_writeback_req_ack;
    //logic task_writeback_req_nack;
} tile_manager_resp_t;
typedef struct packed{
    logic [$clog2(MAX_DAG_NUM)-1:0]  dag_id;
    logic [$clog2(MAX_TASK_NUM_PER_DAG)-1:0] task_id;
    logic [15:0] task_crc;
} distributor_alloc_tile_req_t;


typedef struct packed{
    logic [ADDRESS_BUS_WIDTH - 1:0]  src_addr  ; 
    logic [ADDRESS_BUS_WIDTH - 1:0]  src_size  ; 
    logic [ADDRESS_BUS_WIDTH - 1:0]  dst_addr  ; 
} distributor_assign_dma_req_t;
typedef struct packed{
    logic [$clog2(NUM_MAXIMUM_TASK)-1:0]            task_id;
    logic                                           return_is_all_empty_for_this_task;
    logic [$clog2(NUM_MAXIMUM_TASK_RET_DATA) - 1:0] ret_idx;
    logic [ADDRESS_BUS_WIDTH - 1:0]                 addr;
    logic [ADDRESS_BUS_WIDTH - 1:0]                 size;
} data_management_table_wr_req_t;
parameter [ADDRESS_BUS_WIDTH - 1:0] DAG_DATA_SECTION_BEGIN_ADDR[0:NUM_MAXIMUM_DAG] = '{32'h0100_0000,32'h01ff_ff00,32'h01ff_ff40,32'h01ff_ff80,32'h01ff_ffff};




//logic task_fire_req;
typedef struct packed{
    logic [$clog2(NUM_MAXIMUM_TASK)-1:0] task_id;
    logic [TASK_CRC_BITS-1:0]                         task_crc;
    logic [ADDRESS_BUS_WIDTH - 1:0] src_addr;
    logic [ADDRESS_BUS_WIDTH - 1:0] src_size;
    task_hardware_requirement_t     src_hardware_requirement;
    logic [ADDRESS_BUS_WIDTH - 1:0] dst_addr;
    logic                           pseudo_fire_flag;
} task_manager_req_t;
typedef struct packed{
    logic task_fire_req_ack;
    logic skip_code_transmittion_flag;
    logic task_fire_req_nack;
} task_manager_resp_t;



////////////////////////////
//  l2 mem interface  //
////////////////////////////
typedef logic [(TASK_CONTAINER_BITS / 8) - 1:0]  task_container_strb_t;
typedef logic [31:0] task_container_addr_t;
typedef logic [TASK_CONTAINER_BITS - 1:0] task_container_data_t;

//intf output signal
typedef struct packed {
  logic        mem_wr_en;
  task_container_strb_t mem_wstrb;
  task_container_addr_t mem_waddr;
  task_container_data_t mem_wdata;
  logic         mem_rd_en;
  task_container_addr_t mem_raddr;
} task_container_req_from_scheduler_t;  //intf output


//intf output signal
typedef struct packed {
  logic      mem_wr_en;
  task_container_strb_t mem_wstrb;
  task_container_addr_t mem_waddr;
  task_container_data_t mem_wdata;
  logic    mem_rd_en;
  task_container_addr_t mem_raddr;
} task_container_req_t;  //intf output

//intf input signal
typedef struct packed {
  task_container_data_t   mem_rdata;
} task_container_resp_t;  //intf input



////////////////////////////
//  data management memory interface  //
////////////////////////////
typedef logic [(DATA_MANAGEMENT_BITS / 8) - 1:0]  data_mem_strb_t;
typedef logic [31:0] data_mem_addr_t;
// typedef logic [DATA_MANAGEMENT_BITS - 1:0] data_mem_data_t;
//intf output signal
typedef struct packed {
  logic          mem_wr_en;
  data_mem_strb_t mem_wstrb;
  data_mem_addr_t mem_waddr;
  data_management_content mem_wdata;
  logic          mem_rd_en;
  data_mem_addr_t mem_raddr;
} data_mem_req_t;  //intf output
typedef struct packed {
  data_management_content   mem_rdata;
} data_mem_resp_t;  //intf input
endpackage
