// =============================================================================
// Hazard Unit Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests pipeline hazard detection and forwarding logic
// Author: Auto-generated testbench  
// Date: September 23, 2025
// Features: - Data hazard detection (RAW, WAR, WAW)
//          - Load-use hazard testing
//          - Control hazard testing  
//          - Forwarding logic verification
//          - Stall/flush signal testing
// =============================================================================

`timescale 1ns / 1ps

module hazard_unit_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    parameter REG_ADDR_WIDTH = 5;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg                                 clk;
    reg                                 rst_n;
    reg [REG_ADDR_WIDTH-1:0]            rs1_d, rs2_d;
    reg [REG_ADDR_WIDTH-1:0]            rs1_e, rs2_e, rd_e;
    reg [REG_ADDR_WIDTH-1:0]            rd_m, rd_w;
    reg [1:0]                           reg_read_e;
    reg                                 mem_to_reg_e;
    reg                                 reg_write_m, reg_write_w;
    reg                                 branch_e, jalr_e, jal_d;
    reg                                 icache_miss, dcache_miss;
    
    wire                                stall_f, stall_d, stall_e, stall_m, stall_w;
    wire                                flush_f, flush_d, flush_e, flush_m, flush_w;
    wire [1:0]                          forward_1e, forward_2e;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Expected values for checking
    reg exp_stall_f, exp_stall_d, exp_stall_e;
    reg exp_flush_d, exp_flush_e;
    reg [1:0] exp_forward_1e, exp_forward_2e;
    
    // =================================================================
    // Constants (matching hazard_unit.v)
    // =================================================================
    localparam FORWARD_NONE = 2'b00;
    localparam FORWARD_WB   = 2'b01;
    localparam FORWARD_MEM  = 2'b10;
    
    localparam REG_READ_NONE = 2'b00;
    localparam REG_READ_RS1  = 2'b10;
    localparam REG_READ_RS2  = 2'b01;
    localparam REG_READ_BOTH = 2'b11;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    hazard_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .reg_read_e(reg_read_e),
        .mem_to_reg_e(mem_to_reg_e),
        .reg_write_m(reg_write_m),
        .reg_write_w(reg_write_w),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .jal_d(jal_d),
        .icache_miss(icache_miss),
        .dcache_miss(dcache_miss),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .stall_e(stall_e),
        .stall_m(stall_m),
        .stall_w(stall_w),
        .flush_f(flush_f),
        .flush_d(flush_d),
        .flush_e(flush_e),
        .flush_m(flush_m),
        .flush_w(flush_w),
        .forward_1e(forward_1e),
        .forward_2e(forward_2e)
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
        
        // Initialize all inputs
        initialize_inputs();
        
        $display("========================================");
        $display("HAZARD UNIT TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Reset sequence
        rst_n = 1'b0;
        #(CLOCK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLOCK_PERIOD);
        
        // Run test suites
        run_reset_tests();
        run_no_hazard_tests();
        run_forwarding_tests();
        run_load_use_hazard_tests();
        run_control_hazard_tests();
        run_cache_miss_tests();
        run_complex_hazard_scenarios();
        
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
            rs1_d = 5'h0;
            rs2_d = 5'h0;
            rs1_e = 5'h0;
            rs2_e = 5'h0;
            rd_e = 5'h0;
            rd_m = 5'h0;
            rd_w = 5'h0;
            reg_read_e = REG_READ_NONE;
            mem_to_reg_e = 1'b0;
            reg_write_m = 1'b0;
            reg_write_w = 1'b0;
            branch_e = 1'b0;
            jalr_e = 1'b0;
            jal_d = 1'b0;
            icache_miss = 1'b0;
            dcache_miss = 1'b0;
        end
    endtask
    
    // =================================================================
    // Test Suite: Reset Behavior
    // =================================================================
    task run_reset_tests();
        begin
            $display("\n[%0t] Running Reset Tests...", $time);
            
            // During reset, all stalls should be inactive, all flushes active
            rst_n = 1'b0;
            #1;
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b1, 1'b1, 1'b1, 1'b1, 1'b1,     // All flushes active
                FORWARD_NONE, FORWARD_NONE,        // No forwarding
                "Reset state"
            );
            
            // After reset, everything should be clear
            rst_n = 1'b1;
            #1;
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // No forwarding
                "After reset"
            );
            
            $display("Reset Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: No Hazard Scenarios
    // =================================================================
    task run_no_hazard_tests();
        begin
            $display("\n[%0t] Running No Hazard Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test: No dependencies, no hazards
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_e = 5'h3;
            rd_m = 5'h4;
            rd_w = 5'h5;
            reg_read_e = REG_READ_BOTH;
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // No forwarding
                "No hazards - different registers"
            );
            
            // Test: x0 register (should never forward)
            rs1_e = 5'h0;
            rs2_e = 5'h0;
            rd_m = 5'h0;
            rd_w = 5'h0;
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // No forwarding (x0 never forwards)
                "x0 register - no forwarding"
            );
            
            $display("No Hazard Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Forwarding Logic Tests
    // =================================================================
    task run_forwarding_tests();
        begin
            $display("\n[%0t] Running Forwarding Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test MEM stage forwarding (rs1)
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h1;  // rd_m matches rs1_e
            rd_w = 5'h3;
            reg_read_e = REG_READ_BOTH;
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_MEM, FORWARD_NONE,         // Forward rs1 from MEM
                "MEM stage forwarding - rs1"
            );
            
            // Test MEM stage forwarding (rs2)
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h2;  // rd_m matches rs2_e
            rd_w = 5'h3;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_MEM,         // Forward rs2 from MEM
                "MEM stage forwarding - rs2"
            );
            
            // Test WB stage forwarding (rs1)
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h3;
            rd_w = 5'h1;  // rd_w matches rs1_e
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_WB, FORWARD_NONE,          // Forward rs1 from WB
                "WB stage forwarding - rs1"
            );
            
            // Test WB stage forwarding (rs2)
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h3;
            rd_w = 5'h2;  // rd_w matches rs2_e
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_WB,          // Forward rs2 from WB
                "WB stage forwarding - rs2"
            );
            
            // Test both operands forwarding
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h1;  // Forward rs1 from MEM
            rd_w = 5'h2;  // Forward rs2 from WB
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_MEM, FORWARD_WB,           // Forward both operands
                "Both operands forwarding"
            );
            
            // Test MEM priority over WB
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_m = 5'h1;  // MEM has rs1
            rd_w = 5'h1;  // WB also has rs1, but MEM should take priority
            reg_write_m = 1'b1;
            reg_write_w = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_MEM, FORWARD_NONE,         // MEM takes priority over WB
                "MEM priority over WB"
            );
            
            $display("Forwarding Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Load-Use Hazard Tests
    // =================================================================
    task run_load_use_hazard_tests();
        begin
            $display("\n[%0t] Running Load-Use Hazard Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test load-use hazard (rs1)
            rs1_e = 5'h1;
            rd_e = 5'h1;     // EX stage loads to rs1
            mem_to_reg_e = 1'b1;  // It's a load instruction
            reg_read_e = REG_READ_RS1; // Reading rs1
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Stall IF and ID
                1'b0, 1'b0, 1'b1, 1'b0, 1'b0,     // Flush EX (insert bubble)
                FORWARD_NONE, FORWARD_NONE,        // No forwarding during stall
                "Load-use hazard - rs1"
            );
            
            // Test load-use hazard (rs2)
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_e = 5'h2;     // EX stage loads to rs2
            mem_to_reg_e = 1'b1;
            reg_read_e = REG_READ_RS2; // Reading rs2
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Stall IF and ID
                1'b0, 1'b0, 1'b1, 1'b0, 1'b0,     // Flush EX
                FORWARD_NONE, FORWARD_NONE,        // No forwarding during stall
                "Load-use hazard - rs2"
            );
            
            // Test no load-use hazard when not a load
            rs1_e = 5'h1;
            rd_e = 5'h1;
            mem_to_reg_e = 1'b0;  // Not a load instruction
            reg_read_e = REG_READ_RS1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding logic applies
                "No hazard when not a load"
            );
            
            // Test no hazard with x0
            rs1_e = 5'h0;
            rd_e = 5'h0;
            mem_to_reg_e = 1'b1;
            reg_read_e = REG_READ_RS1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls (x0 doesn't cause hazards)
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // No forwarding to x0
                "No hazard with x0 register"
            );
            
            $display("Load-Use Hazard Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Control Hazard Tests
    // =================================================================
    task run_control_hazard_tests();
        begin
            $display("\n[%0t] Running Control Hazard Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test branch hazard
            branch_e = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Flush IF and ID
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "Branch hazard"
            );
            
            // Test JALR hazard
            branch_e = 1'b0;
            jalr_e = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Flush IF and ID
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "JALR hazard"
            );
            
            // Test JAL hazard
            jalr_e = 1'b0;
            jal_d = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Flush IF and ID
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "JAL hazard"
            );
            
            // Test no control hazard
            jal_d = 1'b0;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "No control hazard"
            );
            
            $display("Control Hazard Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Cache Miss Tests
    // =================================================================
    task run_cache_miss_tests();
        begin
            $display("\n[%0t] Running Cache Miss Tests...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Test instruction cache miss
            icache_miss = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b1, 1'b1, 1'b1,     // Stall entire pipeline
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "Instruction cache miss"
            );
            
            // Test data cache miss
            icache_miss = 1'b0;
            dcache_miss = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b1, 1'b1, 1'b1,     // Stall entire pipeline
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "Data cache miss"
            );
            
            // Test both cache misses
            icache_miss = 1'b1;
            dcache_miss = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b1, 1'b1, 1'b1,     // Stall entire pipeline
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "Both cache misses"
            );
            
            // Test no cache miss
            icache_miss = 1'b0;
            dcache_miss = 1'b0;
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes
                FORWARD_NONE, FORWARD_NONE,        // Normal forwarding
                "No cache miss"
            );
            
            $display("Cache Miss Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Complex Hazard Scenarios
    // =================================================================
    task run_complex_hazard_scenarios();
        begin
            $display("\n[%0t] Running Complex Hazard Scenarios...", $time);
            
            initialize_inputs();
            rst_n = 1'b1;
            
            // Scenario 1: Load-use hazard with forwarding
            rs1_e = 5'h1;
            rs2_e = 5'h2;
            rd_e = 5'h1;        // Load to rs1 causes hazard
            rd_m = 5'h2;        // Also provide forwarding for rs2
            mem_to_reg_e = 1'b1;
            reg_read_e = REG_READ_BOTH;
            reg_write_m = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Stall due to load-use
                1'b0, 1'b0, 1'b1, 1'b0, 1'b0,     // Flush EX
                FORWARD_NONE, FORWARD_MEM,         // Can still forward rs2
                "Load-use with forwarding"
            );
            
            // Scenario 2: Control hazard overrides load-use hazard
            branch_e = 1'b1;    // Branch overrides load-use
            #1;
            
            test_hazard_signals(
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No stalls (control hazard priority)
                1'b1, 1'b1, 1'b0, 1'b0, 1'b0,     // Flush for control hazard
                FORWARD_NONE, FORWARD_MEM,         // Forwarding still works
                "Control hazard overrides load-use"
            );
            
            // Scenario 3: Cache miss overrides everything
            icache_miss = 1'b1;
            #1;
            
            test_hazard_signals(
                1'b1, 1'b1, 1'b1, 1'b1, 1'b1,     // Cache miss stalls everything
                1'b0, 1'b0, 1'b0, 1'b0, 1'b0,     // No flushes with cache miss
                FORWARD_NONE, FORWARD_MEM,         // Forwarding still works
                "Cache miss overrides all"
            );
            
            $display("Complex Hazard Scenarios Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Hazard Signals
    // =================================================================
    task test_hazard_signals(
        input exp_stall_f, exp_stall_d, exp_stall_e, exp_stall_m, exp_stall_w,
        input exp_flush_f, exp_flush_d, exp_flush_e, exp_flush_m, exp_flush_w,
        input [1:0] exp_forward_1e, exp_forward_2e,
        input [200*8:1] test_name
    );
        reg test_passed;
        begin
            test_count = test_count + 1;
            test_passed = 1'b1;
            
            // Check stall signals
            if (stall_f !== exp_stall_f) test_passed = 1'b0;
            if (stall_d !== exp_stall_d) test_passed = 1'b0;
            if (stall_e !== exp_stall_e) test_passed = 1'b0;
            if (stall_m !== exp_stall_m) test_passed = 1'b0;
            if (stall_w !== exp_stall_w) test_passed = 1'b0;
            
            // Check flush signals
            if (flush_f !== exp_flush_f) test_passed = 1'b0;
            if (flush_d !== exp_flush_d) test_passed = 1'b0;
            if (flush_e !== exp_flush_e) test_passed = 1'b0;
            if (flush_m !== exp_flush_m) test_passed = 1'b0;
            if (flush_w !== exp_flush_w) test_passed = 1'b0;
            
            // Check forwarding signals
            if (forward_1e !== exp_forward_1e) test_passed = 1'b0;
            if (forward_2e !== exp_forward_2e) test_passed = 1'b0;
            
            if (test_passed) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Stalls: F=%b D=%b E=%b M=%b W=%b", stall_f, stall_d, stall_e, stall_m, stall_w);
                    $display("      Flushes: F=%b D=%b E=%b M=%b W=%b", flush_f, flush_d, flush_e, flush_m, flush_w);
                    $display("      Forwarding: 1E=%0d 2E=%0d", forward_1e, forward_2e);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Expected Stalls: F=%b D=%b E=%b M=%b W=%b", exp_stall_f, exp_stall_d, exp_stall_e, exp_stall_m, exp_stall_w);
                $display("      Actual Stalls:   F=%b D=%b E=%b M=%b W=%b", stall_f, stall_d, stall_e, stall_m, stall_w);
                $display("      Expected Flushes: F=%b D=%b E=%b M=%b W=%b", exp_flush_f, exp_flush_d, exp_flush_e, exp_flush_m, exp_flush_w);
                $display("      Actual Flushes:   F=%b D=%b E=%b M=%b W=%b", flush_f, flush_d, flush_e, flush_m, flush_w);
                $display("      Expected Forwarding: 1E=%0d 2E=%0d", exp_forward_1e, exp_forward_2e);
                $display("      Actual Forwarding:   1E=%0d 2E=%0d", forward_1e, forward_2e);
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
            $display("HAZARD UNIT TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Hazard Unit implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Hazard Unit implementation.");
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
        $dumpfile("hazard_unit_tb.vcd");
        $dumpvars(0, hazard_unit_tb);
    end

endmodule
