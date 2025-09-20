// Branch Decision Module
// Compares operands based on branch type and generates branch decision
// Based on Blog.md section 2.1 item 5)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define DATA_WIDTH          32          // 32-bit data bus

// Branch Type Constants (3-bit encoding)
`define BRANCH_EQ           3'b000          // Branch if Equal
`define BRANCH_NE           3'b001          // Branch if Not Equal  
`define BRANCH_LT           3'b100          // Branch if Less Than
`define BRANCH_GE           3'b101          // Branch if Greater or Equal
`define BRANCH_LTU          3'b110          // Branch if Less Than Unsigned
`define BRANCH_GEU          3'b111          // Branch if Greater or Equal Unsigned

module branch_decision (
    // Operands for comparison (usually rs1 and rs2, possibly forwarded)
    input  wire [`DATA_WIDTH-1:0]  operand1,
    input  wire [`DATA_WIDTH-1:0]  operand2,
    
    // Branch type control signal
    input  wire [2:0]               branch_type,
    
    // Branch decision output
    output reg                      branch_taken
);

    // Signed comparison helpers
    wire signed [`DATA_WIDTH-1:0] signed_op1, signed_op2;
    assign signed_op1 = operand1;
    assign signed_op2 = operand2;
    
    always @(*) begin
        case (branch_type)
            `BRANCH_EQ: begin
                // BEQ: branch if equal
                branch_taken = (operand1 == operand2);
            end
            
            `BRANCH_NE: begin
                // BNE: branch if not equal  
                branch_taken = (operand1 != operand2);
            end
            
            `BRANCH_LT: begin
                // BLT: branch if less than (signed)
                branch_taken = (signed_op1 < signed_op2);
            end
            
            `BRANCH_GE: begin
                // BGE: branch if greater than or equal (signed)
                branch_taken = (signed_op1 >= signed_op2);
            end
            
            `BRANCH_LTU: begin
                // BLTU: branch if less than (unsigned)
                branch_taken = (operand1 < operand2);
            end
            
            `BRANCH_GEU: begin
                // BGEU: branch if greater than or equal (unsigned)  
                branch_taken = (operand1 >= operand2);
            end
            
            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end

endmodule
