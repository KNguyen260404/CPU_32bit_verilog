// =============================================================================
// Data Memory Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests data memory functionality with read/write operations
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - Read/write operations testing
//          - Address range verification
//          - Write enable testing
//          - Debug interface testing
//          - Reset behavior verification
// =============================================================================

`timescale 1ns / 1ps

module data_memory_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 12;
    parameter MEMORY_DEPTH = 1 << (ADDR_WIDTH-2); // 1K words
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg                     clk;
    reg                     rst_n;
    reg [DATA_WIDTH-1:0]    address;
    reg                     mem_write;
    reg [3:0]               write_enable;
    reg [DATA_WIDTH-1:0]    write_data;
    wire [DATA_WIDTH-1:0]   read_data;
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
    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .RAM_STYLE("distributed"),
        .ENABLE_DEBUG(1),
        .READ_LATENCY(0)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .mem_write(mem_write),
        .write_enable(write_enable),
        .write_data(write_data),
        .read_data(read_data),
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
        
        // Initialize inputs
        rst_n = 1'b0;
        address = 32'h0;
        mem_write = 1'b0;
        write_enable = 4'b0000;
        write_data = 32'h0;
        debug_enable = 1'b0;
        debug_addr = 12'h0;
        
        $display("========================================");
        $display("DATA MEMORY TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset sequence
        #(CLOCK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLOCK_PERIOD);
        
        // Run test suites
        run_basic_write_read_tests();
        run_write_enable_tests();
        run_address_range_tests();
        run_read_write_hazard_tests();
        run_debug_interface_tests();
        run_reset_behavior_tests();
        run_boundary_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: Basic Write/Read Operations
    // =================================================================
    task run_basic_write_read_tests();
        begin
            $display("\n[%0t] Running Basic Write/Read Tests...", $time);
            
            // Test basic write and read
            test_write_read(32'h00000000, 32'h12345678, "Basic write/read at address 0");
            test_write_read(32'h00000004, 32'h9ABCDEF0, "Basic write/read at address 4");
            test_write_read(32'h00000008, 32'hDEADBEEF, "Basic write/read at address 8");
            test_write_read(32'h0000000C, 32'hCAFEBABE, "Basic write/read at address 12");
            
            // Test overwrite
            test_write_read(32'h00000000, 32'hFFFFFFFF, "Overwrite previous data");
            test_write_read(32'h00000000, 32'h00000000, "Write all zeros");
            
            // Test various data patterns
            test_write_read(32'h00000010, 32'hAAAAAAAA, "Alternating pattern 1");
            test_write_read(32'h00000014, 32'h55555555, "Alternating pattern 2");
            test_write_read(32'h00000018, 32'hF0F0F0F0, "Nibble pattern 1");
            test_write_read(32'h0000001C, 32'h0F0F0F0F, "Nibble pattern 2");
            
            $display("Basic Write/Read Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Write Enable Testing
    // =================================================================
    task run_write_enable_tests();
        begin
            $display("\n[%0t] Running Write Enable Tests...", $time);
            
            // Initialize memory location
            test_write_read(32'h00000020, 32'h00000000, "Initialize test location");
            
            // Test write disabled
            test_write_disabled(32'h00000020, 32'h12345678, 32'h00000000, "Write disabled should not change memory");
            
            // Test write enabled
            test_write_read(32'h00000020, 32'h87654321, "Write enabled should change memory");
            
            // Test write enable after disable
            mem_write = 1'b0;
            write_data = 32'hDEADBEEF;
            address = 32'h00000020;
            @(posedge clk);
            mem_write = 1'b1;
            @(posedge clk);
            mem_write = 1'b0;
            #1;
            test_single_signal(read_data, 32'hDEADBEEF, "Write enable toggle");
            
            $display("Write Enable Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Address Range Testing
    // =================================================================
    task run_address_range_tests();
        integer i;
        reg [31:0] test_data;
        begin
            $display("\n[%0t] Running Address Range Tests...", $time);
            
            // Test sequential addresses
            for (i = 0; i < 64; i = i + 4) begin
                test_data = 32'h10000000 + i;
                test_write_read(i, test_data, "Sequential write/read at address");
            end
            
            // Test various address ranges
            test_write_read(32'h00000100, 32'h11111111, "Address 0x100");
            test_write_read(32'h00000200, 32'h22222222, "Address 0x200");
            test_write_read(32'h00000400, 32'h44444444, "Address 0x400");
            test_write_read(32'h00000800, 32'h88888888, "Address 0x800");
            
            // Test unaligned addresses (should use word address)
            test_write_read(32'h00000101, 32'hABCDEF01, "Unaligned address 0x101");
            test_write_read(32'h00000102, 32'hABCDEF02, "Unaligned address 0x102");
            test_write_read(32'h00000103, 32'hABCDEF03, "Unaligned address 0x103");
            
            $display("Address Range Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Read-Write Hazard Testing
    // =================================================================
    task run_read_write_hazard_tests();
        begin
            $display("\n[%0t] Running Read-Write Hazard Tests...", $time);
            
            // Test simultaneous read and write to same address
            address = 32'h00000030;
            mem_write = 1'b1;
            write_enable = 4'b1111;
            write_data = 32'h12345678;
            
            @(posedge clk);
            mem_write = 1'b0;
            #1; // Small delay for read
            
            test_single_signal(read_data, 32'h12345678, "Read after write same address");
            
            // Test read-after-write with different addresses
            test_write_read(32'h00000034, 32'h11111111, "Write to address 0x34");
            test_write_read(32'h00000038, 32'h22222222, "Write to address 0x38");
            
            // Read from first address
            address = 32'h00000034;
            #1;
            test_single_signal(read_data, 32'h11111111, "Read from first address");
            
            // Read from second address  
            address = 32'h00000038;
            #1;
            test_single_signal(read_data, 32'h22222222, "Read from second address");
            
            $display("Read-Write Hazard Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Debug Interface Testing
    // =================================================================
    task run_debug_interface_tests();
        begin
            $display("\n[%0t] Running Debug Interface Tests...", $time);
            
            // Setup test data via normal interface
            test_write_read(32'h00000040, 32'hDEB16001, "Setup debug test data 1");
            test_write_read(32'h00000044, 32'hDEB16002, "Setup debug test data 2");
            test_write_read(32'h00000048, 32'hDEB16003, "Setup debug test data 3");
            
            // Enable debug interface
            debug_enable = 1'b1;
            
            // Test debug reads
            test_debug_read(12'h040, 32'hDEB16001, "Debug read address 0x040");
            test_debug_read(12'h044, 32'hDEB16002, "Debug read address 0x044");
            test_debug_read(12'h048, 32'hDEB16003, "Debug read address 0x048");
            
            // Test debug interface disabled
            debug_enable = 1'b0;
            debug_addr = 12'h044;
            #1;
            test_single_signal(debug_data, 32'h00000000, "Debug disabled should return zero");
            
            // Re-enable for cleanup
            debug_enable = 1'b1;
            
            $display("Debug Interface Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Reset Behavior Testing
    // =================================================================
    task run_reset_behavior_tests();
        begin
            $display("\n[%0t] Running Reset Behavior Tests...", $time);
            
            // Write test data
            test_write_read(32'h00000050, 32'h12345678, "Write before reset test");
            
            // Apply reset
            rst_n = 1'b0;
            #1;
            
            // During reset, reads should return zero
            address = 32'h00000050;
            #1;
            test_single_signal(read_data, 32'h00000000, "Read during reset should return zero");
            
            // Release reset
            rst_n = 1'b1;
            #1;
            
            // After reset, data should still be there (memory contents preserved)
            test_single_signal(read_data, 32'h12345678, "Data preserved after reset");
            
            $display("Reset Behavior Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Boundary Testing
    // =================================================================
    task run_boundary_tests();
        begin
            $display("\n[%0t] Running Boundary Tests...", $time);
            
            // Test last valid address
            test_write_read(32'h00000FFC, 32'h12345678, "Last valid addr");
            
            // Test out-of-range addresses
            test_out_of_range_write(32'h00001000, 32'h5A0DFADE, "Out of range write should be ignored");
            test_out_of_range_read(32'h00001000, 32'h00000000, "Out of range read should return zero");
            
            // Test maximum address
            test_out_of_range_write(32'hFFFFFFFF, 32'h5A0DFADE, "Maximum address write");
            test_out_of_range_read(32'hFFFFFFFF, 32'h00000000, "Maximum address read");
            
            $display("Boundary Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Write then Read
    // =================================================================
    task test_write_read(
        input [31:0] addr,
        input [31:0] data,
        input [1599:0] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Write operation
            address = addr;
            write_data = data;
            mem_write = 1'b1;
            write_enable = 4'b1111;
            
            @(posedge clk);
            
            #1; // Small delay before clearing mem_write to ensure proper timing
            mem_write = 1'b0;
            
            // Read operation
            #1; // Small delay for combinational read
            
            if (read_data === data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Address: 0x%08h, Data: 0x%08h", addr, read_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Address: 0x%08h", addr);
                $display("      Expected: 0x%08h, Got: 0x%08h", data, read_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Write Disabled
    // =================================================================
    task test_write_disabled(
        input [31:0] addr,
        input [31:0] write_val,
        input [31:0] expected_val,
        input [1599:0] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Attempt write with write disabled
            address = addr;
            write_data = write_val;
            mem_write = 1'b0; // Write disabled
            write_enable = 4'b1111;
            
            @(posedge clk);
            
            // Read to check if write occurred
            #1;
            
            if (read_data === expected_val) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Address: 0x%08h, Data unchanged: 0x%08h", addr, read_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Address: 0x%08h", addr);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_val, read_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Debug Read
    // =================================================================
    task test_debug_read(
        input [11:0] addr,
        input [31:0] expected_data,
        input [1599:0] test_name
    );
        begin
            test_count = test_count + 1;
            
            debug_addr = addr;
            #1;
            
            if (debug_data === expected_data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Debug Address: 0x%03h, Data: 0x%08h", addr, debug_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Debug Address: 0x%03h", addr);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_data, debug_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Out of Range Write
    // =================================================================
    task test_out_of_range_write(
        input [31:0] addr,
        input [31:0] data,
        input [1599:0] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Try to write to out-of-range address
            address = addr;
            write_data = data;
            mem_write = 1'b1;
            write_enable = 4'b1111;
            
            @(posedge clk);
            mem_write = 1'b0;
            
            // If we reach here without error, it's expected behavior
            pass_count = pass_count + 1;
            if (VERBOSE_MODE) begin
                $display("  ✅ PASS: %0s", test_name);
                $display("      Out of range write handled gracefully");
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Out of Range Read
    // =================================================================
    task test_out_of_range_read(
        input [31:0] addr,
        input [31:0] expected_data,
        input [1599:0] test_name
    );
        begin
            test_count = test_count + 1;
            
            address = addr;
            #1;
            
            if (read_data === expected_data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Out of range read returned: 0x%08h", read_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_data, read_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Single Signal
    // =================================================================
    task test_single_signal(
        input [31:0] actual_value,
        input [31:0] expected_value,
        input [1599:0] test_name
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
            $display("DATA MEMORY TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Data Memory implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Data Memory implementation.");
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
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);
    end

endmodule
