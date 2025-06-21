module Logic #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [3:0] operation,
    input [$clog2(WIDTH)-1:0] shift_amount,
    input is_signed,
    output reg [WIDTH-1:0] result
);

    // Logic operation encoding
    localparam SLL  = 4'b0000;  // Shift Left Logical
    localparam SRL  = 4'b0001;  // Shift Right Logical
    localparam SRA  = 4'b0011;  // Shift Right Arithmetic
    localparam XOR  = 4'b0010;  // Bitwise XOR
    localparam SLT  = 4'b0100;  // Set Less Than (signed)
    localparam SLTU = 4'b0101;  // Set Less Than Unsigned
    localparam OR   = 4'b0110;  // Bitwise OR
    localparam AND  = 4'b0111;  // Bitwise AND
    localparam EQ   = 4'b1000;  // Equal
    localparam NE   = 4'b1001;  // Not Equal
    localparam LT   = 4'b1010;  // Less Than (signed)
    localparam GE   = 4'b1011;  // Greater Than or Equal (signed)
    localparam LTU  = 4'b1100;  // Less Than Unsigned
    localparam GEU  = 4'b1101;  // Greater Than or Equal Unsigned

    // Temporary variables for signed comparisons
    wire signed [WIDTH-1:0] a_signed = operand_a;
    wire signed [WIDTH-1:0] b_signed = operand_b;
    
    // Logic operations
    always @(*) begin
        case (operation)
            SLL: begin
                // Shift Left Logical
                result = operand_a << shift_amount;
            end
            
            SRL: begin
                // Shift Right Logical
                result = operand_a >> shift_amount;
            end
            
            SRA: begin
                // Shift Right Arithmetic (sign-extending)
                result = $signed(operand_a) >>> shift_amount;
            end
            
            XOR: begin
                // Bitwise XOR
                result = operand_a ^ operand_b;
            end
            
            SLT: begin
                // Set Less Than (signed)
                result = (a_signed < b_signed) ? 1 : 0;
            end
            
            SLTU: begin
                // Set Less Than Unsigned
                result = (operand_a < operand_b) ? 1 : 0;
            end
            
            OR: begin
                // Bitwise OR
                result = operand_a | operand_b;
            end
            
            AND: begin
                // Bitwise AND
                result = operand_a & operand_b;
            end
            
            EQ: begin
                // Equal
                result = (operand_a == operand_b) ? 1 : 0;
            end
            
            NE: begin
                // Not Equal
                result = (operand_a != operand_b) ? 1 : 0;
            end
            
            LT: begin
                // Less Than (signed)
                result = (a_signed < b_signed) ? 1 : 0;
            end
            
            GE: begin
                // Greater Than or Equal (signed)
                result = (a_signed >= b_signed) ? 1 : 0;
            end
            
            LTU: begin
                // Less Than Unsigned
                result = (operand_a < operand_b) ? 1 : 0;
            end
            
            GEU: begin
                // Greater Than or Equal Unsigned
                result = (operand_a >= operand_b) ? 1 : 0;
            end
            
            default: begin
                // Default operation (no operation)
                result = operand_a;
            end
        endcase
    end

endmodule

//------------------------------------------------------
// Basic NAND gate - fundamental building block
//------------------------------------------------------
module nand_gate(
    input a, b,
    output out
);
    // Using RTL definition
    assign out = ~(a & b);
endmodule

//------------------------------------------------------
// Basic NOR gate - fundamental building block
//------------------------------------------------------
module nor_gate(
    input a, b,
    output out
);
    // Using RTL definition
    assign out = ~(a | b);
endmodule

//------------------------------------------------------
// NOT gate built from NAND
//------------------------------------------------------
module not_gate(
    input a,
    output out
);
    // NOT from NAND: a NAND a = NOT a
    nand_gate nand1(
        .a(a),
        .b(a),
        .out(out)
    );
endmodule

//------------------------------------------------------
// AND gate built from NAND
//------------------------------------------------------
module and_gate(
    input a, b,
    output out
);
    wire nand_out;
    
    // AND from NAND: NOT(a NAND b) = a AND b
    nand_gate nand1(
        .a(a),
        .b(b),
        .out(nand_out)
    );
    
    not_gate not1(
        .a(nand_out),
        .out(out)
    );
endmodule

//------------------------------------------------------
// OR gate built from NAND
//------------------------------------------------------
module or_gate(
    input a, b,
    output out
);
    wire not_a, not_b;
    
    // OR from NAND: (NOT a) NAND (NOT b) = a OR b
    not_gate not1(
        .a(a),
        .out(not_a)
    );
    
    not_gate not2(
        .a(b),
        .out(not_b)
    );
    
    nand_gate nand1(
        .a(not_a),
        .b(not_b),
        .out(out)
    );
endmodule

//------------------------------------------------------
// XOR gate built from NAND
//------------------------------------------------------
module xor_gate(
    input a, b,
    output out
);
    wire nand_out, nand_a, nand_b;
    
    // XOR from NAND: (a NAND (a NAND b)) NAND (b NAND (a NAND b))
    nand_gate nand1(
        .a(a),
        .b(b),
        .out(nand_out)
    );
    
    nand_gate nand2(
        .a(a),
        .b(nand_out),
        .out(nand_a)
    );
    
    nand_gate nand3(
        .a(b),
        .b(nand_out),
        .out(nand_b)
    );
    
    nand_gate nand4(
        .a(nand_a),
        .b(nand_b),
        .out(out)
    );
endmodule

//------------------------------------------------------
// Multi-bit AND operation
//------------------------------------------------------
module multi_bit_and #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] result
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : and_loop
            and_gate and_inst(
                .a(a[i]),
                .b(b[i]),
                .out(result[i])
            );
        end
    endgenerate
endmodule

//------------------------------------------------------
// Multi-bit OR operation
//------------------------------------------------------
module multi_bit_or #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] result
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : or_loop
            or_gate or_inst(
                .a(a[i]),
                .b(b[i]),
                .out(result[i])
            );
        end
    endgenerate
endmodule

//------------------------------------------------------
// Multi-bit XOR operation
//------------------------------------------------------
module multi_bit_xor #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] result
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : xor_loop
            xor_gate xor_inst(
                .a(a[i]),
                .b(b[i]),
                .out(result[i])
            );
        end
    endgenerate
endmodule

//------------------------------------------------------
// Multi-bit NOT operation
//------------------------------------------------------
module multi_bit_not #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] result
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : not_loop
            not_gate not_inst(
                .a(a[i]),
                .out(result[i])
            );
        end
    endgenerate
endmodule

//------------------------------------------------------
// Multi-bit NOR operation
//------------------------------------------------------
module multi_bit_nor #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] result
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : nor_loop
            nor_gate nor_inst(
                .a(a[i]),
                .b(b[i]),
                .out(result[i])
            );
        end
    endgenerate
endmodule

//------------------------------------------------------
// 2-to-1 MUX built from basic gates
//------------------------------------------------------
module mux_2to1(
    input a, b, sel,
    output out
);
    wire not_sel, and_a, and_b;
    
    not_gate not1(
        .a(sel),
        .out(not_sel)
    );
    
    and_gate and1(
        .a(a),
        .b(not_sel),
        .out(and_a)
    );
    
    and_gate and2(
        .a(b),
        .b(sel),
        .out(and_b)
    );
    
    or_gate or1(
        .a(and_a),
        .b(and_b),
        .out(out)
    );
endmodule

//------------------------------------------------------
// Barrel Shifter built from MUXes
//------------------------------------------------------
module barrel_shifter #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] data,
    input [$clog2(WIDTH)-1:0] shift_amount,
    input direction,  // 0: left, 1: right
    input arithmetic, // 0: logic, 1: arithmetic (only for right shift)
    output [WIDTH-1:0] result
);
    // Intermediate wires for each stage of shifting
    wire [WIDTH-1:0] temp [0:$clog2(WIDTH)];
    wire [WIDTH-1:0] right_shift_input;
    
    // Reverse data for left shift
    genvar j;
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin : reverse_loop
            assign right_shift_input[j] = direction ? data[j] : data[WIDTH-1-j];
        end
    endgenerate
    
    // Initial assignment
    assign temp[0] = right_shift_input;
    
    // Create shifter stages
    genvar i, k;
    generate
        for (i = 0; i < $clog2(WIDTH); i = i + 1) begin : shift_stage
            for (k = 0; k < WIDTH; k = k + 1) begin : shift_bit
                if (k + (1 << i) < WIDTH) begin
                    // Bit can be shifted
                    mux_2to1 mux(
                        .a(temp[i][k]),
                        .b(temp[i][k + (1 << i)]),
                        .sel(shift_amount[i]),
                        .out(temp[i+1][k])
                    );
                end else begin
                    // Fill-in bit
                    wire fill_bit;
                    // Arithmetic right shift preserves sign bit, others fill with 0
                    assign fill_bit = (arithmetic & direction & temp[i][WIDTH-1]);
                    
                    mux_2to1 mux(
                        .a(temp[i][k]),
                        .b(fill_bit),
                        .sel(shift_amount[i]),
                        .out(temp[i+1][k])
                    );
                end
            end
        end
    endgenerate
    
    // Reverse result for left shift
    wire [WIDTH-1:0] final_result;
    assign final_result = temp[$clog2(WIDTH)];
    
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin : output_reverse_loop
            assign result[j] = direction ? final_result[j] : final_result[WIDTH-1-j];
        end
    endgenerate
endmodule

//------------------------------------------------------
// Comparator module for all comparison operations
//------------------------------------------------------
module comparator #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input is_signed,
    output equal,
    output not_equal,
    output less_than,
    output greater_equal,
    output less_than_unsigned,
    output greater_equal_unsigned
);
    // Equal and Not Equal operations
    wire [WIDTH-1:0] xor_result;
    wire [WIDTH-1:0] or_chain;
    
    // XOR for equality check (a XOR b = 0 when a = b)
    multi_bit_xor #(WIDTH) xor_eq(
        .a(a),
        .b(b),
        .result(xor_result)
    );
    
    // OR reduction to check if any bit is different
    assign or_chain[0] = xor_result[0];
    
    genvar i;
    generate
        for (i = 1; i < WIDTH; i = i + 1) begin : or_reduction
            or_gate or_inst(
                .a(or_chain[i-1]),
                .b(xor_result[i]),
                .out(or_chain[i])
            );
        end
    endgenerate
    
    // Equal if all bits are the same (OR chain = 0)
    not_gate not_eq(
        .a(or_chain[WIDTH-1]),
        .out(equal)
    );
    
    // Not equal is just the opposite of equal
    assign not_equal = or_chain[WIDTH-1];
    
    // Less than and greater equal operations
    wire [WIDTH-1:0] sub_result;
    wire borrow;
    
    // Subtractor to compute a - b
    subtractor #(WIDTH) sub(
        .a(a),
        .b(b),
        .result(sub_result),
        .borrow(borrow)
    );
    
    // For signed comparison
    wire sign_a = a[WIDTH-1];
    wire sign_b = b[WIDTH-1];
    wire sign_result = sub_result[WIDTH-1];
    
    // Less than signed: 
    // If signs are different: a < b if a is negative and b is positive
    // If signs are same: a < b if result is negative
    wire sign_diff;
    xor_gate xor_sign(
        .a(sign_a),
        .b(sign_b),
        .out(sign_diff)
    );
    
    wire lt_same_sign;
    and_gate and_lt_same(
        .a(~sign_diff),
        .b(sign_result),
        .out(lt_same_sign)
    );
    
    wire lt_diff_sign;
    and_gate and_lt_diff(
        .a(sign_diff),
        .b(sign_a),
        .out(lt_diff_sign)
    );
    
    or_gate or_lt(
        .a(lt_same_sign),
        .b(lt_diff_sign),
        .out(less_than)
    );
    
    // Greater than or equal is just the opposite of less than
    not_gate not_lt(
        .a(less_than),
        .out(greater_equal)
    );
    
    // For unsigned comparison, we just check the borrow flag
    assign less_than_unsigned = borrow;
    
    // Greater than or equal unsigned is just the opposite of less than unsigned
    not_gate not_ltu(
        .a(less_than_unsigned),
        .out(greater_equal_unsigned)
    );
endmodule

//------------------------------------------------------
// Subtractor for comparison operations
//------------------------------------------------------
module subtractor #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] result,
    output borrow
);
    wire [WIDTH:0] borrows;
    assign borrows[0] = 1'b0;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sub_bit
            wire not_a, and_not_a_b, and_not_a_borrow, or_borrow;
            
            // not_a = ~a[i]
            not_gate not_a_gate(
                .a(a[i]),
                .out(not_a)
            );
            
            // and_not_a_b = ~a[i] & b[i]
            and_gate and_gate1(
                .a(not_a),
                .b(b[i]),
                .out(and_not_a_b)
            );
            
            // and_not_a_borrow = ~a[i] & borrows[i]
            and_gate and_gate2(
                .a(not_a),
                .b(borrows[i]),
                .out(and_not_a_borrow)
            );
            
            // and_b_borrow = b[i] & borrows[i]
            wire and_b_borrow;
            and_gate and_gate3(
                .a(b[i]),
                .b(borrows[i]),
                .out(and_b_borrow)
            );
            
            // borrows[i+1] = (~a[i] & b[i]) | (~a[i] & borrows[i]) | (b[i] & borrows[i])
            wire or_temp;
            or_gate or_gate1(
                .a(and_not_a_b),
                .b(and_not_a_borrow),
                .out(or_temp)
            );
            
            or_gate or_gate2(
                .a(or_temp),
                .b(and_b_borrow),
                .out(borrows[i+1])
            );
            
            // result[i] = a[i] ^ b[i] ^ borrows[i]
            wire xor_ab;
            xor_gate xor_gate1(
                .a(a[i]),
                .b(b[i]),
                .out(xor_ab)
            );
            
            xor_gate xor_gate2(
                .a(xor_ab),
                .b(borrows[i]),
                .out(result[i])
            );
        end
    endgenerate
    
    // Final borrow indicates if a < b (unsigned)
    assign borrow = borrows[WIDTH];
endmodule
