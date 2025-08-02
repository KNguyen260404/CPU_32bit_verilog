// Fast ALU optimized for 1GHz operation
// Removes complex multiplier/divider for critical path optimization
// Uses simple logic for basic operations

module FastALU(
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] result,
    output wire        zero
);

    // ALU Control Encoding (matching ALUControl_Fast)
    localparam ALU_OR   = 4'b0000;  // OR
    localparam ALU_XOR  = 4'b0001;  // XOR
    localparam ALU_ADD  = 4'b0010;  // ADD
    localparam ALU_SRL  = 4'b0011;  // SRL - Shift Right Logical  
    localparam ALU_SLL  = 4'b0100;  // SLL - Shift Left Logical
    localparam ALU_SRA  = 4'b0101;  // SRA - Shift Right Arithmetic
    localparam ALU_SUB  = 4'b0110;  // SUB
    localparam ALU_SLT  = 4'b0111;  // SLT - Set Less Than
    localparam ALU_SLTU = 4'b1000;  // SLTU - Set Less Than Unsigned
    localparam ALU_AND  = 4'b1001;  // AND

    // Fast combinational logic - optimized for timing  
    always @(*) begin
        case (alu_control)
            ALU_OR:   result = operand_a | operand_b;                    // 0000: OR
            ALU_XOR:  result = operand_a ^ operand_b;                    // 0001: XOR
            ALU_ADD:  result = operand_a + operand_b;                    // 0010: ADD
            ALU_SRL:  result = operand_a >> operand_b[4:0];              // 0011: SRL
            ALU_SLL:  result = operand_a << operand_b[4:0];              // 0100: SLL
            ALU_SRA:  result = $signed(operand_a) >>> operand_b[4:0];    // 0101: SRA  
            ALU_SUB:  result = operand_a - operand_b;                    // 0110: SUB
            ALU_SLT:  result = ($signed(operand_a) < $signed(operand_b)) ? 32'h1 : 32'h0;  // 0111: SLT
            ALU_SLTU: result = (operand_a < operand_b) ? 32'h1 : 32'h0;  // 1000: SLTU
            ALU_AND:  result = operand_a & operand_b;                    // 1001: AND
            default:  result = 32'h00000000;
        endcase
    end

    // Zero flag
    assign zero = (result == 32'h00000000);

endmodule
