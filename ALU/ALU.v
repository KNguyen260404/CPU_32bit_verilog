module ALU #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [4:0] alu_control,     // 5-bit control signal
    input [$clog2(WIDTH)-1:0] shift_amount,
    output [WIDTH-1:0] result,
    output zero,
    output overflow
);
    // ALU control signal breakdown
    // alu_control[4]: 0 = Arithmetic operation, 1 = Logic operation
    // alu_control[3:2]: Operation type for Arithmetic (00: ADD, 01: SUB, 10: MUL, 11: DIV)
    // alu_control[3:0]: Operation type for Logic (see Logic module)
    // alu_control[0]: Signed flag for arithmetic operations

    // Separate control signals for Arithmetic and Logic units
    wire [1:0] arith_op = alu_control[3:2];
    wire [3:0] logic_op = alu_control[3:0];
    wire is_signed = alu_control[0];
    wire is_logic_op = alu_control[4];

    // Results from sub-modules
    wire [WIDTH-1:0] arith_result;
    wire [WIDTH-1:0] logic_result;
    wire arith_overflow, arith_zero;

    // Arithmetic Unit
    Arithmetic #(WIDTH) arithmetic_unit (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(arith_op),
        .is_signed(is_signed),
        .result(arith_result),
        .overflow(arith_overflow),
        .zero(arith_zero)
    );

    // Logic Unit
    Logic #(WIDTH) logic_unit (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(logic_op),
        .shift_amount(shift_amount),
        .is_signed(is_signed),
        .result(logic_result)
    );

    // Select between Arithmetic and Logic results
    assign result = is_logic_op ? logic_result : arith_result;
    
    // Zero flag - true if result is zero
    assign zero = (result == {WIDTH{1'b0}});
    
    // Overflow flag - only valid for arithmetic operations
    assign overflow = is_logic_op ? 1'b0 : arith_overflow;

endmodule
