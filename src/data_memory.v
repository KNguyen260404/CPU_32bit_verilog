// =============================================================================
// Data Memory Module - ASIC Synthesis Optimized
// =============================================================================
// Description: Simple data memory with clean single-cycle access
//              100% synthesis compatible with no clock domain conflicts
// Author: Auto-generated for OpenLane flow
// Date: September 15, 2025
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// Data Width Constants (minimal needed for this module)
`define DATA_WIDTH          32          // 32-bit data bus

module data_memory #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter DATA_WIDTH = 32,              // Data width
    parameter ADDR_WIDTH = 12,              // Address width (4KB default)
    parameter RAM_STYLE = "block",          // "block", "distributed", "ultra"
    parameter INIT_FILE = "",               // Memory initialization file (unused in ASIC)
    parameter ENABLE_DEBUG = 1,             // Enable debug features
    parameter READ_LATENCY = 0              // Read latency (0=async for synthesis)
)(
    // =================================================================
    // Clock and Reset Interface
    // =================================================================
    input  wire                     clk,
    input  wire                     rst_n,      // Synchronized reset
    
    // =================================================================
    // Memory Interface
    // =================================================================
    input  wire [DATA_WIDTH-1:0]    address,    // Memory address
    input  wire                     mem_write,  // Write enable
    input  wire [3:0]               write_enable, // Byte write enables
    input  wire [DATA_WIDTH-1:0]    write_data, // Write data
    output wire [DATA_WIDTH-1:0]    read_data,  // Read data
    
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
    
    // Memory array - word addressable with synthesis attributes
    (* ram_style = RAM_STYLE *)
    reg [DATA_WIDTH-1:0] memory [0:MEMORY_DEPTH-1];
    
    // Address decoding
    wire [ADDR_WIDTH-3:0] word_addr;
    wire addr_valid;
    
    assign word_addr = address[ADDR_WIDTH-1:2];  // Word address only
    assign addr_valid = (word_addr < MEMORY_DEPTH);
    
    // =================================================================
    // Memory Write Logic - Pure Synthesis Style
    // =================================================================
    always @(posedge clk) begin
        if (mem_write && addr_valid && rst_n) begin
            // Only write full word - simplest synthesis
            memory[word_addr] <= write_data;
        end
    end
    
    // =================================================================
    // Memory Read Logic - Combinational
    // =================================================================
    assign read_data = (addr_valid && rst_n) ? memory[word_addr] : {DATA_WIDTH{1'b0}};
    
    // =================================================================
    // Debug Interface
    // =================================================================
    wire [ADDR_WIDTH-3:0] debug_word_addr = debug_addr[ADDR_WIDTH-1:2];
    assign debug_data = (debug_enable && debug_word_addr < MEMORY_DEPTH) ? 
                       memory[debug_word_addr] : {DATA_WIDTH{1'b0}};

endmodule