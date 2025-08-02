module Isolated_Test5_tb;
    reg clk = 0;
    reg reset = 1;
    
    wire [31:0] pc_current;
    wire [31:0] instruction_debug;
    wire [3:0] pipeline_state;
    wire [31:0] debug_reg1, debug_reg2, debug_reg3;
    
    CPU_Pipeline_Fixed dut (
        .clk(clk),
        .reset(reset),
        .pc_current(pc_current),
        .instruction_debug(instruction_debug),
        .pipeline_state(pipeline_state),
        .debug_reg1(debug_reg1),
        .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3)
    );
    
    always #5 clk = ~clk;
    
    integer i;
    
    initial begin
        $dumpfile("isolated_test5.vcd");
        $dumpvars(0, Isolated_Test5_tb);
        
        $display("ISOLATED TEST 5 ONLY");
        
        clk = 0; reset = 1;
        
        // FRESH START - Clear everything
        #10; reset = 0; #5;
        
        // Clear ALL instruction memory 
        for (i = 0; i < 1024; i = i + 1) begin
            dut.imem.imem[i] = 32'h00000013; // nop
        end
        
        // Load ONLY TEST 5 instructions
        dut.imem.imem[0] = 32'h00a00093;  // addi x1, x0, 10
        dut.imem.imem[1] = 32'h00500113;  // addi x2, x0, 5
        dut.imem.imem[2] = 32'h002081b3;  // add x3, x1, x2
        
        // Full reset sequence
        #1; reset = 1; #10; reset = 0; #10;
        
        // Wait much longer
        #200;
        
        $display("Results after 200ns:");
        $display("x1 = %h (expected: 0000000a)", dut.register_file.registers[1]);
        $display("x2 = %h (expected: 00000005)", dut.register_file.registers[2]);
        $display("x3 = %h (expected: 0000000f)", dut.register_file.registers[3]);
        
        // Check for any other registers that shouldn't have values
        for (i = 4; i < 32; i = i + 1) begin
            if (dut.register_file.registers[i] != 32'h00000000) begin
                $display("UNEXPECTED: x%0d = %h", i, dut.register_file.registers[i]);
            end
        end
        
        if (dut.register_file.registers[1] == 32'h0000000a &&
            dut.register_file.registers[2] == 32'h00000005 &&
            dut.register_file.registers[3] == 32'h0000000f) begin
            $display("✅ ISOLATED TEST 5 PASSED!");
        end else begin
            $display("❌ ISOLATED TEST 5 FAILED!");
            $display("This indicates a fundamental CPU bug, not test interference");
            
            // Debug PC and instruction execution
            $display("PC = %h", pc_current);
            $display("Current instruction = %h", instruction_debug);
        end
        
        $finish;
    end
endmodule
