// =============================================================================
// Reset Synchronizer Module
// =============================================================================
// Description: Provides async reset, synchronous de-assert functionality
//              Follows RTL design rules for robust reset strategy
// Author: Auto-generated following RTL design rules
// Date: September 15, 2025
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// (No constants needed for this module)

module reset_synchronizer #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter SYNC_STAGES = 2,              // Number of sync flip-flops
    parameter RESET_POLARITY = 1'b0         // 0: active low, 1: active high
)(
    // =================================================================
    // Clock and Reset Interface
    // =================================================================
    input  wire clk,                        // Clock input
    input  wire async_rst,                  // Asynchronous reset input
    output wire sync_rst_n                  // Synchronized reset output (always active low)
);

    // =================================================================
    // Local Parameters  
    // =================================================================
    localparam RESET_ACTIVE = RESET_POLARITY;
    // localparam RESET_INACTIVE = ~RESET_POLARITY;  // unused

    // =================================================================
    // Signal Declarations
    // =================================================================
    reg [SYNC_STAGES-1:0] sync_reg;

    // =================================================================
    // Reset Synchronizer Logic
    // =================================================================
    // Async reset, sync de-assert pattern
    always @(posedge clk or posedge (async_rst == RESET_ACTIVE ? 1'b1 : 1'b0)) begin
        if (async_rst == RESET_ACTIVE) begin
            sync_reg <= {SYNC_STAGES{1'b0}};
        end else begin
            sync_reg <= {sync_reg[SYNC_STAGES-2:0], 1'b1};
        end
    end

    // =================================================================
    // Output Assignment
    // =================================================================
    assign sync_rst_n = sync_reg[SYNC_STAGES-1];


endmodule

// =============================================================================
// End of File
// =============================================================================