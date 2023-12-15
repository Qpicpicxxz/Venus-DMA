
//----------------------------------------------------------------------------
// Project    : Pheidippides
// Company    : Cadence Design Systems
//----------------------------------------------------------------------------
// Description:
// This file contains the Cadence AXI 4 Master BFM.
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Required defines.
//----------------------------------------------------------------------------



//----------------------------------------------------------------------------
// Project    : Pheidippides
// Company    : Cadence Design Systems
//----------------------------------------------------------------------------
// Description:
// This file contains the defines required for the Cadence AXI 4 BFMs.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Required timescale.
//----------------------------------------------------------------------------
`timescale 1ns / 1ps

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

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// The AXI 4 Master BFM Module.
//----------------------------------------------------------------------------

module cdn_axi4_master_bfm (ACLK, ARESETn,
                            AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK,
                            AWCACHE, AWPROT, AWREGION, AWQOS, AWUSER,
                            AWVALID, AWREADY,
                            WDATA, WSTRB, WLAST, WUSER, WVALID, WREADY,
                            BID, BRESP, BVALID, BUSER, BREADY,
                            ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK,
                            ARCACHE, ARPROT, ARREGION, ARQOS, ARUSER,
                            ARVALID, ARREADY,
                            RID, RDATA, RRESP, RLAST, RUSER, RVALID, RREADY);

   //------------------------------------------------------------------------
   // Configuration Parameters
   //------------------------------------------------------------------------
   parameter NAME = "MASTER_0";
   parameter DATA_BUS_WIDTH = 32;
   parameter ADDRESS_BUS_WIDTH = 32;
   parameter ID_BUS_WIDTH = 4;
   parameter AWUSER_BUS_WIDTH = 1;
   parameter ARUSER_BUS_WIDTH = 1;
   parameter RUSER_BUS_WIDTH  = 1;
   parameter WUSER_BUS_WIDTH  = 1;
   parameter BUSER_BUS_WIDTH  = 1;
   parameter MAX_OUTSTANDING_TRANSACTIONS = 8;
   parameter EXCLUSIVE_ACCESS_SUPPORTED = 1;

   integer BFM_CLK_DELAY = 0;
   integer TASK_RESET_HANDLING = 0;
   integer WRITE_BURST_DATA_TRANSFER_GAP = 0;
   integer WRITE_BURST_ADDRESS_DATA_PHASE_GAP = 0;
   integer WRITE_BURST_DATA_ADDRESS_PHASE_GAP = 0;
   integer RESPONSE_TIMEOUT = `AXI4_RESPONSE_TIMEOUT;
   reg     DISABLE_RESET_VALUE_CHECKS = 1'b0;
   reg     STOP_ON_ERROR = 1'b1;
   reg     CHANNEL_LEVEL_INFO = 1'b0;
   reg     FUNCTION_LEVEL_INFO = 1'b1;
   reg     CLEAR_SIGNALS_AFTER_HANDSHAKE = 1'b0;
   reg     ERROR_ON_SLVERR = 1'b0;
   reg     ERROR_ON_DECERR = 1'b0;

   //------------------------------------------------------------------------
   // Signal Definitions
   //------------------------------------------------------------------------

   // Global Clock Input. All signals are sampled on the rising edge.
   input wire ACLK;
   // Global Reset Input. Active Low.
   input wire ARESETn;

   // Internal Clock created by delaying the input clock and used for sampling
   // and driving input and output signals respectively to avoid race
   // conditions.
   wire bfm_aclk;

   // Write Address Channel Signals.
   output reg [ID_BUS_WIDTH-1:0]      AWID;
   // Master Write address ID.
   output reg [ADDRESS_BUS_WIDTH-1:0] AWADDR;
 // Master Write address.
   output reg [`AXI4_LENGTH_BUS_WIDTH-1:0] AWLEN;
  // Master Burst length.
   output reg [`AXI4_SIZE_BUS_WIDTH-1:0]   AWSIZE;
 // Master Burst size.
   output reg [`AXI4_BURST_BUS_WIDTH-1:0]  AWBURST;  // [1:0]
// Master Burst type.
   output reg [`AXI4_LOCK_BUS_WIDTH-1:0]   AWLOCK;
 // Master Lock type.
   output reg [`AXI4_CACHE_BUS_WIDTH-1:0]  AWCACHE;
// Master Cache type.
   output reg [`AXI4_PROT_BUS_WIDTH-1:0]   AWPROT;
 // Master Protection type.
   output reg [`AXI4_REGION_BUS_WIDTH-1:0] AWREGION;// Master Region signals.
   output reg [`AXI4_QOS_BUS_WIDTH-1:0]    AWQOS;
  // Master QoS signals.
   output reg [AWUSER_BUS_WIDTH-1:0]  AWUSER;
 // Master User defined signals.
   output reg                         AWVALID;
// Master Write address valid.
   input  wire                        AWREADY;
// Slave Write address ready.


   // Write Data Channel Signals.
   output reg [DATA_BUS_WIDTH-1:0]     WDATA;
 // Master Write data.
   output reg [(DATA_BUS_WIDTH/8)-1:0] WSTRB;
 // Master Write strobes.
   output reg                          WLAST;
 // Master Write last.
   output reg [WUSER_BUS_WIDTH-1:0]    WUSER;
 // Master Write User defined signals.
   output reg                          WVALID;
// Master Write valid.
   input  wire                         WREADY;
// Slave Write ready.

   // Write Response Channel Signals.
   input  wire [ID_BUS_WIDTH-1:0]      BID;
   // Slave Response ID.
   input  wire [`AXI4_RESP_BUS_WIDTH-1:0]   BRESP;
 // Slave Write response.
   input  wire                         BVALID;
// Slave Write response valid.
   input  wire [BUSER_BUS_WIDTH-1:0]   BUSER;
 // Slave Write user defined signals.
   output reg                          BREADY;
// Master Response ready.

   // Read Address Channel Signals.
   output reg [ID_BUS_WIDTH-1:0]       ARID;
   // Master Read address ID.
   output reg [ADDRESS_BUS_WIDTH-1:0]  ARADDR;
 // Master Read address.
   output reg [`AXI4_LENGTH_BUS_WIDTH-1:0]  ARLEN;
  // Master Burst length.
   output reg [`AXI4_SIZE_BUS_WIDTH-1:0]    ARSIZE;
 // Master Burst size.
   output reg [`AXI4_BURST_BUS_WIDTH-1:0]   ARBURST;
// Master Burst type.
   output reg [`AXI4_LOCK_BUS_WIDTH-1:0]    ARLOCK;
 // Master Lock type.
   output reg [`AXI4_CACHE_BUS_WIDTH-1:0]   ARCACHE;
// Master Cache type.
   output reg [`AXI4_PROT_BUS_WIDTH-1:0]    ARPROT;
 // Master Protection type.
   output reg [`AXI4_REGION_BUS_WIDTH-1:0]  ARREGION;// Master Region signals.
   output reg [`AXI4_QOS_BUS_WIDTH-1:0]     ARQOS;
  // Master QoS signals.
   output reg [ARUSER_BUS_WIDTH-1:0]   ARUSER;
 // Master User defined signals.
   output reg                          ARVALID;
// Master Read address valid.
   input  wire                         ARREADY;
// Slave Read address ready.

   // Read Data Channel Signals.
   input  wire [ID_BUS_WIDTH-1:0]      RID;
   // Slave Read ID tag.
   input  wire [DATA_BUS_WIDTH-1:0]    RDATA;
 // Slave Read data.
   input  wire [`AXI4_RESP_BUS_WIDTH-1:0]   RRESP;
 // Slave Read response.
   input  wire                         RLAST;
 // Slave Read last.
   input  wire [RUSER_BUS_WIDTH-1:0]   RUSER;
 // Slave Read user defined signals.
   input  wire                         RVALID;
// Slave Read valid.
   output reg                          RREADY;
// Master Read ready.

   //------------------------------------------------------------------------
   // Local Variables
   //------------------------------------------------------------------------
   reg                                 read_address_bus_locked;
   reg                                 write_address_bus_locked;
   reg                                 write_data_bus_locked;
   integer                             error_count;
   integer                             warning_count;
   integer                             pending_transactions_count;
   reg                                 reset_message_done;

   //------------------------------------------------------------------------
   // Local Events
   //------------------------------------------------------------------------
   event                             read_address_transfer_complete;
   event                             write_address_transfer_complete;
   event                             read_data_transfer_complete;
   event                             write_data_transfer_complete;
   event                             read_data_burst_complete;
   event                             write_data_burst_complete;
   event                             write_response_transfer_complete;

   //------------------------------------------------------------------------
   // Generate internal sampling/driving clock.
   //------------------------------------------------------------------------
   assign #BFM_CLK_DELAY bfm_aclk = ACLK;

   //------------------------------------------------------------------------
   // Initialize Local Variables
   //------------------------------------------------------------------------
   initial begin
      read_address_bus_locked = 1'b0;
      write_address_bus_locked = 1'b0;
      write_data_bus_locked = 1'b0;
      error_count = 0;
      warning_count = 0;
      pending_transactions_count = 0;
      reset_message_done = 1'b0;
   end

   //------------------------------------------------------------------------
   // Display BFM Header
   //------------------------------------------------------------------------
   initial begin
     //if ($xilinx_lic_check(`AXI4_MODEL_NAME, `AXI4_MODEL_VERSION) != 0)
     if(1)
       begin
          $display("BFM Xilinx: License succeeded for %s, version %f",
                   `AXI4_MODEL_NAME, `AXI4_MODEL_VERSION);
       end
     else
       begin
          $display("BFM Xilinx: License failed for %s, version %f",
                   `AXI4_MODEL_NAME, `AXI4_MODEL_VERSION);
          $finish;
// Do not allow simulation to continue
       end
      $display("**********************************************************");
      $display("* Cadence AXI 4 MASTER BFM                               *");
      $display("**********************************************************");
      $display("* VERSION NUMBER : ",`CDN_AXI4_BFM_VIP_VERSION_NUMBER);
      report_config;
   end

   //------------------------------------------------------------------------
   // UTILITY TASK: report_config
   //------------------------------------------------------------------------
   // Description:
   // This task prints out the current config of the master BFM.
   //------------------------------------------------------------------------
   task report_config;
     begin
        $display("**********************************************************");
        $display("* CONFIGURATION: ");
        $display("* NAME = %s",NAME);
        $display("* DATA_BUS_WIDTH = %0d",DATA_BUS_WIDTH);
        $display("* ADDRESS_BUS_WIDTH = %0d",ADDRESS_BUS_WIDTH);
        $display("* ID_BUS_WIDTH = %0d",ID_BUS_WIDTH);
        $display("* AWUSER_BUS_WIDTH = %0d",AWUSER_BUS_WIDTH);
        $display("* ARUSER_BUS_WIDTH = %0d",ARUSER_BUS_WIDTH);
        $display("* RUSER_BUS_WIDTH = %0d",RUSER_BUS_WIDTH);
        $display("* WUSER_BUS_WIDTH = %0d",WUSER_BUS_WIDTH);
        $display("* BUSER_BUS_WIDTH = %0d",BUSER_BUS_WIDTH);
        $display("* MAX_OUTSTANDING_TRANSACTIONS = %0d",
                 MAX_OUTSTANDING_TRANSACTIONS);
        $display("* EXCLUSIVE_ACCESS_SUPPORTED = %0d",
                 EXCLUSIVE_ACCESS_SUPPORTED);
        $display("* WRITE_BURST_DATA_TRANSFER_GAP = %0d",
                 WRITE_BURST_DATA_TRANSFER_GAP);
        $display("* WRITE_BURST_ADDRESS_DATA_PHASE_GAP = %0d",
                 WRITE_BURST_ADDRESS_DATA_PHASE_GAP);
        $display("* WRITE_BURST_DATA_ADDRESS_PHASE_GAP = %0d",
                 WRITE_BURST_DATA_ADDRESS_PHASE_GAP);
        $display("* RESPONSE_TIMEOUT = %0d",RESPONSE_TIMEOUT);
        $display("* CLEAR_SIGNALS_AFTER_HANDSHAKE = %0d",CLEAR_SIGNALS_AFTER_HANDSHAKE);
        $display("* DISABLE_RESET_VALUE_CHECKS = %0d",DISABLE_RESET_VALUE_CHECKS);
        $display("* ERROR_ON_SLVERR = %0d",ERROR_ON_SLVERR);
        $display("* ERROR_ON_DECERR = %0d",ERROR_ON_DECERR);
        $display("* STOP_ON_ERROR = %0d",STOP_ON_ERROR);
        $display("* CHANNEL_LEVEL_INFO = %0d",CHANNEL_LEVEL_INFO);
        $display("* FUNCTION_LEVEL_INFO = %0d",FUNCTION_LEVEL_INFO);
        $display("**********************************************************");
     end
   endtask

   //------------------------------------------------------------------------
   // Include Common Checker Tasks
   //------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Project    : Pheidippides
// Company    : Cadence Design Systems
//----------------------------------------------------------------------------
// Description:
// This file contains the common checkers required for the Cadence AXI 4 BFMs.
// The reason for putting them here is so that the Master and Slave BFMs can
// leverage from common checks. This also makes maintenance easier.
//----------------------------------------------------------------------------

//------------------------------------------------------------------------
// CHECKING TASKS
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// CHECKING TASK: check_burst_type
//------------------------------------------------------------------------
// Description:
// AXI 3 Spec (section 4.4) says the following types of burst are valid:
// b00 - FIXED
// b01 - INCR
// b10 - WRAP
// b11 - Reserved - This will be marked as an error.
//------------------------------------------------------------------------
task automatic check_burst_type;
   input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
   begin
      if (burst_type === 2'b11) begin
         $display("[%0t] : %s : ERROR : Burst type cannot be equal to 2'b11 as this is RESERVED - AMBA AXI SPEC V2 - Section 4.4 Burst type",$time,NAME);
         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end
endtask

//------------------------------------------------------------------------
// CHECKING TASK: check_burst_length
//------------------------------------------------------------------------
// Description:
// check_burst_length(burst_type,length,lock_type)
// AXI 3 say the following types of burst length are valid:
// - if the burst type = WRAP then length must be either 2,4,8 or 16
// NOTE: The length value is encoded as 4'b0000 = 1, 4'b0001 = 2 etc.
// AXI 4 Allows burst of up to 256 beats but only for INCR burst.
// Exclusive accessares are not permitted to use a burst length of more
// than 16 beats.
//------------------------------------------------------------------------
task automatic check_burst_length;
   input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
   input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
   input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
   reg                           ok;
   begin
      if (burst_type === `AXI4_BURST_TYPE_WRAP) begin
         case (length)
           4'b0001 : ok = 1'b1;
// 4'b0001 = length 2
           4'b0011 : ok = 1'b1;
// 4'b0011 = length 4
           4'b0111 : ok = 1'b1;
// 4'b0111 = length 8
           4'b1111 : ok = 1'b1;
// 4'b1111 = length 16
           default : begin
              $display("[%0t] : %s : *ERROR : Burst length cannot be equal to %0d when the burst type is WRAP. It must be either 2,4,8 or 16 - AMBA AXI SPEC V2 - Section 4.2 Burst length",$time,NAME,decode_burst_length(length));
              if(STOP_ON_ERROR == 1) begin
                $display("*** TEST FAILED");
                $stop;
              end
              error_count = error_count+1;
           end
         endcase
      end
      // AXI 4 - Only Non exclusive bursts of type INCR are allowed to be
      // longer than 16 beats.
      if (decode_burst_length(length) > 16) begin
         if (burst_type !== `AXI4_BURST_TYPE_INCR) begin
              $display("[%0t] : %s : *ERROR : Burst length cannot be greater than 16 when the burst type is not INCR. - AMBA AXI SPEC V2 - AXI 4 Section 13.1.3 Burst Support - Limitations of use",$time,NAME);
              if(STOP_ON_ERROR == 1) begin
                $display("*** TEST FAILED");
                $stop;
              end
              error_count = error_count+1;
         end
         if (lock_type === `AXI4_LOCK_TYPE_EXCLUSIVE) begin
              $display("[%0t] : %s : *ERROR : Burst length cannot be greater than 16 when the burst is an exclusive accesses. - AMBA AXI SPEC V2 - AXI 4 Section 13.1.3 Burst Support - Limitations of use",$time,NAME);
              if(STOP_ON_ERROR == 1) begin
                $display("*** TEST FAILED");
                $stop;
              end
              error_count = error_count+1;
         end

      end

   end
endtask

//------------------------------------------------------------------------
// CHECKING TASK: check_burst_size
//------------------------------------------------------------------------
// Description:
// check_burst_size(size)
// AXI 3 Spec (section 4.3) says the size of a burst cannot be greater
// than the size of the data bus width.
//------------------------------------------------------------------------
task automatic check_burst_size;
   input [`AXI4_SIZE_BUS_WIDTH-1:0]  size;
   begin
      if (transfer_size_in_bytes(size) > (DATA_BUS_WIDTH/8)) begin
         $display("[%0t] : %s : *ERROR : Burst size cannot be greater than the data bus width - AMBA AXI SPEC V2 - Section 4.3 Burst size",$time,NAME);
         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end
endtask

//------------------------------------------------------------------------
// CHECKING TASK: check_lock_type
//------------------------------------------------------------------------
// Description:
// check_lock_type(lock_type)
// AXI 4 Spec (section 13.15.1) says the following types of lock are valid:
// b0 - Normal Access
// b1 - Exclusive Access
//------------------------------------------------------------------------
task automatic check_lock_type;
   input [`AXI4_LOCK_BUS_WIDTH-1:0]  lock_type;
   begin
      if (lock_type > 1 ) begin
         $display("[%0t] : %s : *ERROR : Lock type cannot be greater than 1 as this should be implemented as a single bit in AXI 4. - AMBA AXI SPEC V2 - Section 13.15.1 AWLOCK and ARLOCK changes",$time,NAME);
         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end
endtask

//------------------------------------------------------------------------
// CHECKING TASK: check_cache_type
//------------------------------------------------------------------------
// Description:
// check_cache_type(cache_type)
// AXI 4 Spec (section 13.8) says the following types of cache bit
// combinations are reserved and will be marked as an error.
// b0100 - Reserved
// b0101 - Reserved
// b1000 - Reserved
// b1001 - Reserved
// b1100 - Reserved
// b1101 - Reserved
//------------------------------------------------------------------------
task automatic check_cache_type;
   input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
   reg                           ok;
   begin
      case (cache_type)
        4'b0100 : ok = 1'b0;
        4'b0101 : ok = 1'b0;
        4'b1000 : ok = 1'b0;
        4'b1001 : ok = 1'b0;
        4'b1100 : ok = 1'b0;
        4'b1101 : ok = 1'b0;
        default : ok = 1'b1;
      endcase

      if (ok ==1'b0) begin
         $display("[%0t] : %s : *ERROR : CACHE type cannot be equal to %4b as this is RESERVED - AMBA AXI SPEC V2 - AXI 4 Section 13.8 Cache support",$time,NAME,cache_type);
         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end
endtask

//------------------------------------------------------------------------
// CHECKING TASK: check_address
//------------------------------------------------------------------------
// Description:
// check_address(address,burst_type,size)
// If the burst type = WRAP then address must be aligned relative to the
// burst size.
//------------------------------------------------------------------------
task automatic check_address;
   input [ADDRESS_BUS_WIDTH-1:0] address;
   input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
   input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
   reg [ADDRESS_BUS_WIDTH-1:0]       address_offset;
   integer                       trans_size_in_bytes;
   begin
      trans_size_in_bytes = transfer_size_in_bytes(size);
      address_offset = address-((address/trans_size_in_bytes)*(trans_size_in_bytes));
      if (burst_type === `AXI4_BURST_TYPE_WRAP && address_offset !== 0) begin
         $display("[%0t] : %s : *ERROR : When the burst type is equal to WRAP the start address must be aligned to the size of the transfer - AMBA AXI SPEC V2 - Section 4.4.3 Burst length",$time,NAME);
         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end
endtask

//------------------------------------------------------------------------
// COMMON FUNCTION: transfer_size_in_bytes
//------------------------------------------------------------------------
// Description:
// transfer_size_in_bytes(size)
// This function takes the transfer size input and decodes it into the
// integer number of bytes in the transfer.
//------------------------------------------------------------------------
function integer transfer_size_in_bytes;
   input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
   begin
      case (size)
        `AXI4_BURST_SIZE_1_BYTE    : transfer_size_in_bytes = 1;
        `AXI4_BURST_SIZE_2_BYTES   : transfer_size_in_bytes = 2;
        `AXI4_BURST_SIZE_4_BYTES   : transfer_size_in_bytes = 4;
        `AXI4_BURST_SIZE_8_BYTES   : transfer_size_in_bytes = 8;
        `AXI4_BURST_SIZE_16_BYTES  : transfer_size_in_bytes = 16;
        `AXI4_BURST_SIZE_32_BYTES  : transfer_size_in_bytes = 32;
        `AXI4_BURST_SIZE_64_BYTES  : transfer_size_in_bytes = 64;
        `AXI4_BURST_SIZE_128_BYTES : transfer_size_in_bytes = 128;
      endcase
   end
endfunction

//------------------------------------------------------------------------
// COMMON FUNCTION: decode_burst_length
//------------------------------------------------------------------------
// Description:
// decode_burst_length(length)
// This function takes the burst length and decodes it into an integer
// number.
//------------------------------------------------------------------------
function integer decode_burst_length;
   input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
   begin
      // Take the length and increment it in a second step
      decode_burst_length = length;
      decode_burst_length = decode_burst_length+1;
   end
endfunction

//------------------------------------------------------------------------
// FUNCTION: calculate_strobe
//------------------------------------------------------------------------
// Description:
// calculate_strobe(transfer_number,address,length,size,burst_type)
// This function calculates the strobe signals based on the transfer
// number, burst type, burst size and data bus size.
// NOTE: From the AXI spec, section 9.3  narrorw transfers "In a fixed
// burst the address remains constant and the byte lanes used are also
// constant."
// NOTE: The formulas used here are from the AMBA AXI spec, section 4.5
// burst address.
//------------------------------------------------------------------------
function [(DATA_BUS_WIDTH/8)-1:0] calculate_strobe;
   input integer transfer_number;
   input [ADDRESS_BUS_WIDTH-1:0] address;
   input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
   input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
   input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;

   reg [ADDRESS_BUS_WIDTH-1:0]       Start_Address;
   integer                           Number_Bytes;
   integer                           Data_Bus_Bytes;
   reg [ADDRESS_BUS_WIDTH-1:0]       Aligned_Address;
   integer                           Burst_Length;
   reg [ADDRESS_BUS_WIDTH-1:0]       Address_N;
   reg [ADDRESS_BUS_WIDTH-1:0]       Wrap_Boundary;
   reg [ADDRESS_BUS_WIDTH-1:0]       Lower_Byte_Lane;
   reg [ADDRESS_BUS_WIDTH-1:0]       Upper_Byte_Lane;
   integer                           strobe_index;

   begin
      // Initialize local variables
      transfer_number = transfer_number+1;

      Start_Address = address;
      Number_Bytes = transfer_size_in_bytes(size);
      Burst_Length = decode_burst_length(length);
      Aligned_Address = (Start_Address/Number_Bytes)*Number_Bytes;
      Data_Bus_Bytes = (DATA_BUS_WIDTH/8);

//      $display("STROBE : %s : Start_Address = 0x%0h : Number_Bytes = d%0d : Burst_Length = %0d : Aligned_Address = 0x%0h : Data_Bus_Bytes = d%0d",NAME,Start_Address,Number_Bytes,Burst_Length,Aligned_Address,Data_Bus_Bytes);

      if (transfer_number == 1 || burst_type == `AXI4_BURST_TYPE_FIXED) begin
         // First transfer
         Address_N = Start_Address;

//          $display("STROBE : %s : transfer_number = %0d : Address_N = 0x%0h",NAME,transfer_number,Address_N);

         // Calculate Byte Enable Ranges for generating the first strobe.
         Lower_Byte_Lane = Start_Address - ((Start_Address/Data_Bus_Bytes)*Data_Bus_Bytes);
         Upper_Byte_Lane = Aligned_Address + (Number_Bytes-1) - ((Start_Address/Data_Bus_Bytes)*Data_Bus_Bytes);

      end
      else begin
         // Subsequent transfers
         Address_N = Aligned_Address+((transfer_number-1)*Number_Bytes);

         // For Wrapped transfers work out the wrap boundary.
         if (burst_type == `AXI4_BURST_TYPE_WRAP) begin
            Wrap_Boundary = (Start_Address/(Number_Bytes*Burst_Length))*(Number_Bytes*Burst_Length);
            if (Address_N == (Wrap_Boundary+(Number_Bytes*Burst_Length))) begin
               Address_N = Wrap_Boundary;
            end
            else begin
               // If the current address is over the wrap boundary then recalculate the address.
               if(Address_N > (Wrap_Boundary+(Number_Bytes*Burst_Length))) begin
                  Address_N = Start_Address + ((transfer_number-1)*Number_Bytes) - (Number_Bytes*Burst_Length);
               end
            end
         end
         // Calculate Byte Enable Ranges for generating the subsequent strobes.
         Lower_Byte_Lane = Address_N - ((Address_N/Data_Bus_Bytes)*Data_Bus_Bytes);
         Upper_Byte_Lane = Lower_Byte_Lane + Number_Bytes - 1;

//         $display("STROBE : %s : transfer_number = %0d : Address_N = 0x%0h",NAME,transfer_number,Address_N);

      end

      // Using the Upper and Lower Byte Lane ranges, generate the strobe signal.
      calculate_strobe = 0;

      for (strobe_index = Lower_Byte_Lane; strobe_index <= Upper_Byte_Lane; strobe_index = strobe_index+1) begin
         calculate_strobe[strobe_index] = 1;
      end

//      $display("STROBE : %s : t = %0d : calculate_strobe = 4'b%4b : address = 0x%h : burst_type = %0d : transfer size = %0d",NAME,transfer_number,calculate_strobe, address, burst_type,Number_Bytes);
//      $display("STROBE : %s : t = %0d : Lower_Byte_Lane = %0d : Upper_Byte_Lane = %0d",NAME,transfer_number,Lower_Byte_Lane,Upper_Byte_Lane);
   end
endfunction

//------------------------------------------------------------------------
// FUNCTION: calculate_response
//------------------------------------------------------------------------
// Description:
// calculate_response(lock_type)
// This function calculates the correct response based on the lock_type.
// i.e. OKAY or EXOKAY
//------------------------------------------------------------------------
function [`AXI4_RESP_BUS_WIDTH-1:0] calculate_response;
   input [`AXI4_LOCK_BUS_WIDTH-1:0]  lock_type;
   begin
      case (lock_type)
        `AXI4_LOCK_TYPE_NORMAL : calculate_response = `AXI4_RESPONSE_OKAY;
        `AXI4_LOCK_TYPE_EXCLUSIVE : begin
           if (EXCLUSIVE_ACCESS_SUPPORTED == 1) begin
             calculate_response = `AXI4_RESPONSE_EXOKAY;
           end
           else begin
             calculate_response = `AXI4_RESPONSE_OKAY;
           end
        end
        default: calculate_response = `AXI4_RESPONSE_SLVERR;
      endcase
   end
endfunction

//------------------------------------------------------------------------
// API TASKS/FUNCTIONS
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// API TASK: set_channel_level_info
//------------------------------------------------------------------------
// set_channel_level_info(level)
// Description:
// This task sets the CHANNEL_LEVEL_INFO internal variable to the
// specified input value.
//------------------------------------------------------------------------
task automatic set_channel_level_info;
   input level;
   begin
      $display("[%0t] : %s : *INFO : Setting CHANNEL_LEVEL_INFO to %0d",$time,NAME,level);
      CHANNEL_LEVEL_INFO = level;
   end
endtask

//------------------------------------------------------------------------
// API TASK: set_function_level_info
//------------------------------------------------------------------------
// set_function_level_info(level)
// Description:
// This task sets the FUNCTION_LEVEL_INFO internal variable to the
// specified input value.
//------------------------------------------------------------------------
task automatic set_function_level_info;
   input level;
   begin
      //$display("[%0t] : %s : *INFO : Setting FUNCTION_LEVEL_INFO to %0d",$time,NAME,level);
      FUNCTION_LEVEL_INFO = level;
   end
endtask

//------------------------------------------------------------------------
// API TASK: set_stop_on_error
//------------------------------------------------------------------------
// set_stop_on_error(level)
// Description:
// This task sets the STOP_ON_ERROR internal variable to the
// specified input value.
//------------------------------------------------------------------------
task automatic set_stop_on_error;
   input level;
   begin
      $display("[%0t] : %s : *INFO : Setting STOP_ON_ERROR to %0d",$time,NAME,level);
      STOP_ON_ERROR = level;
   end
endtask

//------------------------------------------------------------------------
// API TASK: set_clear_signals_after_handshake
//------------------------------------------------------------------------
// set_clear_signals_after_handshake(level)
// Description:
// This task sets the CLEAR_SIGNALS_AFTER_HANDSHAKE internal variable
// to the specified input value.
//------------------------------------------------------------------------
task automatic set_clear_signals_after_handshake;
   input level;
   begin
      $display("[%0t] : %s : *INFO : Setting CLEAR_SIGNALS_AFTER_HANDSHAKE to %0d",$time,NAME,level);
      CLEAR_SIGNALS_AFTER_HANDSHAKE = level;
   end
endtask

//------------------------------------------------------------------------
// API TASK: set_response_timeout
//------------------------------------------------------------------------
// set_response_timeout(level)
// Description:
// This task sets the RESPONSE_TIMEOUT internal variable to the
// specified input value.
//------------------------------------------------------------------------
task automatic set_response_timeout;
   input integer level;
   begin
      $display("[%0t] : %s : *INFO : Setting RESPONSE_TIMEOUT to %0d",$time,NAME,level);
      RESPONSE_TIMEOUT = level;
   end
endtask

//------------------------------------------------------------------------
// UTILITY FUNCTIONS
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// API TASK: set_task_call_and_reset_handling(task_reset_handling)
// Description:
// This task sets the TASK_RESET_HANDLING internal variable to the
// specified input value.
// 0 - Ignore reset and continue to process task (default)
// 1 - Stall task execution until out of reset and print info message.
// 2 - Issue an error and stop (depending on STOP_ON_ERROR value)
// 3 - Issue a warning and continue
//------------------------------------------------------------------------
task automatic set_task_call_and_reset_handling;
   input integer task_reset_handling;
   begin
      $display("[%0t] : %s : *INFO : Setting TASK_RESET_HANDLING to %0d",$time,NAME,task_reset_handling);
      TASK_RESET_HANDLING = task_reset_handling;
   end
endtask

//------------------------------------------------------------------------
// task_reset_handling
// Description:
// This task is used to handle reset inside the channel level tasks
// based on the value of TASK_RESET_HANDLING
// 0 - Ignore reset and continue to process task (default)
// 1 - Stall task execution until out of reset and print info message.
// 2 - Issue an error and stop (depending on STOP_ON_ERROR value)
// 3 - Issue a warning and continue
//------------------------------------------------------------------------
task automatic task_reset_handling;
    begin
        if (!ARESETn) begin
            case(TASK_RESET_HANDLING)
              1 : begin
                  $display("[%0t] : %s : *INFO : Channel Level Task called during reset - Waiting until reset is clear before continuing task call.",$time,NAME);
                  while(!ARESETn) @(bfm_aclk);
              end
              2 : begin
                  $display("[%0t] : %s : *ERROR : Channel Level Task called during reset",$time,NAME);
                  if(STOP_ON_ERROR == 1) begin
                      $display("*** TEST FAILED");
                      $stop;
                  end
                  error_count = error_count+1;
              end
              3 : begin
                  $display("[%0t] : %s : *WARNING : Channel Level Task called during reset - ignoring reset and continuing task execution.",$time,NAME);
                  warning_count = warning_count+1;
              end
            endcase
        end
   end
endtask

//------------------------------------------------------------------------
// set_bfm_clk_delay(clk_delay)
// Description:
// This task sets the BFM_CLK_DELAY internal variable to the
// specified input value.
//------------------------------------------------------------------------
task automatic set_bfm_clk_delay;
   input integer clk_delay;
   begin
      $display("[%0t] : %s : *INFO : Setting BFM_CLK_DELAY to %0d",$time,NAME,clk_delay);
      BFM_CLK_DELAY = clk_delay;
   end
endtask

//------------------------------------------------------------------------
// API TASK: set_disable_reset_value_checks
//------------------------------------------------------------------------
// set_disable_reset_value_checks(disable_value)
// Description:
// This task sets the DISABLE_RESET_VALUE_CHECKS internal variable
// to the specified input value.
// 0 means enabled
// 1 means disabled
//------------------------------------------------------------------------
task automatic set_disable_reset_value_checks;
   input disable_value;
   begin
      $display("[%0t] : %s : *INFO : Setting DISABLE_RESET_VALUE_CHECKS to %0d",$time,NAME,disable_value);
      DISABLE_RESET_VALUE_CHECKS = disable_value;
   end
endtask

//------------------------------------------------------------------------
// UTILITY FUNCTION: report_status
//------------------------------------------------------------------------
// report_status(0)
// Description:
// This function prints out the current status of the BFM. A return value
// of zero means status OK. Non-zero means errors, warnings and/or pending
// transactions.
//------------------------------------------------------------------------
function integer report_status;
   input dummy_bit;
   begin
      $display("[%0t] : %s : *INFO : REPORT_STATUS : errors = %0d, warnings = %0d, pending transactions = %0d",$time,NAME,error_count,warning_count,pending_transactions_count);
      report_status = error_count + warning_count + pending_transactions_count;
   end
endfunction

//------------------------------------------------------------------------
// UTILITY TASK: add_pending_transaction;
//------------------------------------------------------------------------
// add_pending_transaction
// Description:
// This task checks the current pending transactions count and checks it
// with the value of MAX_OUTSTANDING_TRANSACTIONS. If the count is less
// than this value then the transaction can proceed, otherwise it must wait
// i.e. this task is blocking.
//------------------------------------------------------------------------
task automatic add_pending_transaction;
   reg print_message;
   begin
      print_message = 1;
      while (pending_transactions_count == MAX_OUTSTANDING_TRANSACTIONS) begin
         if (print_message == 1) begin
            $display("[%0t] : %s : *INFO : Reached the maximum outstanding transactions limit (%0d). Blocking all future transactions until at least 1 of the outstanding transactions has completed.",$time,NAME,pending_transactions_count);
            print_message = 0;
         end
         @(posedge ACLK);
      end
      pending_transactions_count = pending_transactions_count+1;
   end
endtask

//------------------------------------------------------------------------
// UTILITY TASK: remove_pending_transaction;
//------------------------------------------------------------------------
// remove_pending_transaction
// Description:
// This task decrements the pending transactions count.
//------------------------------------------------------------------------
task automatic remove_pending_transaction;
   begin
      pending_transactions_count = pending_transactions_count-1;
   end
endtask

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Reset Logic and Reset Check
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. The outputs of this BFM should be driven to the correct reset values.
   // 3. The inputs to this BFM should be checked for the correct reset values.
   // NOTE: The ready signal inputs can be ignored as they may be tied to 1.
   //------------------------------------------------------------------------
   always @(posedge ACLK) begin
      if (!ARESETn) begin
         //------------------------------------------------------------------
         // Step 1. Display INFO Message
         //------------------------------------------------------------------
         if(reset_message_done == 0) begin
             $display("[%0t] : %s : *INFO : Reset detected - setting output signals to reset values and checking input signals for correct reset values.",$time,NAME);
         end

         //------------------------------------------------------------------
         // Step 2. Drive outputs to reset values.
         //------------------------------------------------------------------

         // Write Address Channel Signals.
         AWID <= 0;
         AWADDR <= 0;
         AWLEN <= 0;
         AWSIZE <= 0;
         AWBURST <= 0;
         AWLOCK <= 0;
         AWCACHE <= 0;
         AWPROT <= 0;
         AWREGION <= 0;
         AWQOS <= 0;
         AWUSER <= 0;
         AWVALID <= 0;

         // Write Data Channel Signals.
         WDATA <= 0;
         WSTRB <= 0;
         WLAST <= 0;
         WUSER <= 0;
         WVALID <= 0;

         // Write Response Channel Signals.
         BREADY <= 0;

         // Read Address Channel Signals.
         ARID <= 0;
         ARADDR <= 0;
         ARLEN <= 0;
         ARSIZE <= 0;
         ARBURST <= 0;
         ARLOCK <= 0;
         ARCACHE <= 0;
         ARPROT <= 0;
         ARREGION <= 0;
         ARQOS <= 0;
         ARUSER <= 0;
         ARVALID <= 0;

         // Read Data Channel Signals.
         RREADY <= 0;

         //------------------------------------------------------------------
         // Step 3. Check input signals are at the correct reset values.
         //------------------------------------------------------------------
         // Wait a clock cycle for reset to take effect and then check reset
         // values on input signals from the slave/interconnect.
         @(posedge ACLK);

         if (BVALID !== 0 && DISABLE_RESET_VALUE_CHECKS == 0) begin
            $display("[%0t] : %s : *ERROR : BVALID from slave is not zero (reset value) - AMBA AXI SPEC V2 - Section 11.1.2 Reset",$time,NAME);
            if(STOP_ON_ERROR == 1) begin
              $display("*** TEST FAILED");
              $stop;
            end
            error_count = error_count+1;
         end

         if (RVALID !== 0 && DISABLE_RESET_VALUE_CHECKS == 0) begin
            $display("[%0t] : %s : *ERROR : RVALID from slave is not zero (reset value) - AMBA AXI SPEC V2 - Section 11.1.2 Reset",$time,NAME);

            if(STOP_ON_ERROR == 1) begin
               $display("*** TEST FAILED");
               $stop;
            end
            error_count = error_count+1;
         end
         if(DISABLE_RESET_VALUE_CHECKS == 0) begin
             if(reset_message_done == 0) begin
                 $display("[%0t] : %s : *INFO : Reset Checks Complete",$time,NAME);
             end
         end
         reset_message_done = 1;

      end // if (!ARESETn)
      else begin
         reset_message_done = 0;
      end
   end

   //------------------------------------------------------------------------
   // Reset Release Check
   //------------------------------------------------------------------------
   // Description:
   // Reset should be released on the rising edge of the ACLK.
   // It is hard to check this without assertions.
   //------------------------------------------------------------------------
   always @(posedge ARESETn) begin
      if (ACLK === 0 && $stime != 0) begin
         $display("[%0t] : %s : *ERROR : Invalid release of reset. Reset can be asserted asyncronously but must be deasserted on the rising edge of the clock - AMBA AXI SPEC V2 - Section 11.1.2 Reset",$time,NAME);

         if(STOP_ON_ERROR == 1) begin
           $display("*** TEST FAILED");
           $stop;
         end
         error_count = error_count+1;
      end
   end


   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: SEND_WRITE_ADDRESS
   //------------------------------------------------------------------------
   // Description:
   // SEND_WRITE_ADDRESS(ID,ADDR,LEN,SIZE,BURST,LOCK,CACHE,PROT,REGION,QOS,
   // AWUSER)
   // Creates a write address channel transaction.
   // This task returns after the write address has been acknowledged by the
   // slave.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO message.
   // 2. Check input parameters.
   // 3. Check if the write address bus is free or locked.
   // If free: lock and continue
   // If locked: then wait until free and lock it.
   // 4. Drive the Write Address Channel with AWVALID asserted.
   // 5. Wait for handshake on the next clk edge and de-assert AWVALID.
   // 6. Release write address bus lock.
   // 7. Emit write_address_transfer_complete event.
   //------------------------------------------------------------------------
   task automatic SEND_WRITE_ADDRESS;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
      input [`AXI4_PROT_BUS_WIDTH-1:0]   protection_type;
      input [`AXI4_REGION_BUS_WIDTH-1:0] region;
      input [`AXI4_QOS_BUS_WIDTH-1:0]    qos;
      input [AWUSER_BUS_WIDTH-1:0]  awuser;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : SEND_WRITE_ADDRESS Task Call - ",
                     $time,NAME,
                     "id = 0x%h",id,
                     ", address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",transfer_size_in_bytes(size),
                     ", burst_type = 0x%0h",burst_type,
                     ", lock_type = 0x%0h",lock_type,
                     ", cache_type = 0x%0h",cache_type,
                     ", protection_type = 0x%0h",protection_type,
                     ", region = 0x%0h",region,
                     ", qos = 0x%0h",qos,
                     ", awuser = 0x%0h",awuser);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Check input parameters.
         //------------------------------------------------------------------
         check_burst_type(burst_type);
         check_burst_length(burst_type,length,lock_type);
         check_burst_size(size);
         check_lock_type(lock_type);
         check_cache_type(cache_type);
         check_address(address,burst_type,size);

         //------------------------------------------------------------------
         // Step 3. Check if the write address bus is free or locked.
         // If free: lock and continue
         // If locked: then wait until free and lock it.
         //------------------------------------------------------------------
         if (write_address_bus_locked == 1'b1) begin
            wait(write_address_bus_locked == 1'b0);
         end
         write_address_bus_locked = 1'b1;

         add_pending_transaction;

         //------------------------------------------------------------------
         // Step 4. Drive the Write Address Channel with AWVALID asserted.
         //------------------------------------------------------------------
         AWID <= id;
         AWADDR <= address;
         AWLEN <= length;
         AWSIZE <= size;
         AWBURST <= burst_type;
         AWLOCK <= lock_type;
         AWCACHE <= cache_type;
         AWPROT <= protection_type;
         AWREGION <= region;
         AWQOS <= qos;
         AWUSER <= awuser;
         AWVALID <= 1;
         //------------------------------------------------------------------
         // Step 5. Wait for handshake on the next clk edge and
         // de-assert AWVALID.
         //------------------------------------------------------------------
         @(posedge bfm_aclk);
         while (!(AWREADY === 1 && AWVALID === 1)) @(posedge bfm_aclk);
         AWVALID <= 0;

         if (CLEAR_SIGNALS_AFTER_HANDSHAKE == 1'b1) begin
             AWID <= 0;
             AWADDR <= 0;
             AWLEN <= 0;
             AWSIZE <= 0;
             AWBURST <= 0;
             AWLOCK <= 0;
             AWCACHE <= 0;
             AWPROT <= 0;
             AWREGION <= 0;
             AWQOS <= 0;
             AWUSER <= 0;
         end

         //------------------------------------------------------------------
         // Step 6. Release write address bus lock.
         //------------------------------------------------------------------
         write_address_bus_locked = 1'b0;

         //------------------------------------------------------------------
         // Step 7. Emit write_address_transfer_complete event.
         //------------------------------------------------------------------
         -> write_address_transfer_complete;

      end
   endtask

   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: SEND_WRITE_DATA
   //------------------------------------------------------------------------
   // Description:
   // SEND_WRITE_DATA(STROBE,DATA,LAST,WUSER)
   // Creates a single write data channel transaction. If a burst is needed
   // then control of the LAST flag must be taken. The data should
   // be the same size as the width of the data bus. This task returns after
   // is has been acknowledged by the slave. NOTE: This would need to be
   // called multiple times for a burst.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Check if the write data bus is free or locked.
   // If free: lock and continue
   // If locked: then wait until free and lock it.
   // 3. Drive the Write Data Channel with WVALID asserted.
   // 4. Wait for handshake on the next clk edge and de-assert WVALID and ensure
   // that WLAST is low.
   // 5. Release write data bus lock.
   // 6. Emit write_data_transfer_complete event.
   //------------------------------------------------------------------------
   task automatic SEND_WRITE_DATA;
      input [(DATA_BUS_WIDTH/8)-1:0] strobe;
      input [DATA_BUS_WIDTH-1:0]     wr_data;
      input                          last;
      input [WUSER_BUS_WIDTH-1:0]    wuser;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : SEND_WRITE_DATA Task Call - ",
                     $time,NAME,
                     "strobe = 0x%0h",strobe,
                     ", data = 0x%0h",wr_data,
                     ", last = 0x%0h",last,
                     ", wuser = 0x%0h",wuser);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Check if the write data bus is free or locked.
         // If free: lock and continue
         // If locked: then wait until free and lock it.
         // Check the write order is allowed before locking the bus.
         //------------------------------------------------------------------
         if (write_data_bus_locked == 1'b1) begin
            wait(write_data_bus_locked == 1'b0);
         end
         write_data_bus_locked = 1'b1;

         //------------------------------------------------------------------
         // Step 3. Drive the Write Data Channel with WVALID asserted.
         //------------------------------------------------------------------
         WSTRB <= strobe;
         WDATA <= wr_data;
         WLAST <= last;
         WUSER <= wuser;
         WVALID <= 1;

         //------------------------------------------------------------------
         // Step 4. Wait for handshake on the next clk edge and de-assert
         // WVALID and ensure that WLAST is low.
         //------------------------------------------------------------------
         @(posedge bfm_aclk);
         while (!(WREADY === 1 && WVALID === 1)) @(posedge bfm_aclk);
         WVALID <= 0;
         WLAST <= 0;

         if (CLEAR_SIGNALS_AFTER_HANDSHAKE == 1'b1) begin
             WSTRB <= 0;
             WDATA <= 0;
             WLAST <= 0;
             WUSER <= 0;
         end

         //------------------------------------------------------------------
         // Step 5. Release write data bus lock.
         //------------------------------------------------------------------
         write_data_bus_locked = 1'b0;

         //------------------------------------------------------------------
         // Step 6. Emit write_data_transfer_complete event.
         //------------------------------------------------------------------
         -> write_data_transfer_complete;
      end
   endtask


   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: SEND_READ_ADDRESS
   //------------------------------------------------------------------------
   // Description:
   // SEND_READ_ADDRESS(ID,ADDR,LEN,SIZE,BURST,LOCK,CACHE,PROT,REGION,QOS,
   // ARUSER)
   // Creates a read address channel transaction. This task returns after the
   // read address has been acknowledged by the slave.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Check input parameters.
   // 3. Check if the read address bus is free or locked.
   // If free: lock and continue
   // If locked: then wait until free and lock it.
   // 4. Drive the Read Address Channel with ARVALID asserted.
   // 5. Wait for handshake on the next clk edge and de-assert ARVALID.
   // 6. Release read address bus lock.
   // 7. Emit read_address_transfer_complete event.
   //------------------------------------------------------------------------
   task automatic SEND_READ_ADDRESS;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
      input [`AXI4_PROT_BUS_WIDTH-1:0]   protection_type;
      input [`AXI4_REGION_BUS_WIDTH-1:0] region;
      input [`AXI4_QOS_BUS_WIDTH-1:0]    qos;
      input [ARUSER_BUS_WIDTH-1:0]  aruser;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : SEND_READ_ADDRESS Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",transfer_size_in_bytes(size),
                     ", burst_type = 0x%0h",burst_type,
                     ", lock_type = 0x%0h",lock_type,
                     ", cache_type = 0x%0h",cache_type,
                     ", protection_type = 0x%0h",protection_type,
                     ", region = 0x%0h",region,
                     ", qos = 0x%0h",qos,
                     ", aruser = 0x%0h",aruser);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Check input parameters.
         //------------------------------------------------------------------
         check_burst_type(burst_type);
         check_burst_length(burst_type,length,lock_type);
         check_burst_size(size);
         check_lock_type(lock_type);
         check_cache_type(cache_type);
         check_address(address,burst_type,size);

         //------------------------------------------------------------------
         // Step 3. Check if the read address bus is free or locked.
         // If free: lock and continue
         // If locked: then wait until free and lock it.
         //------------------------------------------------------------------
         if (read_address_bus_locked == 1'b1) begin
            wait(read_address_bus_locked == 1'b0);
         end
         read_address_bus_locked = 1'b1;
         add_pending_transaction;

         //------------------------------------------------------------------
         // Step 4. Drive the Read Address Channel with ARVALID asserted.
         //------------------------------------------------------------------
         ARID <= id;
         ARADDR <= address;
         ARLEN <= length;
         ARSIZE <= size;
         ARBURST <= burst_type;
         ARLOCK <= lock_type;
         ARCACHE <= cache_type;
         ARPROT <= protection_type;
         ARREGION <= region;
         ARQOS <= qos;
         ARUSER <= aruser;
         ARVALID <= 1;

         //------------------------------------------------------------------
         // Step 5. Wait for handshake on the next clk edge and de-assert
         // ARVALID.
         //------------------------------------------------------------------
         @(posedge bfm_aclk);
         while (!(ARREADY === 1 && ARVALID === 1)) @(posedge bfm_aclk);
         ARVALID <= 0;

         if (CLEAR_SIGNALS_AFTER_HANDSHAKE == 1'b1) begin
             ARID <= 0;
             ARADDR <= 0;
             ARLEN <= 0;
             ARSIZE <= 0;
             ARBURST <= 0;
             ARLOCK <= 0;
             ARCACHE <= 0;
             ARPROT <= 0;
             ARREGION <= 0;
             ARQOS <= 0;
             ARUSER <= 0;
         end

         //------------------------------------------------------------------
         // Step 6. Release read address bus lock.
         //------------------------------------------------------------------
         read_address_bus_locked = 1'b0;

         //------------------------------------------------------------------
         // Step 7. Emit read_address_transfer_complete event.
         //------------------------------------------------------------------
         -> read_address_transfer_complete;
      end
   endtask

   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: RECEIVE_READ_DATA
   //------------------------------------------------------------------------
   // Description:
   // RECEIVE_READ_DATA(ID,DATA,RESPONSE,LAST,RUSER)
   // This task drives the RREADY signal and monitors the read data bus for
   // read transfers coming from the slave that have the specified ID tag.
   // It then returns the data associated with the transaction and the status
   // of the last flag. NOTE: This would need to be called multiple times for
   // a burst > 1.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Drive RREADY and Wait for RVALID to be asserted and the RID to be
   // the expected id.
   // If it is then sample RDATA, RRESP, RLAST and RUSER.
   // If not reassert RREADY, increment the timeout counter and wait
   // for RVALID and RID again or timeout with error message.
   // 3. Display INFO Message containing the sampled values.
   // 4. Check Response
   // 5. De-assert RREADY.
   // 6. Emit read_data_transfer_complete event.
   //------------------------------------------------------------------------
   task automatic RECEIVE_READ_DATA;
      input [ID_BUS_WIDTH-1:0]      id;
      output [DATA_BUS_WIDTH-1:0]   rd_data;
      output [`AXI4_RESP_BUS_WIDTH-1:0]  response;
      output                        last;
      output [AWUSER_BUS_WIDTH-1:0] ruser;
      integer                       timeout_counter;
      reg                           trigger_condition;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : RECEIVE_READ_DATA Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Drive RREADY and Wait for RVALID to be asserted and the
         // RID to be the expected id.
         // If it is then sample RDATA, RRESP, RLAST and RUSER.
         // If not reassert RREADY, increment the timeout counter and wait
         // for RVALID and RID again or timeout with error message.
         //------------------------------------------------------------------
         trigger_condition = 0;

         timeout_counter = 0;
         RREADY <= 1;

         while (!trigger_condition) @(posedge bfm_aclk) begin
         RREADY <= 1;
            trigger_condition = (RVALID === 1 && RREADY === 1 && RID === id);

            timeout_counter = timeout_counter+1;
            if (timeout_counter == RESPONSE_TIMEOUT) begin
               $display("[%0t] : %s : *ERROR : RECEIVE_READ_DATA Task TIMEOUT - ",$time,NAME,
                        "TASK timed out waiting for a READ DATA transfer with the id = 0x%h",id);
               $stop;
            end
         end
         // Sample the signals.
         rd_data = RDATA;
         response = RRESP;
         last = RLAST;
         ruser = RUSER;


         //------------------------------------------------------------------
         // Step 3. Display INFO Message containing the sampled values.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : RECEIVE_READ_DATA Task - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", rd_data = 0x%0h",rd_data,
                     ", response = 0x%0h",response,
                     ", last = 0x%0h",last,
                     ", ruser = 0x%0h",ruser);
         end

         //------------------------------------------------------------------
         // Step 4. Check Response
         //------------------------------------------------------------------
         check_response_value(id,response,0);

         //------------------------------------------------------------------
         // Step 5. De-assert RREADY.
         //------------------------------------------------------------------
         if (pending_transactions_count == 1) RREADY <= 0;

         //------------------------------------------------------------------
         // Step 6. Emit read_data_transfer_complete event.
         //------------------------------------------------------------------
         -> read_data_transfer_complete;

      end
   endtask

   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: RECEIVE_WRITE_RESPONSE
   //------------------------------------------------------------------------
   // Description:
   // RECEIVE_WRITE_RESPONSE(ID,RESPONSE,BUSER)
   // This task drives the BREADY signal and monitors the write response bus
   // for write responses coming from the slave that have the specified ID
   // tag. It then returns the response associated with the transaction.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Drive BREADY and Wait for BVALID to be asserted and the BID to be
   // the expected id.
   // If it is then sample BRESP and BUSER.
   // If not reassert BREADY, increment the timeout counter and wait
   // for BVALID and BID again or timeout with error message.
   // 3. Display INFO Message containing the sampled value.
   // 4. Check response.
   // 5. De-assert BREADY and remove from pending transactions
   // 6. Emit write_response_transfer_complete event.
   //------------------------------------------------------------------------
   task automatic RECEIVE_WRITE_RESPONSE;
      input [ID_BUS_WIDTH-1:0]  id;
      output [`AXI4_RESP_BUS_WIDTH-1:0] response;
      output [BUSER_BUS_WIDTH-1:0] buser;
      integer                      timeout_counter;
      reg                          trigger_condition;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : RECEIVE_WRITE_RESPONSE Task Call - "
                     ,$time,NAME,
                     "id = 0x%0h",id);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Drive BREADY and Wait for BVALID to be asserted and the
         // BID to be the expected id.
         // If it is then sample BRESP.
         // If not reassert BREADY, increment the timeout counter and wait
         // for BVALID and BID again or timeout with error message.
         //------------------------------------------------------------------
         trigger_condition = 0;

         timeout_counter = 0;
         BREADY <= 1;

         while (!trigger_condition) @(posedge bfm_aclk) begin
            BREADY <= 1;
            trigger_condition = (BVALID === 1 && BREADY === 1 && BID === id);
            timeout_counter = timeout_counter+1;
            if (timeout_counter == RESPONSE_TIMEOUT) begin
               $display("[%0t] : %s : *ERROR : RECEIVE_WRITE_RESPONSE Task TIMEOUT - ",$time,NAME,
                        " TASK timed out waiting for a WRITE RESPONSE transfer with the id = 0x%h",id);
               $stop;
            end
         end
         // Sample the BRESP and BUSER signals.
         response = BRESP;
         buser = BUSER;

         //------------------------------------------------------------------
         // Step 3. Display INFO Message containing the sampled value.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : RECEIVE_WRITE_RESPONSE Task - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", response = 0x%0h",response,
                     ", buser = 0x%0h",buser);
         end

         //------------------------------------------------------------------
         // Step 4. Check Response
         //------------------------------------------------------------------
         check_response_value(id,response,1);

         //------------------------------------------------------------------
         // Step 5. De-assert BREADY and remove from pending transactions
         //------------------------------------------------------------------
         BREADY <= 0;
         remove_pending_transaction;

         //------------------------------------------------------------------
         // Step 6. Emit write_response_transfer_complete event.
         //------------------------------------------------------------------
         -> write_response_transfer_complete;

      end
   endtask

   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: SEND_WRITE_BURST
   //------------------------------------------------------------------------
   // Description:
   // SEND_WRITE_BURST(ADDR,LEN,SIZE,BURST,DATA,DATASIZE,WUSER)
   // This task does a write burst on the write data lines. It does not
   // execute the write address transfer.
   // This task uses the SEND_WRITE_DATA task from the channel level API.
   // This task returns when the complete write burst is complete.
   // This task automatically supports the generation of narrow transfers and
   // unaligned transfers i.e. this task aligns the input data with the
   // burst so data padding is not required.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Call the SEND_WRITE_DATA task to start sending the write data onto
   // the write data channel. This needs to be done until the burst is
   // complete and the last burst is marked with the last signal asserted.
   // 3. Emit write_data_burst_complete event.
   //------------------------------------------------------------------------
   task automatic SEND_WRITE_BURST;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [(DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] wr_data;
      input integer                                      datasize;
      input [(WUSER_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] v_wuser;
      reg [DATA_BUS_WIDTH-1:0]      wr_data_slice;
      reg [WUSER_BUS_WIDTH-1:0]     wuser;
      reg                           last;
      reg [(DATA_BUS_WIDTH/8)-1:0]  strobe;
      integer                       wr_transfer_count;
      integer                       trans_size_in_bytes;
      integer                       byte_number;
      integer                       slice_byte_number;
      integer                       strobe_index;
      integer                       i;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         trans_size_in_bytes = transfer_size_in_bytes(size);

         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : SEND_WRITE_BURST Task Call - ",
                     $time,NAME,
                     "address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",trans_size_in_bytes,
                     ", burst_type = 0x%0h",burst_type,
                     ", valid data size (in bytes) = %0d",datasize);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Call the SEND_WRITE_DATA task to start sending the write
         // data onto the write data channel. This needs to be done until the
         // burst is complete and the last burst is marked with the last
         // signal asserted.
         //------------------------------------------------------------------

         // Send the complete write burst data
         byte_number = 0;
         for (wr_transfer_count = 0; wr_transfer_count <= length; wr_transfer_count = wr_transfer_count+1) begin
            if (wr_transfer_count == length) begin

               last = 1;
            end
            else begin
               last = 0;
            end

            // Calculate the stobe required for this transfer.
            strobe = calculate_strobe(wr_transfer_count,address,length,size,burst_type);
            // Check if the number of bytes transmitted does not exceed the
            // valid datasize. If it is going to on the current transfer then
            // modify the strobe as it controls the data transfer.
            // ASSUMPTION: This code is for the condition that the burst size is
            // greater than the data to send.
            if(datasize < (trans_size_in_bytes*decode_burst_length(length))) begin
              if (datasize <= byte_number+(DATA_BUS_WIDTH/8)) begin
               // Reset the strobe.
               strobe = 0;
               // Build the final sparse strobe.
               for (i=0; i<(datasize-byte_number); i=i+1) begin
                  strobe[i] = 1'b1;
               end
              end
            end

            // Align the input data to the valid bytes of the transfer.
            slice_byte_number = 0;
            for (strobe_index = 0; strobe_index < (DATA_BUS_WIDTH/8); strobe_index = strobe_index+1) begin
               if (strobe[strobe_index] == 1) begin
                  wr_data_slice[slice_byte_number*8 +: 8] = wr_data[byte_number*8 +: 8];
                  // Only increment the byte number if the byte is used.
                  byte_number = byte_number+1;
               end
               else begin

                  wr_data_slice[slice_byte_number*8 +: 8] = 0;
               end
               slice_byte_number = slice_byte_number+1;
            end

            wuser = v_wuser[wr_transfer_count*WUSER_BUS_WIDTH +: WUSER_BUS_WIDTH];

            SEND_WRITE_DATA(strobe,wr_data_slice,last,wuser);
            // No need to insert a gap after the last transfer.
            if (last != 1) begin
                if (WRITE_BURST_DATA_TRANSFER_GAP == 0) begin
                    WVALID <= 1;
                end
                repeat(WRITE_BURST_DATA_TRANSFER_GAP) @(posedge bfm_aclk);
            end
         end

         //------------------------------------------------------------------
         // Step 3. Emit write_data_burst_complete event.
         //------------------------------------------------------------------
         -> write_data_burst_complete;

      end
   endtask

   //------------------------------------------------------------------------
   // CHANNEL LEVEL API: RECEIVE_READ_BURST
   //------------------------------------------------------------------------
   // Description:
   // RECEIVE_READ_BURST(ID,ADDR,LEN,SIZE,BURST,LOCK,DATA,RESPONSE,RUSER)
   // This task receives a read channel burst based on the id input.
   // The RECEIVE_READ_DATA from the channel level API is used.
   // This task returns when the complete read transaction is complete.
   // The response output vector is generated by concatenating all slave
   // responses together.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Call the RECEIVE_READ_DATA task to collect the read channel
   // transfers associated with this burst. Keep reading data until last has
   // been flagged.
   // Check the length of the burst is correct.
   // Check each response and issue a warning if not as expected.
   // 3. Remove from pending transactions
   // 4. Emit read_data_burst_complete event.
   //------------------------------------------------------------------------
   task automatic RECEIVE_READ_BURST;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      output [(DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] rd_data;
      output [(`AXI4_RESP_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] response;
      output [(RUSER_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] v_ruser;
      reg [DATA_BUS_WIDTH-1:0]      rd_data_slice;
      reg [RUSER_BUS_WIDTH-1:0]     ruser;
      reg [(DATA_BUS_WIDTH/8)-1:0]  strobe;
      integer                       rd_transfer_count;
      integer                       byte_number;
      integer                       slice_byte_number;
      integer                       strobe_index;
      reg                           last;
      reg [`AXI4_RESP_BUS_WIDTH-1:0]     local_response;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (CHANNEL_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : RECEIVE_READ_BURST Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id);
         end

         task_reset_handling;

         //------------------------------------------------------------------
         // Step 2. Call the RECEIVE_READ_DATA task to collect the read
         // channel transfers associated with this burst. Keep reading data
         // until last has been flagged.
         // Check the length of the burst is correct.
         //------------------------------------------------------------------
         rd_transfer_count = 0;
         last = 0;
         response = 0;
         local_response = 0;
         byte_number = 0;
         while (last !== 1) begin
            RECEIVE_READ_DATA(id,rd_data_slice,local_response,last,ruser);
            if (last === 0) RREADY <= 1;
            // Check the length of the burst is correct.
            if (rd_transfer_count > length) begin
               $display("[%0t] : %s : *ERROR : RECEIVE_READ_BURST Task - ",
                        $time,NAME,
                        " The number of READ transfers with the id = 0x%h",id,
                        " is greater than the burst length i.e. length = %0d",
                        decode_burst_length(length),
                        " != # of transfers = %0d",rd_transfer_count);

               if(STOP_ON_ERROR == 1) begin
                 $display("*** TEST FAILED");
                 $stop;
               end
               error_count = error_count+1;
            end
            // Check each response and issue a warning if not as expected.
            if (local_response != calculate_response(lock_type)) begin
               $display("[%0t] : %s : *WARNING : Read Burst Response (id=%0d) = %0d but %0d was expected! (lock_type = 0x%0h)",
                        $time,NAME,id,local_response,
                        calculate_response(lock_type),lock_type);
               warning_count = warning_count+1;
            end

            // Concatenate the responses together to make the final response
            // vector.
            response[rd_transfer_count*`AXI4_RESP_BUS_WIDTH +: `AXI4_RESP_BUS_WIDTH] = local_response;
            // Concatenate the ruser data responses together to make a vector
            v_ruser[rd_transfer_count*RUSER_BUS_WIDTH +: RUSER_BUS_WIDTH] = ruser;

            if (CHANNEL_LEVEL_INFO == 1) begin
               $display("[%0t] : %s : *INFO : RECEIVE_READ_BURST Task - ",
                        $time,NAME,
                        "id = 0x%h",id,
                        ", read data = 0x%h",rd_data_slice,
                        ", transfer number = %0d of %0d",rd_transfer_count+1,
                        decode_burst_length(length),
                        ", last = %0d",last);
            end

            // Calculate the stobe that would be required for this type of
            // transfer.
            strobe = calculate_strobe(rd_transfer_count,
                                      address,
                                      length,
                                      size,
                                      burst_type);

            // Align the valid bytes of the read transfer data to the output
            // data vector.
            slice_byte_number = 0;
            for (strobe_index = 0; strobe_index < (DATA_BUS_WIDTH/8); strobe_index = strobe_index+1) begin
               if (strobe[strobe_index] == 1) begin
                  rd_data[byte_number*8 +: 8] = rd_data_slice[slice_byte_number*8 +: 8];
                  // Only increment the byte number if the byte is used.
                  byte_number = byte_number+1;
               end
               slice_byte_number = slice_byte_number+1;
            end
            rd_transfer_count = rd_transfer_count+1;
         end
         // Check the final burst length was not too small.
         if (rd_transfer_count+1 < length) begin
            $display("[%0t] : %s : *ERROR : RECEIVE_READ_BURST Task - ",$time,NAME,
                     " The number of READ transfers with the id = 0x%h",id,
                     " is less than the burst length i.e. length = %0d",decode_burst_length(length),
                     " != # of transfers = %0d",rd_transfer_count);
            if(STOP_ON_ERROR == 1) begin
               $display("*** TEST FAILED");
               $stop;
            end
            error_count = error_count+1;
         end

         //------------------------------------------------------------------
         // Step 3. Remove from pending transactions
         //------------------------------------------------------------------
         remove_pending_transaction;
         if (pending_transactions_count == 0) RREADY <= 0;

         //------------------------------------------------------------------
         // Step 4. Emit read_data_burst_complete event.
         //------------------------------------------------------------------
         -> read_data_burst_complete;
      end
   endtask

   //------------------------------------------------------------------------
   // FUNCTION LEVEL API: READ_BURST
   //------------------------------------------------------------------------
   // Description:
   // READ_BURST(ID,ADDR,LEN,SIZE,BURST,LOCK,CACHE,PROT,REGION,QOS,ARUSER,
   // DATA,RESPONSE,RUSER)
   // This task does a full read process. It is composed of the tasks
   // SEND_READ_ADDRESS and RECEIVE_READ_BURST from the channel level API.
   // This task returns when the complete read transaction is complete.
   // Most of the input values are checked in the channel level API.
   // The response output vector is generated by concatenating all slave
   // responses together.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Call the SEND_READ_ADDRESS task to start a read address channel
   // access.
   // 3. Call the RECEIVE_READ_BURST task to collect the read channel
   // transfers associated with this burst.
   //------------------------------------------------------------------------
   task automatic READ_BURST;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
      input [`AXI4_PROT_BUS_WIDTH-1:0]   protection_type;
      input [`AXI4_REGION_BUS_WIDTH-1:0] region;
      input [`AXI4_QOS_BUS_WIDTH-1:0]    qos;
      input [ARUSER_BUS_WIDTH-1:0]  aruser;
      output [(DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] rd_data;
      output [(`AXI4_RESP_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] response;
      output [(RUSER_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] v_ruser;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         if (FUNCTION_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : READ_BURST Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",transfer_size_in_bytes(size),
                     ", burst_type = 0x%0h",burst_type,
                     ", lock_type = 0x%0h",lock_type,
                     ", cache_type = 0x%0h",cache_type,
                     ", protection_type = 0x%0h",protection_type,
                     ", region = 0x%0h",region,
                     ", qos = 0x%0h",qos,
                     ", aruser = 0x%0h",aruser);
         end

         //------------------------------------------------------------------
         // Step 2. Call the SEND_READ_ADDRESS task to start a read address
         // channel access.
         //------------------------------------------------------------------
         SEND_READ_ADDRESS(id, address, length, size, burst_type, lock_type, cache_type, protection_type, region, qos, aruser);

         //------------------------------------------------------------------
         // Step 3. Call the RECEIVE_READ_BURST task to collect the read
         // channel transfers associated with this burst. Keep reading data
         // until last has been flagged.
         //------------------------------------------------------------------
         RECEIVE_READ_BURST(id,address,length,size,burst_type,lock_type,rd_data,response,v_ruser);

      end
   endtask

   //------------------------------------------------------------------------
   // FUNCTION LEVEL API: WRITE_BURST
   //------------------------------------------------------------------------
   // Description:
   // WRITE_BURST(ID,ADDR,LEN,SIZE,BURST,LOCK,CACHE,PROT,DATA,DATASIZE,
   // REGION,QOS,AWUSER,WUSER,RESPONSE,BUSER)
   // This task does a full write process. It is composed of the tasks
   // SEND_WRITE_ADDRESS, SEND_WRITE_BURST and RECEIVE_WRITE_RESPONSE from
   // the channel level API.
   // This task returns when the complete write transaction is complete.
   // This task automatically supports the generation of narrow transfers and
   // unaligned transfers.
   // This task aligns the input data with the burst so data padding is not
   // required.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Call the SEND_WRITE_ADDRESS task to start a write address channel
   // access.
   // 3. Call the SEND_WRITE_BURST task to send the burst onto the write data
   // channel.
   // 4. Call the RECEIVE_WRITE_RESPONSE task to collect the write response
   // from the write response channel.
   //------------------------------------------------------------------------
   task automatic WRITE_BURST;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
      input [`AXI4_PROT_BUS_WIDTH-1:0]   protection_type;
      input [(DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] wr_data;
      input integer                                      datasize;
      input [`AXI4_REGION_BUS_WIDTH-1:0] region;
      input [`AXI4_QOS_BUS_WIDTH-1:0]    qos;
      input [AWUSER_BUS_WIDTH-1:0]  awuser;
      input [(WUSER_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] v_wuser;
      output [`AXI4_RESP_BUS_WIDTH-1:0]  response;
      output [BUSER_BUS_WIDTH-1:0]  buser;
      integer                       trans_size_in_bytes;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         trans_size_in_bytes = transfer_size_in_bytes(size);

         if (FUNCTION_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : WRITE_BURST Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",trans_size_in_bytes,
                     ", burst_type = 0x%0h",burst_type,
                     ", lock_type = 0x%0h",lock_type,
                     ", cache_type = 0x%0h",cache_type,
                     ", protection_type = 0x%0h",protection_type,
                     ", valid data size (in bytes) = %0d",datasize,
                     ", region = 0x%0h",region,
                     ", qos = 0x%0h",qos,
                     ", awuser = 0x%0h",awuser);
         end


         //------------------------------------------------------------------
         // Step 2. Call the SEND_WRITE_ADDRESS task to start a write address
         // channel access.
         //------------------------------------------------------------------
         SEND_WRITE_ADDRESS(id, address, length, size, burst_type, lock_type, cache_type, protection_type, region, qos, awuser);
         repeat(WRITE_BURST_ADDRESS_DATA_PHASE_GAP) @(posedge bfm_aclk);

         //------------------------------------------------------------------
         // Step 3. Call the SEND_WRITE_BURST task to send the write burst
         // onto the write data channel.
         //------------------------------------------------------------------
         SEND_WRITE_BURST(address,length,size,burst_type,wr_data,datasize,v_wuser);

         //------------------------------------------------------------------
         // Step 4. Call the RECEIVE_WRITE_RESPONSE task to collect the write
         // response from the write response channel.
         //------------------------------------------------------------------
         RECEIVE_WRITE_RESPONSE(id,response,buser);

      end
   endtask

   //------------------------------------------------------------------------
   // FUNCTION LEVEL API: WRITE_BURST_CONCURRENT
   //------------------------------------------------------------------------
   // Description:
   // WRITE_BURST_CONCURRENT(ID,ADDR,LEN,SIZE,BURST,LOCK,CACHE,PROT,DATA,
   // DATASIZE,REGION,QOS,AWUSER,WUSER,RESPONSE,BUSER)
   // This task is the same as WRITE_BURST but performs the write address and
   // write data phases concurrently.
   //------------------------------------------------------------------------
   // Algorithm:
   // 1. Display INFO Message.
   // 2. Call the SEND_WRITE_ADDRESS task to start a write address channel
   // access and call the SEND_WRITE_BURST task to send the burst onto the
   // write data channel, both concurrently.
   // 3. Call the RECEIVE_WRITE_RESPONSE task to collect the write response
   // from the write response channel.
   //------------------------------------------------------------------------
   task automatic WRITE_BURST_CONCURRENT;
      input [ID_BUS_WIDTH-1:0]  id;
      input [ADDRESS_BUS_WIDTH-1:0] address;
      input [`AXI4_LENGTH_BUS_WIDTH-1:0] length;
      input [`AXI4_SIZE_BUS_WIDTH-1:0]   size;
      input [`AXI4_BURST_BUS_WIDTH-1:0]  burst_type;
      input [`AXI4_LOCK_BUS_WIDTH-1:0]   lock_type;
      input [`AXI4_CACHE_BUS_WIDTH-1:0]  cache_type;
      input [`AXI4_PROT_BUS_WIDTH-1:0]   protection_type;
      input [(DATA_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] wr_data;
      input integer                                      datasize;
      input [`AXI4_REGION_BUS_WIDTH-1:0] region;
      input [`AXI4_QOS_BUS_WIDTH-1:0]    qos;
      input [AWUSER_BUS_WIDTH-1:0]  awuser;
      input [(WUSER_BUS_WIDTH*(`AXI4_MAX_BURST_LENGTH+1))-1:0] v_wuser;
      output [`AXI4_RESP_BUS_WIDTH-1:0]  response;
      output [BUSER_BUS_WIDTH-1:0]  buser;
      integer                       trans_size_in_bytes;
      begin
         //------------------------------------------------------------------
         // Step 1. Display INFO message.
         //------------------------------------------------------------------
         trans_size_in_bytes = transfer_size_in_bytes(size);

         if (FUNCTION_LEVEL_INFO == 1) begin
            $display("[%0t] : %s : *INFO : WRITE_BURST_CONCURRENT Task Call - ",
                     $time,NAME,
                     "id = 0x%0h",id,
                     ", address = 0x%0h",address,
                     ", length = %0d",decode_burst_length(length),
                     ", size = %0d",trans_size_in_bytes,
                     ", burst_type = 0x%0h",burst_type,
                     ", lock_type = 0x%0h",lock_type,
                     ", cache_type = 0x%0h",cache_type,
                     ", protection_type = 0x%0h",protection_type,
                     ", valid data size (in bytes) = %0d",datasize,
                     ", region = 0x%0h",region,
                     ", qos = 0x%0h",qos,
                     ", awuser = 0x%0h",awuser);
         end


         //------------------------------------------------------------------
         // Step 2. Call the SEND_WRITE_ADDRESS task to start a write address
         // channel access and call the SEND_WRITE_BURST task to send the
         // burst onto the write data channel, both concurrently.
         //------------------------------------------------------------------
         fork
            begin
                repeat(WRITE_BURST_DATA_ADDRESS_PHASE_GAP) @(posedge bfm_aclk);

                SEND_WRITE_ADDRESS(id, address, length, size, burst_type, lock_type, cache_type, protection_type, region, qos, awuser);
            end

            SEND_WRITE_BURST(address,length,size,burst_type,wr_data,datasize,v_wuser);
         join

         //------------------------------------------------------------------
         // Step 3. Call the RECEIVE_WRITE_RESPONSE task to collect the write
         // response from the write response channel.
         //------------------------------------------------------------------
         RECEIVE_WRITE_RESPONSE(id,response,buser);

      end
   endtask

   //------------------------------------------------------------------------
   // API TASKS/FUNCTIONS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // API TASK: set_write_burst_data_transfer_gap
   //------------------------------------------------------------------------
   // set_write_burst_data_transfer_gap(gap_length)
   // Description:
   // This function sets the WRITE_BURST_DATA_TRANSFER_GAP internal variable
   // to the specified input value.
   //------------------------------------------------------------------------
   task automatic set_write_burst_data_transfer_gap;
      input integer gap_length;
      begin
         $display("[%0t] : %s : *INFO : Setting WRITE_BURST_DATA_TRANSFER_GAP to %0d",$time,NAME,gap_length);
         WRITE_BURST_DATA_TRANSFER_GAP = gap_length;
      end
   endtask

   //------------------------------------------------------------------------
   // API TASK: set_write_burst_address_data_phase_gap
   //------------------------------------------------------------------------
   // set_write_burst_address_data_phase_gap(gap_length)
   // Description:
   // This function sets the WRITE_BURST_ADDRESS_DATA_PHASE_GAP internal
   // variable to the specified input value.
   // This variable is only used in the WRITE_BURST function level task.
   //------------------------------------------------------------------------
   task automatic set_write_burst_address_data_phase_gap;
      input integer gap_length;
      begin
         $display("[%0t] : %s : *INFO : Setting WRITE_BURST_ADDRESS_DATA_PHASE_GAP to %0d",$time,NAME,gap_length);
         WRITE_BURST_ADDRESS_DATA_PHASE_GAP = gap_length;
      end
   endtask

   //------------------------------------------------------------------------
   // API TASK: set_write_burst_data_address_phase_gap
   //------------------------------------------------------------------------
   // set_write_burst_data_address_phase_gap(gap_length)
   // Description:
   // This function sets the WRITE_BURST_DATA_ADDRESS_PHASE_GAP internal
   // variable to the specified input value.
   // This variable is only used in the WRITE_BURST_CONCURRENT function level
   // task.
   //------------------------------------------------------------------------
   task automatic set_write_burst_data_address_phase_gap;
      input integer gap_length;
      begin
         $display("[%0t] : %s : *INFO : Setting WRITE_BURST_DATA_ADDRESS_PHASE_GAP to %0d",$time,NAME,gap_length);
         WRITE_BURST_DATA_ADDRESS_PHASE_GAP = gap_length;
      end
   endtask

   //------------------------------------------------------------------------
   // API TASK: set_error_on_slverr
   //------------------------------------------------------------------------
   // set_error_on_slverr(level)
   // Description:
   // This task sets the ERROR_ON_SLVERR internal variable to the specified
   // input value: 1 = create error on slverr; 0 = Only warn about slverr.
   //------------------------------------------------------------------------
   task automatic set_error_on_slverr;
      input level;
      begin
         $display("[%0t] : %s : *INFO : Setting ERROR_ON_SLVERR to %0d",$time,NAME,level);
         ERROR_ON_SLVERR = level;
      end
   endtask

   //------------------------------------------------------------------------
   // API TASK: set_error_on_decerr
   //------------------------------------------------------------------------
   // set_error_on_decerr(level)
   // Description:
   // This task sets the ERROR_ON_DECERR internal variable to the specified
   // input value: 1 = create error on decerr; 0 = Only warn about decerr.
   //------------------------------------------------------------------------
   task automatic set_error_on_decerr;
      input level;
      begin
         $display("[%0t] : %s : *INFO : Setting ERROR_ON_DECERR to %0d",$time,NAME,level);
         ERROR_ON_DECERR = level;
      end
   endtask

   //------------------------------------------------------------------------
   // CHECKING TASK: check_response_value
   //------------------------------------------------------------------------
   // Description:
   // check_response_value(id,response,direction)
   // NOTE: id and direction are needed for messages only.
   // Direction: 1 = WRITE and 0 = READ.
   // The response from either the read/write can have two error types:
   // SLVERR - Slave Error
   // DECERR - Decode Error
   // This task checks the response type and if one of the errors will report
   // an error or warning depending on the ERROR_ON_SLVERR and
   // ERROR_ON_DECERR control variables respectively.
   //------------------------------------------------------------------------
   task automatic check_response_value;
       input [ID_BUS_WIDTH-1:0]  id;
       input [`AXI4_RESP_BUS_WIDTH-1:0] response;
       input direction;
       begin
           // Check if the response was a slave error and check
           if (response === `AXI4_RESPONSE_SLVERR) begin
               if(ERROR_ON_SLVERR) begin
                   if(direction) begin
                       $display("[%0t] : %s : *ERROR : Write Response (id=%0d) = %0d - SLVERR detected.",
                                $time,NAME,id,response);
                   end else begin
                       $display("[%0t] : %s : *ERROR : Read Response (id=%0d) = %0d - SLVERR detected.",
                                $time,NAME,id,response);
                   end

                   if(STOP_ON_ERROR == 1) begin
                       $display("*** TEST FAILED");
                       $stop;
                   end
                       error_count = error_count+1;
               end
               else begin
                   if(direction) begin
                       $display("[%0t] : %s : *WARNING : Write Response (id=%0d) = %0d - SLVERR detected.",
                                $time,NAME,id,response);
                   end else begin
                       $display("[%0t] : %s : *WARNING : Read Response (id=%0d) = %0d - SLVERR detected.",
                                $time,NAME,id,response);
                   end
                   warning_count = warning_count+1;
               end
           end
           // Check if the response was a decode error and check
           if (response === `AXI4_RESPONSE_DECERR) begin
               if(ERROR_ON_DECERR) begin
                   if(direction) begin
                       $display("[%0t] : %s : *ERROR : Write Response (id=%0d) = %0d - DECERR detected.",
                                $time,NAME,id,response);
                   end else begin
                       $display("[%0t] : %s : *ERROR : Read Response (id=%0d) = %0d - DECERR detected.",
                                $time,NAME,id,response);
                   end

                   if(STOP_ON_ERROR == 1) begin
                       $display("*** TEST FAILED");
                       $stop;
                   end
                   error_count = error_count+1;
               end
               else begin
                   if(direction) begin
                       $display("[%0t] : %s : *WARNING : Write Response (id=%0d) = %0d - DECERR detected.",
                                $time,NAME,id,response);
                   end else begin
                       $display("[%0t] : %s : *WARNING : Read Response (id=%0d) = %0d - DECERR detected.",
                                $time,NAME,id,response);
                   end
                   warning_count = warning_count+1;
               end
           end
       end
   endtask

endmodule

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
