module ALU #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [4:0] alu_control,     // 5-bit control signal
    input [$clog2(WIDTH)-1:0] shift_amount,
    output reg [WIDTH-1:0] result,
    output zero,
    output overflow
);
    // ALU control signal breakdown
    // alu_control[4]: 0 = Arithmetic operation, 1 = Logic operation
    // alu_control[3:2]: Operation type for Arithmetic (00: ADD, 01: SUB, 10: MUL, 11: DIV)
    // alu_control[3:0]: Operation type for Logic (see Logic module)
    // alu_control[0]: Signed flag for arithmetic operations

    // Define specific control values for arithmetic operations
    localparam ADD_UNSIGNED = 5'b00000; // Unsigned addition
    localparam ADD_SIGNED   = 5'b00001; // Signed addition
    localparam SUB_UNSIGNED = 5'b00100; // Unsigned subtraction
    localparam SUB_SIGNED   = 5'b00101; // Signed subtraction

    // Define specific control values for M extension
    localparam MUL_SIGNED   = 5'b01001; // Signed multiplication (lower bits)
    localparam MULH        = 5'b01011; // Signed multiplication (upper bits)
    localparam MULHSU      = 5'b01010; // Signed * Unsigned multiplication (upper bits)
    localparam MUL_UNSIGNED = 5'b01000; // Unsigned multiplication (upper bits)
    localparam DIV_SIGNED  = 5'b01101; // Signed division
    localparam DIV_UNSIGNED = 5'b01100; // Unsigned division
    localparam REM_SIGNED  = 5'b01111; // Signed remainder
    localparam REM_UNSIGNED = 5'b01110; // Unsigned remainder

    // Separate control signals for Arithmetic and Logic units
    wire [1:0] arith_op = alu_control[3:2];
    wire [3:0] logic_op = alu_control[3:0];
    wire is_signed = alu_control[0];
    wire is_logic_op = alu_control[4];
    
    // Flag to indicate if this is a remainder operation
    wire is_remainder_op = (alu_control == REM_SIGNED || alu_control == REM_UNSIGNED);

    // Results from sub-modules
    wire [WIDTH-1:0] arith_result;
    wire [WIDTH-1:0] logic_result;
    wire arith_overflow, arith_zero;

    // Temporary variables for M extension operations
    wire signed [WIDTH-1:0] a_signed = operand_a;
    wire signed [WIDTH-1:0] b_signed = operand_b;
    wire [WIDTH-1:0] a_unsigned = operand_a;
    wire [WIDTH-1:0] b_unsigned = operand_b;
    
    // Direct addition/subtraction results for better handling
    wire [WIDTH:0] add_result_full = {1'b0, operand_a} + {1'b0, operand_b};
    wire [WIDTH:0] sub_result_full = {1'b0, operand_a} - {1'b0, operand_b};
    
    // Extract the result and carry
    wire add_carry = add_result_full[WIDTH];
    wire sub_carry = sub_result_full[WIDTH];
    
    // Actual results
    wire [WIDTH-1:0] add_result = add_result_full[WIDTH-1:0];
    wire [WIDTH-1:0] sub_result = sub_result_full[WIDTH-1:0];
    
    // Overflow detection for signed operations
    wire add_overflow = is_signed && ((operand_a[WIDTH-1] == operand_b[WIDTH-1]) && 
                                     (add_result[WIDTH-1] != operand_a[WIDTH-1]));
    
    wire sub_overflow = is_signed && ((operand_a[WIDTH-1] != operand_b[WIDTH-1]) && 
                                     (sub_result[WIDTH-1] != operand_a[WIDTH-1]));
    
    // Multiplication results with proper sign handling
    wire signed [2*WIDTH-1:0] signed_mul = a_signed * b_signed;
    wire [2*WIDTH-1:0] unsigned_mul = a_unsigned * b_unsigned;
    wire signed [2*WIDTH-1:0] signed_unsigned_mul = a_signed * b_unsigned;
    
    // Division and remainder results with proper handling of edge cases
    wire div_by_zero = (operand_b == 0);
    
    // Special case for signed division: most negative number divided by -1
    wire signed_div_overflow = is_signed && (operand_a == {1'b1, {(WIDTH-1){1'b0}}}) && 
                              (operand_b == {WIDTH{1'b1}});
    
    // Division results
    wire signed [WIDTH-1:0] signed_div = div_by_zero ? {WIDTH{1'b1}} : 
                                        signed_div_overflow ? {1'b1, {(WIDTH-1){1'b0}}} : 
                                        a_signed / b_signed;
    
    wire [WIDTH-1:0] unsigned_div = div_by_zero ? {WIDTH{1'b1}} : a_unsigned / b_unsigned;
    
    // Remainder results
    wire signed [WIDTH-1:0] signed_rem = div_by_zero ? a_signed : 
                                        signed_div_overflow ? {WIDTH{1'b0}} : 
                                        a_signed % b_signed;
    
    wire [WIDTH-1:0] unsigned_rem = div_by_zero ? a_unsigned : a_unsigned % b_unsigned;

    // Arithmetic Unit
    Arithmetic #(WIDTH) arithmetic_unit (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(arith_op),
        .is_signed(is_signed),
        .is_remainder_op(is_remainder_op),
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

    // Determine the final result based on the operation
    reg m_overflow;
    
    // Wire for temporary sign bit and expected upper bits
    wire sign_bit;
    wire [WIDTH-1:0] expected_upper;
    
    assign sign_bit = result[WIDTH-1];
    assign expected_upper = {WIDTH{sign_bit}};
    
    always @(*) begin
        m_overflow = 1'b0;
        
        if (is_logic_op) begin
            // Logic operations
            result = logic_result;
        end else begin
            // Arithmetic operations
            case (alu_control)
                // ADD operations - handle directly for better accuracy
                ADD_UNSIGNED, ADD_SIGNED: begin
                    result = add_result;
                    m_overflow = add_overflow;
                end
                
                // SUB operations - handle directly for better accuracy
                SUB_UNSIGNED, SUB_SIGNED: begin
                    result = sub_result;
                    m_overflow = sub_overflow;
                end
                
                // MUL - Lower 32 bits of multiplication
                MUL_SIGNED: begin
                    // For MUL, we want the lower 32 bits of the result
                    result = signed_mul[WIDTH-1:0];
                    // No overflow for lower bits
                    m_overflow = 1'b0;
                end
                
                // MULH - Upper 32 bits of signed multiplication
                MULH: begin
                    result = signed_mul[2*WIDTH-1:WIDTH];
                    m_overflow = 1'b0; // No overflow for upper bits
                end
                
                // MULHSU - Upper 32 bits of signed * unsigned multiplication
                MULHSU: begin
                    result = signed_unsigned_mul[2*WIDTH-1:WIDTH];
                    m_overflow = 1'b0; // No overflow for upper bits
                end
                
                // MULHU - Upper 32 bits of unsigned multiplication
                MUL_UNSIGNED: begin
                    result = unsigned_mul[2*WIDTH-1:WIDTH];
                    m_overflow = 1'b0; // No overflow for upper bits
                end
                
                // DIV - Signed division
                DIV_SIGNED: begin
                    result = signed_div;
                    m_overflow = div_by_zero || signed_div_overflow;
                end
                
                // DIVU - Unsigned division
                DIV_UNSIGNED: begin
                    result = unsigned_div;
                    m_overflow = div_by_zero;
                end
                
                // REM - Signed remainder
                REM_SIGNED: begin
                    result = signed_rem;
                    m_overflow = div_by_zero;
                end
                
                // REMU - Unsigned remainder
                REM_UNSIGNED: begin
                    result = unsigned_rem;
                    m_overflow = div_by_zero;
                end
                
                default: begin
                    result = arith_result;
                    m_overflow = arith_overflow;
                end
            endcase
        end
    end
    
    // Zero flag - true if result is zero
    assign zero = (result == {WIDTH{1'b0}});
    
    // Overflow flag - only valid for arithmetic operations
    assign overflow = is_logic_op ? 1'b0 : m_overflow;

endmodule
