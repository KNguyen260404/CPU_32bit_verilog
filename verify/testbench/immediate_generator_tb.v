// =============================================================================
// Immediate Generator Testbench - Comprehensive Verification  
// =============================================================================
// Description: Tests immediate generation for all RISC-V instruction types
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - All immediate types testing (I, S, B, U, J)
//          - Sign extension verification
//          - Corner cases and boundary testing
// =============================================================================

`timescale 1ns / 1ps

module immediate_generator_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations  
    // =================================================================
    reg [31:0]  instruction;
    reg [2:0]   imm_type;
    wire [31:0] immediate;
    
    // Test control
    integer test_count;
    integer pass_count; 
    integer fail_count;
    
    // =================================================================
    // Constants (matching immediate_generator.v)
    // =================================================================
    localparam IMM_TYPE_I = 3'b000;
    localparam IMM_TYPE_S = 3'b001;
    localparam IMM_TYPE_B = 3'b010;
    localparam IMM_TYPE_U = 3'b011;
    localparam IMM_TYPE_J = 3'b100;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    immediate_generator dut (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );
    
    // =================================================================
    // Test Execution Control
    // =================================================================
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        instruction = 32'h0;
        imm_type = 3'h0;
        
        $display("========================================");
        $display("IMMEDIATE GENERATOR TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Run test suites
        #10;
        run_i_type_tests();
        run_s_type_tests();
        run_b_type_tests();
        run_u_type_tests();
        run_j_type_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: I-Type Immediates
    // =================================================================
    task run_i_type_tests();
        begin
            $display("\n[%0t] Running I-Type Immediate Tests...", $time);
            
            // Positive immediate
            test_immediate_generation(
                32'h00000FFF,  // instruction[31:20] = 0x0FF (positive)
                IMM_TYPE_I,
                32'h00000FFF,
                "I-Type: Positive immediate 0x0FF"
            );
            
            // Negative immediate (sign bit set)
            test_immediate_generation(
                32'h800007FF,  // instruction[31:20] = 0x800 (negative)
                IMM_TYPE_I,
                32'hFFFFF800,
                "I-Type: Negative immediate 0x800"
            );
            
            // Zero immediate
            test_immediate_generation(
                32'h00000000,
                IMM_TYPE_I,
                32'h00000000,
                "I-Type: Zero immediate"
            );
            
            // Maximum positive immediate (0x7FF)
            test_immediate_generation(
                32'h7FF00000,
                IMM_TYPE_I,
                32'h000007FF,
                "I-Type: Maximum positive (0x7FF)"
            );
            
            // Minimum negative immediate (0x800)
            test_immediate_generation(
                32'h80000000,
                IMM_TYPE_I,
                32'hFFFFF800,
                "I-Type: Minimum negative (0x800)"
            );
            
            $display("I-Type Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: S-Type Immediates
    // =================================================================
    task run_s_type_tests();
        begin
            $display("\n[%0t] Running S-Type Immediate Tests...", $time);
            
            // Positive immediate: [31:25] = 0x00, [11:7] = 0x0F
            test_immediate_generation(
                32'h000000F0,  // [11:7] = 0x0F
                IMM_TYPE_S,
                32'h0000000F,
                "S-Type: Positive immediate"
            );
            
            // Negative immediate: [31:25] = 0x7F, [11:7] = 0x1F
            test_immediate_generation(
                32'hFE0000F0,  // [31:25] = 0x7F, [11:7] = 0x0F  
                IMM_TYPE_S,
                32'hFFFFFFEF,
                "S-Type: Negative immediate"
            );
            
            // Mixed bits: [31:25] = 0x2A, [11:7] = 0x15
            test_immediate_generation(
                32'h540000A0,  // [31:25] = 0x2A, [11:7] = 0x15
                IMM_TYPE_S,
                32'h00000555,
                "S-Type: Mixed pattern"
            );
            
            // Zero immediate
            test_immediate_generation(
                32'h00000000,
                IMM_TYPE_S,
                32'h00000000,
                "S-Type: Zero immediate"
            );
            
            $display("S-Type Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: B-Type Immediates
    // =================================================================
    task run_b_type_tests();
        begin
            $display("\n[%0t] Running B-Type Immediate Tests...", $time);
            
            // Positive branch offset
            // [31]=0, [7]=0, [30:25]=0x10, [11:8]=0x8
            test_immediate_generation(
                32'h20000880,
                IMM_TYPE_B,
                32'h00000410,  // Expected: 0000 0100 0001 0000 (0x410)
                "B-Type: Positive branch offset"
            );
            
            // Negative branch offset
            // [31]=1, [7]=1, [30:25]=0x3F, [11:8]=0xF  
            test_immediate_generation(
                32'hFE000F80,
                IMM_TYPE_B,
                32'hFFFFFFFE,  // All 1s with LSB=0 
                "B-Type: Negative branch offset"
            );
            
            // Zero branch offset
            test_immediate_generation(
                32'h00000000,
                IMM_TYPE_B,
                32'h00000000,
                "B-Type: Zero branch offset"
            );
            
            // Maximum positive branch offset
            // [31]=0, [7]=0, [30:25]=0x3F, [11:8]=0xF
            test_immediate_generation(
                32'h7E000F00,
                IMM_TYPE_B,
                32'h00000FFE,
                "B-Type: Maximum positive offset"
            );
            
            $display("B-Type Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: U-Type Immediates
    // =================================================================
    task run_u_type_tests();
        begin
            $display("\n[%0t] Running U-Type Immediate Tests...", $time);
            
            // Positive upper immediate
            test_immediate_generation(
                32'h12345678,  // [31:12] = 0x12345
                IMM_TYPE_U,
                32'h12345000,
                "U-Type: Positive upper immediate"
            );
            
            // Negative upper immediate
            test_immediate_generation(
                32'h87654321,  // [31:12] = 0x87654
                IMM_TYPE_U,
                32'h87654000,
                "U-Type: Negative upper immediate"
            );
            
            // Zero upper immediate
            test_immediate_generation(
                32'h00000FFF,  // [31:12] = 0x00000 (lower bits ignored)
                IMM_TYPE_U,
                32'h00000000,
                "U-Type: Zero upper immediate"
            );
            
            // Maximum upper immediate
            test_immediate_generation(
                32'hFFFFF000,  // [31:12] = 0xFFFFF
                IMM_TYPE_U,
                32'hFFFFF000,
                "U-Type: Maximum upper immediate"
            );
            
            $display("U-Type Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: J-Type Immediates
    // =================================================================
    task run_j_type_tests();
        begin
            $display("\n[%0t] Running J-Type Immediate Tests...", $time);
            
            // Positive jump offset
            // [31]=0, [19:12]=0x12, [20]=0, [30:21]=0x345
            test_immediate_generation(
                32'h6AC12000,  // Constructed carefully
                IMM_TYPE_J,
                32'h00356240,  // Expected value
                "J-Type: Positive jump offset"
            );
            
            // Negative jump offset
            // [31]=1, [19:12]=0xFF, [20]=1, [30:21]=0x3FF
            test_immediate_generation(
                32'hFFEFF000,
                IMM_TYPE_J,
                32'hFFFFFFE0,  // Sign extended
                "J-Type: Negative jump offset"  
            );
            
            // Zero jump offset
            test_immediate_generation(
                32'h00000000,
                IMM_TYPE_J,
                32'h00000000,
                "J-Type: Zero jump offset"
            );
            
            // Large positive jump
            test_immediate_generation(
                32'h7FE00000,  // Positive with large offset
                IMM_TYPE_J,
                32'h0003FFE0,
                "J-Type: Large positive jump"
            );
            
            $display("J-Type Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Invalid immediate type
            test_immediate_generation(
                32'hDEADBEEF,
                3'b111,  // Invalid type
                32'h00000000,
                "Corner: Invalid immediate type should return zero"
            );
            
            // All 1s instruction
            test_immediate_generation(
                32'hFFFFFFFF,
                IMM_TYPE_I,
                32'hFFFFFFFF,
                "Corner: All 1s instruction (I-type)"
            );
            
            test_immediate_generation(
                32'hFFFFFFFF,
                IMM_TYPE_U,
                32'hFFFFF000,
                "Corner: All 1s instruction (U-type)"
            );
            
            // Sign bit boundary cases
            test_immediate_generation(
                32'h7FFFFFFF,  // Positive with MSB=0
                IMM_TYPE_I,
                32'h000007FF,
                "Corner: I-type sign bit boundary (positive)"
            );
            
            test_immediate_generation(
                32'h80000000,  // Negative with MSB=1
                IMM_TYPE_I,
                32'hFFFFF800,
                "Corner: I-type sign bit boundary (negative)"
            );
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Immediate Generation
    // =================================================================
    task test_immediate_generation(
        input [31:0] test_instruction,
        input [2:0]  test_imm_type,
        input [31:0] expected_immediate,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            instruction = test_instruction;
            imm_type = test_imm_type;
            
            // Wait for propagation
            #1;
            
            // Check result
            if (immediate === expected_immediate) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Instruction: 0x%08h, Type: %0d, Immediate: 0x%08h", 
                             test_instruction, test_imm_type, immediate);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Instruction: 0x%08h, Type: %0d", test_instruction, test_imm_type);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_immediate, immediate);
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
            $display("IMMEDIATE GENERATOR TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Immediate Generator implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Immediate Generator implementation.");
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
        $dumpfile("immediate_generator_tb.vcd");
        $dumpvars(0, immediate_generator_tb);
    end

endmodule
