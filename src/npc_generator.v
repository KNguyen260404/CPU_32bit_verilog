// Next PC Generator Module
// Implements priority selection for next PC: JalrE/BranchE > JalD > PC+4
// Based on Blog.md section 2.1 item 1)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define DATA_WIDTH          32          // 32-bit data bus
`define RESET_PC            32'h00000000    // Reset PC address

module npc_generator (
    input  wire                     clk,    // unused but kept for interface consistency
    input  wire                     rst_n,
    
    // Current PC
    input  wire [`DATA_WIDTH-1:0]  pc_f,
    
    // Control signals from different stages
    input  wire                     branch_e,       // Branch decision from EX stage
    input  wire                     jalr_e,         // JALR from EX stage  
    input  wire                     jal_d,          // JAL from ID stage
    
    // Target addresses
    input  wire [`DATA_WIDTH-1:0]  branch_target,  // Branch target (BrT)
    input  wire [`DATA_WIDTH-1:0]  jalr_target,    // JALR target (JalrT) 
    input  wire [`DATA_WIDTH-1:0]  jal_target,     // JAL target (JalT)
    
    // Stall signal from hazard unit
    input  wire                     stall_f,
    
    // Output next PC
    output reg  [`DATA_WIDTH-1:0]  pc_next
);

    always @(*) begin
        if (!rst_n) begin
            pc_next = `RESET_PC;
        end else if (stall_f) begin
            // Hold current PC when stalled
            pc_next = pc_f;
        end else begin
            // Priority selection based on Blog.md analysis:
            // EX stage signals (JalrE, BranchE) have higher priority than ID stage (JalD)
            if (jalr_e) begin
                pc_next = jalr_target;
            end else if (branch_e) begin
                pc_next = branch_target;
            end else if (jal_d) begin
                pc_next = jal_target;
            end else begin
                // Default: sequential execution (PC + 4)
                pc_next = pc_f + 32'd4;
            end
        end
    end

endmodule