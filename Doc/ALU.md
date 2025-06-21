# Thiết kế ALU (Arithmetic Logic Unit) từ các khối cơ bản

## 1. Giới thiệu

ALU (Arithmetic Logic Unit) là thành phần trung tâm của CPU, thực hiện các phép toán số học và logic. Thay vì sử dụng các toán tử sẵn có trong Verilog (như `+`, `-`, `*`, `/`), chúng ta có thể thiết kế ALU từ các khối cơ bản để hiểu rõ hơn về kiến trúc phần cứng thực tế và tối ưu hóa hiệu suất.

## 2. Các khối cơ bản

### 2.1 Half Adder (HA)

Half Adder là khối cộng cơ bản nhất, cộng hai bit và tạo ra tổng (sum) và bit nhớ (carry).

```verilog
module half_adder(
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;      // XOR
    assign carry = a & b;    // AND
endmodule
```

### 2.2 Full Adder (FA)

Full Adder cộng ba bit (hai bit đầu vào và một bit nhớ) và tạo ra tổng và bit nhớ mới.

```verilog
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
```

### 2.3 Ripple Carry Adder (RCA)

RCA kết nối nhiều Full Adder để cộng hai số nhiều bit.

```verilog
module ripple_carry_adder #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);
    wire [WIDTH:0] carry;
    assign carry[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : adder_loop
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    assign cout = carry[WIDTH];
endmodule
```

### 2.4 Carry Lookahead Adder (CLA)

CLA cải thiện tốc độ của RCA bằng cách tính toán các bit nhớ song song.

```verilog
module carry_lookahead_adder #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input cin,
    output [WIDTH-1:0] sum,
    output cout
);
    wire [WIDTH-1:0] p, g; // Propagate, Generate
    wire [WIDTH:0] c;      // Carries
    
    assign c[0] = cin;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : pg_loop
            assign p[i] = a[i] ^ b[i];  // Propagate
            assign g[i] = a[i] & b[i];  // Generate
        end
    endgenerate
    
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_loop
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sum_loop
            assign sum[i] = p[i] ^ c[i];
        end
    endgenerate
    
    assign cout = c[WIDTH];
endmodule
```

## 3. Phép trừ sử dụng bù 2

Để thực hiện phép trừ A - B, chúng ta tính A + (-B), trong đó -B là bù 2 của B.

```verilog
module subtractor #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    output [WIDTH-1:0] result,
    output overflow
);
    wire [WIDTH-1:0] b_complement;
    wire cout;
    
    // Bù 1 của B
    wire [WIDTH-1:0] b_complement_1 = ~b;
    
    // Bù 2 của B (bù 1 + 1)
    ripple_carry_adder #(WIDTH) adder1(
        .a(b_complement_1),
        .b({{(WIDTH-1){1'b0}}, 1'b1}),
        .cin(1'b0),
        .sum(b_complement),
        .cout()
    );
    
    // A + (-B)
    ripple_carry_adder #(WIDTH) adder2(
        .a(a),
        .b(b_complement),
        .cin(1'b0),
        .sum(result),
        .cout(cout)
    );
    
    // Overflow xảy ra khi dấu của a và result khác nhau, và dấu của b_complement và result giống nhau
    assign overflow = (a[WIDTH-1] != result[WIDTH-1]) && (b_complement[WIDTH-1] != a[WIDTH-1]);
endmodule
```

## 4. Phép nhân tốc độ cao

### 4.1 Array Multiplier

Phương pháp nhân cơ bản, sử dụng phép cộng và dịch bit.

```verilog
module array_multiplier #(
    parameter WIDTH = 16
)(
    input [WIDTH-1:0] a, b,
    output [2*WIDTH-1:0] product
);
    wire [WIDTH-1:0] partial_products [WIDTH-1:0];
    wire [WIDTH-1:0] sum [WIDTH-1:0];
    wire [WIDTH-1:0] carry;
    
    genvar i, j;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : pp_row
            for (j = 0; j < WIDTH; j = j + 1) begin : pp_col
                assign partial_products[i][j] = a[j] & b[i];
            end
        end
    endgenerate
    
    // Tính tổng các partial products
    // (Phần này đơn giản hóa, thực tế cần nhiều adder kết nối phức tạp hơn)
    
    // Kết quả cuối cùng
    // (Phần này cũng đơn giản hóa)
    assign product = {sum[WIDTH-1], partial_products[0]};
endmodule
```

### 4.2 Booth Multiplier

Thuật toán Booth giảm số lượng phép cộng cần thiết.

```verilog
module booth_multiplier #(
    parameter WIDTH = 16
)(
    input [WIDTH-1:0] a, b,
    output [2*WIDTH-1:0] product
);
    reg [2*WIDTH:0] A, S, P;
    integer i;
    
    always @(*) begin
        // Khởi tạo
        A = {{WIDTH{1'b0}}, a, 1'b0};
        S = {{WIDTH{1'b1}}, ~a + 1'b1, 1'b0};
        P = {{WIDTH{1'b0}}, b, 1'b0};
        
        // Thuật toán Booth
        for (i = 0; i < WIDTH; i = i + 1) begin
            case (P[1:0])
                2'b01: P = P + A;
                2'b10: P = P + S;
                default: ; // Không làm gì
            endcase
            
            // Dịch phải số học
            P = {P[2*WIDTH], P[2*WIDTH:1]};
        end
    end
    
    assign product = P[2*WIDTH:1];
endmodule
```

### 4.3 Wallace Tree Multiplier

Wallace Tree sử dụng các Carry Save Adder để giảm độ trễ.

```verilog
// Đây là phần giới thiệu về Wallace Tree, mã thực tế phức tạp hơn nhiều
module wallace_tree_multiplier #(
    parameter WIDTH = 16
)(
    input [WIDTH-1:0] a, b,
    output [2*WIDTH-1:0] product
);
    // Tạo partial products
    wire [WIDTH-1:0] pp [WIDTH-1:0];
    
    genvar i, j;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : pp_gen
            for (j = 0; j < WIDTH; j = j + 1) begin
                assign pp[i][j] = a[j] & b[i];
            end
        end
    endgenerate
    
    // Wallace Tree reduction (đơn giản hóa)
    // ...
    
    // Final addition
    // ...
    
    // Kết quả cuối cùng
    assign product = /* ... */;
endmodule
```

## 5. Phép chia tốc độ cao

### 5.1 Restoring Division

Thuật toán chia cơ bản.

```verilog
module restoring_division #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] dividend, divisor,
    output [WIDTH-1:0] quotient, remainder
);
    reg [WIDTH-1:0] q, r;
    reg [WIDTH-1:0] d;
    integer i;
    
    always @(*) begin
        r = {WIDTH{1'b0}};
        q = dividend;
        d = divisor;
        
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Dịch trái R và thêm bit cao nhất của Q
            r = {r[WIDTH-2:0], q[WIDTH-1]};
            q = {q[WIDTH-2:0], 1'b0};
            
            // Trừ divisor
            r = r - d;
            
            // Kiểm tra kết quả
            if (r[WIDTH-1] == 1'b1) begin
                // Nếu âm, restore và set bit thấp nhất của Q = 0
                r = r + d;
            end else begin
                // Nếu không âm, set bit thấp nhất của Q = 1
                q[0] = 1'b1;
            end
        end
    end
    
    assign quotient = q;
    assign remainder = r;
endmodule
```

### 5.2 Non-Restoring Division

Cải tiến của Restoring Division.

```verilog
module non_restoring_division #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] dividend, divisor,
    output [WIDTH-1:0] quotient, remainder
);
    reg [WIDTH-1:0] q, r;
    reg [WIDTH-1:0] d;
    integer i;
    
    always @(*) begin
        r = {WIDTH{1'b0}};
        q = dividend;
        d = divisor;
        
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Dịch trái R và thêm bit cao nhất của Q
            r = {r[WIDTH-2:0], q[WIDTH-1]};
            q = {q[WIDTH-2:0], 1'b0};
            
            // Cộng hoặc trừ divisor tùy thuộc vào dấu của R
            if (r[WIDTH-1] == 1'b0) begin
                r = r - d;
                if (r[WIDTH-1] == 1'b0)
                    q[0] = 1'b1;
            end else begin
                r = r + d;
                if (r[WIDTH-1] == 1'b1)
                    q[0] = 1'b1;
            end
        end
        
        // Điều chỉnh remainder nếu nó âm
        if (r[WIDTH-1] == 1'b1)
            r = r + d;
    end
    
    assign quotient = q;
    assign remainder = r;
endmodule
```

## 6. Phép toán logic

### 6.1 Phép AND, OR, XOR, NOT

```verilog
module logic_unit #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input [1:0] op,
    output reg [WIDTH-1:0] result
);
    always @(*) begin
        case (op)
            2'b00: result = a & b;    // AND
            2'b01: result = a | b;    // OR
            2'b10: result = a ^ b;    // XOR
            2'b11: result = ~a;       // NOT
        endcase
    end
endmodule
```

### 6.2 Phép dịch bit (Shifter)

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
    reg [WIDTH-1:0] temp;
    integer i;
    
    always @(*) begin
        temp = data;
        
        if (direction == 1'b0) begin
            // Left shift
            temp = temp << shift_amount;
        end else begin
            // Right shift
            if (arithmetic == 1'b1) begin
                // Arithmetic right shift (giữ bit dấu)
                temp = $signed(temp) >>> shift_amount;
            end else begin
                // Logical right shift
                temp = temp >> shift_amount;
            end
        end
    end
    
    assign result = temp;
endmodule
```

## 7. Thiết kế ALU hoàn chỉnh

Kết hợp tất cả các module trên để tạo ALU hoàn chỉnh.

```verilog
module alu #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] operand_a, operand_b,
    input [3:0] alu_control,
    output reg [WIDTH-1:0] result,
    output zero, overflow, negative
);
    // Kết quả từ các module con
    wire [WIDTH-1:0] add_result, sub_result;
    wire [2*WIDTH-1:0] mul_result;
    wire [WIDTH-1:0] div_quotient, div_remainder;
    wire [WIDTH-1:0] logic_result;
    wire [WIDTH-1:0] shift_result;
    wire add_overflow, sub_overflow;
    
    // Instantiate các module con
    ripple_carry_adder #(WIDTH) adder(
        .a(operand_a),
        .b(operand_b),
        .cin(1'b0),
        .sum(add_result),
        .cout()
    );
    
    subtractor #(WIDTH) sub(
        .a(operand_a),
        .b(operand_b),
        .result(sub_result),
        .overflow(sub_overflow)
    );
    
    booth_multiplier #(WIDTH/2) mult(  // Giảm kích thước để đơn giản hóa
        .a(operand_a[WIDTH/2-1:0]),
        .b(operand_b[WIDTH/2-1:0]),
        .product(mul_result)
    );
    
    non_restoring_division #(WIDTH) div(
        .dividend(operand_a),
        .divisor(operand_b),
        .quotient(div_quotient),
        .remainder(div_remainder)
    );
    
    logic_unit #(WIDTH) logic_op(
        .a(operand_a),
        .b(operand_b),
        .op(alu_control[1:0]),
        .result(logic_result)
    );
    
    barrel_shifter #(WIDTH) shifter(
        .data(operand_a),
        .shift_amount(operand_b[$clog2(WIDTH)-1:0]),
        .direction(alu_control[0]),
        .arithmetic(alu_control[1]),
        .result(shift_result)
    );
    
    // Chọn kết quả dựa trên alu_control
    always @(*) begin
        case (alu_control)
            4'b0000: result = add_result;                // ADD
            4'b0001: result = sub_result;                // SUB
            4'b0010: result = mul_result[WIDTH-1:0];     // MUL (lấy phần thấp)
            4'b0011: result = div_quotient;              // DIV
            4'b0100: result = div_remainder;             // REM
            4'b0101: result = logic_result;              // AND
            4'b0110: result = logic_result;              // OR
            4'b0111: result = logic_result;              // XOR
            4'b1000: result = shift_result;              // SLL
            4'b1001: result = shift_result;              // SRL
            4'b1010: result = shift_result;              // SRA
            4'b1011: result = {31'b0, operand_a < operand_b}; // SLT
            default: result = {WIDTH{1'b0}};
        endcase
    end
    
    // Cờ trạng thái
    assign zero = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];
    assign overflow = (alu_control == 4'b0000) ? 
                      ((operand_a[WIDTH-1] == operand_b[WIDTH-1]) && (result[WIDTH-1] != operand_a[WIDTH-1])) :
                      (alu_control == 4'b0001) ? sub_overflow : 1'b0;
endmodule
```

## 8. Tối ưu hóa hiệu suất

### 8.1 Tối ưu tốc độ

- Sử dụng Carry Lookahead Adder thay vì Ripple Carry Adder
- Sử dụng Wallace Tree hoặc Dadda Multiplier thay vì Array Multiplier
- Sử dụng SRT Division thay vì Non-Restoring Division
- Pipeline các phép toán phức tạp như nhân và chia

### 8.2 Tối ưu diện tích

- Sử dụng Ripple Carry Adder cho diện tích nhỏ
- Sử dụng Sequential Multiplier thay vì Combinational Multiplier
- Chia sẻ tài nguyên giữa các phép toán khác nhau

### 8.3 Tối ưu năng lượng

- Giảm chuyển đổi trạng thái không cần thiết
- Sử dụng clock gating cho các phép toán không thường xuyên sử dụng
- Sử dụng các kỹ thuật thiết kế năng lượng thấp như operand isolation

## 9. Kiểm thử ALU

### 9.1 Testbench cơ bản

```verilog
module alu_tb;
    parameter WIDTH = 32;
    
    reg [WIDTH-1:0] operand_a, operand_b;
    reg [3:0] alu_control;
    wire [WIDTH-1:0] result;
    wire zero, overflow, negative;
    
    // Instantiate ALU
    alu #(WIDTH) uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .negative(negative)
    );
    
    initial begin
        // Test ADD
        operand_a = 32'd10; operand_b = 32'd20; alu_control = 4'b0000;
        #10;
        if (result !== 32'd30) $display("ADD test failed");
        
        // Test SUB
        operand_a = 32'd30; operand_b = 32'd10; alu_control = 4'b0001;
        #10;
        if (result !== 32'd20) $display("SUB test failed");
        
        // Test AND
        operand_a = 32'hFF00FF00; operand_b = 32'h0F0F0F0F; alu_control = 4'b0101;
        #10;
        if (result !== 32'h0F000F00) $display("AND test failed");
        
        // Test OR
        operand_a = 32'hFF00FF00; operand_b = 32'h0F0F0F0F; alu_control = 4'b0110;
        #10;
        if (result !== 32'hFF0FFF0F) $display("OR test failed");
        
        // Test overflow
        operand_a = 32'h7FFFFFFF; operand_b = 32'd1; alu_control = 4'b0000;
        #10;
        if (!overflow) $display("Overflow test failed");
        
        // Test zero
        operand_a = 32'd0; operand_b = 32'd0; alu_control = 4'b0000;
        #10;
        if (!zero) $display("Zero test failed");
        
        $display("All tests completed");
        $finish;
    end
endmodule
```

### 9.2 Kiểm thử tự động

Sử dụng các công cụ kiểm thử tự động như SystemVerilog Assertions hoặc UVM để kiểm tra chức năng của ALU một cách toàn diện.

## 10. Kết luận

Thiết kế ALU từ các khối cơ bản như HA, FA, RCA và các thuật toán nhân chia tốc độ cao giúp:

1. Hiểu sâu hơn về kiến trúc phần cứng
2. Kiểm soát tốt hơn về hiệu suất (tốc độ, diện tích, năng lượng)
3. Tạo ra thiết kế phù hợp với các ràng buộc cụ thể
4. Dễ dàng tối ưu hóa và mở rộng

Việc sử dụng các khối cơ bản cũng giúp thiết kế dễ dàng tổng hợp (synthesis) thành phần cứng thực tế hơn so với việc sử dụng các toán tử trừu tượng của Verilog. 