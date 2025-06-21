`timescale 1ns/1ps

module CPU_tb();
    // Testbench signals
    reg clk;
    reg reset;
    wire [31:0] pc_current;
    
    // Instantiate the CPU
    CPU dut (
        .clk(clk),
        .reset(reset),
        .pc_current(pc_current)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;  // 10ns period clock (100MHz)
    end
    
    // Test procedure
    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, CPU_tb);
        
        // Initialize inputs
        clk = 0;
        reset = 0;
        
        // Apply reset
        #2 reset = 1;
        #10 reset = 0;
        
        // Run for some cycles and observe behavior
        $display("Starting CPU simulation...");
        $display("Time\tPC\t\tState");
        $display("------------------------------------");
        
        // Monitor PC and state for 50 cycles
        repeat (50) begin
            @(posedge clk);
            #1; // Wait a bit after clock edge to let signals settle
            $display("%0t\t%h\t%0d", $time, pc_current, dut.current_state);
        end
        
        $display("------------------------------------");
        $display("CPU simulation completed");
        $finish;
    end
    
    // Optional: Monitor memory accesses
    always @(posedge clk) begin
        if (dut.mem_read)
            $display("%0t: Memory read at address %h, data = %h", 
                    $time, dut.memory_address, dut.memory_data_out);
        if (dut.mem_write)
            $display("%0t: Memory write at address %h, data = %h", 
                    $time, dut.memory_address, dut.b_reg_out);
    end
    
    // Optional: Monitor register writes
    always @(posedge clk) begin
        if (dut.reg_write && dut.reg_write_addr != 0)
            $display("%0t: Register x%0d write, data = %h", 
                    $time, dut.reg_write_addr, dut.reg_write_data);
    end
    
    // Optional: Monitor instruction fetch
    always @(posedge clk) begin
        if (dut.ir_write)
            $display("%0t: Instruction fetch: %h", $time, dut.instruction);
    end
    
endmodule
