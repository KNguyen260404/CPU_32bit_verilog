module Arithmetic #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [1:0] operation,    // 00: Add, 01: Subtract, 10: Multiply, 11: Divide/Remainder
    input is_signed,         // 0: Unsigned, 1: Signed
    input is_remainder_op,   // 0: Division, 1: Remainder
    output reg [WIDTH-1:0] result,
    output reg overflow,
    output reg zero
);

    // Operation encoding
    localparam ADD = 2'b00;
    localparam SUB = 2'b01;
    localparam MUL = 2'b10;
    localparam DIV = 2'b11;  // This now includes both division and remainder

    // Temporary variables for calculations
    wire [WIDTH-1:0] add_result;
    wire add_cout;
    wire [WIDTH-1:0] sub_result;
    wire sub_cout;
    wire [2*WIDTH-1:0] mul_result;
    wire [WIDTH-1:0] div_result;
    wire [WIDTH-1:0] rem_result;
    wire add_overflow, sub_overflow, mul_overflow;
    
    // Direct addition/subtraction results for better handling
    wire [WIDTH:0] add_result_full = {1'b0, operand_a} + {1'b0, operand_b};
    wire [WIDTH:0] sub_result_full = {1'b0, operand_a} - {1'b0, operand_b};
    
    // Extract the result and carry
    wire add_carry = add_result_full[WIDTH];
    wire sub_carry = sub_result_full[WIDTH];
    
    // Actual results
    wire [WIDTH-1:0] add_result_direct = add_result_full[WIDTH-1:0];
    wire [WIDTH-1:0] sub_result_direct = sub_result_full[WIDTH-1:0];
    
    // Overflow detection for signed operations
    wire add_overflow_direct = is_signed && ((operand_a[WIDTH-1] == operand_b[WIDTH-1]) && 
                                           (add_result_direct[WIDTH-1] != operand_a[WIDTH-1]));
    
    wire sub_overflow_direct = is_signed && ((operand_a[WIDTH-1] != operand_b[WIDTH-1]) && 
                                           (sub_result_direct[WIDTH-1] != operand_a[WIDTH-1]));
    
    // Adder for addition
    carry_lookahead_adder #(WIDTH) adder(
        .a(operand_a),
        .b(operand_b),
        .cin(1'b0),
        .sum(add_result),
        .cout(add_cout)
    );
    
    // Adder for subtraction (A - B = A + (-B) = A + ~B + 1)
    carry_lookahead_adder #(WIDTH) subtractor(
        .a(operand_a),
        .b(~operand_b),
        .cin(1'b1),
        .sum(sub_result),
        .cout(sub_cout)
    );

    // Overflow detection for addition
    assign add_overflow = is_signed & 
                         ((operand_a[WIDTH-1] == operand_b[WIDTH-1]) && 
                          (add_result[WIDTH-1] != operand_a[WIDTH-1]));
    
    // Overflow detection for subtraction
    // For subtraction: A - B = A + (-B)
    // Overflow occurs when:
    // 1. A positive, B negative, result negative -> overflow
    // 2. A negative, B positive, result positive -> overflow
    assign sub_overflow = is_signed & 
                         ((operand_a[WIDTH-1] != operand_b[WIDTH-1]) && 
                          (sub_result[WIDTH-1] != operand_a[WIDTH-1]));

    // Multiplication
    // For RISC-V M extension support
    wire signed [WIDTH-1:0] a_signed = operand_a;
    wire signed [WIDTH-1:0] b_signed = operand_b;
    wire [WIDTH-1:0] a_unsigned = operand_a;
    wire [WIDTH-1:0] b_unsigned = operand_b;
    
    // Different multiplication results based on operation type (MUL, MULH, MULHU, MULHSU)
    wire signed [2*WIDTH-1:0] signed_mul = a_signed * b_signed;
    wire [2*WIDTH-1:0] unsigned_mul = a_unsigned * b_unsigned;
    wire signed [2*WIDTH-1:0] signed_unsigned_mul = a_signed * b_unsigned;
    
    // Select appropriate multiplication result based on is_signed flag
    assign mul_result = is_signed ? signed_mul : unsigned_mul;
    
    // Division and Remainder
    // Handle division by zero separately
    wire div_by_zero = (operand_b == 0);
    
    // Special case for signed division: most negative number divided by -1
    wire signed_div_overflow = is_signed && (operand_a == {1'b1, {(WIDTH-1){1'b0}}}) && 
                              (operand_b == {WIDTH{1'b1}});
    
    // Signed division
    wire signed [WIDTH-1:0] signed_div_result;
    wire signed [WIDTH-1:0] signed_rem_result;
    assign signed_div_result = div_by_zero ? {WIDTH{1'b1}} : 
                              signed_div_overflow ? {1'b1, {(WIDTH-1){1'b0}}} : 
                              a_signed / b_signed;
    assign signed_rem_result = div_by_zero ? a_signed : 
                              signed_div_overflow ? {WIDTH{1'b0}} : 
                              a_signed % b_signed;
    
    // Unsigned division
    wire [WIDTH-1:0] unsigned_div_result;
    wire [WIDTH-1:0] unsigned_rem_result;
    assign unsigned_div_result = div_by_zero ? {WIDTH{1'b1}} : a_unsigned / b_unsigned;
    assign unsigned_rem_result = div_by_zero ? a_unsigned : a_unsigned % b_unsigned;
    
    // Select appropriate division result based on is_signed flag
    assign div_result = is_signed ? signed_div_result : unsigned_div_result;
    assign rem_result = is_signed ? signed_rem_result : unsigned_rem_result;
    
    // Wire for sign bit and expected upper bits
    wire sign_bit;
    wire [WIDTH-1:0] expected_upper;
    
    assign sign_bit = result[WIDTH-1];
    assign expected_upper = {WIDTH{sign_bit}};
    
    // Main operation selection
    always @(*) begin
        overflow = 1'b0;
        zero = 1'b0;
        
        case (operation)
            ADD: begin
                // Use direct addition for better accuracy
                result = add_result_direct;
                overflow = add_overflow_direct;
            end
            SUB: begin
                // Use direct subtraction for better accuracy
                // Make sure we're using the correct subtraction result
                result = sub_result; // Use the carry_lookahead_adder result for better accuracy
                overflow = sub_overflow;
            end
            MUL: begin
                // For standard MUL, use lower half of product
                if (is_signed) begin
                    // Signed multiplication
                    result = signed_mul[WIDTH-1:0];
                    overflow = 1'b0; // No overflow for lower bits
                end else begin
                    // Unsigned multiplication
                    result = unsigned_mul[WIDTH-1:0];
                    overflow = 1'b0; // No overflow for lower bits
                end
            end
            DIV: begin
                if (div_by_zero) begin
                    // Division by zero
                    result = is_remainder_op ? operand_a : {WIDTH{1'b1}}; // For remainder, return dividend
                    overflow = 1'b1;
                end else if (signed_div_overflow && !is_remainder_op) begin
                    // Special case: most negative number divided by -1
                    result = {1'b1, {(WIDTH-1){1'b0}}}; // Return most negative number
                    overflow = 1'b1;
                end else if (signed_div_overflow && is_remainder_op) begin
                    // Special case: remainder of most negative number divided by -1
                    result = {WIDTH{1'b0}}; // Return 0
                    overflow = 1'b0;
                end else begin
                    // Select between quotient and remainder based on is_remainder_op
                    result = is_remainder_op ? rem_result : div_result;
                    overflow = 1'b0;
                end
            end
        endcase
        
        // Set zero flag
        zero = (result == {WIDTH{1'b0}});
    end

endmodule

//------------------------------------------------------
// Half Adder - Basic building block
//------------------------------------------------------
module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;      // XOR
    assign carry = a & b;    // AND
endmodule

//------------------------------------------------------
// Full Adder - Built from Half Adders
//------------------------------------------------------
module full_adder(
    input a, b, cin,
    output sum, cout
);
    wire sum1, carry1, carry2;
    
    half_adder ha1(
        .a(a),
        .b(b),
        .sum(sum1),
        .carry(carry1)
    );
    
    half_adder ha2(
        .a(sum1),
        .b(cin),
        .sum(sum),
        .carry(carry2)
    );
    
    assign cout = carry1 | carry2;
endmodule

//------------------------------------------------------
// Carry Lookahead Adder built from HA and FA
//------------------------------------------------------
module carry_lookahead_adder #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);
    // Generate P (propagate) and G (generate) signals
    wire [WIDTH-1:0] p, g;
    wire [WIDTH:0] c;      // Carries
    
    // Initialize carry-in
    assign c[0] = cin;
    
    // Generate P and G signals using half adders
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : pg_gen
            half_adder ha_pg(
                .a(a[i]),
                .b(b[i]),
                .sum(p[i]),  // p[i] = a[i] ^ b[i]
                .carry(g[i]) // g[i] = a[i] & b[i]
            );
        end
    endgenerate
    
    // Calculate carries using CLA logic
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_gen
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    
    // Calculate sums using full adders
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sum_gen
            assign sum[i] = p[i] ^ c[i]; // p[i] ^ c[i] = (a[i] ^ b[i]) ^ c[i]
        end
    endgenerate
    
    // Final carry-out
    assign cout = c[WIDTH];
endmodule

//------------------------------------------------------
// Wallace Tree Multiplier for fast multiplication
//------------------------------------------------------
module wallace_tree_multiplier #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input is_signed,
    output [2*WIDTH-1:0] product
);
    // Handle sign extension for signed multiplication
    wire [WIDTH:0] a_extended, b_extended;
    assign a_extended = is_signed ? {a[WIDTH-1], a} : {1'b0, a};
    assign b_extended = is_signed ? {b[WIDTH-1], b} : {1'b0, b};
    
    // Generate partial products
    wire [WIDTH:0] pp[WIDTH:0];
    
    genvar i, j;
    generate
        for (i = 0; i <= WIDTH; i = i + 1) begin : pp_gen
            for (j = 0; j <= WIDTH; j = j + 1) begin : pp_bit
                assign pp[i][j] = a_extended[j] & b_extended[i];
            end
        end
    endgenerate
    
    // Wallace Tree reduction
    // Level 1: Reduce 3 rows to 2 at a time using full adders
    wire [2*WIDTH+1:0] level1_sum[WIDTH/3:0];
    wire [2*WIDTH+1:0] level1_carry[WIDTH/3:0];
    
    // Implementation of Wallace Tree reduction levels
    // This is a simplified version - a full implementation would have multiple reduction stages
    
    // Final stage: Add the last two rows with carry-lookahead adder
    wire [2*WIDTH+1:0] final_sum, final_carry;
    
    // Final product assignment
    // For simplicity, we're using Verilog's built-in multiplication here
    // In a real implementation, you would complete the Wallace Tree reduction
    wire signed [WIDTH-1:0] a_signed = a;
    wire signed [WIDTH-1:0] b_signed = b;
    wire signed [2*WIDTH-1:0] signed_product = a_signed * b_signed;
    wire [2*WIDTH-1:0] unsigned_product = a * b;
    
    assign product = is_signed ? signed_product : unsigned_product;
endmodule

//------------------------------------------------------
// SRT Divider for fast division
//------------------------------------------------------
module srt_divider #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    input is_signed,
    output [WIDTH-1:0] quotient,
    output div_by_zero
);
    // Check for division by zero
    assign div_by_zero = (divisor == {WIDTH{1'b0}});
    
    // Handle sign conversion for signed division
    wire [WIDTH-1:0] abs_dividend, abs_divisor;
    wire dividend_sign = is_signed & dividend[WIDTH-1];
    wire divisor_sign = is_signed & divisor[WIDTH-1];
    wire result_sign = dividend_sign ^ divisor_sign;
    
    // Calculate absolute values for signed division
    assign abs_dividend = dividend_sign ? (~dividend + 1'b1) : dividend;
    assign abs_divisor = divisor_sign ? (~divisor + 1'b1) : divisor;
    
    // Internal variables for the SRT algorithm
    reg [WIDTH-1:0] q;
    reg [WIDTH:0] r;
    reg [WIDTH-1:0] d;
    integer i;
    
    // Simplified SRT division algorithm
    // In a real implementation, this would be more complex with radix-4 or higher
    always @(*) begin
        r = {WIDTH{1'b0}};
        q = abs_dividend;
        d = abs_divisor;
        
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Shift left
            r = {r[WIDTH-1:0], q[WIDTH-1]};
            q = {q[WIDTH-2:0], 1'b0};
            
            // Try to subtract
            if (!r[WIDTH]) begin
                if (r >= {1'b0, d}) begin
                    r = r - {1'b0, d};
                    q[0] = 1'b1;
                end
            end else begin
                if (r >= {1'b0, d}) begin
                    r = r - {1'b0, d};
                    q[0] = 1'b1;
                end
            end
        end
    end
    
    // Apply sign to result if needed
    assign quotient = (result_sign && !div_by_zero) ? (~q + 1'b1) : q;
endmodule
