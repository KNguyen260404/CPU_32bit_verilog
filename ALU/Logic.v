module Logic #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [3:0] operation,    // Added 1 more bit to support more operations
    input [$clog2(WIDTH)-1:0] shift_amount,
    input is_signed,          // Added to indicate if comparison should be signed
    output [WIDTH-1:0] result
);

    // Operation encoding
    localparam AND_OP = 4'b0000;
    localparam OR_OP  = 4'b0001;
    localparam XOR_OP = 4'b0010;
    localparam NOT_OP = 4'b0011;
    localparam SLL_OP = 4'b0100;
    localparam SRL_OP = 4'b0101;
    localparam SRA_OP = 4'b0110;
    localparam NOR_OP = 4'b0111;
    // New comparison operations
    localparam EQ_OP  = 4'b1000; // Equal
    localparam NE_OP  = 4'b1001; // Not Equal
    localparam LT_OP  = 4'b1010; // Less Than
    localparam GE_OP  = 4'b1011; // Greater Than or Equal
    localparam LTU_OP = 4'b1100; // Less Than Unsigned
    localparam GEU_OP = 4'b1101; // Greater Than or Equal Unsigned

    // Results from each operation
    wire [WIDTH-1:0] and_result, or_result, xor_result, not_result;
    wire [WIDTH-1:0] sll_result, srl_result, sra_result, nor_result;
    // Comparison results
    wire eq_result, ne_result, lt_result, ge_result, ltu_result, geu_result;
    
    // Instantiate the logic modules
    multi_bit_and #(WIDTH) and_op(
        .a(operand_a),
        .b(operand_b),
        .result(and_result)
    );
    
    multi_bit_or #(WIDTH) or_op(
        .a(operand_a),
        .b(operand_b),
        .result(or_result)
    );
    
    multi_bit_xor #(WIDTH) xor_op(
        .a(operand_a),
        .b(operand_b),
        .result(xor_result)
    );
    
    multi_bit_not #(WIDTH) not_op(
        .a(operand_a),
        .result(not_result)
    );
    
    multi_bit_nor #(WIDTH) nor_op(
        .a(operand_a),
        .b(operand_b),
        .result(nor_result)
    );
    
    // Barrel shifters for shift operations
    barrel_shifter #(WIDTH) sll_shifter(
        .data(operand_a),
        .shift_amount(shift_amount),
        .direction(1'b0),  // left shift
        .arithmetic(1'b0), // logical shift
        .result(sll_result)
    );
    
    barrel_shifter #(WIDTH) srl_shifter(
        .data(operand_a),
        .shift_amount(shift_amount),
        .direction(1'b1),  // right shift
        .arithmetic(1'b0), // logical shift
        .result(srl_result)
    );
    
    barrel_shifter #(WIDTH) sra_shifter(
        .data(operand_a),
        .shift_amount(shift_amount),
        .direction(1'b1),  // right shift
        .arithmetic(1'b1), // arithmetic shift
        .result(sra_result)
    );
    
    // Comparison operations
    comparator #(WIDTH) comp(
        .a(operand_a),
        .b(operand_b),
        .is_signed(is_signed),
        .equal(eq_result),
        .not_equal(ne_result),
        .less_than(lt_result),
        .greater_equal(ge_result),
        .less_than_unsigned(ltu_result),
        .greater_equal_unsigned(geu_result)
    );
    
    // Select the result based on operation
    reg [WIDTH-1:0] selected_result;
    always @(*) begin
        case (operation)
            AND_OP: selected_result = and_result;
            OR_OP:  selected_result = or_result;
            XOR_OP: selected_result = xor_result;
            NOT_OP: selected_result = not_result;
            SLL_OP: selected_result = sll_result;
            SRL_OP: selected_result = srl_result;
            SRA_OP: selected_result = sra_result;
            NOR_OP: selected_result = nor_result;
            EQ_OP:  selected_result = {{(WIDTH-1){1'b0}}, eq_result};
            NE_OP:  selected_result = {{(WIDTH-1){1'b0}}, ne_result};
            LT_OP:  selected_result = {{(WIDTH-1){1'b0}}, lt_result};
            GE_OP:  selected_result = {{(WIDTH-1){1'b0}}, ge_result};
            LTU_OP: selected_result = {{(WIDTH-1){1'b0}}, ltu_result};
            GEU_OP: selected_result = {{(WIDTH-1){1'b0}}, geu_result};
            default: selected_result = {WIDTH{1'b0}};
        endcase
    end
    
    assign result = selected_result;

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
