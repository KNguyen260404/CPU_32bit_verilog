`timescale 1ns / 1ps

module ALU_control_unit_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    // Inputs
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7;

    // Outputs
    wire [4:0] alu_control;

    // Clock generation
    reg clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instantiate the Unit Under Test (UUT)
    ALU_control_unit uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    // VCD file generation for GTKWave
    initial begin
        // Create VCD file for waveform viewing
        $dumpfile("alu_control_unit_waveform.vcd");
        // Dump all variables at all levels
        $dumpvars(0, ALU_control_unit_tb);
    end

    // ALU operations (matching ALU module)
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
    reg [4:0] expected_control;

    // Task to display test results
    task display_test_result;
        input [8*30:1] test_name;
        begin
            $display("Test Case %0d: %s", test_case, test_name);
            $display("  ALUOp = %b, funct3 = %b, funct7 = %b", ALUOp, funct3, funct7);
            $display("  Expected: alu_control = %b", expected_control);
            $display("  Actual:   alu_control = %b", alu_control);
            
            if (alu_control !== expected_control) begin
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
        ALUOp = 2'b00;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        test_case = 0;

        // Wait for global reset
        #100;

        // Test 1: Memory access operation (load/store)
        test_case = test_case + 1;
        ALUOp = 2'b00;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        expected_control = ADD_UNSIGNED;
        #20;
        display_test_result("Memory Access Operation");

        // Test 2: Branch operation - BEQ
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b000; // BEQ
        funct7 = 7'b0000000;
        expected_control = EQ_OP;
        #20;
        display_test_result("Branch - BEQ");

        // Test 3: Branch operation - BNE
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b001; // BNE
        funct7 = 7'b0000000;
        expected_control = NE_OP;
        #20;
        display_test_result("Branch - BNE");

        // Test 4: Branch operation - BLT
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b100; // BLT
        funct7 = 7'b0000000;
        expected_control = LT_SIGNED;
        #20;
        display_test_result("Branch - BLT");

        // Test 5: Branch operation - BGE
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b101; // BGE
        funct7 = 7'b0000000;
        expected_control = GE_SIGNED;
        #20;
        display_test_result("Branch - BGE");

        // Test 6: Branch operation - BLTU
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b110; // BLTU
        funct7 = 7'b0000000;
        expected_control = LT_UNSIGNED;
        #20;
        display_test_result("Branch - BLTU");

        // Test 7: Branch operation - BGEU
        test_case = test_case + 1;
        ALUOp = 2'b01;
        funct3 = 3'b111; // BGEU
        funct7 = 7'b0000000;
        expected_control = GE_UNSIGNED;
        #20;
        display_test_result("Branch - BGEU");

        // Test 8: R-type - ADD
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b000; // ADD/SUB
        funct7 = 7'b0000000; // ADD
        expected_control = ADD_SIGNED;
        #20;
        display_test_result("R-type - ADD");

        // Test 9: R-type - SUB
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b000; // ADD/SUB
        funct7 = 7'b0100000; // SUB
        expected_control = SUB_SIGNED;
        #20;
        display_test_result("R-type - SUB");

        // Test 10: R-type - SLL
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b001; // SLL
        funct7 = 7'b0000000;
        expected_control = SLL_OP;
        #20;
        display_test_result("R-type - SLL");

        // Test 11: R-type - SLT
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b010; // SLT
        funct7 = 7'b0000000;
        expected_control = LT_SIGNED;
        #20;
        display_test_result("R-type - SLT");

        // Test 12: R-type - SLTU
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b011; // SLTU
        funct7 = 7'b0000000;
        expected_control = LT_UNSIGNED;
        #20;
        display_test_result("R-type - SLTU");

        // Test 13: R-type - XOR
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b100; // XOR
        funct7 = 7'b0000000;
        expected_control = XOR_OP;
        #20;
        display_test_result("R-type - XOR");

        // Test 14: R-type - SRL
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b101; // SRL/SRA
        funct7 = 7'b0000000; // SRL
        expected_control = SRL_OP;
        #20;
        display_test_result("R-type - SRL");

        // Test 15: R-type - SRA
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b101; // SRL/SRA
        funct7 = 7'b0100000; // SRA
        expected_control = SRA_OP;
        #20;
        display_test_result("R-type - SRA");

        // Test 16: R-type - OR
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b110; // OR
        funct7 = 7'b0000000;
        expected_control = OR_OP;
        #20;
        display_test_result("R-type - OR");

        // Test 17: R-type - AND
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b111; // AND
        funct7 = 7'b0000000;
        expected_control = AND_OP;
        #20;
        display_test_result("R-type - AND");

        // Test 18: I-type - ADDI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b000; // ADDI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = ADD_SIGNED;
        #20;
        display_test_result("I-type - ADDI");

        // Test 19: I-type - SLTI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b010; // SLTI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = LT_SIGNED;
        #20;
        display_test_result("I-type - SLTI");

        // Test 20: I-type - SLTIU
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b011; // SLTIU
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = LT_UNSIGNED;
        #20;
        display_test_result("I-type - SLTIU");

        // Test 21: I-type - XORI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b100; // XORI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = XOR_OP;
        #20;
        display_test_result("I-type - XORI");

        // Test 22: I-type - ORI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b110; // ORI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = OR_OP;
        #20;
        display_test_result("I-type - ORI");

        // Test 23: I-type - ANDI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b111; // ANDI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = AND_OP;
        #20;
        display_test_result("I-type - ANDI");

        // Test 24: I-type - SLLI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b001; // SLLI
        funct7 = 7'b0000000; // Don't care for I-type
        expected_control = SLL_OP;
        #20;
        display_test_result("I-type - SLLI");

        // Test 25: I-type - SRLI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b101; // SRLI/SRAI
        funct7 = 7'b0000000; // SRLI (bit 5 = 0)
        expected_control = SRL_OP;
        #20;
        display_test_result("I-type - SRLI");

        // Test 26: I-type - SRAI
        test_case = test_case + 1;
        ALUOp = 2'b11;
        funct3 = 3'b101; // SRLI/SRAI
        funct7 = 7'b0100000; // SRAI (bit 5 = 1)
        expected_control = SRA_OP;
        #20;
        display_test_result("I-type - SRAI");

        // Test 27: R-type - MUL (M extension)
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b000; // MUL
        funct7 = 7'b0000001; // M extension
        expected_control = MUL_SIGNED;
        #20;
        display_test_result("R-type - MUL (M extension)");

        // Test 28: R-type - DIV (M extension)
        test_case = test_case + 1;
        ALUOp = 2'b10;
        funct3 = 3'b100; // DIV
        funct7 = 7'b0000001; // M extension
        expected_control = DIV_SIGNED;
        #20;
        display_test_result("R-type - DIV (M extension)");

        // Finish simulation
        $display("All tests completed!");
        #(CLK_PERIOD*2);
        $finish;
    end

endmodule
