module Memory_Data_Register_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg reset;
    reg mdr_write;
    reg [31:0] data_in;
    
    // Outputs
    wire [31:0] data_out;
    
    // Instantiate the Memory Data Register
    Memory_Data_Register dut (
        .clk(clk),
        .reset(reset),
        .mdr_write(mdr_write),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        mdr_write = 0;
        data_in = 32'h0;
        
        // Apply reset
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;
        
        // Test 1: Write data to MDR
        data_in = 32'hA5A5A5A5;
        mdr_write = 1;
        #CLK_PERIOD;
        mdr_write = 0;
        
        // Verify data was written
        if (data_out !== 32'hA5A5A5A5) begin
            $display("Test 1 Failed: data_out = %h, expected = %h", data_out, 32'hA5A5A5A5);
        end else begin
            $display("Test 1 Passed: data_out = %h", data_out);
        end
        
        // Test 2: Change data_in without mdr_write (should not update)
        data_in = 32'h5A5A5A5A;
        #CLK_PERIOD;
        
        // Verify data was not written
        if (data_out !== 32'hA5A5A5A5) begin
            $display("Test 2 Failed: data_out = %h, expected = %h", data_out, 32'hA5A5A5A5);
        end else begin
            $display("Test 2 Passed: data_out unchanged when mdr_write=0");
        end
        
        // Test 3: Write new data to MDR
        data_in = 32'h12345678;
        mdr_write = 1;
        #CLK_PERIOD;
        mdr_write = 0;
        
        // Verify new data was written
        if (data_out !== 32'h12345678) begin
            $display("Test 3 Failed: data_out = %h, expected = %h", data_out, 32'h12345678);
        end else begin
            $display("Test 3 Passed: data_out = %h", data_out);
        end
        
        // Test 4: Reset MDR
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        
        // Verify data was reset to 0
        if (data_out !== 32'h0) begin
            $display("Test 4 Failed: data_out = %h, expected = %h", data_out, 32'h0);
        end else begin
            $display("Test 4 Passed: data_out reset to 0");
        end
        
        // Test 5: Reset has priority over write
        data_in = 32'hFFFFFFFF;
        mdr_write = 1;
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        mdr_write = 0;
        
        // Verify data was reset to 0 despite mdr_write being 1
        if (data_out !== 32'h0) begin
            $display("Test 5 Failed: data_out = %h, expected = %h", data_out, 32'h0);
        end else begin
            $display("Test 5 Passed: reset has priority over write");
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("memory_data_register_waveform.vcd");
        $dumpvars(0, Memory_Data_Register_tb);
    end
    
endmodule
