`ifndef CDN_AXI4_MASTER_BFM_VH
`define CDN_AXI4_MASTER_BFM_VH
//----------------------------------------------------------------------------
// Defines.
//----------------------------------------------------------------------------
`define CDN_AXI4_BFM_VIP_VERSION_NUMBER "3.0"
`define AXI4_MODEL_NAME "Xilinx_AXI_BFM"
`define AXI4_MODEL_VERSION 2010.10

// Response timeout value is used for tasks that wait for some action or
// response. If the timeout value is reached (measured in clock cycles) then

// a timeout error message should be initiated.
`define AXI4_RESPONSE_TIMEOUT 500


// Burst Type Defines
`define AXI4_BURST_TYPE_FIXED 2'b00
`define AXI4_BURST_TYPE_INCR  2'b01
`define AXI4_BURST_TYPE_WRAP  2'b10

// Burst Size Defines
`define AXI4_BURST_SIZE_1_BYTE    3'b000
`define AXI4_BURST_SIZE_2_BYTES   3'b001
`define AXI4_BURST_SIZE_4_BYTES   3'b010
`define AXI4_BURST_SIZE_8_BYTES   3'b011
`define AXI4_BURST_SIZE_16_BYTES  3'b100
`define AXI4_BURST_SIZE_32_BYTES  3'b101
`define AXI4_BURST_SIZE_64_BYTES  3'b110
`define AXI4_BURST_SIZE_128_BYTES 3'b111

// Lock Type Defines
`define AXI4_LOCK_TYPE_NORMAL    1'b0
`define AXI4_LOCK_TYPE_EXCLUSIVE 1'b1

// Response Type Defines
`define AXI4_RESPONSE_OKAY 2'b00
`define AXI4_RESPONSE_EXOKAY 2'b01
`define AXI4_RESPONSE_SLVERR 2'b10
`define AXI4_RESPONSE_DECERR 2'b11

// AMBA AXI 4 Bus Size Constants
`define AXI4_LENGTH_BUS_WIDTH 8
`define AXI4_SIZE_BUS_WIDTH 3
`define AXI4_BURST_BUS_WIDTH 2
`define AXI4_LOCK_BUS_WIDTH 1
`define AXI4_CACHE_BUS_WIDTH 4
`define AXI4_PROT_BUS_WIDTH 3
`define AXI4_RESP_BUS_WIDTH 2
`define AXI4_QOS_BUS_WIDTH 4
`define AXI4_REGION_BUS_WIDTH 4

// AMBA AXI 4 Range Constants
`define AXI4_AXI3_MAX_BURST_LENGTH 8'b0000_1111
`define AXI4_MAX_BURST_LENGTH 8'b1111_1111
`define AXI4_MAX_DATA_SIZE (DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))/8

// Message defines
`define AXI4_MSG_WARNING WARNING
`define AXI4_MSG_INFO    INFO
`define AXI4_MSG_ERROR   ERROR

// Define for intenal control value
`define AXI4_ANY_ID_NEXT 100
`define AXI4_IDVALID_TRUE  1'b1
`define AXI4_IDVALID_FALSE 1'b0

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
