# Thiết kế các Module Logic từ Cổng Logic Cơ bản

## 1. Giới thiệu

Thay vì sử dụng các toán tử logic có sẵn trong Verilog (`&`, `|`, `^`, `~`, `<<`, `>>`), chúng ta có thể thiết kế các module logic từ các cổng cơ bản. Điều này giúp hiểu rõ hơn về cách các cổng logic được triển khai trong phần cứng thực tế.

## 2. Cổng Logic Cơ bản

### 2.1 Cổng NAND

NAND là cổng logic vạn năng, có thể dùng để xây dựng tất cả các cổng logic khác. Trong Verilog, chúng ta có thể định nghĩa cổng NAND như sau:

```verilog
// Cổng NAND 2 đầu vào
module nand_gate(
    input a, b,
    output out
);
    // Sử dụng primitive trong Verilog
    nand(out, a, b);
    
    // Hoặc có thể định nghĩa bằng RTL
    // assign out = ~(a & b);
endmodule
```

### 2.2 Cổng NOR

NOR cũng là cổng logic vạn năng:

```verilog
// Cổng NOR 2 đầu vào
module nor_gate(
    input a, b,
    output out
);
    // Sử dụng primitive trong Verilog
    nor(out, a, b);
    
    // Hoặc có thể định nghĩa bằng RTL
    // assign out = ~(a | b);
endmodule
```

## 3. Xây dựng các Cổng Logic từ NAND và NOR

### 3.1 Cổng NOT từ NAND

```verilog
module not_gate(
    input a,
    output out
);
    // NOT từ NAND: a NAND a = NOT a
    nand_gate nand1(
        .a(a),
        .b(a),
        .out(out)
    );
endmodule
```

### 3.2 Cổng AND từ NAND

```verilog
module and_gate(
    input a, b,
    output out
);
    wire nand_out;
    
    // AND từ NAND: NOT(a NAND b) = a AND b
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
```

### 3.3 Cổng OR từ NAND

```verilog
module or_gate(
    input a, b,
    output out
);
    wire not_a, not_b;
    
    // OR từ NAND: (NOT a) NAND (NOT b) = a OR b
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
```

### 3.4 Cổng XOR từ NAND

```verilog
module xor_gate(
    input a, b,
    output out
);
    wire nand_out, nand_a, nand_b;
    
    // XOR từ NAND: (a NAND (a NAND b)) NAND (b NAND (a NAND b))
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
```

## 4. Module Logic nhiều bit

### 4.1 Module AND nhiều bit

```verilog
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
```

### 4.2 Module OR nhiều bit

```verilog
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
```

### 4.3 Module XOR nhiều bit

```verilog
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
```

### 4.4 Module NOT nhiều bit

```verilog
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
```

## 5. Thiết kế Shifter từ MUX

### 5.1 2-to-1 MUX từ cổng logic cơ bản

```verilog
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
```

### 5.2 Barrel Shifter từ MUX

```verilog
module barrel_shifter #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] data,
    input [$clog2(WIDTH)-1:0] shift_amount,
    input direction,  // 0: left, 1: right
    input arithmetic, // 0: logic, 1: arithmetic (chỉ cho right shift)
    output [WIDTH-1:0] result
);
    // Khai báo các dây nối trung gian
    wire [WIDTH-1:0] temp [0:$clog2(WIDTH)];
    wire [WIDTH-1:0] right_shift_input;
    
    // Đảo ngược dữ liệu cho left shift
    genvar j;
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin : reverse_loop
            assign right_shift_input[j] = direction ? data[j] : data[WIDTH-1-j];
        end
    endgenerate
    
    // Gán giá trị ban đầu
    assign temp[0] = right_shift_input;
    
    // Tạo các tầng shifter
    genvar i, k;
    generate
        for (i = 0; i < $clog2(WIDTH); i = i + 1) begin : shift_stage
            for (k = 0; k < WIDTH; k = k + 1) begin : shift_bit
                if (k + (1 << i) < WIDTH) begin
                    // Bit có thể shift
                    mux_2to1 mux(
                        .a(temp[i][k]),
                        .b(temp[i][k + (1 << i)]),
                        .sel(shift_amount[i]),
                        .out(temp[i+1][k])
                    );
                end else begin
                    // Bit fill-in
                    wire fill_bit;
                    // Arithmetic right shift giữ bit dấu, còn lại fill 0
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
    
    // Đảo ngược kết quả cho left shift
    wire [WIDTH-1:0] final_result;
    assign final_result = temp[$clog2(WIDTH)];
    
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin : output_reverse_loop
            assign result[j] = direction ? final_result[j] : final_result[WIDTH-1-j];
        end
    endgenerate
endmodule
```

## 6. Module Logic Unit Hoàn Chỉnh

Kết hợp tất cả các module trên để tạo một Logic Unit hoàn chỉnh:

```verilog
module logic_unit #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input [2:0] op,  // 000: AND, 001: OR, 010: XOR, 011: NOT, 100: SLL, 101: SRL, 110: SRA
    input [$clog2(WIDTH)-1:0] shift_amount,
    output [WIDTH-1:0] result
);
    wire [WIDTH-1:0] and_result, or_result, xor_result, not_result;
    wire [WIDTH-1:0] sll_result, srl_result, sra_result;
    
    // Instantiate các module logic
    multi_bit_and #(WIDTH) and_op(
        .a(a),
        .b(b),
        .result(and_result)
    );
    
    multi_bit_or #(WIDTH) or_op(
        .a(a),
        .b(b),
        .result(or_result)
    );
    
    multi_bit_xor #(WIDTH) xor_op(
        .a(a),
        .b(b),
        .result(xor_result)
    );
    
    multi_bit_not #(WIDTH) not_op(
        .a(a),
        .result(not_result)
    );
    
    // Left shift (SLL)
    barrel_shifter #(WIDTH) sll_op(
        .data(a),
        .shift_amount(shift_amount),
        .direction(1'b0),  // left shift
        .arithmetic(1'b0), // logic shift
        .result(sll_result)
    );
    
    // Right logic shift (SRL)
    barrel_shifter #(WIDTH) srl_op(
        .data(a),
        .shift_amount(shift_amount),
        .direction(1'b1),  // right shift
        .arithmetic(1'b0), // logic shift
        .result(srl_result)
    );
    
    // Right arithmetic shift (SRA)
    barrel_shifter #(WIDTH) sra_op(
        .data(a),
        .shift_amount(shift_amount),
        .direction(1'b1),  // right shift
        .arithmetic(1'b1), // arithmetic shift
        .result(sra_result)
    );
    
    // Multiplexer để chọn kết quả cuối cùng
    reg [WIDTH-1:0] mux_result;
    always @(*) begin
        case (op)
            3'b000: mux_result = and_result;
            3'b001: mux_result = or_result;
            3'b010: mux_result = xor_result;
            3'b011: mux_result = not_result;
            3'b100: mux_result = sll_result;
            3'b101: mux_result = srl_result;
            3'b110: mux_result = sra_result;
            default: mux_result = {WIDTH{1'b0}};
        endcase
    end
    
    assign result = mux_result;
endmodule
```

## 7. Tối ưu hóa và Cải tiến

### 7.1 Tối ưu hóa Barrel Shifter

Barrel Shifter có thể được tối ưu hóa bằng cách sử dụng cấu trúc log2(N) tầng, mỗi tầng xử lý shift 1, 2, 4, 8, ... bit:

```verilog
module optimized_barrel_shifter #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] data,
    input [$clog2(WIDTH)-1:0] shift_amount,
    input direction,  // 0: left, 1: right
    input arithmetic, // 0: logic, 1: arithmetic
    output [WIDTH-1:0] result
);
    // Tương tự như barrel_shifter nhưng với cấu trúc tối ưu hơn
    // ...
endmodule
```

### 7.2 Sử dụng Transmission Gate thay vì MUX

Trong thiết kế CMOS thực tế, Transmission Gate thường được sử dụng thay vì MUX để giảm độ trễ và tiêu thụ điện năng:

```verilog
// Mô phỏng Transmission Gate trong Verilog
module transmission_gate(
    input data,
    input control,
    output out
);
    // Trong Verilog, chúng ta mô phỏng hành vi của transmission gate
    assign out = control ? data : 1'bz;
endmodule
```

## 8. Kiểm thử các Module Logic

### 8.1 Testbench cho các cổng logic cơ bản

```verilog
module basic_gates_tb;
    reg a, b;
    wire and_out, or_out, xor_out, not_out;
    
    // Instantiate các module cần test
    and_gate and_gate_inst(.a(a), .b(b), .out(and_out));
    or_gate or_gate_inst(.a(a), .b(b), .out(or_out));
    xor_gate xor_gate_inst(.a(a), .b(b), .out(xor_out));
    not_gate not_gate_inst(.a(a), .out(not_out));
    
    initial begin
        // Test case 1: a=0, b=0
        a = 0; b = 0;
        #10;
        if (and_out !== 0 || or_out !== 0 || xor_out !== 0 || not_out !== 1)
            $display("Test case 1 failed");
        
        // Test case 2: a=0, b=1
        a = 0; b = 1;
        #10;
        if (and_out !== 0 || or_out !== 1 || xor_out !== 1)
            $display("Test case 2 failed");
        
        // Test case 3: a=1, b=0
        a = 1; b = 0;
        #10;
        if (and_out !== 0 || or_out !== 1 || xor_out !== 1 || not_out !== 0)
            $display("Test case 3 failed");
        
        // Test case 4: a=1, b=1
        a = 1; b = 1;
        #10;
        if (and_out !== 1 || or_out !== 1 || xor_out !== 0)
            $display("Test case 4 failed");
        
        $display("All tests completed");
        $finish;
    end
endmodule
```

### 8.2 Testbench cho Barrel Shifter

```verilog
module barrel_shifter_tb;
    parameter WIDTH = 8;
    
    reg [WIDTH-1:0] data;
    reg [$clog2(WIDTH)-1:0] shift_amount;
    reg direction, arithmetic;
    wire [WIDTH-1:0] result;
    
    // Instantiate barrel shifter
    barrel_shifter #(WIDTH) uut(
        .data(data),
        .shift_amount(shift_amount),
        .direction(direction),
        .arithmetic(arithmetic),
        .result(result)
    );
    
    initial begin
        // Test logical left shift
        data = 8'b00001111; shift_amount = 2; direction = 0; arithmetic = 0;
        #10;
        if (result !== 8'b00111100)
            $display("Left shift test failed: %b", result);
        
        // Test logical right shift
        data = 8'b11110000; shift_amount = 2; direction = 1; arithmetic = 0;
        #10;
        if (result !== 8'b00111100)
            $display("Logical right shift test failed: %b", result);
        
        // Test arithmetic right shift
        data = 8'b10110000; shift_amount = 2; direction = 1; arithmetic = 1;
        #10;
        if (result !== 8'b11101100)
            $display("Arithmetic right shift test failed: %b", result);
        
        $display("All tests completed");
        $finish;
    end
endmodule
```

## 9. Kết luận

Thiết kế các module logic từ cổng cơ bản thay vì sử dụng các toán tử có sẵn trong Verilog giúp:

1. Hiểu sâu hơn về cách triển khai phần cứng thực tế
2. Kiểm soát tốt hơn về hiệu suất (tốc độ, diện tích, năng lượng)
3. Tạo ra thiết kế phù hợp với các ràng buộc cụ thể
4. Dễ dàng tối ưu hóa từng thành phần

Các module logic này có thể được tích hợp vào ALU để tạo thành một CPU hoàn chỉnh mà không cần sử dụng các toán tử có sẵn của Verilog. 