module Memory_Address_Register_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg reset;
    reg mar_write;
    reg [31:0] address_in;
    
    // Outputs
    wire [31:0] address_out;
    
    // Instantiate the Memory Address Register
    Memory_Address_Register dut (
        .clk(clk),
        .reset(reset),
        .mar_write(mar_write),
        .address_in(address_in),
        .address_out(address_out)
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
        mar_write = 0;
        address_in = 32'h0;
        
        // Apply reset
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;
        
        // Test 1: Write address to MAR
        address_in = 32'h12345678;
        mar_write = 1;
        #CLK_PERIOD;
        mar_write = 0;
        
        // Verify address was written
        if (address_out !== 32'h12345678) begin
            $display("Test 1 Failed: address_out = %h, expected = %h", address_out, 32'h12345678);
        end else begin
            $display("Test 1 Passed: address_out = %h", address_out);
        end
        
        // Test 2: Change address_in without mar_write (should not update)
        address_in = 32'h87654321;
        #CLK_PERIOD;
        
        // Verify address was not written
        if (address_out !== 32'h12345678) begin
            $display("Test 2 Failed: address_out = %h, expected = %h", address_out, 32'h12345678);
        end else begin
            $display("Test 2 Passed: address_out unchanged when mar_write=0");
        end
        
        // Test 3: Write new address to MAR
        address_in = 32'hAABBCCDD;
        mar_write = 1;
        #CLK_PERIOD;
        mar_write = 0;
        
        // Verify new address was written
        if (address_out !== 32'hAABBCCDD) begin
            $display("Test 3 Failed: address_out = %h, expected = %h", address_out, 32'hAABBCCDD);
        end else begin
            $display("Test 3 Passed: address_out = %h", address_out);
        end
        
        // Test 4: Reset MAR
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        
        // Verify address was reset to 0
        if (address_out !== 32'h0) begin
            $display("Test 4 Failed: address_out = %h, expected = %h", address_out, 32'h0);
        end else begin
            $display("Test 4 Passed: address_out reset to 0");
        end
        
        // Test 5: Reset has priority over write
        address_in = 32'hFFFFFFFF;
        mar_write = 1;
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        mar_write = 0;
        
        // Verify address was reset to 0 despite mar_write being 1
        if (address_out !== 32'h0) begin
            $display("Test 5 Failed: address_out = %h, expected = %h", address_out, 32'h0);
        end else begin
            $display("Test 5 Passed: reset has priority over write");
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("memory_address_register_waveform.vcd");
        $dumpvars(0, Memory_Address_Register_tb);
    end
    
endmodule
