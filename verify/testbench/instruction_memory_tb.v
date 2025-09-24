// =============================================================================
// Instruction Memory Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests instruction memory functionality with various access patterns
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - Address range testing
//          - Memory initialization testing  
//          - Debug interface testing
//          - Reset behavior verification
// =============================================================================

`timescale 1ns / 1ps

module instruction_memory_tb;

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
    reg [DATA_WIDTH-1:0]    pc_f;
    wire [DATA_WIDTH-1:0]   instruction_f;
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
    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEMORY_STYLE("distributed"),
        .ENABLE_DEBUG(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_f(pc_f),
        .instruction_f(instruction_f),
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
        pc_f = 32'h0;
        debug_enable = 1'b0;
        debug_addr = 12'h0;
        
        $display("========================================");
        $display("INSTRUCTION MEMORY TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset sequence
        #(CLOCK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLOCK_PERIOD);
        
        // Initialize memory with test patterns
        initialize_test_memory();
        
        // Run test suites
        run_basic_read_tests();
        run_address_range_tests();
        run_debug_interface_tests();
        run_reset_behavior_tests();
        run_boundary_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Initialize Memory with Test Patterns
    // =================================================================
    task initialize_test_memory();
        integer i;
        begin
            $display("\n[%0t] Initializing test memory...", $time);
            
            // Load test instructions into memory
            for (i = 0; i < 64; i = i + 1) begin
                dut.imem[i] = 32'h00000000 + i; // Simple pattern: addr as instruction
            end
            
            // Special test patterns
            dut.imem[0] = 32'h00000013;   // ADDI x0, x0, 0 (NOP)
            dut.imem[1] = 32'h00100093;   // ADDI x1, x0, 1
            dut.imem[2] = 32'h00200113;   // ADDI x2, x0, 2  
            dut.imem[3] = 32'h00300193;   // ADDI x3, x0, 3
            dut.imem[4] = 32'hFE000EE3;   // BEQ loop instruction
            dut.imem[5] = 32'h00100073;   // EBREAK
            
            $display("  Memory initialized with test patterns");
        end
    endtask
    
    // =================================================================
    // Test Suite: Basic Read Operations
    // =================================================================
    task run_basic_read_tests();
        begin
            $display("\n[%0t] Running Basic Read Tests...", $time);
            
            // Test reading from address 0
            test_instruction_read(32'h00000000, 32'h00000013, "Read from address 0 (NOP)");
            
            // Test reading from address 4 (word 1)
            test_instruction_read(32'h00000004, 32'h00100093, "Read from address 4");
            
            // Test reading from address 8 (word 2)
            test_instruction_read(32'h00000008, 32'h00200113, "Read from address 8");
            
            // Test reading from address 12 (word 3)  
            test_instruction_read(32'h0000000C, 32'h00300193, "Read from address 12");
            
            // Test reading from address 16 (word 4)
            test_instruction_read(32'h00000010, 32'hFE000EE3, "Read from address 16");
            
            // Test reading from address 20 (word 5)
            test_instruction_read(32'h00000014, 32'h00100073, "Read from address 20");
            
            $display("Basic Read Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Address Range Testing
    // =================================================================
    task run_address_range_tests();
        integer i;
        reg [31:0] expected_data;
        begin
            $display("\n[%0t] Running Address Range Tests...", $time);
            
            // Test sequential addresses
            for (i = 24; i < 64; i = i + 4) begin
                expected_data = 32'h00000000 + (i/4);
                test_instruction_read(i, expected_data, $sformatf("Sequential read at address %0d", i));
            end
            
            // Test word alignment - addresses must be word-aligned
            test_instruction_read(32'h00000100, 32'h00000040, "Read from address 0x100");
            test_instruction_read(32'h00000200, 32'h00000080, "Read from address 0x200");
            
            // Test unaligned address behavior (should use word address)
            test_instruction_read(32'h00000001, 32'h00000013, "Unaligned address 1 (should read word 0)");
            test_instruction_read(32'h00000002, 32'h00000013, "Unaligned address 2 (should read word 0)");
            test_instruction_read(32'h00000003, 32'h00000013, "Unaligned address 3 (should read word 0)");
            
            $display("Address Range Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Debug Interface Testing
    // =================================================================
    task run_debug_interface_tests();
        begin
            $display("\n[%0t] Running Debug Interface Tests...", $time);
            
            // Enable debug interface
            debug_enable = 1'b1;
            
            // Test debug reads
            test_debug_read(12'h000, 32'h00000013, "Debug read address 0");
            test_debug_read(12'h004, 32'h00100093, "Debug read address 4");
            test_debug_read(12'h008, 32'h00200113, "Debug read address 8");
            test_debug_read(12'h00C, 32'h00300193, "Debug read address 12");
            
            // Test debug interface disabled
            debug_enable = 1'b0;
            debug_addr = 12'h004;
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
            
            // Test normal operation
            pc_f = 32'h00000000;
            #1;
            test_single_signal(instruction_f, 32'h00000013, "Normal operation before reset");
            
            // Apply reset
            rst_n = 1'b0;
            #1;
            test_single_signal(instruction_f, 32'h00000013, "During reset should return NOP");
            
            // Release reset
            rst_n = 1'b1;
            #1;
            test_single_signal(instruction_f, 32'h00000013, "After reset normal operation");
            
            $display("Reset Behavior Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Boundary Testing
    // =================================================================
    task run_boundary_tests();
        begin
            $display("\n[%0t] Running Boundary Tests...", $time);
            
            // Test valid address at boundary
            test_instruction_read(32'h00000FFC, 32'h000003FF, "Last valid address");
            
            // Test out-of-range addresses (should return NOP)
            test_instruction_read(32'h00001000, 32'h00000013, "Out of range address (should return NOP)");
            test_instruction_read(32'h0000FFFF, 32'h00000013, "Large out of range address");
            
            // Test maximum PC values
            test_instruction_read(32'hFFFFFFFC, 32'h00000013, "Maximum PC value");
            
            $display("Boundary Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Instruction Read
    // =================================================================
    task test_instruction_read(
        input [31:0] address,
        input [31:0] expected_instruction,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Set PC and wait for propagation
            pc_f = address;
            #1;
            
            if (instruction_f === expected_instruction) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Address: 0x%08h, Instruction: 0x%08h", address, instruction_f);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Address: 0x%08h", address);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_instruction, instruction_f);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Debug Read
    // =================================================================
    task test_debug_read(
        input [11:0] address,
        input [31:0] expected_data,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            debug_addr = address;
            #1;
            
            if (debug_data === expected_data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Debug Address: 0x%03h, Data: 0x%08h", address, debug_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Debug Address: 0x%03h", address);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_data, debug_data);
            end
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Single Signal
    // =================================================================
    task test_single_signal(
        input [31:0] actual_value,
        input [31:0] expected_value,
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
            $display("INSTRUCTION MEMORY TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Instruction Memory implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Instruction Memory implementation.");
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
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);
    end

endmodule
