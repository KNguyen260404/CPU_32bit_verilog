// =============================================================================
// NPC Generator Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests Next PC generation logic with priority selection
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - Priority testing (JALR > Branch > JAL > PC+4)
//          - Stall behavior testing
//          - Reset behavior verification
//          - Edge cases and corner testing
// =============================================================================

`timescale 1ns / 1ps

module npc_generator_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    parameter DATA_WIDTH = 32;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg                     clk;
    reg                     rst_n;
    reg [DATA_WIDTH-1:0]    pc_f;
    reg                     branch_e;
    reg                     jalr_e;
    reg                     jal_d;
    reg [DATA_WIDTH-1:0]    branch_target;
    reg [DATA_WIDTH-1:0]    jalr_target;
    reg [DATA_WIDTH-1:0]    jal_target;
    reg                     stall_f;
    wire [DATA_WIDTH-1:0]   pc_next;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    npc_generator dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_f(pc_f),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .jal_d(jal_d),
        .branch_target(branch_target),
        .jalr_target(jalr_target),
        .jal_target(jal_target),
        .stall_f(stall_f),
        .pc_next(pc_next)
    );
    
    // =================================================================
    // Clock Generation
    // =================================================================
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end
    
    // =================================================================
    // Test Execution Control
    // =================================================================
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        initialize_inputs();
        
        $display("========================================");
        $display("NPC GENERATOR TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset sequence
        rst_n = 1'b0;
        #(CLOCK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLOCK_PERIOD);
        
        // Run test suites
        run_reset_tests();
        run_sequential_pc_tests();
        run_jal_tests();
        run_branch_tests();
        run_jalr_tests();
        run_priority_tests();
        run_stall_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Initialize Inputs Task
    // =================================================================
    task initialize_inputs();
        begin
            clk = 1'b0;
            rst_n = 1'b0;
            pc_f = 32'h00000000;
            branch_e = 1'b0;
            jalr_e = 1'b0;
            jal_d = 1'b0;
            branch_target = 32'h00000000;
            jalr_target = 32'h00000000;
            jal_target = 32'h00000000;
            stall_f = 1'b0;
        end
    endtask
    
    // =================================================================
    // Test Suite: Reset Behavior
    // =================================================================
    task run_reset_tests();
        begin
            $display("\n[%0t] Running Reset Tests...", $time);
            
            // During reset, PC should go to reset address
            pc_f = 32'h12345678;  // Non-zero current PC
            rst_n = 1'b0;
            #1;
            test_pc_generation(32'h00000000, "Reset state - PC should be 0x00000000");
            
            // After reset release
            rst_n = 1'b1;
            #1;
            test_pc_generation(32'h1234567C, "After reset - sequential PC+4");
            
            $display("Reset Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Sequential PC Tests
    // =================================================================
    task run_sequential_pc_tests();
        begin
            $display("\n[%0t] Running Sequential PC Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test basic PC+4 increment
            pc_f = 32'h00000000;
            #1;
            test_pc_generation(32'h00000004, "Sequential: PC=0 -> PC+4=4");
            
            pc_f = 32'h00000100;
            #1;
            test_pc_generation(32'h00000104, "Sequential: PC=0x100 -> PC+4=0x104");
            
            pc_f = 32'h12345678;
            #1;
            test_pc_generation(32'h1234567C, "Sequential: PC=0x12345678 -> PC+4");
            
            // Test various address alignments
            pc_f = 32'h00001000;
            #1;
            test_pc_generation(32'h00001004, "Sequential: Aligned address");
            
            pc_f = 32'hFFFFFFF8;
            #1;
            test_pc_generation(32'hFFFFFFFC, "Sequential: Near maximum address");
            
            $display("Sequential PC Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: JAL Instruction Tests
    // =================================================================
    task run_jal_tests();
        begin
            $display("\n[%0t] Running JAL Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test JAL with positive offset
            pc_f = 32'h00000100;
            jal_d = 1'b1;
            jal_target = 32'h00001000;
            #1;
            test_pc_generation(32'h00001000, "JAL: Jump to positive target");
            
            // Test JAL with negative offset (backwards jump)
            pc_f = 32'h00001000;
            jal_target = 32'h00000200;
            #1;
            test_pc_generation(32'h00000200, "JAL: Jump to backwards target");
            
            // Test JAL disabled
            jal_d = 1'b0;
            #1;
            test_pc_generation(32'h00001004, "JAL disabled: Should be sequential");
            
            // Test JAL to address 0
            jal_d = 1'b1;
            jal_target = 32'h00000000;
            #1;
            test_pc_generation(32'h00000000, "JAL: Jump to address 0");
            
            $display("JAL Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Branch Instruction Tests
    // =================================================================
    task run_branch_tests();
        begin
            $display("\n[%0t] Running Branch Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test branch taken
            pc_f = 32'h00000200;
            branch_e = 1'b1;
            branch_target = 32'h00000400;
            #1;
            test_pc_generation(32'h00000400, "Branch taken: Jump to target");
            
            // Test branch not taken
            branch_e = 1'b0;
            #1;
            test_pc_generation(32'h00000204, "Branch not taken: Sequential PC+4");
            
            // Test branch to backwards address
            branch_e = 1'b1;
            branch_target = 32'h00000100;
            #1;
            test_pc_generation(32'h00000100, "Branch taken: Backwards target");
            
            // Test branch priority over JAL
            jal_d = 1'b1;
            jal_target = 32'h00002000;
            branch_e = 1'b1;
            branch_target = 32'h00000800;
            #1;
            test_pc_generation(32'h00000800, "Branch priority: Branch beats JAL");
            
            $display("Branch Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: JALR Instruction Tests
    // =================================================================
    task run_jalr_tests();
        begin
            $display("\n[%0t] Running JALR Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test JALR
            pc_f = 32'h00000300;
            jalr_e = 1'b1;
            jalr_target = 32'h00005000;
            #1;
            test_pc_generation(32'h00005000, "JALR: Jump to register target");
            
            // Test JALR to address 0
            jalr_target = 32'h00000000;
            #1;
            test_pc_generation(32'h00000000, "JALR: Jump to address 0");
            
            // Test JALR disabled
            jalr_e = 1'b0;
            #1;
            test_pc_generation(32'h00000304, "JALR disabled: Sequential PC+4");
            
            $display("JALR Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Priority Testing
    // =================================================================
    task run_priority_tests();
        begin
            $display("\n[%0t] Running Priority Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            pc_f = 32'h00000400;
            
            // Test JALR highest priority
            jalr_e = 1'b1;
            jalr_target = 32'h00001000;
            branch_e = 1'b1;
            branch_target = 32'h00002000;
            jal_d = 1'b1;
            jal_target = 32'h00003000;
            #1;
            test_pc_generation(32'h00001000, "Priority: JALR beats Branch and JAL");
            
            // Test Branch over JAL
            jalr_e = 1'b0;
            branch_e = 1'b1;
            jal_d = 1'b1;
            #1;
            test_pc_generation(32'h00002000, "Priority: Branch beats JAL");
            
            // Test JAL over sequential
            branch_e = 1'b0;
            jal_d = 1'b1;
            #1;
            test_pc_generation(32'h00003000, "Priority: JAL beats sequential");
            
            // Test all disabled - sequential
            jal_d = 1'b0;
            #1;
            test_pc_generation(32'h00000404, "Priority: All disabled, sequential PC+4");
            
            $display("Priority Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Stall Behavior Tests
    // =================================================================
    task run_stall_tests();
        begin
            $display("\n[%0t] Running Stall Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test stall with sequential PC
            pc_f = 32'h00000500;
            stall_f = 1'b1;
            #1;
            test_pc_generation(32'h00000500, "Stall: PC should not change");
            
            // Test stall with JAL
            jal_d = 1'b1;
            jal_target = 32'h00001000;
            stall_f = 1'b1;
            #1;
            test_pc_generation(32'h00000500, "Stall with JAL: PC should not change");
            
            // Test stall with Branch
            jal_d = 1'b0;
            branch_e = 1'b1;
            branch_target = 32'h00002000;
            stall_f = 1'b1;
            #1;
            test_pc_generation(32'h00000500, "Stall with Branch: PC should not change");
            
            // Test stall with JALR
            branch_e = 1'b0;
            jalr_e = 1'b1;
            jalr_target = 32'h00003000;
            stall_f = 1'b1;
            #1;
            test_pc_generation(32'h00000500, "Stall with JALR: PC should not change");
            
            // Test stall release
            stall_f = 1'b0;
            #1;
            test_pc_generation(32'h00003000, "Stall release: JALR should work");
            
            $display("Stall Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test maximum address
            pc_f = 32'hFFFFFFFC;
            #1;
            test_pc_generation(32'h00000000, "Corner: Maximum PC wraps to 0");
            
            // Test all targets same
            pc_f = 32'h00000600;
            jalr_e = 1'b1;
            branch_e = 1'b1;
            jal_d = 1'b1;
            jalr_target = 32'h00001000;
            branch_target = 32'h00001000;
            jal_target = 32'h00001000;
            #1;
            test_pc_generation(32'h00001000, "Corner: All targets same, JALR priority");
            
            // Test target equals current PC
            pc_f = 32'h00000700;
            jalr_e = 1'b0;
            branch_e = 1'b1;
            jal_d = 1'b0;
            branch_target = 32'h00000700;
            #1;
            test_pc_generation(32'h00000700, "Corner: Branch to same address");
            
            // Test misaligned PC
            pc_f = 32'h00000701; // Unaligned
            branch_e = 1'b0;
            #1;
            test_pc_generation(32'h00000705, "Corner: Unaligned PC + 4");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test PC Generation
    // =================================================================
    task test_pc_generation(
        input [31:0] expected_pc,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            if (pc_next === expected_pc) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Current PC: 0x%08h, Next PC: 0x%08h", pc_f, pc_next);
                    $display("      Controls: JALR=%b Branch=%b JAL=%b Stall=%b", jalr_e, branch_e, jal_d, stall_f);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Current PC: 0x%08h", pc_f);
                $display("      Controls: JALR=%b Branch=%b JAL=%b Stall=%b", jalr_e, branch_e, jal_d, stall_f);
                $display("      Targets: JALR=0x%08h Branch=0x%08h JAL=0x%08h", jalr_target, branch_target, jal_target);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_pc, pc_next);
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
            $display("NPC GENERATOR TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! NPC Generator implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review NPC Generator implementation.");
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
        $dumpfile("npc_generator_tb.vcd");
        $dumpvars(0, npc_generator_tb);
    end

endmodule
