// Immediate Generator Module
// Generates 32-bit sign-extended immediates for different instruction types
// Based on Blog.md section 2.1 item 4)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define DATA_WIDTH          32          // 32-bit data bus

// Immediate Type Constants (3-bit encoding)
`define IMM_TYPE_I          3'b000          // I-type immediate (12-bit)
`define IMM_TYPE_S          3'b001          // S-type immediate (12-bit)
`define IMM_TYPE_B          3'b010          // B-type immediate (12-bit)
`define IMM_TYPE_U          3'b011          // U-type immediate (20-bit)
`define IMM_TYPE_J          3'b100          // J-type immediate (20-bit)

module immediate_generator (
    // Instruction bits (excluding opcode)
    input  wire [`DATA_WIDTH-1:0]  instruction,
    
    // Immediate type selection
    input  wire [2:0]               imm_type,
    
    // Generated 32-bit immediate
    output reg  [`DATA_WIDTH-1:0]  immediate
);

    always @(*) begin
        case (imm_type)
            `IMM_TYPE_I: begin
                // I-type: bits [31:20]
                // Used for: ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, LB, LH, LW, LBU, LHU, JALR
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            `IMM_TYPE_S: begin
                // S-type: bits [31:25][11:7]  
                // Used for: SB, SH, SW
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            `IMM_TYPE_B: begin
                // B-type: bits [31][7][30:25][11:8]
                // Used for: BEQ, BNE, BLT, BGE, BLTU, BGEU
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                           instruction[30:25], instruction[11:8], 1'b0};
            end
            
            `IMM_TYPE_U: begin
                // U-type: bits [31:12]
                // Used for: LUI, AUIPC
                immediate = {instruction[31:12], 12'b000000000000};
            end
            
            `IMM_TYPE_J: begin
                // J-type: bits [31][19:12][20][30:21]
                // Used for: JAL
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                           instruction[20], instruction[30:21], 1'b0};
            end
            
            default: begin
                immediate = 32'h00000000;
            end
        endcase
    end

endmodule