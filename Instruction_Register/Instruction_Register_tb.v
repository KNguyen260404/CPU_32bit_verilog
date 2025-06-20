module Instruction_Register_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg reset;
    reg ir_write;
    reg [31:0] instruction_in;
    
    // Outputs
    wire [31:0] instruction_out;
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    // Instantiate the Instruction Register
    Instruction_Register dut (
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(instruction_in),
        .instruction_out(instruction_out),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
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
        ir_write = 0;
        instruction_in = 32'h0;
        
        // Apply reset
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;
        
        // Test 1: Write R-type instruction (add x1, x2, x3)
        // R-type format: funct7 rs2 rs1 funct3 rd opcode
        // For add x1, x2, x3: funct7=0000000, rs2=00011(3), rs1=00010(2), funct3=000, rd=00001(1), opcode=0110011
        ir_write = 1;
        instruction_in = 32'h003100B3; // add x1, x2, x3 - correct encoding
        #CLK_PERIOD;
        ir_write = 0;
        #CLK_PERIOD;
        
        // Verify instruction fields
        if (instruction_out !== 32'h003100B3) begin
            $display("Test 1 Failed: instruction_out = %h, expected = %h", instruction_out, 32'h003100B3);
        end else begin
            $display("Test 1 Passed: instruction_out = %h", instruction_out);
        end
        
        if (opcode !== 7'b0110011) begin
            $display("Test 1 Failed: opcode = %b, expected = %b", opcode, 7'b0110011);
        end else begin
            $display("Test 1 Passed: opcode = %b", opcode);
        end
        
        if (rd !== 5'd1) begin
            $display("Test 1 Failed: rd = %d, expected = %d", rd, 5'd1);
        end else begin
            $display("Test 1 Passed: rd = %d", rd);
        end
        
        if (rs1 !== 5'd2) begin
            $display("Test 1 Failed: rs1 = %d, expected = %d", rs1, 5'd2);
        end else begin
            $display("Test 1 Passed: rs1 = %d", rs1);
        end
        
        if (rs2 !== 5'd3) begin
            $display("Test 1 Failed: rs2 = %d, expected = %d", rs2, 5'd3);
        end else begin
            $display("Test 1 Passed: rs2 = %d", rs2);
        end
        
        if (funct3 !== 3'b000) begin
            $display("Test 1 Failed: funct3 = %b, expected = %b", funct3, 3'b000);
        end else begin
            $display("Test 1 Passed: funct3 = %b", funct3);
        end
        
        if (funct7 !== 7'b0000000) begin
            $display("Test 1 Failed: funct7 = %b, expected = %b", funct7, 7'b0000000);
        end else begin
            $display("Test 1 Passed: funct7 = %b", funct7);
        end
        
        // Test 2: Write I-type instruction (addi x4, x5, 42)
        // addi instruction: imm[11:0] rs1 funct3 rd opcode
        // 000000101010 00101 000 00100 0010011
        ir_write = 1;
        instruction_in = 32'h02A28213; // addi x4, x5, 42
        #CLK_PERIOD;
        ir_write = 0;
        #CLK_PERIOD;
        
        // Verify instruction fields
        if (opcode !== 7'b0010011) begin
            $display("Test 2 Failed: opcode = %b, expected = %b", opcode, 7'b0010011);
        end else begin
            $display("Test 2 Passed: opcode = %b", opcode);
        end
        
        if (rd !== 5'd4) begin
            $display("Test 2 Failed: rd = %d, expected = %d", rd, 5'd4);
        end else begin
            $display("Test 2 Passed: rd = %d", rd);
        end
        
        if (rs1 !== 5'd5) begin
            $display("Test 2 Failed: rs1 = %d, expected = %d", rs1, 5'd5);
        end else begin
            $display("Test 2 Passed: rs1 = %d", rs1);
        end
        
        if (funct3 !== 3'b000) begin
            $display("Test 2 Failed: funct3 = %b, expected = %b", funct3, 3'b000);
        end else begin
            $display("Test 2 Passed: funct3 = %b", funct3);
        end
        
        // Test 3: Test ir_write control (should not update when ir_write=0)
        ir_write = 0;
        instruction_in = 32'hFFFFFFFF;
        #CLK_PERIOD;
        
        // Verify instruction didn't change
        if (instruction_out !== 32'h02A28213) begin
            $display("Test 3 Failed: instruction_out = %h, expected = %h", instruction_out, 32'h02A28213);
        end else begin
            $display("Test 3 Passed: instruction didn't change when ir_write=0");
        end
        
        // Test 4: Write S-type instruction (sw x6, 8(x7))
        // S-type: imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
        // S-type format: imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
        // For sw x6, 8(x7): imm=8 (000000001000), rs2=6, rs1=7, funct3=010, opcode=0100011
        // imm[11:5]=0000000, rs2=00110, rs1=00111, funct3=010, imm[4:0]=01000, opcode=0100011
        ir_write = 1;
        instruction_in = 32'h0063A423; // sw x6, 8(x7) - correct encoding
        #CLK_PERIOD;
        ir_write = 0;
        #CLK_PERIOD;
        
        // Verify instruction fields
        if (opcode !== 7'b0100011) begin
            $display("Test 4 Failed: opcode = %b, expected = %b", opcode, 7'b0100011);
        end else begin
            $display("Test 4 Passed: opcode = %b", opcode);
        end
        
        if (rs1 !== 5'd7) begin
            $display("Test 4 Failed: rs1 = %d, expected = %d", rs1, 5'd7);
        end else begin
            $display("Test 4 Passed: rs1 = %d", rs1);
        end
        
        if (rs2 !== 5'd6) begin
            $display("Test 4 Failed: rs2 = %d, expected = %d", rs2, 5'd6);
        end else begin
            $display("Test 4 Passed: rs2 = %d", rs2);
        end
        
        if (funct3 !== 3'b010) begin
            $display("Test 4 Failed: funct3 = %b, expected = %b", funct3, 3'b010);
        end else begin
            $display("Test 4 Passed: funct3 = %b", funct3);
        end
        
        // Test 5: Reset test
        reset = 1;
        #CLK_PERIOD;
        reset = 0;
        #CLK_PERIOD;
        
        // Verify registers are reset to 0
        if (instruction_out !== 32'h0) begin
            $display("Test 5 Failed: After reset, instruction_out = %h, expected = %h", instruction_out, 32'h0);
        end else begin
            $display("Test 5 Passed: instruction_out reset to 0");
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("instruction_register_waveform.vcd");
        $dumpvars(0, Instruction_Register_tb);
    end
    
endmodule
