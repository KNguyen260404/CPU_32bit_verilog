// =============================================================================
// Branch Decision Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests branch condition evaluation for all RISC-V branch types
// Author: Auto-generated testbench  
// Date: September 23, 2025
// Features: - All branch types testing (BEQ, BNE, BLT, BGE, BLTU, BGEU)
//          - Signed/unsigned comparison verification
//          - Corner cases and boundary testing
// =============================================================================

`timescale 1ns / 1ps

module branch_decision_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================  
    reg [31:0]  operand1;
    reg [31:0]  operand2;
    reg [2:0]   branch_type;
    wire        branch_taken;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // Constants (matching branch_decision.v)
    // =================================================================
    localparam BRANCH_EQ  = 3'b000;
    localparam BRANCH_NE  = 3'b001;
    localparam BRANCH_LT  = 3'b100;
    localparam BRANCH_GE  = 3'b101;
    localparam BRANCH_LTU = 3'b110;
    localparam BRANCH_GEU = 3'b111;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    branch_decision dut (
        .operand1(operand1),
        .operand2(operand2),
        .branch_type(branch_type),
        .branch_taken(branch_taken)
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
        operand1 = 32'h0;
        operand2 = 32'h0;
        branch_type = 3'h0;
        
        $display("========================================");
        $display("BRANCH DECISION TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Run test suites
        #10;
        run_beq_tests();
        run_bne_tests();
        run_blt_tests();
        run_bge_tests();
        run_bltu_tests();
        run_bgeu_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: BEQ (Branch if Equal)
    // =================================================================
    task run_beq_tests();
        begin
            $display("\n[%0t] Running BEQ Tests...", $time);
            
            // Equal operands - should take branch
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_EQ, 1'b1, "BEQ: Equal operands");
            test_branch_decision(32'h00000000, 32'h00000000, BRANCH_EQ, 1'b1, "BEQ: Both zero");
            test_branch_decision(32'hFFFFFFFF, 32'hFFFFFFFF, BRANCH_EQ, 1'b1, "BEQ: Both all 1s");
            
            // Unequal operands - should not take branch
            test_branch_decision(32'h12345678, 32'h87654321, BRANCH_EQ, 1'b0, "BEQ: Different operands");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_EQ, 1'b0, "BEQ: Zero vs one");
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_EQ, 1'b0, "BEQ: Max positive vs min negative");
            
            $display("BEQ Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: BNE (Branch if Not Equal)
    // =================================================================
    task run_bne_tests();
        begin
            $display("\n[%0t] Running BNE Tests...", $time);
            
            // Unequal operands - should take branch
            test_branch_decision(32'h12345678, 32'h87654321, BRANCH_NE, 1'b1, "BNE: Different operands");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_NE, 1'b1, "BNE: Zero vs one");
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_NE, 1'b1, "BNE: Max positive vs min negative");
            
            // Equal operands - should not take branch
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_NE, 1'b0, "BNE: Equal operands");
            test_branch_decision(32'h00000000, 32'h00000000, BRANCH_NE, 1'b0, "BNE: Both zero");
            test_branch_decision(32'hFFFFFFFF, 32'hFFFFFFFF, BRANCH_NE, 1'b0, "BNE: Both all 1s");
            
            $display("BNE Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: BLT (Branch if Less Than - Signed)
    // =================================================================
    task run_blt_tests();
        begin
            $display("\n[%0t] Running BLT Tests...", $time);
            
            // op1 < op2 (signed) - should take branch
            test_branch_decision(32'h80000000, 32'h7FFFFFFF, BRANCH_LT, 1'b1, "BLT: Min negative < Max positive");
            test_branch_decision(32'hFFFFFFFF, 32'h00000000, BRANCH_LT, 1'b1, "BLT: -1 < 0");
            test_branch_decision(32'hFFFFFFFE, 32'hFFFFFFFF, BRANCH_LT, 1'b1, "BLT: -2 < -1");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_LT, 1'b1, "BLT: 0 < 1");
            
            // op1 >= op2 (signed) - should not take branch  
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_LT, 1'b0, "BLT: Max positive >= Min negative");
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_LT, 1'b0, "BLT: 0 >= -1");
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_LT, 1'b0, "BLT: Equal operands");
            test_branch_decision(32'h00000001, 32'h00000000, BRANCH_LT, 1'b0, "BLT: 1 >= 0");
            
            $display("BLT Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: BGE (Branch if Greater than or Equal - Signed)
    // =================================================================
    task run_bge_tests();
        begin
            $display("\n[%0t] Running BGE Tests...", $time);
            
            // op1 >= op2 (signed) - should take branch
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_GE, 1'b1, "BGE: Max positive >= Min negative");
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_GE, 1'b1, "BGE: 0 >= -1");
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_GE, 1'b1, "BGE: Equal operands");
            test_branch_decision(32'h00000001, 32'h00000000, BRANCH_GE, 1'b1, "BGE: 1 >= 0");
            test_branch_decision(32'hFFFFFFFF, 32'hFFFFFFFE, BRANCH_GE, 1'b1, "BGE: -1 >= -2");
            
            // op1 < op2 (signed) - should not take branch
            test_branch_decision(32'h80000000, 32'h7FFFFFFF, BRANCH_GE, 1'b0, "BGE: Min negative < Max positive");
            test_branch_decision(32'hFFFFFFFF, 32'h00000000, BRANCH_GE, 1'b0, "BGE: -1 < 0");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_GE, 1'b0, "BGE: 0 < 1");
            
            $display("BGE Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: BLTU (Branch if Less Than - Unsigned)
    // =================================================================
    task run_bltu_tests();
        begin
            $display("\n[%0t] Running BLTU Tests...", $time);
            
            // op1 < op2 (unsigned) - should take branch
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_LTU, 1'b1, "BLTU: 0x7FFF... < 0x8000...");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_LTU, 1'b1, "BLTU: 0 < 1");
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_LTU, 1'b1, "BLTU: 0 < Max unsigned");
            test_branch_decision(32'hFFFFFFFE, 32'hFFFFFFFF, BRANCH_LTU, 1'b1, "BLTU: Max-1 < Max");
            
            // op1 >= op2 (unsigned) - should not take branch
            test_branch_decision(32'h80000000, 32'h7FFFFFFF, BRANCH_LTU, 1'b0, "BLTU: 0x8000... >= 0x7FFF...");
            test_branch_decision(32'hFFFFFFFF, 32'h00000000, BRANCH_LTU, 1'b0, "BLTU: Max >= 0");
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_LTU, 1'b0, "BLTU: Equal operands");
            test_branch_decision(32'h00000001, 32'h00000000, BRANCH_LTU, 1'b0, "BLTU: 1 >= 0");
            
            $display("BLTU Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: BGEU (Branch if Greater than or Equal - Unsigned)
    // =================================================================
    task run_bgeu_tests();
        begin
            $display("\n[%0t] Running BGEU Tests...", $time);
            
            // op1 >= op2 (unsigned) - should take branch
            test_branch_decision(32'h80000000, 32'h7FFFFFFF, BRANCH_GEU, 1'b1, "BGEU: 0x8000... >= 0x7FFF...");
            test_branch_decision(32'hFFFFFFFF, 32'h00000000, BRANCH_GEU, 1'b1, "BGEU: Max >= 0");
            test_branch_decision(32'h12345678, 32'h12345678, BRANCH_GEU, 1'b1, "BGEU: Equal operands");
            test_branch_decision(32'h00000001, 32'h00000000, BRANCH_GEU, 1'b1, "BGEU: 1 >= 0");
            test_branch_decision(32'hFFFFFFFF, 32'hFFFFFFFE, BRANCH_GEU, 1'b1, "BGEU: Max >= Max-1");
            
            // op1 < op2 (unsigned) - should not take branch  
            test_branch_decision(32'h7FFFFFFF, 32'h80000000, BRANCH_GEU, 1'b0, "BGEU: 0x7FFF... < 0x8000...");
            test_branch_decision(32'h00000000, 32'h00000001, BRANCH_GEU, 1'b0, "BGEU: 0 < 1");
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_GEU, 1'b0, "BGEU: 0 < Max");
            
            $display("BGEU Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Invalid branch type - should not take branch
            test_branch_decision(32'h12345678, 32'h87654321, 3'b010, 1'b0, "Corner: Invalid branch type 010");
            test_branch_decision(32'h12345678, 32'h87654321, 3'b011, 1'b0, "Corner: Invalid branch type 011");
            
            // Boundary values
            test_branch_decision(32'h7FFFFFFF, 32'h7FFFFFFF, BRANCH_EQ, 1'b1, "Corner: Max positive equal");
            test_branch_decision(32'h80000000, 32'h80000000, BRANCH_EQ, 1'b1, "Corner: Min negative equal");
            
            // One's complement vs two's complement edge cases
            test_branch_decision(32'h7FFFFFFF, 32'h80000001, BRANCH_LT, 1'b0, "Corner: Signed comparison edge");
            test_branch_decision(32'h7FFFFFFF, 32'h80000001, BRANCH_LTU, 1'b1, "Corner: Unsigned comparison edge");
            
            // Zero vs negative one
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_LT, 1'b0, "Corner: 0 vs -1 signed");
            test_branch_decision(32'h00000000, 32'hFFFFFFFF, BRANCH_LTU, 1'b1, "Corner: 0 vs -1 unsigned");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Branch Decision
    // =================================================================
    task test_branch_decision(
        input [31:0] op1,
        input [31:0] op2,
        input [2:0]  br_type,
        input        expected_taken,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            operand1 = op1;
            operand2 = op2;
            branch_type = br_type;
            
            // Wait for propagation
            #1;
            
            // Check result
            if (branch_taken === expected_taken) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Op1: 0x%08h, Op2: 0x%08h, Type: %0d, Taken: %0b", 
                             op1, op2, br_type, branch_taken);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Op1: 0x%08h, Op2: 0x%08h, Type: %0d", op1, op2, br_type);
                $display("      Expected: %0b, Got: %0b", expected_taken, branch_taken);
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
            $display("BRANCH DECISION TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Branch Decision implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Branch Decision implementation.");
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
        $dumpfile("branch_decision_tb.vcd");
        $dumpvars(0, branch_decision_tb);
    end

endmodule
