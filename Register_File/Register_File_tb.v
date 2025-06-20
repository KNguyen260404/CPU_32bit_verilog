module Register_File_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg reset;
    reg reg_write;
    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg [4:0] rd_addr;
    reg [31:0] write_data;
    
    // Outputs
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    
    // Instantiate the Register File
    Register_File dut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
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
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        write_data = 0;
        
        // Apply reset
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;
        
        // Test 1: Write to register x1 and read it back
        rd_addr = 5'd1;
        write_data = 32'hA5A5A5A5;
        reg_write = 1;
        #CLK_PERIOD;
        reg_write = 0;
        rs1_addr = 5'd1;
        #CLK_PERIOD;
        
        // Verify read data
        if (rs1_data !== 32'hA5A5A5A5) begin
            $display("Test 1 Failed: rs1_data = %h, expected = %h", rs1_data, 32'hA5A5A5A5);
        end else begin
            $display("Test 1 Passed: rs1_data = %h", rs1_data);
        end
        
        // Test 2: Write to register x2 and read it back
        rd_addr = 5'd2;
        write_data = 32'h5A5A5A5A;
        reg_write = 1;
        #CLK_PERIOD;
        reg_write = 0;
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #CLK_PERIOD;
        
        // Verify read data
        if (rs1_data !== 32'hA5A5A5A5 || rs2_data !== 32'h5A5A5A5A) begin
            $display("Test 2 Failed: rs1_data = %h, rs2_data = %h", rs1_data, rs2_data);
        end else begin
            $display("Test 2 Passed: rs1_data = %h, rs2_data = %h", rs1_data, rs2_data);
        end
        
        // Test 3: Try to write to register x0 (should remain 0)
        rd_addr = 5'd0;
        write_data = 32'hFFFFFFFF;
        reg_write = 1;
        #CLK_PERIOD;
        reg_write = 0;
        rs1_addr = 5'd0;
        #CLK_PERIOD;
        
        // Verify x0 remains 0
        if (rs1_data !== 32'h0) begin
            $display("Test 3 Failed: rs1_data = %h, expected = %h", rs1_data, 32'h0);
        end else begin
            $display("Test 3 Passed: x0 remains 0 as expected");
        end
        
        // Test 4: Test write enable signal
        rd_addr = 5'd3;
        write_data = 32'hAAAAAAAA;
        reg_write = 0; // Disable write
        #CLK_PERIOD;
        rs1_addr = 5'd3;
        #CLK_PERIOD;
        
        // Verify register wasn't written when reg_write=0
        if (rs1_data !== 32'h0) begin
            $display("Test 4 Failed: rs1_data = %h, expected = %h", rs1_data, 32'h0);
        end else begin
            $display("Test 4 Passed: No write occurred when reg_write=0");
        end
        
        // Test 5: Write to multiple registers and read them back
        // Write to x3
        rd_addr = 5'd3;
        write_data = 32'h33333333;
        reg_write = 1;
        #CLK_PERIOD;
        
        // Write to x4
        rd_addr = 5'd4;
        write_data = 32'h44444444;
        #CLK_PERIOD;
        
        // Write to x5
        rd_addr = 5'd5;
        write_data = 32'h55555555;
        #CLK_PERIOD;
        
        reg_write = 0;
        
        // Read and verify x3
        rs1_addr = 5'd3;
        #CLK_PERIOD;
        if (rs1_data !== 32'h33333333) begin
            $display("Test 5a Failed: rs1_data (x3) = %h", rs1_data);
        end else begin
            $display("Test 5a Passed: rs1_data (x3) = %h", rs1_data);
        end
        
        // Read and verify x4
        rs1_addr = 5'd4;
        #CLK_PERIOD;
        if (rs1_data !== 32'h44444444) begin
            $display("Test 5b Failed: rs1_data (x4) = %h", rs1_data);
        end else begin
            $display("Test 5b Passed: rs1_data (x4) = %h", rs1_data);
        end
        
        // Read and verify x5
        rs1_addr = 5'd5;
        #CLK_PERIOD;
        if (rs1_data !== 32'h55555555) begin
            $display("Test 5c Failed: rs1_data (x5) = %h", rs1_data);
        end else begin
            $display("Test 5c Passed: rs1_data (x5) = %h", rs1_data);
        end
        
        // Test 6: Reset test
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        
        // Verify registers are reset to 0
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #CLK_PERIOD;
        
        if (rs1_data !== 32'h0 || rs2_data !== 32'h0) begin
            $display("Test 6 Failed: After reset, rs1_data = %h, rs2_data = %h", rs1_data, rs2_data);
        end else begin
            $display("Test 6 Passed: All registers reset to 0");
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("register_file_waveform.vcd");
        $dumpvars(0, Register_File_tb);
    end
    
endmodule
