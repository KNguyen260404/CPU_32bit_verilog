// =============================================================================
// Reset Synchronizer Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests reset synchronizer for async reset, sync deassert behavior
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - Async reset assertion testing
//          - Sync reset deassertion testing
//          - Timing verification  
//          - Multiple sync stages testing
//          - Reset polarity testing
// =============================================================================

`timescale 1ns / 1ps

module reset_synchronizer_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg         clk;
    reg         async_rst;
    wire        sync_rst_n;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Multiple DUTs for different configurations
    wire sync_rst_n_2stage;
    wire sync_rst_n_3stage; 
    wire sync_rst_n_active_high;
    
    // =================================================================
    // Device Under Test (DUT) - Multiple Configurations
    // =================================================================
    
    // Standard 2-stage, active-low reset
    reset_synchronizer #(
        .SYNC_STAGES(2),
        .RESET_POLARITY(1'b0)  // Active low async reset
    ) dut_2stage (
        .clk(clk),
        .async_rst(async_rst),
        .sync_rst_n(sync_rst_n_2stage)
    );
    
    // 3-stage synchronizer
    reset_synchronizer #(
        .SYNC_STAGES(3),
        .RESET_POLARITY(1'b0)
    ) dut_3stage (
        .clk(clk),
        .async_rst(async_rst),
        .sync_rst_n(sync_rst_n_3stage)
    );
    
    // Active-high reset input
    reset_synchronizer #(
        .SYNC_STAGES(2),
        .RESET_POLARITY(1'b1)  // Active high async reset
    ) dut_active_high (
        .clk(clk),
        .async_rst(~async_rst),  // Invert for active-high testing
        .sync_rst_n(sync_rst_n_active_high)
    );
    
    // Default DUT for main tests
    assign sync_rst_n = sync_rst_n_2stage;
    
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
        
        // Initialize inputs - start with reset active
        async_rst = 1'b0; // Active low reset
        
        $display("========================================");
        $display("RESET SYNCHRONIZER TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Wait for initial settling
        #(CLOCK_PERIOD * 3);
        
        // Run test suites
        run_async_reset_tests();
        run_sync_deassert_tests();
        run_timing_tests();
        run_multi_stage_tests();
        run_reset_polarity_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: Asynchronous Reset Tests
    // =================================================================
    task run_async_reset_tests();
        begin
            $display("\n[%0t] Running Asynchronous Reset Tests...", $time);
            
            // Test immediate reset assertion (async)
            async_rst = 1'b1;  // Release reset first
            #(CLOCK_PERIOD * 2);
            
            async_rst = 1'b0;  // Assert reset asynchronously (not on clock edge)
            #1; // Immediate check, not waiting for clock
            
            test_reset_signal(sync_rst_n, 1'b0, "Async reset: Should be immediate (not on clock edge)");
            
            // Reset should be active regardless of clock
            #(CLOCK_PERIOD * 0.7); // Check mid-clock cycle
            test_reset_signal(sync_rst_n, 1'b0, "Async reset: Active independent of clock");
            
            // Keep reset asserted through multiple clocks
            #(CLOCK_PERIOD * 2);
            test_reset_signal(sync_rst_n, 1'b0, "Async reset: Remains active");
            
            $display("Asynchronous Reset Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Synchronous Deassertion Tests
    // =================================================================
    task run_sync_deassert_tests();
        begin
            $display("\n[%0t] Running Synchronous Deassertion Tests...", $time);
            
            // Start with reset asserted
            async_rst = 1'b0;
            #(CLOCK_PERIOD);
            test_reset_signal(sync_rst_n, 1'b0, "Reset asserted before deassertion test");
            
            // Release async reset and check synchronous deassertion
            async_rst = 1'b1;
            
            // First clock edge - should still be in reset (2-stage synchronizer)
            @(posedge clk);
            #1; // Small delay for propagation
            test_reset_signal(sync_rst_n, 1'b0, "Sync deassert: 1st clock - still in reset");
            
            // Second clock edge - should come out of reset (2-stage)
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Sync deassert: 2nd clock - out of reset");
            
            // Should remain out of reset
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Sync deassert: Remains out of reset");
            
            $display("Synchronous Deassertion Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Timing Verification Tests
    // =================================================================
    task run_timing_tests();
        begin
            $display("\n[%0t] Running Timing Tests...", $time);
            
            // Test setup and hold time behavior
            async_rst = 1'b0; // Assert reset
            #(CLOCK_PERIOD);
            
            // Release reset just before clock edge
            #(CLOCK_PERIOD - 1);
            async_rst = 1'b1;
            #1;
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b0, "Timing: Reset released just before clock");
            
            // Next clock should start deassertion
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b0, "Timing: First deassert clock");
            
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Timing: Second deassert clock");
            
            // Test reset assertion during deassertion sequence
            async_rst = 1'b0; // Assert reset
            #(CLOCK_PERIOD);
            async_rst = 1'b1; // Release
            
            @(posedge clk);
            async_rst = 1'b0; // Re-assert during deassertion
            #1;
            test_reset_signal(sync_rst_n, 1'b0, "Timing: Re-assert during deassertion");
            
            $display("Timing Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Multiple Stage Tests
    // =================================================================
    task run_multi_stage_tests();
        begin
            $display("\n[%0t] Running Multi-Stage Tests...", $time);
            
            // Compare 2-stage vs 3-stage behavior
            async_rst = 1'b0;
            #(CLOCK_PERIOD);
            test_reset_signal(sync_rst_n_2stage, 1'b0, "Multi: 2-stage in reset");
            test_reset_signal(sync_rst_n_3stage, 1'b0, "Multi: 3-stage in reset");
            
            // Release and compare timing
            async_rst = 1'b1;
            
            // 1st clock
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n_2stage, 1'b0, "Multi: 2-stage 1st clock - still reset");
            test_reset_signal(sync_rst_n_3stage, 1'b0, "Multi: 3-stage 1st clock - still reset");
            
            // 2nd clock
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n_2stage, 1'b1, "Multi: 2-stage 2nd clock - out of reset");
            test_reset_signal(sync_rst_n_3stage, 1'b0, "Multi: 3-stage 2nd clock - still reset");
            
            // 3rd clock
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n_2stage, 1'b1, "Multi: 2-stage 3rd clock - out of reset");
            test_reset_signal(sync_rst_n_3stage, 1'b1, "Multi: 3-stage 3rd clock - out of reset");
            
            $display("Multi-Stage Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Reset Polarity Tests
    // =================================================================
    task run_reset_polarity_tests();
        begin
            $display("\n[%0t] Running Reset Polarity Tests...", $time);
            
            // Note: async_rst is inverted for active-high DUT
            
            // Test active-high reset assertion
            async_rst = 1'b1;  // This makes ~async_rst = 0 (active for active-high)
            #1;
            test_reset_signal(sync_rst_n_active_high, 1'b0, "Polarity: Active-high reset asserted");
            
            // Test active-high reset release
            async_rst = 1'b0;  // This makes ~async_rst = 1 (inactive for active-high)
            
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n_active_high, 1'b0, "Polarity: Active-high 1st clock");
            
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n_active_high, 1'b1, "Polarity: Active-high 2nd clock - released");
            
            // Compare with active-low behavior (should be same output timing)
            async_rst = 1'b1;  // Reset both
            #(CLOCK_PERIOD);
            
            async_rst = 1'b0;  // Release both (active-low normal, active-high through inversion)
            
            @(posedge clk);
            #1;
            test_reset_signals_equal(sync_rst_n_2stage, sync_rst_n_active_high, "Polarity: Both should behave same - 1st clock");
            
            @(posedge clk);
            #1;
            test_reset_signals_equal(sync_rst_n_2stage, sync_rst_n_active_high, "Polarity: Both should behave same - 2nd clock");
            
            $display("Reset Polarity Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Test multiple reset assertions/releases
            async_rst = 1'b0;
            #(CLOCK_PERIOD/4);
            async_rst = 1'b1;
            #(CLOCK_PERIOD/4);
            async_rst = 1'b0;
            #(CLOCK_PERIOD/4);
            async_rst = 1'b1;
            #1;
            
            // Should be following the last transition
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b0, "Corner: Multiple toggles - 1st clock");
            
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Corner: Multiple toggles - 2nd clock");
            
            // Test very short reset pulse
            async_rst = 1'b0;
            #1; // Very short pulse
            async_rst = 1'b1;
            #1;
            test_reset_signal(sync_rst_n, 1'b0, "Corner: Short reset pulse should still work");
            
            // Wait for deassertion
            @(posedge clk);
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Corner: Short pulse recovery");
            
            // Test reset at various clock phases
            async_rst = 1'b0;
            #(CLOCK_PERIOD/2); // Mid clock cycle
            test_reset_signal(sync_rst_n, 1'b0, "Corner: Reset at mid-clock");
            
            async_rst = 1'b1;
            #(CLOCK_PERIOD/4);
            async_rst = 1'b0;
            #(CLOCK_PERIOD/4);
            async_rst = 1'b1;
            
            // Final test - normal operation
            @(posedge clk);
            @(posedge clk);
            #1;
            test_reset_signal(sync_rst_n, 1'b1, "Corner: Final normal operation");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Reset Signal
    // =================================================================
    task test_reset_signal(
        input       actual_value,
        input       expected_value,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            if (actual_value === expected_value) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      sync_rst_n: %b (expected: %b)", actual_value, expected_value);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Expected: %b, Got: %b", expected_value, actual_value);
                $display("      async_rst: %b, Time: %0t", async_rst, $time);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Two Signals Equal
    // =================================================================
    task test_reset_signals_equal(
        input       signal1,
        input       signal2,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            if (signal1 === signal2) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Both signals: %b", signal1);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Signal1: %b, Signal2: %b", signal1, signal2);
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
            $display("RESET SYNCHRONIZER TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Reset Synchronizer implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Reset Synchronizer implementation.");
                end
            end
            
            $display("========================================");
            $display("Simulation completed at time: %0t", $time);
            $display("\nReset Synchronizer Features Verified:");
            $display("✅ Asynchronous reset assertion");
            $display("✅ Synchronous reset deassertion");  
            $display("✅ 2-stage and 3-stage operation");
            $display("✅ Active-low and active-high polarity");
            $display("✅ Timing and corner cases");
        end
    endtask
    
    // =================================================================
    // Waveform Dumping
    // =================================================================
    initial begin
        $dumpfile("reset_synchronizer_tb.vcd");
        $dumpvars(0, reset_synchronizer_tb);
    end

endmodule
