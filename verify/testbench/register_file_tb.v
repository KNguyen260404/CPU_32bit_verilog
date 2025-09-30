// =============================================================================
// Register File Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests register file functionality including x0 hardwired to zero
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - All register access testing
//          - x0 hardwired zero verification
//          - Read-after-write testing
//          - Simultaneous read/write testing
//          - Reset behavior testing
//          - Debug interface testing
// =============================================================================

`timescale 1ns / 1ps

module register_file_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 5;
    parameter NUM_REGS = 1 << ADDR_WIDTH;  // 32 registers
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg                     clk;
    reg                     rst_n;
    reg [ADDR_WIDTH-1:0]    rs1_addr;
    reg [ADDR_WIDTH-1:0]    rs2_addr;
    wire [DATA_WIDTH-1:0]   rs1_data;
    wire [DATA_WIDTH-1:0]   rs2_data;
    reg                     reg_write;
    reg [ADDR_WIDTH-1:0]    rd_addr;
    reg [DATA_WIDTH-1:0]    rd_data;
    reg                     debug_enable;
    reg [ADDR_WIDTH-1:0]    debug_addr;
    wire [DATA_WIDTH-1:0]   debug_data;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .RAM_STYLE("distributed"),
        .ENABLE_DEBUG(1),
        .RESET_ALL_REGS(1)  // Enable reset for all registers in testbench
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .reg_write(reg_write),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .debug_enable(debug_enable),
        .debug_addr(debug_addr),
        .debug_data(debug_data)
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
        
        // Initialize signals
        rst_n = 1'b0;
        rs1_addr = 5'h0;
        rs2_addr = 5'h0;
        reg_write = 1'b0;
        rd_addr = 5'h0;
        rd_data = 32'h0;
        debug_enable = 1'b0;
        debug_addr = 5'h0;
        
        $display("========================================");
        $display("REGISTER FILE TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset sequence
        #(CLOCK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLOCK_PERIOD * 2);
        
        // Run test suites
        run_reset_tests();
        run_x0_hardwired_tests();
        run_basic_write_read_tests();
        run_all_register_tests();
        run_simultaneous_read_write_tests();
        run_read_after_write_tests();
        run_debug_interface_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: Reset Behavior
    // =================================================================
    task run_reset_tests();
        integer i;
        begin
            $display("\n[%0t] Running Reset Tests...", $time);
            
            // Write some values first
            for (i = 1; i < NUM_REGS; i = i + 1) begin
                write_register(i, $random);
            end
            
            // Apply reset
            rst_n = 1'b0;
            #(CLOCK_PERIOD * 2);
            rst_n = 1'b1;
            #(CLOCK_PERIOD);
            
            // Check all registers are zero
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                test_read_register(i, 32'h00000000, "Reset: Register should be zero");
            end
            
            $display("Reset Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: x0 Hardwired to Zero
    // =================================================================
    task run_x0_hardwired_tests();
        begin
            $display("\n[%0t] Running x0 Hardwired Tests...", $time);
            
            // Try to write to x0 - should remain zero
            write_register(0, 32'hDEADBEEF);
            test_read_register(0, 32'h00000000, "x0 hardwired: x0 should remain zero after write");
            
            // Try various write values to x0
            write_register(0, 32'hFFFFFFFF);
            test_read_register(0, 32'h00000000, "x0 hardwired: x0 should remain zero (0xFFFFFFFF)");
            
            write_register(0, 32'h12345678);
            test_read_register(0, 32'h00000000, "x0 hardwired: x0 should remain zero (0x12345678)");
            
            // Test x0 on both read ports
            rs1_addr = 5'h0;
            rs2_addr = 5'h0;
            #1;
            test_single_signal(rs1_data, 32'h00000000, "x0 hardwired: rs1_data should be zero when reading x0");
            test_single_signal(rs2_data, 32'h00000000, "x0 hardwired: rs2_data should be zero when reading x0");
            
            $display("x0 Hardwired Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Basic Write and Read Operations
    // =================================================================
    task run_basic_write_read_tests();
        begin
            $display("\n[%0t] Running Basic Write/Read Tests...", $time);
            
            // Test writing and reading specific values
            write_register(1, 32'h12345678);
            test_read_register(1, 32'h12345678, "Basic: Write/Read x1");
            
            write_register(2, 32'h87654321);
            test_read_register(2, 32'h87654321, "Basic: Write/Read x2");
            
            write_register(31, 32'hFFFFFFFF);
            test_read_register(31, 32'hFFFFFFFF, "Basic: Write/Read x31");
            
            // Test overwriting
            write_register(1, 32'hDEADBEEF);
            test_read_register(1, 32'hDEADBEEF, "Basic: Overwrite x1");
            
            // Test various patterns
            write_register(3, 32'h00000000);
            test_read_register(3, 32'h00000000, "Basic: All zeros");
            
            write_register(4, 32'hAAAAAAAA);
            test_read_register(4, 32'hAAAAAAAA, "Basic: Alternating pattern 1");
            
            write_register(5, 32'h55555555);
            test_read_register(5, 32'h55555555, "Basic: Alternating pattern 2");
            
            $display("Basic Write/Read Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: All Register Access
    // =================================================================
    task run_all_register_tests();
        integer i;
        reg [DATA_WIDTH-1:0] test_value;
        begin
            $display("\n[%0t] Running All Register Tests...", $time);
            
            // Write unique values to all registers (except x0)
            for (i = 1; i < NUM_REGS; i = i + 1) begin
                test_value = 32'h00000000 + i * 32'h01010101;  // Unique pattern for each register
                write_register(i, test_value);
                test_read_register(i, test_value, "All registers write/read");
            end
            
            // Verify all values are still correct (no interference)
            for (i = 1; i < NUM_REGS; i = i + 1) begin
                test_value = 32'h00000000 + i * 32'h01010101;
                test_read_register(i, test_value, "All registers retention");
            end
            
            $display("All Register Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Simultaneous Read/Write
    // =================================================================
    task run_simultaneous_read_write_tests();
        begin
            $display("\n[%0t] Running Simultaneous Read/Write Tests...", $time);
            
            // Setup initial values
            write_register(1, 32'h11111111);
            write_register(2, 32'h22222222);
            write_register(3, 32'h33333333);
            
            // Test reading two registers while writing a third
            @(posedge clk);
            rs1_addr = 5'h1;
            rs2_addr = 5'h2;
            reg_write = 1'b1;
            rd_addr = 5'h3;
            rd_data = 32'hDEADBEEF;
            
            @(posedge clk);
            reg_write = 1'b0;
            #1;
            
            test_single_signal(rs1_data, 32'h11111111, "Simultaneous: rs1_data should not be affected by write");
            test_single_signal(rs2_data, 32'h22222222, "Simultaneous: rs2_data should not be affected by write");
            test_read_register(3, 32'hDEADBEEF, "Simultaneous: Written register should have new value");
            
            // Test reading the register being written (bypass behavior)
            @(posedge clk);
            rs1_addr = 5'h4;
            rs2_addr = 5'h4;
            reg_write = 1'b1;
            rd_addr = 5'h4;
            rd_data = 32'h44444444;
            
            @(posedge clk);
            reg_write = 1'b0;
            #1;
            
            test_read_register(4, 32'h44444444, "Simultaneous: Read same register being written");
            
            $display("Simultaneous Read/Write Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Read-After-Write Hazards
    // =================================================================
    task run_read_after_write_tests();
        begin
            $display("\n[%0t] Running Read-After-Write Tests...", $time);
            
            // Write to register and immediately read it
            write_register(10, 32'hAAAABBBB);
            test_read_register(10, 32'hAAAABBBB, "RAW: Immediate read after write");
            
            // Write to register, wait one cycle, then read
            write_register(11, 32'hCCCCDDDD);
            @(posedge clk);
            test_read_register(11, 32'hCCCCDDDD, "RAW: Read after one cycle delay");
            
            // Multiple writes to same register
            write_register(12, 32'h11111111);
            write_register(12, 32'h22222222);
            write_register(12, 32'h33333333);
            test_read_register(12, 32'h33333333, "RAW: Multiple writes to same register");
            
            // Write with reg_write disabled should not affect register
            write_register(13, 32'hDEADBEEF);
            @(posedge clk);
            rs1_addr = 5'h13;
            reg_write = 1'b0;  // Disabled
            rd_addr = 5'h13;
            rd_data = 32'hCAFEBABE;
            @(posedge clk);
            #1;
            test_single_signal(rs1_data, 32'hDEADBEEF, "RAW: Disabled write should not change register");
            
            $display("Read-After-Write Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Debug Interface
    // =================================================================
    task run_debug_interface_tests();
        integer i;
        reg [DATA_WIDTH-1:0] test_value;
        begin
            $display("\n[%0t] Running Debug Interface Tests...", $time);
            
            // Setup test data in registers
            for (i = 0; i < 8; i = i + 1) begin
                if (i != 0) begin  // Skip x0
                    test_value = 32'h10000000 + i;
                    write_register(i, test_value);
                end
            end
            
            // Test debug interface with debug_enable = 1
            debug_enable = 1'b1;
            
            for (i = 0; i < 8; i = i + 1) begin
                debug_addr = i;
                #1;
                if (i == 0) begin
                    test_single_signal(debug_data, 32'h00000000, "Debug: x0 should be zero");
                end else begin
                    test_value = 32'h10000000 + i;
                    test_single_signal(debug_data, test_value, "Debug: register value check");
                end
            end
            
            // Test debug interface with debug_enable = 0
            debug_enable = 1'b0;
            debug_addr = 5'h1;
            #1;
            test_single_signal(debug_data, 32'h00000000, "Debug: Should output zero when disabled");
            
            // Re-enable for cleanup
            debug_enable = 1'b1;
            debug_addr = 5'h0;
            
            $display("Debug Interface Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Test maximum and minimum values
            write_register(20, 32'hFFFFFFFF);
            test_read_register(20, 32'hFFFFFFFF, "Corner: Maximum value (0xFFFFFFFF)");
            
            write_register(21, 32'h00000000);
            test_read_register(21, 32'h00000000, "Corner: Minimum value (0x00000000)");
            
            write_register(22, 32'h80000000);
            test_read_register(22, 32'h80000000, "Corner: Sign bit set");
            
            write_register(23, 32'h7FFFFFFF);
            test_read_register(23, 32'h7FFFFFFF, "Corner: Maximum positive");
            
            // Test address boundary conditions
            write_register(31, 32'hDEADBEEF);  // Last register
            test_read_register(31, 32'hDEADBEEF, "Corner: Last register (x31)");
            
            write_register(1, 32'hCAFEBABE);   // First writable register
            test_read_register(1, 32'hCAFEBABE, "Corner: First writable register (x1)");
            
            // Test reading unwritten registers (should be zero after reset)
            // First ensure reset state
            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            @(posedge clk);
            
            test_read_register(15, 32'h00000000, "Corner: Unwritten register should be zero");
            test_read_register(25, 32'h00000000, "Corner: Another unwritten register should be zero");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Write to Register
    // =================================================================
    task write_register(
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] data
    );
        begin
            @(posedge clk);
            reg_write = 1'b1;
            rd_addr = addr;
            rd_data = data;
            @(posedge clk);
            reg_write = 1'b0;
            #1;  // Small delay for signal propagation
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Register Read
    // =================================================================
    task test_read_register(
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] expected_data,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Read from register using rs1_addr
            rs1_addr = addr;
            #1;
            
            if (rs1_data === expected_data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Address: x%0d, Data: 0x%08h", addr, rs1_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Address: x%0d", addr);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_data, rs1_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Single Signal
    // =================================================================
    task test_single_signal(
        input [DATA_WIDTH-1:0] actual_value,
        input [DATA_WIDTH-1:0] expected_value,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            if (actual_value === expected_value) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Value: 0x%08h", actual_value);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_value, actual_value);
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
            $display("REGISTER FILE TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Register File implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Register File implementation.");
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
        $dumpfile("register_file_tb.vcd");
        $dumpvars(0, register_file_tb);
    end

endmodule
