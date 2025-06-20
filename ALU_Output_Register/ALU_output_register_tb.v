`timescale 1ns / 1ps

module ALU_output_register_tb;
    // Parameters
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    // Inputs
    reg clk;
    reg reset;
    reg alu_out_write;
    reg [WIDTH-1:0] result;

    // Outputs
    wire [WIDTH-1:0] result_out;

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Instantiate the Unit Under Test (UUT)
    ALU_output_register uut (
        .clk(clk),
        .reset(reset),
        .alu_out_write(alu_out_write),
        .result(result),
        .result_out(result_out)
    );

    // VCD file generation for GTKWave
    initial begin
        // Create VCD file for waveform viewing
        $dumpfile("alu_output_register_waveform.vcd");
        // Dump all variables at all levels
        $dumpvars(0, ALU_output_register_tb);
    end

    // Test case counter and expected results
    integer test_case;
    reg [WIDTH-1:0] expected_result;

    // Task to display test results
    task display_test_result;
        input [8*30:1] test_name;
        begin
            $display("Test Case %0d: %s", test_case, test_name);
            $display("  Input result = %h, alu_out_write = %b", result, alu_out_write);
            $display("  Expected: result_out = %h", expected_result);
            $display("  Actual:   result_out = %h", result_out);
            
            if (result_out !== expected_result) begin
                $display("  TEST FAILED!");
            end else begin
                $display("  Test passed.");
            end
            $display("--------------------------------------");
        end
    endtask

    // Main test procedure
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        alu_out_write = 0;
        result = 0;
        test_case = 0;
        expected_result = 0;

        // Apply reset
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;

        // Test 1: Write value when alu_out_write is enabled
        test_case = test_case + 1;
        result = 32'h12345678;
        alu_out_write = 1;
        expected_result = 32'h12345678;
        #CLK_PERIOD;
        display_test_result("Write value with alu_out_write enabled");

        // Test 2: Keep value when alu_out_write is disabled
        test_case = test_case + 1;
        result = 32'h87654321;
        alu_out_write = 0;
        expected_result = 32'h12345678; // Should keep previous value
        #CLK_PERIOD;
        display_test_result("Keep value with alu_out_write disabled");

        // Test 3: Write new value when alu_out_write is enabled again
        test_case = test_case + 1;
        result = 32'hABCDEF01;
        alu_out_write = 1;
        expected_result = 32'hABCDEF01;
        #CLK_PERIOD;
        display_test_result("Write new value with alu_out_write enabled");

        // Test 4: Reset should clear the register
        test_case = test_case + 1;
        reset = 1;
        expected_result = 32'h00000000;
        #CLK_PERIOD;
        display_test_result("Reset clears the register");
        reset = 0;

        // Test 5: Write after reset
        test_case = test_case + 1;
        result = 32'h55555555;
        alu_out_write = 1;
        expected_result = 32'h55555555;
        #CLK_PERIOD;
        display_test_result("Write after reset");

        // Test 6: Test with ALU addition result (10 + 15 = 25)
        test_case = test_case + 1;
        result = 32'd25; // Simulating ALU addition result of 10 + 15
        alu_out_write = 1;
        expected_result = 32'd25;
        #CLK_PERIOD;
        display_test_result("Store ALU addition result");

        // Test 7: Test with ALU subtraction result (20 - 10 = 10)
        test_case = test_case + 1;
        result = 32'd10; // Simulating ALU subtraction result of 20 - 10
        alu_out_write = 1;
        expected_result = 32'd10;
        #CLK_PERIOD;
        display_test_result("Store ALU subtraction result");

        // Test 8: Test with ALU logic result (AND operation)
        test_case = test_case + 1;
        result = 32'h00FF00FF; // Simulating ALU AND result
        alu_out_write = 1;
        expected_result = 32'h00FF00FF;
        #CLK_PERIOD;
        display_test_result("Store ALU logic result");

        // Finish simulation
        $display("All tests completed!");
        #(CLK_PERIOD*2);
        $finish;
    end

endmodule
