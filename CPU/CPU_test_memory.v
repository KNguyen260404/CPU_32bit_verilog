`timescale 1ns/1ps

module CPU_test_memory();
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
        $dumpfile("cpu_memory_waveform.vcd");
        $dumpvars(0, CPU_test_memory);
        
        // Initialize inputs
        clk = 0;
        reset = 0;
        
        // Load memory test program into memory
        // This is done in the Memory module initialization
        
        // Apply reset
        #2 reset = 1;
        #10 reset = 0;
        
        // Run for some cycles and observe behavior
        $display("Starting CPU Memory Test...");
        $display("Time\tPC\t\tState\tInstruction");
        $display("----------------------------------------------------");
        
        // Monitor PC, state, and instruction for 150 cycles
        repeat (150) begin
            @(posedge clk);
            #1; // Wait a bit after clock edge to let signals settle
            $display("%0t\t%h\t%0d\t%h", $time, pc_current, dut.current_state, dut.instruction);
        end
        
        $display("----------------------------------------------------");
        $display("CPU Memory Test completed");
        
        // Check register values
        $display("\nRegister Values:");
        $display("x1 = %h", dut.register_file.registers[1]);
        $display("x2 = %h", dut.register_file.registers[2]);
        $display("x3 = %h", dut.register_file.registers[3]);
        $display("x4 = %h", dut.register_file.registers[4]);
        
        // Check memory values
        $display("\nMemory Values:");
        $display("Mem[100] = %h", {dut.memory.memory[103], dut.memory.memory[102], dut.memory.memory[101], dut.memory.memory[100]});
        $display("Mem[104] = %h", {dut.memory.memory[107], dut.memory.memory[106], dut.memory.memory[105], dut.memory.memory[104]});
        $display("Mem[108] = %h", {dut.memory.memory[111], dut.memory.memory[110], dut.memory.memory[109], dut.memory.memory[108]});
        
        $finish;
    end
    
    // Monitor memory accesses
    always @(posedge clk) begin
        if (dut.mem_read)
            $display("%0t: Memory read at address %h, data = %h", 
                    $time, dut.memory_address, dut.memory_data_out);
        if (dut.mem_write)
            $display("%0t: Memory write at address %h, data = %h", 
                    $time, dut.memory_address, dut.b_reg_out);
    end
    
    // Monitor register writes
    always @(posedge clk) begin
        if (dut.reg_write && dut.reg_write_addr != 0)
            $display("%0t: Register x%0d write, data = %h", 
                    $time, dut.reg_write_addr, dut.reg_write_data);
    end
    
    // Initialize memory with memory test program
    initial begin
        // Program to test memory operations
        
        // addi x1, x0, 42    # x1 = 42
        dut.memory.memory[0] = 8'h93;
        dut.memory.memory[1] = 8'h00;
        dut.memory.memory[2] = 8'hA2;
        dut.memory.memory[3] = 8'h02;
        
        // addi x2, x0, 100   # x2 = 100 (memory address)
        dut.memory.memory[4] = 8'h13;
        dut.memory.memory[5] = 8'h01;
        dut.memory.memory[6] = 8'h40;
        dut.memory.memory[7] = 8'h06;
        
        // sw x1, 0(x2)       # Store 42 to address 100
        dut.memory.memory[8] = 8'h23;
        dut.memory.memory[9] = 8'h20;
        dut.memory.memory[10] = 8'h11;
        dut.memory.memory[11] = 8'h00;
        
        // addi x1, x0, 84    # x1 = 84
        dut.memory.memory[12] = 8'h93;
        dut.memory.memory[13] = 8'h00;
        dut.memory.memory[14] = 8'h40;
        dut.memory.memory[15] = 8'h05;
        
        // sw x1, 4(x2)       # Store 84 to address 104
        dut.memory.memory[16] = 8'h23;
        dut.memory.memory[17] = 8'h22;
        dut.memory.memory[18] = 8'h11;
        dut.memory.memory[19] = 8'h00;
        
        // addi x1, x0, 126   # x1 = 126
        dut.memory.memory[20] = 8'h93;
        dut.memory.memory[21] = 8'h00;
        dut.memory.memory[22] = 8'hE0;
        dut.memory.memory[23] = 8'h07;
        
        // sw x1, 8(x2)       # Store 126 to address 108
        dut.memory.memory[24] = 8'h23;
        dut.memory.memory[25] = 8'h24;
        dut.memory.memory[26] = 8'h11;
        dut.memory.memory[27] = 8'h00;
        
        // lw x3, 0(x2)       # Load from address 100 into x3 (should be 42)
        dut.memory.memory[28] = 8'h83;
        dut.memory.memory[29] = 8'h21;
        dut.memory.memory[30] = 8'h01;
        dut.memory.memory[31] = 8'h00;
        
        // lw x4, 4(x2)       # Load from address 104 into x4 (should be 84)
        dut.memory.memory[32] = 8'h03;
        dut.memory.memory[33] = 8'h22;
        dut.memory.memory[34] = 8'h41;
        dut.memory.memory[35] = 8'h00;
        
        // lw x1, 8(x2)       # Load from address 108 into x1 (should be 126)
        dut.memory.memory[36] = 8'h83;
        dut.memory.memory[37] = 8'h20;
        dut.memory.memory[38] = 8'h81;
        dut.memory.memory[39] = 8'h00;
        
        // End program (infinite loop)
        // jal x0, End        # Jump to self (infinite loop)
        dut.memory.memory[40] = 8'hEF;
        dut.memory.memory[41] = 8'h00;
        dut.memory.memory[42] = 8'h00;
        dut.memory.memory[43] = 8'h00;
    end

endmodule 