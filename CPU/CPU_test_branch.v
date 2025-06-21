`timescale 1ns/1ps

module CPU_test_branch();
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
        $dumpfile("cpu_branch_waveform.vcd");
        $dumpvars(0, CPU_test_branch);
        
        // Initialize inputs
        clk = 0;
        reset = 0;
        
        // Load branch test program into memory
        // This is done in the Memory module initialization
        
        // Apply reset
        #2 reset = 1;
        #10 reset = 0;
        
        // Run for some cycles and observe behavior
        $display("Starting CPU Branch Test...");
        $display("Time\tPC\t\tState\tInstruction");
        $display("----------------------------------------------------");
        
        // Monitor PC, state, and instruction for 200 cycles
        repeat (200) begin
            @(posedge clk);
            #1; // Wait a bit after clock edge to let signals settle
            $display("%0t\t%h\t%0d\t%h", $time, pc_current, dut.current_state, dut.instruction);
        end
        
        $display("----------------------------------------------------");
        $display("CPU Branch Test completed");
        
        // Check register values
        $display("\nRegister Values:");
        $display("x1 = %h", dut.register_file.registers[1]);
        $display("x2 = %h", dut.register_file.registers[2]);
        $display("x3 = %h", dut.register_file.registers[3]);
        $display("x4 = %h", dut.register_file.registers[4]);
        $display("x5 = %h", dut.register_file.registers[5]);
        $display("x6 = %h", dut.register_file.registers[6]);
        $display("x7 = %h", dut.register_file.registers[7]);
        
        $finish;
    end
    
    // Monitor memory accesses
    always @(posedge clk) begin
        if (dut.mem_read)
            $display("%0t: Memory read at address %h, data = %h", 
                    $time, dut.memory_address, dut.memory_data_out);
    end
    
    // Monitor register writes
    always @(posedge clk) begin
        if (dut.reg_write && dut.reg_write_addr != 0)
            $display("%0t: Register x%0d write, data = %h", 
                    $time, dut.reg_write_addr, dut.reg_write_data);
    end
    
    // Monitor branch operations
    always @(posedge clk) begin
        if (dut.current_state == 4'h6) // EX_BRANCH state
            $display("%0t: Branch operation, condition = %b, target = %h", 
                    $time, dut.branch_result, dut.alu_result);
    end
    
    // Initialize memory with branch test program
    initial begin
        // Program to test branch operations
        
        // Initialize registers
        // addi x1, x0, 5     # x1 = 5
        dut.memory.memory[0] = 8'h93;
        dut.memory.memory[1] = 8'h00;
        dut.memory.memory[2] = 8'h50;
        dut.memory.memory[3] = 8'h00;
        
        // addi x2, x0, 10    # x2 = 10
        dut.memory.memory[4] = 8'h13;
        dut.memory.memory[5] = 8'h01;
        dut.memory.memory[6] = 8'hA0;
        dut.memory.memory[7] = 8'h00;
        
        // addi x3, x0, 5     # x3 = 5 (same as x1)
        dut.memory.memory[8] = 8'h93;
        dut.memory.memory[9] = 8'h01;
        dut.memory.memory[10] = 8'h50;
        dut.memory.memory[11] = 8'h00;
        
        // addi x4, x0, 0     # x4 = 0 (counter)
        dut.memory.memory[12] = 8'h13;
        dut.memory.memory[13] = 8'h02;
        dut.memory.memory[14] = 8'h00;
        dut.memory.memory[15] = 8'h00;
        
        // Test BEQ (should branch)
        // beq x1, x3, SKIP1  # Branch if x1 == x3 (true)
        dut.memory.memory[16] = 8'h63;
        dut.memory.memory[17] = 8'h84;
        dut.memory.memory[18] = 8'h31;
        dut.memory.memory[19] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[20] = 8'h13;
        dut.memory.memory[21] = 8'h02;
        dut.memory.memory[22] = 8'h12;
        dut.memory.memory[23] = 8'h00;
        
        // SKIP1:
        // Test BNE (should branch)
        // bne x1, x2, SKIP2  # Branch if x1 != x2 (true)
        dut.memory.memory[24] = 8'h63;
        dut.memory.memory[25] = 8'h94;
        dut.memory.memory[26] = 8'h21;
        dut.memory.memory[27] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[28] = 8'h13;
        dut.memory.memory[29] = 8'h02;
        dut.memory.memory[30] = 8'h12;
        dut.memory.memory[31] = 8'h00;
        
        // SKIP2:
        // Test BLT (should branch)
        // blt x1, x2, SKIP3  # Branch if x1 < x2 (true)
        dut.memory.memory[32] = 8'h63;
        dut.memory.memory[33] = 8'h44;
        dut.memory.memory[34] = 8'h21;
        dut.memory.memory[35] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[36] = 8'h13;
        dut.memory.memory[37] = 8'h02;
        dut.memory.memory[38] = 8'h12;
        dut.memory.memory[39] = 8'h00;
        
        // SKIP3:
        // Test BGE (should not branch)
        // bge x1, x2, SKIP4  # Branch if x1 >= x2 (false)
        dut.memory.memory[40] = 8'h63;
        dut.memory.memory[41] = 8'h54;
        dut.memory.memory[42] = 8'h21;
        dut.memory.memory[43] = 8'h00;
        
        // addi x4, x4, 1     # This should execute (x4 = 1)
        dut.memory.memory[44] = 8'h13;
        dut.memory.memory[45] = 8'h02;
        dut.memory.memory[46] = 8'h12;
        dut.memory.memory[47] = 8'h00;
        
        // SKIP4:
        // Test BGE (should branch)
        // bge x1, x3, SKIP5  # Branch if x1 >= x3 (true)
        dut.memory.memory[48] = 8'h63;
        dut.memory.memory[49] = 8'h54;
        dut.memory.memory[50] = 8'h31;
        dut.memory.memory[51] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[52] = 8'h13;
        dut.memory.memory[53] = 8'h02;
        dut.memory.memory[54] = 8'h12;
        dut.memory.memory[55] = 8'h00;
        
        // SKIP5:
        // Test BLTU (should branch)
        // bltu x1, x2, SKIP6 # Branch if x1 < x2 unsigned (true)
        dut.memory.memory[56] = 8'h63;
        dut.memory.memory[57] = 8'h64;
        dut.memory.memory[58] = 8'h21;
        dut.memory.memory[59] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[60] = 8'h13;
        dut.memory.memory[61] = 8'h02;
        dut.memory.memory[62] = 8'h12;
        dut.memory.memory[63] = 8'h00;
        
        // SKIP6:
        // Test BGEU (should not branch)
        // bgeu x1, x2, SKIP7 # Branch if x1 >= x2 unsigned (false)
        dut.memory.memory[64] = 8'h63;
        dut.memory.memory[65] = 8'h74;
        dut.memory.memory[66] = 8'h21;
        dut.memory.memory[67] = 8'h00;
        
        // addi x4, x4, 1     # This should execute (x4 = 2)
        dut.memory.memory[68] = 8'h13;
        dut.memory.memory[69] = 8'h02;
        dut.memory.memory[70] = 8'h12;
        dut.memory.memory[71] = 8'h00;
        
        // SKIP7:
        // Test JAL
        // jal x5, SKIP8      # Jump and link (x5 = PC+4)
        dut.memory.memory[72] = 8'hEF;
        dut.memory.memory[73] = 8'h02;
        dut.memory.memory[74] = 8'h00;
        dut.memory.memory[75] = 8'h00;
        
        // addi x4, x4, 1     # This should be skipped
        dut.memory.memory[76] = 8'h13;
        dut.memory.memory[77] = 8'h02;
        dut.memory.memory[78] = 8'h12;
        dut.memory.memory[79] = 8'h00;
        
        // SKIP8:
        // addi x4, x4, 1     # This should execute (x4 = 3)
        dut.memory.memory[80] = 8'h13;
        dut.memory.memory[81] = 8'h02;
        dut.memory.memory[82] = 8'h12;
        dut.memory.memory[83] = 8'h00;
        
        // End program (infinite loop)
        // jal x0, End        # Jump to self (infinite loop)
        dut.memory.memory[84] = 8'hEF;
        dut.memory.memory[85] = 8'h00;
        dut.memory.memory[86] = 8'h00;
        dut.memory.memory[87] = 8'h00;
    end

endmodule 