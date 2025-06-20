module Memory_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg [31:0] address;
    reg [31:0] write_data;
    reg mem_write;
    reg mem_read;
    reg [1:0] size;
    
    // Outputs
    wire [31:0] read_data;
    
    // Instantiate the Memory module
    Memory dut (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .size(size),
        .read_data(read_data)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        address = 32'h0;
        write_data = 32'h0;
        mem_write = 0;
        mem_read = 0;
        size = 2'b10; // Word size
        
        // Wait for a few clock cycles
        #(CLK_PERIOD*2);
        
        // Test 1: Write a word to memory
        address = 32'h00000000;
        write_data = 32'h12345678;
        mem_write = 1;
        size = 2'b10; // Word
        #CLK_PERIOD;
        mem_write = 0;
        
        // Read the word back
        mem_read = 1;
        #CLK_PERIOD;
        
        // Verify read data
        if (read_data !== 32'h12345678) begin
            $display("Test 1 Failed: read_data = %h, expected = %h", read_data, 32'h12345678);
        end else begin
            $display("Test 1 Passed: read_data = %h", read_data);
        end
        
        // Test 2: Write a half-word to memory
        address = 32'h00000004;
        write_data = 32'h0000ABCD;
        mem_write = 1;
        size = 2'b01; // Half-word
        #CLK_PERIOD;
        mem_write = 0;
        
        // Read the half-word back
        mem_read = 1;
        #CLK_PERIOD;
        
        // Verify read data (sign-extended)
        if (read_data !== 32'hFFFFABCD) begin
            $display("Test 2 Failed: read_data = %h, expected = %h", read_data, 32'hFFFFABCD);
        end else begin
            $display("Test 2 Passed: read_data = %h", read_data);
        end
        
        // Test 3: Write a byte to memory
        address = 32'h00000008;
        write_data = 32'h000000FF;
        mem_write = 1;
        size = 2'b00; // Byte
        #CLK_PERIOD;
        mem_write = 0;
        
        // Read the byte back
        mem_read = 1;
        #CLK_PERIOD;
        
        // Verify read data (sign-extended)
        if (read_data !== 32'hFFFFFFFF) begin
            $display("Test 3 Failed: read_data = %h, expected = %h", read_data, 32'hFFFFFFFF);
        end else begin
            $display("Test 3 Passed: read_data = %h", read_data);
        end
        
        // Test 4: Write a positive byte to memory (no sign extension)
        address = 32'h0000000C;
        write_data = 32'h0000007F;
        mem_write = 1;
        size = 2'b00; // Byte
        #CLK_PERIOD;
        mem_write = 0;
        
        // Read the byte back
        mem_read = 1;
        #CLK_PERIOD;
        
        // Verify read data (sign-extended, but positive)
        if (read_data !== 32'h0000007F) begin
            $display("Test 4 Failed: read_data = %h, expected = %h", read_data, 32'h0000007F);
        end else begin
            $display("Test 4 Passed: read_data = %h", read_data);
        end
        
        // Test 5: Write a word and read it back in parts
        address = 32'h00000010;
        write_data = 32'h12345678;
        mem_write = 1;
        size = 2'b10; // Word
        #CLK_PERIOD;
        mem_write = 0;
        
        // Read the lower half-word
        address = 32'h00000010;
        mem_read = 1;
        size = 2'b01; // Half-word
        #CLK_PERIOD;
        
        // Verify read data
        if (read_data !== 32'h00005678) begin
            $display("Test 5a Failed: read_data = %h, expected = %h", read_data, 32'h00005678);
        end else begin
            $display("Test 5a Passed: read_data = %h", read_data);
        end
        
        // Read the upper half-word
        address = 32'h00000012;
        #CLK_PERIOD;
        
        // Verify read data
        if (read_data !== 32'h00001234) begin
            $display("Test 5b Failed: read_data = %h, expected = %h", read_data, 32'h00001234);
        end else begin
            $display("Test 5b Passed: read_data = %h", read_data);
        end
        
        // Test 6: Test mem_read control
        mem_read = 0;
        #CLK_PERIOD;
        
        // Verify read data is 0 when mem_read=0
        if (read_data !== 32'h0) begin
            $display("Test 6 Failed: read_data = %h, expected = %h", read_data, 32'h0);
        end else begin
            $display("Test 6 Passed: read_data = %h when mem_read=0", read_data);
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("memory_waveform.vcd");
        $dumpvars(0, Memory_tb);
    end
    
endmodule
