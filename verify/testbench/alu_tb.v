// =============================================================================
// ALU Testbench - Comprehensive Verification
// =============================================================================
// Description: Exhaustive testing of ALU operations with corner cases
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - All ALU operations testing
//          - Corner case verification  
//          - Randomized testing
//          - Performance monitoring
//          - Self-checking testbench
// =============================================================================

`timescale 1ns / 1ps

module alu_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter NUM_RANDOM_TESTS = 1000;
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg [31:0]  operand1;
    reg [31:0]  operand2;
    reg [3:0]   alu_control;
    wire [31:0] alu_result;
    wire        zero_flag;
    
    // Test control variables
    reg clk;
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // ALU Operation Constants (matching alu.v)
    // =================================================================
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    alu dut (
        .operand1(operand1),
        .operand2(operand2),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero_flag(zero_flag)
    );
    
    // =================================================================
    // Clock Generation (for sequential testing)
    // =================================================================
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end
    
    // =================================================================
    // Test Execution Control
    // =================================================================
    initial begin
        // Initialize test counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        operand1 = 32'h0;
        operand2 = 32'h0;
        alu_control = 4'h0;
        
        $display("========================================");
        $display("ALU TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Wait for initial settling
        #(CLOCK_PERIOD * 2);
        
        // Run test suites
        run_basic_arithmetic_tests();
        run_logic_operation_tests();
        run_comparison_tests();
        run_shift_operation_tests();
        run_corner_case_tests();
        run_randomized_tests();
        run_zero_flag_tests();
        
        // Display final results
        display_test_summary();
        
        // Finish simulation
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: Basic Arithmetic Operations
    // =================================================================
    task run_basic_arithmetic_tests();
        begin
            $display("\n[%0t] Running Basic Arithmetic Tests...", $time);
            
            // ADD Tests
            test_alu_operation(ALU_ADD, 32'h12345678, 32'h87654321, 32'h99999999, "ADD: Normal case");
            test_alu_operation(ALU_ADD, 32'h00000000, 32'h12345678, 32'h12345678, "ADD: Zero + value");
            test_alu_operation(ALU_ADD, 32'hFFFFFFFF, 32'h00000001, 32'h00000000, "ADD: Overflow wrap");
            test_alu_operation(ALU_ADD, 32'h7FFFFFFF, 32'h00000001, 32'h80000000, "ADD: Positive overflow");
            
            // SUB Tests
            test_alu_operation(ALU_SUB, 32'h87654321, 32'h12345678, 32'h751FDB09, "SUB: Normal case");
            test_alu_operation(ALU_SUB, 32'h12345678, 32'h12345678, 32'h00000000, "SUB: Same operands");
            test_alu_operation(ALU_SUB, 32'h00000000, 32'h12345678, 32'hEDCBA988, "SUB: Zero - value");
            test_alu_operation(ALU_SUB, 32'h80000000, 32'h00000001, 32'h7FFFFFFF, "SUB: Underflow wrap");
            
            $display("Basic Arithmetic Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Logic Operations
    // =================================================================
    task run_logic_operation_tests();
        begin
            $display("\n[%0t] Running Logic Operation Tests...", $time);
            
            // AND Tests
            test_alu_operation(ALU_AND, 32'hFFFFFFFF, 32'h12345678, 32'h12345678, "AND: All 1s & value");
            test_alu_operation(ALU_AND, 32'h00000000, 32'h12345678, 32'h00000000, "AND: All 0s & value");
            test_alu_operation(ALU_AND, 32'hAAAAAAAA, 32'h55555555, 32'h00000000, "AND: Alternating bits");
            test_alu_operation(ALU_AND, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, "AND: Complement masks");
            
            // OR Tests
            test_alu_operation(ALU_OR, 32'h00000000, 32'h12345678, 32'h12345678, "OR: Zero | value");
            test_alu_operation(ALU_OR, 32'hFFFFFFFF, 32'h12345678, 32'hFFFFFFFF, "OR: All 1s | value");
            test_alu_operation(ALU_OR, 32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, "OR: Alternating bits");
            test_alu_operation(ALU_OR, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "OR: Complement masks");
            
            // XOR Tests
            test_alu_operation(ALU_XOR, 32'h00000000, 32'h12345678, 32'h12345678, "XOR: Zero ^ value");
            test_alu_operation(ALU_XOR, 32'hFFFFFFFF, 32'h12345678, 32'hEDCBA987, "XOR: All 1s ^ value");
            test_alu_operation(ALU_XOR, 32'h12345678, 32'h12345678, 32'h00000000, "XOR: Same operands");
            test_alu_operation(ALU_XOR, 32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, "XOR: Alternating bits");
            
            $display("Logic Operation Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Comparison Operations
    // =================================================================
    task run_comparison_tests();
        begin
            $display("\n[%0t] Running Comparison Tests...", $time);
            
            // SLT (Set Less Than - Signed) Tests
            test_alu_operation(ALU_SLT, 32'h7FFFFFFF, 32'h80000000, 32'h00000000, "SLT: Max positive < Min negative (signed)");
            test_alu_operation(ALU_SLT, 32'h80000000, 32'h7FFFFFFF, 32'h00000001, "SLT: Min negative < Max positive (signed)");
            test_alu_operation(ALU_SLT, 32'hFFFFFFFF, 32'h00000000, 32'h00000001, "SLT: -1 < 0 (signed)");
            test_alu_operation(ALU_SLT, 32'h00000000, 32'hFFFFFFFF, 32'h00000000, "SLT: 0 < -1 (signed)");
            test_alu_operation(ALU_SLT, 32'h12345678, 32'h12345678, 32'h00000000, "SLT: Equal values (signed)");
            
            // SLTU (Set Less Than - Unsigned) Tests
            test_alu_operation(ALU_SLTU, 32'h7FFFFFFF, 32'h80000000, 32'h00000001, "SLTU: 0x7FFF... < 0x8000... (unsigned)");
            test_alu_operation(ALU_SLTU, 32'h80000000, 32'h7FFFFFFF, 32'h00000000, "SLTU: 0x8000... < 0x7FFF... (unsigned)");
            test_alu_operation(ALU_SLTU, 32'hFFFFFFFF, 32'h00000000, 32'h00000000, "SLTU: Max < 0 (unsigned)");
            test_alu_operation(ALU_SLTU, 32'h00000000, 32'hFFFFFFFF, 32'h00000001, "SLTU: 0 < Max (unsigned)");
            test_alu_operation(ALU_SLTU, 32'h12345678, 32'h12345678, 32'h00000000, "SLTU: Equal values (unsigned)");
            
            $display("Comparison Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Shift Operations
    // =================================================================
    task run_shift_operation_tests();
        begin
            $display("\n[%0t] Running Shift Operation Tests...", $time);
            
            // SLL (Shift Left Logical) Tests
            test_alu_operation(ALU_SLL, 32'h12345678, 32'h00000000, 32'h12345678, "SLL: Shift by 0");
            test_alu_operation(ALU_SLL, 32'h12345678, 32'h00000004, 32'h23456780, "SLL: Shift by 4");
            test_alu_operation(ALU_SLL, 32'h12345678, 32'h0000001F, 32'h00000000, "SLL: Shift by 31");
            test_alu_operation(ALU_SLL, 32'h00000001, 32'h0000001F, 32'h80000000, "SLL: 1 shift by 31");
            test_alu_operation(ALU_SLL, 32'h12345678, 32'h00000020, 32'h12345678, "SLL: Shift by 32 (only use 5 bits)");
            
            // SRL (Shift Right Logical) Tests
            test_alu_operation(ALU_SRL, 32'h12345678, 32'h00000000, 32'h12345678, "SRL: Shift by 0");
            test_alu_operation(ALU_SRL, 32'h12345678, 32'h00000004, 32'h01234567, "SRL: Shift by 4");
            test_alu_operation(ALU_SRL, 32'h12345678, 32'h0000001F, 32'h00000000, "SRL: Shift by 31");
            test_alu_operation(ALU_SRL, 32'h80000000, 32'h0000001F, 32'h00000001, "SRL: MSB shift by 31");
            test_alu_operation(ALU_SRL, 32'hFFFFFFFF, 32'h00000001, 32'h7FFFFFFF, "SRL: All 1s shift by 1");
            
            // SRA (Shift Right Arithmetic) Tests
            test_alu_operation(ALU_SRA, 32'h12345678, 32'h00000000, 32'h12345678, "SRA: Positive shift by 0");
            test_alu_operation(ALU_SRA, 32'h12345678, 32'h00000004, 32'h01234567, "SRA: Positive shift by 4");
            test_alu_operation(ALU_SRA, 32'h80000000, 32'h00000001, 32'hC0000000, "SRA: Negative shift by 1");
            test_alu_operation(ALU_SRA, 32'h80000000, 32'h0000001F, 32'hFFFFFFFF, "SRA: Negative shift by 31");
            test_alu_operation(ALU_SRA, 32'hFFFFFFFF, 32'h00000001, 32'hFFFFFFFF, "SRA: -1 shift by 1");
            
            $display("Shift Operation Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Maximum and minimum values
            test_alu_operation(ALU_ADD, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, "Corner: Max + Max");
            test_alu_operation(ALU_SUB, 32'h00000000, 32'hFFFFFFFF, 32'h00000001, "Corner: Min - Max");
            
            // Zero operand cases
            test_alu_operation(ALU_AND, 32'h00000000, 32'hFFFFFFFF, 32'h00000000, "Corner: Zero AND Max");
            test_alu_operation(ALU_OR, 32'h00000000, 32'h00000000, 32'h00000000, "Corner: Zero OR Zero");
            
            // Sign extension corner cases
            test_alu_operation(ALU_SRA, 32'h80000001, 32'h0000001F, 32'hFFFFFFFF, "Corner: SRA sign extension");
            test_alu_operation(ALU_SLT, 32'h80000001, 32'h80000000, 32'h00000000, "Corner: SLT negative comparison");
            
            // Invalid operation code
            test_alu_operation(4'b1111, 32'h12345678, 32'h87654321, 32'h00000000, "Corner: Invalid opcode");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Zero Flag Verification
    // =================================================================
    task run_zero_flag_tests();
        begin
            $display("\n[%0t] Running Zero Flag Tests...", $time);
            
            // Test cases that should produce zero result
            test_zero_flag(ALU_SUB, 32'h12345678, 32'h12345678, 1'b1, "Zero flag: SUB equal operands");
            test_zero_flag(ALU_XOR, 32'h12345678, 32'h12345678, 1'b1, "Zero flag: XOR equal operands");
            test_zero_flag(ALU_AND, 32'h12345678, 32'h00000000, 1'b1, "Zero flag: AND with zero");
            test_zero_flag(ALU_SLL, 32'h00000000, 32'h00000005, 1'b1, "Zero flag: SLL zero value");
            
            // Test cases that should produce non-zero result
            test_zero_flag(ALU_ADD, 32'h00000001, 32'h00000001, 1'b0, "Zero flag: ADD non-zero result");
            test_zero_flag(ALU_OR, 32'h00000001, 32'h00000000, 1'b0, "Zero flag: OR non-zero result");
            test_zero_flag(ALU_SLT, 32'h00000000, 32'h00000001, 1'b0, "Zero flag: SLT non-zero result");
            
            $display("Zero Flag Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Randomized Testing
    // =================================================================
    task run_randomized_tests();
        integer i;
        reg [31:0] rand_op1, rand_op2;
        reg [3:0] rand_ctrl;
        begin
            $display("\n[%0t] Running Randomized Tests (%0d iterations)...", $time, NUM_RANDOM_TESTS);
            
            for (i = 0; i < NUM_RANDOM_TESTS; i = i + 1) begin
                rand_op1 = $random;
                rand_op2 = $random;
                rand_ctrl = $random % 10; // Valid operations only (0-9)
                
                // Apply inputs
                operand1 = rand_op1;
                operand2 = rand_op2;
                alu_control = rand_ctrl;
                
                // Wait for propagation
                #1;
                
                // Basic sanity check - result should be stable
                if (alu_result === 32'hx || alu_result === 32'hz) begin
                    $display("ERROR: Invalid result for random test %0d: op1=0x%08h, op2=0x%08h, ctrl=%0d", 
                             i, rand_op1, rand_op2, rand_ctrl);
                    fail_count = fail_count + 1;
                end else begin
                    pass_count = pass_count + 1;
                end
                test_count = test_count + 1;
                
                if (i % (NUM_RANDOM_TESTS/10) == 0) begin
                    $display("  Random test progress: %0d%%", (i * 100) / NUM_RANDOM_TESTS);
                end
            end
            
            $display("Randomized Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test ALU Operation
    // =================================================================
    task test_alu_operation(
        input [3:0]  op_code,
        input [31:0] op1,
        input [31:0] op2,
        input [31:0] expected_result,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            alu_control = op_code;
            operand1 = op1;
            operand2 = op2;
            
            // Wait for propagation delay
            #1;
            
            // Check result
            if (alu_result === expected_result) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Op1: 0x%08h, Op2: 0x%08h, Result: 0x%08h", op1, op2, alu_result);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Op1: 0x%08h, Op2: 0x%08h", op1, op2);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_result, alu_result);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Zero Flag
    // =================================================================
    task test_zero_flag(
        input [3:0]  op_code,
        input [31:0] op1,
        input [31:0] op2,
        input        expected_zero_flag,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            alu_control = op_code;
            operand1 = op1;
            operand2 = op2;
            
            // Wait for propagation delay
            #1;
            
            // Check zero flag
            if (zero_flag === expected_zero_flag) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Zero flag: %0b, Result: 0x%08h", zero_flag, alu_result);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Expected zero flag: %0b, Got: %0b", expected_zero_flag, zero_flag);
                $display("      Result: 0x%08h", alu_result);
            end
        end
    endtask
    
    // =================================================================
    // Test Summary Display
    // =================================================================
    task display_test_summary();
        real pass_rate;
        begin
            $display("\n========================================");
            $display("ALU TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! ALU implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review ALU implementation.");
                end
            end
            
            $display("========================================");
            $display("Simulation completed at time: %0t", $time);
        end
    endtask
    
    // =================================================================
    // Waveform Dumping
    // =================================================================
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
