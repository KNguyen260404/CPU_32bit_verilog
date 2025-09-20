// Arithmetic Logic Unit (ALU)
// Supports ADD/SUB/AND/OR/XOR/SLT/SLTU/SLL/SRL/SRA operations
// Based on Blog.md section 2.1 item 6)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define DATA_WIDTH          32          // 32-bit data bus

// ALU Operation Constants (4-bit encoding)
`define ALU_ADD             4'b0000         // Addition
`define ALU_SUB             4'b0001         // Subtraction
`define ALU_AND             4'b0010         // Bitwise AND
`define ALU_OR              4'b0011         // Bitwise OR
`define ALU_XOR             4'b0100         // Bitwise XOR
`define ALU_SLT             4'b0101         // Set Less Than (signed)
`define ALU_SLTU            4'b0110         // Set Less Than Unsigned
`define ALU_SLL             4'b0111         // Shift Left Logical
`define ALU_SRL             4'b1000         // Shift Right Logical
`define ALU_SRA             4'b1001         // Shift Right Arithmetic

module alu (
    // Input operands (from register/immediate/PC via AluSrc mux)
    input  wire [`DATA_WIDTH-1:0]  operand1,
    input  wire [`DATA_WIDTH-1:0]  operand2,
    
    // ALU operation control
    input  wire [3:0]               alu_control,
    
    // ALU result output
    output reg  [`DATA_WIDTH-1:0]  alu_result,
    
    // Zero flag (useful for branch conditions)
    output wire                     zero_flag
);

    // Shift amount (lower 5 bits of operand2)
    wire [4:0] shift_amount;
    assign shift_amount = operand2[4:0];
    
    // Signed operands for comparison
    wire signed [`DATA_WIDTH-1:0] signed_op1, signed_op2;
    assign signed_op1 = operand1;
    assign signed_op2 = operand2;
    
    always @(*) begin
        case (alu_control)
            `ALU_ADD: begin
                alu_result = operand1 + operand2;
            end
            
            `ALU_SUB: begin
                alu_result = operand1 - operand2;
            end
            
            `ALU_AND: begin
                alu_result = operand1 & operand2;
            end
            
            `ALU_OR: begin
                alu_result = operand1 | operand2;
            end
            
            `ALU_XOR: begin
                alu_result = operand1 ^ operand2;
            end
            
            `ALU_SLT: begin
                // Set less than (signed)
                alu_result = (signed_op1 < signed_op2) ? 32'h00000001 : 32'h00000000;
            end
            
            `ALU_SLTU: begin
                // Set less than unsigned
                alu_result = (operand1 < operand2) ? 32'h00000001 : 32'h00000000;
            end
            
            `ALU_SLL: begin
                // Shift left logical
                alu_result = operand1 << shift_amount;
            end
            
            `ALU_SRL: begin
                // Shift right logical  
                alu_result = operand1 >> shift_amount;
            end
            
            `ALU_SRA: begin
                // Shift right arithmetic
                alu_result = signed_op1 >>> shift_amount;
            end
            
            default: begin
                alu_result = 32'h00000000;
            end
        endcase
    end
    
    // Zero flag for branch conditions
    assign zero_flag = (alu_result == 32'h00000000);

endmodule
