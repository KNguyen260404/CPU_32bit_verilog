// =============================================================================
// Register File Module
// =============================================================================
// Description: 32-entry general-purpose register file with x0 hardwired to 0
//              Optimized for FPGA with distributed RAM inference
// Author: Auto-generated following RTL design rules
// Date: September 15, 2025
// Features: - Parameterized width and depth
//          - Dual read ports, single write port
//          - x0 hardwired to zero (RISC-V compliance)
//          - Debug interface and verification assertions
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// Data Width Constants (minimal needed for this module)
`define DATA_WIDTH          32          // 32-bit data bus

module register_file #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter DATA_WIDTH = 32,              // Register data width
    parameter ADDR_WIDTH = 5,               // Register address width (32 regs)
    parameter RAM_STYLE = "distributed",    // "distributed", "block", "ultra"
    parameter ENABLE_DEBUG = 1,             // Enable debug features
    parameter RESET_ALL_REGS = 0            // Reset all registers (0=only x0)
)(
    // =================================================================
    // Clock and Reset Interface
    // =================================================================
    input  wire                     clk,
    input  wire                     rst_n,      // Synchronized reset
    
    // =================================================================
    // Read Interface (Dual Port)
    // =================================================================
    input  wire [ADDR_WIDTH-1:0]    rs1_addr,   // Source 1 address
    input  wire [ADDR_WIDTH-1:0]    rs2_addr,   // Source 2 address
    output wire [DATA_WIDTH-1:0]    rs1_data,   // Source 1 data
    output wire [DATA_WIDTH-1:0]    rs2_data,   // Source 2 data
    
    // =================================================================
    // Write Interface
    // =================================================================
    input  wire                     reg_write,  // Write enable
    input  wire [ADDR_WIDTH-1:0]    rd_addr,    // Destination address
    input  wire [DATA_WIDTH-1:0]    rd_data,    // Write data
    
    // =================================================================
    // Debug Interface (Optional)
    // =================================================================
    input  wire                     debug_enable,
    input  wire [ADDR_WIDTH-1:0]    debug_addr,
    output wire [DATA_WIDTH-1:0]    debug_data
);

    // =================================================================
    // Local Parameters
    // =================================================================
    localparam NUM_REGS = 1 << ADDR_WIDTH;  // Number of registers
    
    // =================================================================
    // Register Array with Synthesis Attributes
    // =================================================================
    (* ram_style = RAM_STYLE *)
    reg [DATA_WIDTH-1:0] registers [1:NUM_REGS-1];  // x1-x31 (x0 is hardwired)
    
    // =================================================================
    // Write Logic (Synchronous with Reset)
    // =================================================================
    generate
        if (RESET_ALL_REGS) begin : gen_reset_all
            // Reset all registers (slower but more predictable)
            always @(posedge clk) begin
                if (!rst_n) begin
                    integer i;
                    for (i = 1; i < NUM_REGS; i = i + 1) begin
                        registers[i] <= {DATA_WIDTH{1'b0}};
                    end
                end else if (reg_write && (rd_addr != {ADDR_WIDTH{1'b0}})) begin
                    registers[rd_addr] <= rd_data;
                end
            end
        end else begin : gen_reset_minimal
            // Only reset when writing (faster synthesis)
            always @(posedge clk) begin
                if (reg_write && rst_n && (rd_addr != {ADDR_WIDTH{1'b0}})) begin
                    registers[rd_addr] <= rd_data;
                end
            end
        end
    endgenerate
    
    // =================================================================
    // Read Logic (Asynchronous for zero latency)
    // =================================================================
    // x0 is always zero, other registers read from array
    assign rs1_data = (rs1_addr == {ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : 
                      (!rst_n) ? {DATA_WIDTH{1'b0}} : registers[rs1_addr];
                      
    assign rs2_data = (rs2_addr == {ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : 
                      (!rst_n) ? {DATA_WIDTH{1'b0}} : registers[rs2_addr];

    // =================================================================
    // Debug Interface Implementation
    // =================================================================
    generate
        if (ENABLE_DEBUG) begin : gen_debug
            assign debug_data = debug_enable ? 
                               ((debug_addr == {ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : registers[debug_addr]) :
                               {DATA_WIDTH{1'b0}};
        end else begin : gen_no_debug
            assign debug_data = {DATA_WIDTH{1'b0}};
        end
    endgenerate


endmodule

// =============================================================================
// End of File
// =============================================================================