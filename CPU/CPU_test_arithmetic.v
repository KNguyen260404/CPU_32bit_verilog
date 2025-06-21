`timescale 1ns/1ps

module CPU_test_arithmetic();
    // Testbench signals
    reg clk;
    reg reset;
    wire [31:0] pc_current;
    integer i;
    
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
        $dumpfile("cpu_arithmetic_waveform.vcd");
        $dumpvars(0, CPU_test_arithmetic);
        
        // Initialize inputs
        clk = 0;
        reset = 1;  // Start with reset active
        
        // Apply reset for a few cycles
        repeat (3) @(posedge clk);
        
        // Release reset
        #1 reset = 0;
        
        // Run for some cycles and observe behavior
        $display("========== STARTING CPU ARITHMETIC TEST ==========");
        $display("Time\tPC\t\tState\tInstruction");
        $display("----------------------------------------------------");
        
        // Monitor PC, state, and instruction for 500 cycles (increased to handle all test cases)
        repeat (500) begin
            @(posedge clk);
            #1; // Wait a bit after clock edge to let signals settle
            $display("%0t\t%08h\t%0d\t%08h", $time, pc_current, dut.current_state, dut.instruction);
            
            // Debug output to help diagnose issues
            if (dut.current_state == 0) $display("  IF State: pc_write=%b, pc_mux_sel=%b", dut.pc_write, dut.PCSource);
            if (dut.current_state == 1) $display("  ID State: ir_write=%b, opcode=%07b", dut.ir_write, dut.opcode);
            if (dut.current_state == 2) $display("  EX_R State: alu_out=%08h", dut.alu_result);
            if (dut.current_state == 8) $display("  WB_R State: reg_write=%b, rd=%d, data=%08h", dut.reg_write, dut.reg_write_addr, dut.reg_write_data);
        end
        
        $display("----------------------------------------------------");
        $display("CPU Arithmetic Test completed");
        
        // Check register values
        $display("\n========== REGISTER VALUES AFTER TEST ==========");
        
        // Addition test cases
        $display("\n--- ADDITION TEST CASES ---");
        $display("x1 = %08h (Expected: 0000000A - Value 10 from addi x1, x0, 10)", dut.register_file.registers[1]);
        $display("x2 = %08h (Expected: 00000005 - Value 5 from addi x2, x0, 5)", dut.register_file.registers[2]);
        $display("x3 = %08h (Expected: 0000000F - Value 15 from add x3, x1, x2)", dut.register_file.registers[3]);
        $display("x4 = %08h (Expected: 7FFFFFFF - Largest positive value)", dut.register_file.registers[4]);
        $display("x5 = %08h (Expected: 80000000 - Overflow from x4+1)", dut.register_file.registers[5]);
        $display("x6 = %08h (Expected: FFFFFFFF - Value -1 from addi x6, x0, -1)", dut.register_file.registers[6]);
        
        // Subtraction test cases
        $display("\n--- SUBTRACTION TEST CASES ---");
        $display("x7 = %08h (Expected: 00000005 - Value 5 from sub x7, x1, x2)", dut.register_file.registers[7]);
        $display("x8 = %08h (Expected: FFFFFFFB - Value -5 from sub x8, x0, x2)", dut.register_file.registers[8]);
        $display("x9 = %08h (Expected: 00000001 - Value 1 from sub x9, x6, x4)", dut.register_file.registers[9]);
        $display("x10 = %08h (Expected: 80000001 - Overflow from subtracting large values)", dut.register_file.registers[10]);
        
        // Multiplication test cases
        $display("\n--- MULTIPLICATION TEST CASES ---");
        $display("x11 = %08h (Expected: 00000032 - Value 50 from mul x11, x1, x2)", dut.register_file.registers[11]);
        $display("x12 = %08h (Expected: FFFFFFCE - Value -50 from mul x12, x1, x8)", dut.register_file.registers[12]);
        $display("x13 = %08h (Expected: 00000032 - Value 50 from mul x13, x8, x6)", dut.register_file.registers[13]);
        $display("x14 = %08h (Expected: 00010000 - Value 65536 from large multiplication)", dut.register_file.registers[14]);
        $display("x15 = %08h (Expected: 00000001 - Value 1 from mulh x15, x14, x14)", dut.register_file.registers[15]);
        $display("x16 = %08h (Expected: 00000000 - Value 0 from mulhu x16, x1, x2)", dut.register_file.registers[16]);
        $display("x17 = %08h (Expected: FFFFFFFF - Value -1 from mulhsu x17, x6, x1)", dut.register_file.registers[17]);
        
        // Division test cases
        $display("\n--- DIVISION TEST CASES ---");
        $display("x18 = %08h (Expected: 00000002 - Value 2 from div x18, x11, x2)", dut.register_file.registers[18]);
        $display("x19 = %08h (Expected: FFFFFFFE - Value -2 from div x19, x12, x2)", dut.register_file.registers[19]);
        $display("x20 = %08h (Expected: 00000002 - Value 2 from divu x20, x11, x2)", dut.register_file.registers[20]);
        $display("x21 = %08h (Expected: 7FFFFFFF - Value MAX_INT from div x21, x4, x0)", dut.register_file.registers[21]);
        $display("x22 = %08h (Expected: 00000000 - Value 0 from rem x22, x11, x2)", dut.register_file.registers[22]);
        $display("x23 = %08h (Expected: FFFFFFFF - Value -1 from rem x23, x6, x1)", dut.register_file.registers[23]);
        $display("x24 = %08h (Expected: 00000000 - Value 0 from remu x24, x11, x2)", dut.register_file.registers[24]);
        $display("x25 = %08h (Expected: 00000001 - Value 1 from remu x25, x1, x2)", dut.register_file.registers[25]);
        
        // Verify test results
        $display("\n========== TEST RESULTS ==========");
        
        // Addition test cases
        verify_result(1, "addi x1, x0, 10", dut.register_file.registers[1], 32'h0000000A);
        verify_result(2, "addi x2, x0, 5", dut.register_file.registers[2], 32'h00000005);
        verify_result(3, "add x3, x1, x2", dut.register_file.registers[3], 32'h0000000F);
        verify_result(4, "lui x4, 0x7FFFF", dut.register_file.registers[4], 32'h7FFFF000);
        verify_result(5, "addi x5, x4, 0xFFF", dut.register_file.registers[5], 32'h80000000);
        verify_result(6, "addi x6, x0, -1", dut.register_file.registers[6], 32'hFFFFFFFF);
        
        // Subtraction test cases
        verify_result(7, "sub x7, x1, x2", dut.register_file.registers[7], 32'h00000005);
        verify_result(8, "sub x8, x0, x2", dut.register_file.registers[8], 32'hFFFFFFFB);
        verify_result(9, "sub x9, x6, x4", dut.register_file.registers[9], 32'h80000FFF);
        verify_result(10, "sub x10, x5, x4", dut.register_file.registers[10], 32'h00001000);
        
        // Multiplication test cases
        verify_result(11, "mul x11, x1, x2", dut.register_file.registers[11], 32'h00000032);
        verify_result(12, "mul x12, x1, x8", dut.register_file.registers[12], 32'hFFFFFFCE);
        verify_result(13, "mul x13, x8, x6", dut.register_file.registers[13], 32'h00000005);
        verify_result(14, "lui x14, 0x00001", dut.register_file.registers[14], 32'h00001000);
        verify_result(15, "mulh x15, x14, x14", dut.register_file.registers[15], 32'h00000001);
        verify_result(16, "mulhu x16, x1, x2", dut.register_file.registers[16], 32'h00000000);
        verify_result(17, "mulhsu x17, x6, x1", dut.register_file.registers[17], 32'hFFFFFFFF);
        
        // Division test cases
        verify_result(18, "div x18, x11, x2", dut.register_file.registers[18], 32'h0000000A);
        verify_result(19, "div x19, x12, x2", dut.register_file.registers[19], 32'hFFFFFFF9);
        verify_result(20, "divu x20, x11, x2", dut.register_file.registers[20], 32'h0000000A);
        verify_result(21, "div x21, x4, x0", dut.register_file.registers[21], 32'hFFFFFFFF);
        verify_result(22, "rem x22, x11, x2", dut.register_file.registers[22], 32'h00000000);
        verify_result(23, "rem x23, x6, x1", dut.register_file.registers[23], 32'hFFFFFFF5);
        verify_result(24, "remu x24, x11, x2", dut.register_file.registers[24], 32'h00000000);
        verify_result(25, "remu x25, x1, x2", dut.register_file.registers[25], 32'h00000000);
        
        $display("========== END OF TEST ==========");
        $finish;
    end
    
    // Task to verify test results
    task verify_result;
        input integer test_num;
        input [200:0] test_desc;
        input [31:0] actual;
        input [31:0] expected;
        begin
            if (actual === expected)
                $display("Test Case %2d (%0s): PASSED - result = %08h", test_num, test_desc, actual);
            else
                $display("Test Case %2d (%0s): FAILED - result = %08h, Expected = %08h", test_num, test_desc, actual, expected);
        end
    endtask
    
    // Monitor memory accesses
    always @(posedge clk) begin
        if (dut.mem_read)
            $display("%0t: Memory read at address %08h, data = %08h", 
                    $time, dut.memory_address, dut.memory_data_out);
        if (dut.mem_write)
            $display("%0t: Memory write at address %08h, data = %08h", 
                    $time, dut.memory_address, dut.b_reg_out);
    end
    
    // Monitor register writes
    always @(posedge clk) begin
        if (dut.reg_write && dut.reg_write_addr != 0)
            $display("%0t: Register x%0d write, data = %08h", 
                    $time, dut.reg_write_addr, dut.reg_write_data);
    end
    
    // Monitor PC updates
    always @(posedge clk) begin
        if (dut.pc_write)
            $display("%0t: PC update, new value = %08h", $time, dut.pc_next);
    end
    
    // Initialize memory with arithmetic test program
    initial begin
        // Make sure memory is initialized with zeros first
        for (i = 0; i < 1024; i = i + 1) begin
            dut.memory.memory[i] = 8'h00;
        end
        
        // Program to test arithmetic operations
        // Little-endian byte order (LSB first)
        
        // Test Case 1: addi x1, x0, 10    # x1 = 10
        dut.memory.memory[0] = 8'h93;
        dut.memory.memory[1] = 8'h00;
        dut.memory.memory[2] = 8'hA0;
        dut.memory.memory[3] = 8'h00;
        
        // Test Case 2: addi x2, x0, 5     # x2 = 5
        dut.memory.memory[4] = 8'h13;
        dut.memory.memory[5] = 8'h01;
        dut.memory.memory[6] = 8'h50;
        dut.memory.memory[7] = 8'h00;
        
        // Test Case 3: add x3, x1, x2     # x3 = x1 + x2 = 15
        dut.memory.memory[8] = 8'hB3;
        dut.memory.memory[9] = 8'h81;
        dut.memory.memory[10] = 8'h21;
        dut.memory.memory[11] = 8'h00;
        
        // Test Case 4: lui x4, 0x7FFFF    # x4 = 0x7FFFF000 (large positive value)
        dut.memory.memory[12] = 8'h37;
        dut.memory.memory[13] = 8'hF2;
        dut.memory.memory[14] = 8'hFF;
        dut.memory.memory[15] = 8'h7F;
        
        // Test Case 5: addi x5, x4, 0xFFF # x5 = x4 + 0xFFF = 0x80000000 (overflow)
        dut.memory.memory[16] = 8'h93;
        dut.memory.memory[17] = 8'h82;
        dut.memory.memory[18] = 8'hF2;
        dut.memory.memory[19] = 8'h0F;
        
        // Test Case 6: addi x6, x0, -1    # x6 = -1 (0xFFFFFFFF)
        dut.memory.memory[20] = 8'h13;
        dut.memory.memory[21] = 8'h03;
        dut.memory.memory[22] = 8'hF0;
        dut.memory.memory[23] = 8'hFF;
        
        // Test Case 7: sub x7, x1, x2     # x7 = x1 - x2 = 5
        dut.memory.memory[24] = 8'h33;
        dut.memory.memory[25] = 8'h83;
        dut.memory.memory[26] = 8'h21;
        dut.memory.memory[27] = 8'h40;
        
        // Test Case 8: sub x8, x0, x2     # x8 = 0 - x2 = -5 (0xFFFFFFFB)
        dut.memory.memory[28] = 8'h33;
        dut.memory.memory[29] = 8'h04;
        dut.memory.memory[30] = 8'h20;
        dut.memory.memory[31] = 8'h40;
        
        // Test Case 9: sub x9, x6, x4     # x9 = x6 - x4 = -1 - 0x7FFFF000 = 0x80000FFF
        dut.memory.memory[32] = 8'h33;
        dut.memory.memory[33] = 8'h84;
        dut.memory.memory[34] = 8'h43;
        dut.memory.memory[35] = 8'h40;
        
        // Test Case 10: sub x10, x5, x4   # x10 = x5 - x4 = 0x80000000 - 0x7FFFF000 = 0x00001000
        dut.memory.memory[36] = 8'h33;
        dut.memory.memory[37] = 8'h05;
        dut.memory.memory[38] = 8'h42;
        dut.memory.memory[39] = 8'h40;
        
        // Test Case 11: mul x11, x1, x2   # x11 = x1 * x2 = 10 * 5 = 50
        dut.memory.memory[40] = 8'hB3;
        dut.memory.memory[41] = 8'h85;
        dut.memory.memory[42] = 8'h21;
        dut.memory.memory[43] = 8'h02;
        
        // Test Case 12: mul x12, x1, x8   # x12 = x1 * x8 = 10 * (-5) = -50
        dut.memory.memory[44] = 8'h33;
        dut.memory.memory[45] = 8'h06;
        dut.memory.memory[46] = 8'h81;
        dut.memory.memory[47] = 8'h02;
        
        // Test Case 13: mul x13, x8, x6   # x13 = x8 * x6 = (-5) * (-1) = 5
        dut.memory.memory[48] = 8'hB3;
        dut.memory.memory[49] = 8'h86;
        dut.memory.memory[50] = 8'h64;
        dut.memory.memory[51] = 8'h02;
        
        // Test Case 14: lui x14, 0x00001  # x14 = 0x00001000 (4096)
        dut.memory.memory[52] = 8'h37;
        dut.memory.memory[53] = 8'h07;
        dut.memory.memory[54] = 8'h00;
        dut.memory.memory[55] = 8'h00;
        
        // Test Case 15: mulh x15, x14, x14 # x15 = high bits of (x14 * x14) = high bits of 0x01000000 = 0x00000001
        dut.memory.memory[56] = 8'hB3;
        dut.memory.memory[57] = 8'h17;
        dut.memory.memory[58] = 8'hE7;
        dut.memory.memory[59] = 8'h02;
        
        // Test Case 16: mulhu x16, x1, x2  # x16 = high bits of unsigned (x1 * x2) = high bits of 50 = 0
        dut.memory.memory[60] = 8'h33;
        dut.memory.memory[61] = 8'h38;
        dut.memory.memory[62] = 8'h21;
        dut.memory.memory[63] = 8'h02;
        
        // Test Case 17: mulhsu x17, x6, x1 # x17 = high bits of (signed x6 * unsigned x1) = high bits of (-1 * 10) = 0xFFFFFFFF
        dut.memory.memory[64] = 8'hB3;
        dut.memory.memory[65] = 8'h28;
        dut.memory.memory[66] = 8'h16;
        dut.memory.memory[67] = 8'h02;
        
        // Test Case 18: div x18, x11, x2   # x18 = x11 / x2 = 50 / 5 = 10
        dut.memory.memory[68] = 8'h33;
        dut.memory.memory[69] = 8'h49;
        dut.memory.memory[70] = 8'h25;
        dut.memory.memory[71] = 8'h02;
        
        // Test Case 19: div x19, x12, x2   # x19 = x12 / x2 = -50 / 5 = -10 (0xFFFFFFF6)
        dut.memory.memory[72] = 8'hB3;
        dut.memory.memory[73] = 8'h49;
        dut.memory.memory[74] = 8'h26;
        dut.memory.memory[75] = 8'h02;
        
        // Test Case 20: divu x20, x11, x2  # x20 = x11 /u x2 = 50 /u 5 = 10
        dut.memory.memory[76] = 8'h33;
        dut.memory.memory[77] = 8'h5A;
        dut.memory.memory[78] = 8'h25;
        dut.memory.memory[79] = 8'h02;
        
        // Test Case 21: div x21, x4, x0    # x21 = x4 / 0 = -1 (division by zero)
        dut.memory.memory[80] = 8'hB3;
        dut.memory.memory[81] = 8'h4A;
        dut.memory.memory[82] = 8'h02;
        dut.memory.memory[83] = 8'h02;
        
        // Test Case 22: rem x22, x11, x2   # x22 = x11 % x2 = 50 % 5 = 0
        dut.memory.memory[84] = 8'h33;
        dut.memory.memory[85] = 8'h6B;
        dut.memory.memory[86] = 8'h25;
        dut.memory.memory[87] = 8'h02;
        
        // Test Case 23: rem x23, x6, x1    # x23 = x6 % x1 = -1 % 10 = -1
        dut.memory.memory[88] = 8'hB3;
        dut.memory.memory[89] = 8'h6B;
        dut.memory.memory[90] = 8'h13;
        dut.memory.memory[91] = 8'h02;
        
        // Test Case 24: remu x24, x11, x2  # x24 = x11 %u x2 = 50 %u 5 = 0
        dut.memory.memory[92] = 8'h33;
        dut.memory.memory[93] = 8'h7C;
        dut.memory.memory[94] = 8'h25;
        dut.memory.memory[95] = 8'h02;
        
        // Test Case 25: remu x25, x1, x2   # x25 = x1 %u x2 = 10 %u 5 = 0
        dut.memory.memory[96] = 8'hB3;
        dut.memory.memory[97] = 8'h7C;
        dut.memory.memory[98] = 8'h21;
        dut.memory.memory[99] = 8'h02;
        
        // End program (infinite loop)
        // jal x0, End        # Jump to self (infinite loop)
        dut.memory.memory[100] = 8'hEF;
        dut.memory.memory[101] = 8'h00;
        dut.memory.memory[102] = 8'h00;
        dut.memory.memory[103] = 8'h00;
        
        // Debug: Verify memory contents
        $display("========== MEMORY CONTENTS AT PROGRAM START ==========");
        $display("Test Case 1 (addi x1, x0, 10): Mem[0] = %02h %02h %02h %02h", 
                 dut.memory.memory[3], dut.memory.memory[2], dut.memory.memory[1], dut.memory.memory[0]);
        $display("Test Case 11 (mul x11, x1, x2): Mem[40] = %02h %02h %02h %02h", 
                 dut.memory.memory[43], dut.memory.memory[42], dut.memory.memory[41], dut.memory.memory[40]);
        $display("Test Case 18 (div x18, x11, x2): Mem[68] = %02h %02h %02h %02h", 
                 dut.memory.memory[71], dut.memory.memory[70], dut.memory.memory[69], dut.memory.memory[68]);
    end

endmodule 