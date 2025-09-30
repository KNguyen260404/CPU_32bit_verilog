// =============================================================================
// Data Extension Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests data extension for all RISC-V load types (LB, LH, LW, LBU, LHU)
// Author: Auto-generated testbench
// Date: September 23, 2025  
// Features: - All load types testing
//          - Signed/unsigned extension verification
//          - Byte selection testing
//          - Corner cases and boundary testing
// =============================================================================

`timescale 1ns / 1ps

module data_extension_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg [31:0]  memory_data;
    reg [1:0]   byte_select;
    reg [2:0]   load_type;
    wire [31:0] extended_data;
    
    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // Constants (matching data_extension.v)
    // =================================================================
    localparam FUNCT3_LB  = 3'b000;
    localparam FUNCT3_LH  = 3'b001;
    localparam FUNCT3_LW  = 3'b010;
    localparam FUNCT3_LBU = 3'b100;
    localparam FUNCT3_LHU = 3'b101;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    data_extension dut (
        .memory_data(memory_data),
        .byte_select(byte_select),
        .load_type(load_type),
        .extended_data(extended_data)
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
        memory_data = 32'h0;
        byte_select = 2'h0;
        load_type = 3'h0;
        
        $display("========================================");
        $display("DATA EXTENSION TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Run test suites
        #10;
        run_lb_tests();
        run_lh_tests();
        run_lw_tests();
        run_lbu_tests();
        run_lhu_tests();
        run_corner_case_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: LB (Load Byte - Signed)
    // =================================================================
    task run_lb_tests();
        begin
            $display("\n[%0t] Running LB Tests...", $time);
            
            // Test memory data: 0x87654321
            // Byte 0: 0x21 (positive), Byte 1: 0x43 (positive)  
            // Byte 2: 0x65 (positive), Byte 3: 0x87 (negative)
            
            // Positive byte values (sign extension with 0)
            test_data_extension(32'h87654321, 2'b00, FUNCT3_LB, 32'h00000021, "LB: Byte 0 - positive");
            test_data_extension(32'h87654321, 2'b01, FUNCT3_LB, 32'h00000043, "LB: Byte 1 - positive");
            test_data_extension(32'h87654321, 2'b10, FUNCT3_LB, 32'h00000065, "LB: Byte 2 - positive");
            
            // Negative byte value (sign extension with 1)
            test_data_extension(32'h87654321, 2'b11, FUNCT3_LB, 32'hFFFFFF87, "LB: Byte 3 - negative");
            
            // Test with different memory data
            test_data_extension(32'hFEDCBA98, 2'b00, FUNCT3_LB, 32'hFFFFFF98, "LB: Negative byte at position 0");
            test_data_extension(32'hFEDCBA98, 2'b01, FUNCT3_LB, 32'hFFFFFFBA, "LB: Negative byte at position 1");
            test_data_extension(32'hFEDCBA98, 2'b10, FUNCT3_LB, 32'hFFFFFFDC, "LB: Negative byte at position 2");
            test_data_extension(32'hFEDCBA98, 2'b11, FUNCT3_LB, 32'hFFFFFFFE, "LB: Negative byte at position 3");
            
            // Boundary cases
            test_data_extension(32'h00000000, 2'b00, FUNCT3_LB, 32'h00000000, "LB: Zero byte");
            test_data_extension(32'h7F7F7F7F, 2'b00, FUNCT3_LB, 32'h0000007F, "LB: Maximum positive byte");
            test_data_extension(32'h80808080, 2'b00, FUNCT3_LB, 32'hFFFFFF80, "LB: Minimum negative byte");
            test_data_extension(32'hFFFFFFFF, 2'b00, FUNCT3_LB, 32'hFFFFFFFF, "LB: All 1s");
            
            $display("LB Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: LH (Load Halfword - Signed)
    // =================================================================
    task run_lh_tests();
        begin
            $display("\n[%0t] Running LH Tests...", $time);
            
            // Test memory data: 0x87654321
            // Lower halfword: 0x4321 (positive), Upper halfword: 0x8765 (negative)
            
            // Positive halfword (sign extension with 0)
            test_data_extension(32'h87654321, 2'b00, FUNCT3_LH, 32'h00004321, "LH: Lower halfword - positive");
            test_data_extension(32'h87654321, 2'b01, FUNCT3_LH, 32'h00004321, "LH: Lower halfword - byte_select[0] ignored");
            
            // Negative halfword (sign extension with 1) 
            test_data_extension(32'h87654321, 2'b10, FUNCT3_LH, 32'hFFFF8765, "LH: Upper halfword - negative");
            test_data_extension(32'h87654321, 2'b11, FUNCT3_LH, 32'hFFFF8765, "LH: Upper halfword - byte_select[0] ignored");
            
            // Test with different memory data
            test_data_extension(32'h12349876, 2'b00, FUNCT3_LH, 32'hFFFF9876, "LH: Negative lower halfword");
            test_data_extension(32'h12349876, 2'b10, FUNCT3_LH, 32'h00001234, "LH: Positive upper halfword");
            
            // Boundary cases
            test_data_extension(32'h00000000, 2'b00, FUNCT3_LH, 32'h00000000, "LH: Zero halfword");
            test_data_extension(32'h7FFF7FFF, 2'b00, FUNCT3_LH, 32'h00007FFF, "LH: Maximum positive halfword");
            test_data_extension(32'h80008000, 2'b00, FUNCT3_LH, 32'hFFFF8000, "LH: Minimum negative halfword");
            test_data_extension(32'hFFFFFFFF, 2'b00, FUNCT3_LH, 32'hFFFFFFFF, "LH: All 1s");
            
            $display("LH Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: LW (Load Word)
    // =================================================================
    task run_lw_tests();
        begin
            $display("\n[%0t] Running LW Tests...", $time);
            
            // For word loads, byte_select should be ignored and full word returned
            test_data_extension(32'h87654321, 2'b00, FUNCT3_LW, 32'h87654321, "LW: Full word - byte_select 00");
            test_data_extension(32'h87654321, 2'b01, FUNCT3_LW, 32'h87654321, "LW: Full word - byte_select 01");
            test_data_extension(32'h87654321, 2'b10, FUNCT3_LW, 32'h87654321, "LW: Full word - byte_select 10");
            test_data_extension(32'h87654321, 2'b11, FUNCT3_LW, 32'h87654321, "LW: Full word - byte_select 11");
            
            // Test various word values
            test_data_extension(32'h00000000, 2'b00, FUNCT3_LW, 32'h00000000, "LW: Zero word");
            test_data_extension(32'hFFFFFFFF, 2'b00, FUNCT3_LW, 32'hFFFFFFFF, "LW: All 1s word");
            test_data_extension(32'h7FFFFFFF, 2'b00, FUNCT3_LW, 32'h7FFFFFFF, "LW: Maximum positive word");
            test_data_extension(32'h80000000, 2'b00, FUNCT3_LW, 32'h80000000, "LW: Minimum negative word");
            test_data_extension(32'hAAAA5555, 2'b00, FUNCT3_LW, 32'hAAAA5555, "LW: Alternating pattern");
            
            $display("LW Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: LBU (Load Byte Unsigned - Zero Extension)
    // =================================================================
    task run_lbu_tests();
        begin
            $display("\n[%0t] Running LBU Tests...", $time);
            
            // Test memory data: 0x87654321
            // All bytes should be zero-extended regardless of sign bit
            test_data_extension(32'h87654321, 2'b00, FUNCT3_LBU, 32'h00000021, "LBU: Byte 0 - zero extended");
            test_data_extension(32'h87654321, 2'b01, FUNCT3_LBU, 32'h00000043, "LBU: Byte 1 - zero extended");
            test_data_extension(32'h87654321, 2'b10, FUNCT3_LBU, 32'h00000065, "LBU: Byte 2 - zero extended");
            test_data_extension(32'h87654321, 2'b11, FUNCT3_LBU, 32'h00000087, "LBU: Byte 3 - zero extended (was negative in LB)");
            
            // Test with bytes that have sign bit set (should still zero extend)
            test_data_extension(32'hFEDCBA98, 2'b00, FUNCT3_LBU, 32'h00000098, "LBU: Sign bit byte - zero extended");
            test_data_extension(32'hFEDCBA98, 2'b01, FUNCT3_LBU, 32'h000000BA, "LBU: Sign bit byte - zero extended");
            test_data_extension(32'hFEDCBA98, 2'b10, FUNCT3_LBU, 32'h000000DC, "LBU: Sign bit byte - zero extended");
            test_data_extension(32'hFEDCBA98, 2'b11, FUNCT3_LBU, 32'h000000FE, "LBU: Sign bit byte - zero extended");
            
            // Boundary cases
            test_data_extension(32'h00000000, 2'b00, FUNCT3_LBU, 32'h00000000, "LBU: Zero byte");
            test_data_extension(32'h7F7F7F7F, 2'b00, FUNCT3_LBU, 32'h0000007F, "LBU: Maximum positive byte");
            test_data_extension(32'h80808080, 2'b00, FUNCT3_LBU, 32'h00000080, "LBU: Byte with sign bit set");
            test_data_extension(32'hFFFFFFFF, 2'b00, FUNCT3_LBU, 32'h000000FF, "LBU: Maximum byte value");
            
            $display("LBU Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: LHU (Load Halfword Unsigned - Zero Extension)
    // =================================================================
    task run_lhu_tests();
        begin
            $display("\n[%0t] Running LHU Tests...", $time);
            
            // Test memory data: 0x87654321
            // All halfwords should be zero-extended regardless of sign bit
            test_data_extension(32'h87654321, 2'b00, FUNCT3_LHU, 32'h00004321, "LHU: Lower halfword - zero extended");
            test_data_extension(32'h87654321, 2'b01, FUNCT3_LHU, 32'h00004321, "LHU: Lower halfword - byte_select[0] ignored");
            test_data_extension(32'h87654321, 2'b10, FUNCT3_LHU, 32'h00008765, "LHU: Upper halfword - zero extended");
            test_data_extension(32'h87654321, 2'b11, FUNCT3_LHU, 32'h00008765, "LHU: Upper halfword - byte_select[0] ignored");
            
            // Test with halfwords that have sign bit set
            test_data_extension(32'h98769876, 2'b00, FUNCT3_LHU, 32'h00009876, "LHU: Sign bit halfword - zero extended");
            test_data_extension(32'h98769876, 2'b10, FUNCT3_LHU, 32'h00009876, "LHU: Sign bit halfword - zero extended");
            
            // Mixed positive/negative halfwords
            test_data_extension(32'h12349876, 2'b00, FUNCT3_LHU, 32'h00009876, "LHU: Negative lower halfword - zero extended");
            test_data_extension(32'h12349876, 2'b10, FUNCT3_LHU, 32'h00001234, "LHU: Positive upper halfword - zero extended");
            
            // Boundary cases
            test_data_extension(32'h00000000, 2'b00, FUNCT3_LHU, 32'h00000000, "LHU: Zero halfword");
            test_data_extension(32'h7FFF7FFF, 2'b00, FUNCT3_LHU, 32'h00007FFF, "LHU: Maximum positive halfword");
            test_data_extension(32'h80008000, 2'b00, FUNCT3_LHU, 32'h00008000, "LHU: Halfword with sign bit set");
            test_data_extension(32'hFFFFFFFF, 2'b00, FUNCT3_LHU, 32'h0000FFFF, "LHU: Maximum halfword value");
            
            $display("LHU Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Corner Cases
    // =================================================================
    task run_corner_case_tests();
        begin
            $display("\n[%0t] Running Corner Case Tests...", $time);
            
            // Invalid load type - should default to LW behavior
            test_data_extension(32'h87654321, 2'b00, 3'b011, 32'h87654321, "Corner: Invalid load type - defaults to LW");
            test_data_extension(32'h87654321, 2'b00, 3'b110, 32'h87654321, "Corner: Invalid load type - defaults to LW");
            test_data_extension(32'h87654321, 2'b00, 3'b111, 32'h87654321, "Corner: Invalid load type - defaults to LW");
            
            // Test sign extension boundaries for bytes
            test_data_extension(32'h007F807F, 2'b00, FUNCT3_LB, 32'h0000007F, "Corner: Byte sign boundary - positive");
            test_data_extension(32'h007F807F, 2'b10, FUNCT3_LB, 32'hFFFFFF80, "Corner: Byte sign boundary - negative");
            
            // Test sign extension boundaries for halfwords  
            test_data_extension(32'h7FFF8000, 2'b00, FUNCT3_LH, 32'hFFFF8000, "Corner: Halfword sign boundary - negative");
            test_data_extension(32'h7FFF8000, 2'b10, FUNCT3_LH, 32'h00007FFF, "Corner: Halfword sign boundary - positive");
            
            // Test byte selection with all same bytes
            test_data_extension(32'h12121212, 2'b00, FUNCT3_LB, 32'h00000012, "Corner: All same bytes - select 0");
            test_data_extension(32'h12121212, 2'b01, FUNCT3_LB, 32'h00000012, "Corner: All same bytes - select 1");
            test_data_extension(32'h12121212, 2'b10, FUNCT3_LB, 32'h00000012, "Corner: All same bytes - select 2");
            test_data_extension(32'h12121212, 2'b11, FUNCT3_LB, 32'h00000012, "Corner: All same bytes - select 3");
            
            $display("Corner Case Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Data Extension
    // =================================================================
    task test_data_extension(
        input [31:0] mem_data,
        input [1:0]  byte_sel,
        input [2:0]  load_typ,
        input [31:0] expected_data,
        input [200*8:1] test_name
    );
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            memory_data = mem_data;
            byte_select = byte_sel;
            load_type = load_typ;
            
            // Wait for propagation
            #1;
            
            // Check result
            if (extended_data === expected_data) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                    $display("      Mem: 0x%08h, Sel: %0d, Type: %0d, Extended: 0x%08h", 
                             mem_data, byte_sel, load_typ, extended_data);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Mem: 0x%08h, Sel: %0d, Type: %0d", mem_data, byte_sel, load_typ);
                $display("      Expected: 0x%08h, Got: 0x%08h", expected_data, extended_data);
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
            $display("DATA EXTENSION TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Data Extension implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Data Extension implementation.");
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
        $dumpfile("data_extension_tb.vcd");
        $dumpvars(0, data_extension_tb);
    end

endmodule
