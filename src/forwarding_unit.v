// =============================================================================
// Forwarding Unit Module
// =============================================================================
// Description: Data hazard resolution through operand forwarding
//              Implements forwarding logic for pipeline efficiency
// Author: Auto-generated following RTL design rules
// Date: September 15, 2025
// Features: - Dual operand forwarding support
//          - EX and MEM stage forwarding sources
//          - Configurable forwarding policies
//          - Debug and verification support
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// Forwarding Unit Constants (2-bit encoding)
`define FORWARD_NONE        2'b00           // No forwarding
`define FORWARD_WB          2'b01           // Forward from WB stage
`define FORWARD_MEM         2'b10           // Forward from MEM stage

module forwarding_unit #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter ADDR_WIDTH = 5,               // Register address width
    parameter ENABLE_DEBUG = 1              // Enable debug features
)(
    // =================================================================
    // Input Interfaces
    // =================================================================
    input  wire [ADDR_WIDTH-1:0]    rs1_e,          // Source reg 1 in EX stage
    input  wire [ADDR_WIDTH-1:0]    rs2_e,          // Source reg 2 in EX stage
    input  wire [ADDR_WIDTH-1:0]    rd_m,           // Dest reg in MEM stage
    input  wire [ADDR_WIDTH-1:0]    rd_w,           // Dest reg in WB stage
    input  wire                     reg_write_m,    // Write enable MEM stage
    input  wire                     reg_write_w,    // Write enable WB stage
    
    // =================================================================
    // Output Interfaces
    // =================================================================
    output reg  [1:0]              forward_1e,     // Forward control for rs1
    output reg  [1:0]              forward_2e      // Forward control for rs2
);

    // =================================================================
    // Local Parameters
    // =================================================================
    localparam [1:0] FORWARD_NONE = 2'b00;  // No forwarding
    localparam [1:0] FORWARD_WB   = 2'b01;  // Forward from WB stage
    localparam [1:0] FORWARD_MEM  = 2'b10;  // Forward from MEM stage
    localparam [1:0] FORWARD_RSVD = 2'b11;  // Reserved

    // =================================================================
    // Forwarding Logic for RS1
    // =================================================================
    always @(*) begin
        // Default: no forwarding
        forward_1e = FORWARD_NONE;
        
        // MEM stage forwarding (higher priority)
        if (reg_write_m && (rd_m != {ADDR_WIDTH{1'b0}}) && (rd_m == rs1_e)) begin
            forward_1e = FORWARD_MEM;
        end
        // WB stage forwarding (lower priority)
        else if (reg_write_w && (rd_w != {ADDR_WIDTH{1'b0}}) && (rd_w == rs1_e)) begin
            forward_1e = FORWARD_WB;
        end
    end

    // =================================================================
    // Forwarding Logic for RS2
    // =================================================================
    always @(*) begin
        // Default: no forwarding
        forward_2e = FORWARD_NONE;
        
        // MEM stage forwarding (higher priority)
        if (reg_write_m && (rd_m != {ADDR_WIDTH{1'b0}}) && (rd_m == rs2_e)) begin
            forward_2e = FORWARD_MEM;
        end
        // WB stage forwarding (lower priority)
        else if (reg_write_w && (rd_w != {ADDR_WIDTH{1'b0}}) && (rd_w == rs2_e)) begin
            forward_2e = FORWARD_WB;
        end
    end

    // =================================================================
    // Debug Information (Optional)
    // =================================================================
    generate
        if (ENABLE_DEBUG) begin : gen_debug
            // Debug signals for monitoring forwarding decisions
            wire debug_rs1_mem_match = (rd_m == rs1_e) && (rd_m != {ADDR_WIDTH{1'b0}});
            wire debug_rs1_wb_match = (rd_w == rs1_e) && (rd_w != {ADDR_WIDTH{1'b0}});
            wire debug_rs2_mem_match = (rd_m == rs2_e) && (rd_m != {ADDR_WIDTH{1'b0}});
            wire debug_rs2_wb_match = (rd_w == rs2_e) && (rd_w != {ADDR_WIDTH{1'b0}});
            
            // Synthesis will remove these if not used
            (* keep = "true" *) wire [7:0] debug_forward_status = {
                debug_rs2_wb_match, debug_rs2_mem_match,
                debug_rs1_wb_match, debug_rs1_mem_match,
                forward_2e, forward_1e
            };
        end
    endgenerate


endmodule

// =============================================================================
// End of File
// =============================================================================