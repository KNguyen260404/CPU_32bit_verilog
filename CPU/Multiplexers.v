// 2-to-1 Multiplexer
module MUX2to1 #(
    parameter WIDTH = 32
)(
    input select,
    input [WIDTH-1:0] input0,
    input [WIDTH-1:0] input1,
    output [WIDTH-1:0] out
);
    // Combinational logic for 2-to-1 multiplexer
    assign out = select ? input1 : input0;
endmodule

// 4-to-1 Multiplexer
module MUX4to1 #(
    parameter WIDTH = 32
)(
    input [1:0] select,
    input [WIDTH-1:0] input0,
    input [WIDTH-1:0] input1,
    input [WIDTH-1:0] input2,
    input [WIDTH-1:0] input3,
    output [WIDTH-1:0] out
);
    // Combinational logic for 4-to-1 multiplexer
    assign out = (select == 2'b00) ? input0 :
                 (select == 2'b01) ? input1 :
                 (select == 2'b10) ? input2 : input3;
endmodule
