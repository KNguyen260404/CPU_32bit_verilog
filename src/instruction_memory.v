// =============================================================================
// Instruction Memory Module - ASIC Synthesis Optimized
// =============================================================================
// Description: Simple instruction memory with clean single-cycle access
//              100% synthesis compatible with no clock domain conflicts
// Author: Auto-generated for OpenLane flow
// Date: September 15, 2025
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// Data Width Constants (minimal needed for this module)
`define DATA_WIDTH          32          // 32-bit data bus

module instruction_memory #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter DATA_WIDTH = 32,              // Data width
    parameter ADDR_WIDTH = 12,              // Address width (4KB default)
    parameter MEMORY_STYLE = "block",       // "block", "distributed", "ultra" - unused
    parameter INIT_FILE = "",               // Memory initialization file - unused
    parameter ENABLE_DEBUG = 1              // Enable debug features - unused
)(
    // =================================================================
    // Clock and Reset Interface  
    // =================================================================
    input  wire                     clk,
    input  wire                     rst_n,      // Synchronized reset
    
    // =================================================================
    // Memory Interface
    // =================================================================
    input  wire [DATA_WIDTH-1:0]    pc_f,          // Program counter
    output wire [DATA_WIDTH-1:0]    instruction_f, // Fetched instruction
    
    // =================================================================
    // Debug Interface (Optional)
    // =================================================================
    input  wire                     debug_enable,
    input  wire [ADDR_WIDTH-1:0]    debug_addr,
    output wire [DATA_WIDTH-1:0]    debug_data
);

    // =================================================================
    // Local Parameters and Memory Declaration
    // =================================================================
    localparam MEMORY_DEPTH = 1 << (ADDR_WIDTH-2);  // Word-addressable
    
    // Memory array - word addressable
    (* ram_style = MEMORY_STYLE *)
    reg [DATA_WIDTH-1:0] imem [0:MEMORY_DEPTH-1];
    
    // Address decoding
    wire [ADDR_WIDTH-3:0] word_addr;
    wire addr_valid;
    
    assign word_addr = pc_f[ADDR_WIDTH-1:2];  // Word address only
    assign addr_valid = (word_addr < MEMORY_DEPTH);
    
    // =================================================================
    // Memory Logic - Single Process Only
    // =================================================================
    // For ASIC: instructions are loaded externally, no internal initialization
    // This prevents multiple clock domain conflicts
    
    // Combinational read - no clock conflicts
    assign instruction_f = (addr_valid && rst_n) ? imem[word_addr] : 32'h00000013;
    
    // =================================================================
    // Debug Interface
    // =================================================================
    wire [ADDR_WIDTH-3:0] debug_word_addr = debug_addr[ADDR_WIDTH-1:2];
    assign debug_data = (debug_enable && debug_word_addr < MEMORY_DEPTH) ? 
                       imem[debug_word_addr] : {DATA_WIDTH{1'b0}};

endmodule