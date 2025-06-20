`timescale 1ns / 1ps

module ALU_tb;
    // Parameters
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    // Inputs
    reg [WIDTH-1:0] operand_a;
    reg [WIDTH-1:0] operand_b;
    reg [4:0] alu_control;
    reg [$clog2(WIDTH)-1:0] shift_amount;

    // Outputs
    wire [WIDTH-1:0] result;
    wire zero;
    wire overflow;

    // Clock generation
    reg clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instantiate the Unit Under Test (UUT)
    ALU #(
        .WIDTH(WIDTH)
    ) uut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .shift_amount(shift_amount),
        .result(result),
        .zero(zero),
        .overflow(overflow)
    );

    // VCD file generation for GTKWave
    initial begin
        // Create VCD file for waveform viewing
        $dumpfile("alu_waveform.vcd");
        // Dump all variables at all levels
        $dumpvars(0, ALU_tb);
    end

    // ALU Control Signal Definitions
    // alu_control[4]: 0 = Arithmetic, 1 = Logic
    // alu_control[3:2]: Arithmetic op (00: ADD, 01: SUB, 10: MUL, 11: DIV)
    // alu_control[3:0]: Logic op
    // alu_control[0]: Signed flag

    // Arithmetic Operations
    localparam ADD_UNSIGNED = 5'b00000;
    localparam ADD_SIGNED   = 5'b00001;
    localparam SUB_UNSIGNED = 5'b00100;
    localparam SUB_SIGNED   = 5'b00101;
    localparam MUL_UNSIGNED = 5'b01000;
    localparam MUL_SIGNED   = 5'b01001;
    localparam DIV_UNSIGNED = 5'b01100;
    localparam DIV_SIGNED   = 5'b01101;

    // Logic Operations
    localparam AND_OP       = 5'b10000;
    localparam OR_OP        = 5'b10001;
    localparam XOR_OP       = 5'b10010;
    localparam NOT_OP       = 5'b10011;
    localparam SLL_OP       = 5'b10100;
    localparam SRL_OP       = 5'b10101;
    localparam SRA_OP       = 5'b10110;
    localparam NOR_OP       = 5'b10111;
    localparam EQ_OP        = 5'b11000;
    localparam NE_OP        = 5'b11001;
    localparam LT_SIGNED    = 5'b11010;
    localparam GE_SIGNED    = 5'b11011;
    localparam LT_UNSIGNED  = 5'b11100;
    localparam GE_UNSIGNED  = 5'b11101;

    // Test case counter and expected results
    integer test_case;
    reg [WIDTH-1:0] expected_result;
    reg expected_zero;
    reg expected_overflow;

    // Task to display test results
    task display_test_result;
        input [8*20:1] test_name;
        begin
            $display("Test Case %0d: %s", test_case, test_name);
            $display("  operand_a = %h, operand_b = %h", operand_a, operand_b);
            $display("  Expected: result = %h, zero = %b, overflow = %b", 
                     expected_result, expected_zero, expected_overflow);
            $display("  Actual:   result = %h, zero = %b, overflow = %b", 
                     result, zero, overflow);
            
            if (result !== expected_result || zero !== expected_zero || 
                (alu_control[4] == 1'b0 && overflow !== expected_overflow)) begin
                $display("  TEST FAILED!");
            end else begin
                $display("  Test passed.");
            end
            $display("--------------------------------------");
        end
    endtask

    // Main test procedure
    initial begin
        // Initialize inputs
        operand_a = 0;
        operand_b = 0;
        alu_control = 0;
        shift_amount = 0;
        test_case = 0;

        // Wait for global reset
        #100;

        // Test 1: ADD Unsigned (10 + 15 = 25)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd15;
        alu_control = ADD_UNSIGNED;
        expected_result = 32'd25;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("ADD Unsigned");

        // Test 2: ADD Signed (10 + (-15) = -5)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = -32'd15;
        alu_control = ADD_SIGNED;
        expected_result = -32'd5;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("ADD Signed");

        // Test 3: ADD Overflow (2^31-1 + 1 = overflow)
        test_case = test_case + 1;
        operand_a = 32'h7FFFFFFF; // 2^31 - 1 (max positive signed int)
        operand_b = 32'd1;
        alu_control = ADD_SIGNED;
        expected_result = 32'h80000000; // -2^31 (negative due to overflow)
        expected_zero = 0;
        expected_overflow = 1;
        #20;
        display_test_result("ADD Signed Overflow");

        // Test 4: SUB Unsigned (20 - 10 = 10)
        test_case = test_case + 1;
        operand_a = 32'd20;
        operand_b = 32'd10;
        alu_control = SUB_UNSIGNED;
        expected_result = 32'd10;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SUB Unsigned");

        // Test 5: SUB Signed (10 - 20 = -10)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd20;
        alu_control = SUB_SIGNED;
        expected_result = -32'd10;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SUB Signed");

        // Test 6: SUB Overflow (-2^31 - 1 = overflow)
        test_case = test_case + 1;
        operand_a = 32'h80000000; // -2^31 (min negative signed int)
        operand_b = 32'd1;
        alu_control = SUB_SIGNED;
        expected_result = 32'h7FFFFFFF; // 2^31-1 (positive due to overflow)
        expected_zero = 0;
        expected_overflow = 1;
        #20;
        display_test_result("SUB Signed Overflow");

        // Test 7: MUL Unsigned (5 * 7 = 35)
        test_case = test_case + 1;
        operand_a = 32'd5;
        operand_b = 32'd7;
        alu_control = MUL_UNSIGNED;
        expected_result = 32'd35;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("MUL Unsigned");

        // Test 8: MUL Signed (5 * (-7) = -35)
        test_case = test_case + 1;
        operand_a = 32'd5;
        operand_b = -32'd7;
        alu_control = MUL_SIGNED;
        expected_result = -32'd35;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("MUL Signed");

        // Test 9: MUL Overflow (large numbers)
        test_case = test_case + 1;
        operand_a = 32'h10000000; // 2^28
        operand_b = 32'h10;       // 16
        alu_control = MUL_UNSIGNED;
        expected_result = 32'h00000000; // Lower 32 bits are 0
        expected_zero = 1;
        expected_overflow = 1; // Upper bits are non-zero
        #20;
        display_test_result("MUL Overflow");

        // Test 10: DIV Unsigned (100 / 5 = 20)
        test_case = test_case + 1;
        operand_a = 32'd100;
        operand_b = 32'd5;
        alu_control = DIV_UNSIGNED;
        expected_result = 32'd20;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("DIV Unsigned");

        // Test 11: DIV Signed (100 / (-5) = -20)
        test_case = test_case + 1;
        operand_a = 32'd100;
        operand_b = -32'd5;
        alu_control = DIV_SIGNED;
        expected_result = -32'd20;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("DIV Signed");

        // Test 12: DIV by Zero
        test_case = test_case + 1;
        operand_a = 32'd100;
        operand_b = 32'd0;
        alu_control = DIV_UNSIGNED;
        expected_result = 32'hFFFFFFFF; // All 1's for division by zero
        expected_zero = 0;
        expected_overflow = 1;
        #20;
        display_test_result("DIV by Zero");

        // Test 13: AND (0xF0F0F0F0 & 0x0FF00FF0 = 0x00F000F0)
        test_case = test_case + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0FF00FF0;
        alu_control = AND_OP;
        expected_result = 32'h00F000F0;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("AND");

        // Test 14: OR (0xF0F0F0F0 | 0x0FF00FF0 = 0xFFF0FFF0)
        test_case = test_case + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0FF00FF0;
        alu_control = OR_OP;
        expected_result = 32'hFFF0FFF0;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("OR");

        // Test 15: XOR (0xF0F0F0F0 ^ 0x0FF00FF0 = 0xFF00FF00)
        test_case = test_case + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0FF00FF0;
        alu_control = XOR_OP;
        expected_result = 32'hFF00FF00;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("XOR");

        // Test 16: NOT (~0xF0F0F0F0 = 0x0F0F0F0F)
        test_case = test_case + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h00000000; // Not used
        alu_control = NOT_OP;
        expected_result = 32'h0F0F0F0F;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("NOT");

        // Test 17: NOR (~(0xF0F0F0F0 | 0x0FF00FF0) = 0x000F000F)
        test_case = test_case + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0FF00FF0;
        alu_control = NOR_OP;
        expected_result = 32'h000F000F;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("NOR");

        // Test 18: SLL (0x00000001 << 4 = 0x00000010)
        test_case = test_case + 1;
        operand_a = 32'h00000001;
        operand_b = 32'h00000000; // Not used
        shift_amount = 4;
        alu_control = SLL_OP;
        expected_result = 32'h00000010;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SLL");

        // Test 19: SRL (0x80000000 >> 4 = 0x08000000)
        test_case = test_case + 1;
        operand_a = 32'h80000000;
        operand_b = 32'h00000000; // Not used
        shift_amount = 4;
        alu_control = SRL_OP;
        expected_result = 32'h08000000;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SRL");

        // Test 20: SRA (0x80000000 >>> 4 = 0xF8000000) - arithmetic shift
        test_case = test_case + 1;
        operand_a = 32'h80000000;
        operand_b = 32'h00000000; // Not used
        shift_amount = 4;
        alu_control = SRA_OP;
        expected_result = 32'hF8000000;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SRA");

        // Test 21: EQ (10 == 10 = 1)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd10;
        alu_control = EQ_OP;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("EQ");

        // Test 22: NE (10 != 20 = 1)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd20;
        alu_control = NE_OP;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("NE");

        // Test 23: LT Signed (10 < 20 = 1)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd20;
        alu_control = LT_SIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("LT Signed");

        // Test 24: LT Signed (-10 < 20 = 1)
        test_case = test_case + 1;
        operand_a = -32'd10;
        operand_b = 32'd20;
        alu_control = LT_SIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("LT Signed Negative");

        // Test 25: GE Signed (20 >= 10 = 1)
        test_case = test_case + 1;
        operand_a = 32'd20;
        operand_b = 32'd10;
        alu_control = GE_SIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("GE Signed");

        // Test 26: LT Unsigned (0xFFFFFFFF < 0x00000001 = 0) - unsigned comparison
        test_case = test_case + 1;
        operand_a = 32'hFFFFFFFF; // -1 in signed, max value in unsigned
        operand_b = 32'h00000001;
        alu_control = LT_UNSIGNED;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("LT Unsigned");

        // Test 27: GE Unsigned (0xFFFFFFFF >= 0x00000001 = 1) - unsigned comparison
        test_case = test_case + 1;
        operand_a = 32'hFFFFFFFF; // -1 in signed, max value in unsigned
        operand_b = 32'h00000001;
        alu_control = GE_UNSIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("GE Unsigned");

        // Test 28: Zero Result (0 - 0 = 0)
        test_case = test_case + 1;
        operand_a = 32'd0;
        operand_b = 32'd0;
        alu_control = SUB_UNSIGNED;
        expected_result = 32'd0;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("Zero Result");

        // Test 29: ADD Unsigned Max (0xFFFFFFFF + 1 = 0)
        test_case = test_case + 1;
        operand_a = 32'hFFFFFFFF;
        operand_b = 32'd1;
        alu_control = ADD_UNSIGNED;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0; // No overflow for unsigned
        #20;
        display_test_result("ADD Unsigned Max");

        // Test 30: ADD Signed Negative (-10 + (-5) = -15)
        test_case = test_case + 1;
        operand_a = -32'd10;
        operand_b = -32'd5;
        alu_control = ADD_SIGNED;
        expected_result = -32'd15;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("ADD Signed Negative");

        // Test 31: ADD Signed Negative Overflow (-2^31 + (-1) = overflow)
        test_case = test_case + 1;
        operand_a = 32'h80000000; // -2^31
        operand_b = -32'd1;
        alu_control = ADD_SIGNED;
        expected_result = 32'h7FFFFFFF; // 2^31-1 (positive due to overflow)
        expected_zero = 0;
        expected_overflow = 1;
        #20;
        display_test_result("ADD Signed Neg Overflow");

        // Test 32: SUB Unsigned Underflow (0 - 1 = 0xFFFFFFFF)
        test_case = test_case + 1;
        operand_a = 32'd0;
        operand_b = 32'd1;
        alu_control = SUB_UNSIGNED;
        expected_result = 32'hFFFFFFFF;
        expected_zero = 0;
        expected_overflow = 0; // No overflow for unsigned
        #20;
        display_test_result("SUB Unsigned Underflow");

        // Test 33: SUB Signed Negative (-10 - 5 = -15)
        test_case = test_case + 1;
        operand_a = -32'd10;
        operand_b = 32'd5;
        alu_control = SUB_SIGNED;
        expected_result = -32'd15;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SUB Signed Negative");

        // Test 34: MUL Unsigned Large (0xFFFF * 0xFFFF)
        test_case = test_case + 1;
        operand_a = 32'h0000FFFF;
        operand_b = 32'h0000FFFF;
        alu_control = MUL_UNSIGNED;
        expected_result = 32'hFFFE0001; // Lower 32 bits of 0xFFFE0001
        expected_zero = 0;
        expected_overflow = 1; // Upper bits are non-zero
        #20;
        display_test_result("MUL Unsigned Large");

        // Test 35: MUL Signed Negative*Negative ((-5) * (-10) = 50)
        test_case = test_case + 1;
        operand_a = -32'd5;
        operand_b = -32'd10;
        alu_control = MUL_SIGNED;
        expected_result = 32'd50;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("MUL Signed Neg*Neg");

        // Test 36: DIV Unsigned Remainder (10 / 3 = 3)
        test_case = test_case + 1;
        operand_a = 32'd10;
        operand_b = 32'd3;
        alu_control = DIV_UNSIGNED;
        expected_result = 32'd3; // Integer division truncates
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("DIV Unsigned Remainder");

        // Test 37: DIV Signed Mixed Signs ((-10) / 3 = -3)
        test_case = test_case + 1;
        operand_a = -32'd10;
        operand_b = 32'd3;
        alu_control = DIV_SIGNED;
        expected_result = -32'd3; // Integer division truncates toward 0
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("DIV Signed Mixed Signs");

        // Test 38: AND with 0 (0xFFFFFFFF & 0x00000000 = 0)
        test_case = test_case + 1;
        operand_a = 32'hFFFFFFFF;
        operand_b = 32'h00000000;
        alu_control = AND_OP;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("AND with 0");

        // Test 39: OR with all 1s (0x12345678 | 0xFFFFFFFF = 0xFFFFFFFF)
        test_case = test_case + 1;
        operand_a = 32'h12345678;
        operand_b = 32'hFFFFFFFF;
        alu_control = OR_OP;
        expected_result = 32'hFFFFFFFF;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("OR with all 1s");

        // Test 40: XOR same values (0xAAAAAAAA ^ 0xAAAAAAAA = 0)
        test_case = test_case + 1;
        operand_a = 32'hAAAAAAAA;
        operand_b = 32'hAAAAAAAA;
        alu_control = XOR_OP;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("XOR same values");

        // Test 41: NOT all 1s (~0xFFFFFFFF = 0x00000000)
        test_case = test_case + 1;
        operand_a = 32'hFFFFFFFF;
        operand_b = 32'h00000000; // Not used
        alu_control = NOT_OP;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("NOT all 1s");

        // Test 42: NOR with 0 (~(0x12345678 | 0) = ~0x12345678)
        test_case = test_case + 1;
        operand_a = 32'h12345678;
        operand_b = 32'h00000000;
        alu_control = NOR_OP;
        expected_result = ~32'h12345678;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("NOR with 0");

        // Test 43: SLL by 0 (0x12345678 << 0 = 0x12345678)
        test_case = test_case + 1;
        operand_a = 32'h12345678;
        operand_b = 32'h00000000;
        shift_amount = 0;
        alu_control = SLL_OP;
        expected_result = 32'h12345678;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SLL by 0");

        // Test 44: SLL by 31 (1 << 31 = 0x80000000)
        test_case = test_case + 1;
        operand_a = 32'h00000001;
        operand_b = 32'h00000000;
        shift_amount = 31;
        alu_control = SLL_OP;
        expected_result = 32'h80000000;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SLL by 31");

        // Test 45: SRL by 31 (0x80000000 >> 31 = 1)
        test_case = test_case + 1;
        operand_a = 32'h80000000;
        operand_b = 32'h00000000;
        shift_amount = 31;
        alu_control = SRL_OP;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SRL by 31");

        // Test 46: SRA positive number (0x40000000 >>> 16 = 0x00004000)
        test_case = test_case + 1;
        operand_a = 32'h40000000;
        operand_b = 32'h00000000;
        shift_amount = 16;
        alu_control = SRA_OP;
        expected_result = 32'h00004000;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SRA positive number");

        // Test 47: SRA negative number (0x80000000 >>> 16 = 0xFFFF8000)
        test_case = test_case + 1;
        operand_a = 32'h80000000;
        operand_b = 32'h00000000;
        shift_amount = 16;
        alu_control = SRA_OP;
        expected_result = 32'hFFFF8000;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("SRA negative number");

        // Test 48: EQ with different values (5 == 10 = 0)
        test_case = test_case + 1;
        operand_a = 32'd5;
        operand_b = 32'd10;
        alu_control = EQ_OP;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("EQ with different values");

        // Test 49: NE with same values (5 != 5 = 0)
        test_case = test_case + 1;
        operand_a = 32'd5;
        operand_b = 32'd5;
        alu_control = NE_OP;
        expected_result = 32'h00000000;
        expected_zero = 1;
        expected_overflow = 0;
        #20;
        display_test_result("NE with same values");

        // Test 50: GE Signed with equal values (5 >= 5 = 1)
        test_case = test_case + 1;
        operand_a = 32'd5;
        operand_b = 32'd5;
        alu_control = GE_SIGNED;
        expected_result = 32'h00000001;
        expected_zero = 0;
        expected_overflow = 0;
        #20;
        display_test_result("GE Signed with equal values");

        $display("All 50 tests completed!");
        $finish;
    end

endmodule
