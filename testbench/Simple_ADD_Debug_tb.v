module Simple_ADD_Debug_tb;
    // Clock and reset
    reg clk = 0;
    reg reset = 1;
    
    // CPU instantiation
    wire [31:0] pc_current;
    wire [31:0] instruction_debug;
    wire [3:0] pipeline_state;
    wire [31:0] debug_reg1, debug_reg2, debug_reg3;
    
    CPU_Pipeline_Fixed cpu (
        .clk(clk),
        .reset(reset),
        .pc_current(pc_current),
        .instruction_debug(instruction_debug),
        .pipeline_state(pipeline_state),
        .debug_reg1(debug_reg1),
        .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("simple_add_debug.vcd");
        $dumpvars(0, Simple_ADD_Debug_tb);
        
        // Reset release
        #20;
        reset = 0;
        
        // Initialize memory with simple ADD test
        // ADDI x1, x0, 10   -> Load 10 into x1
        cpu.imem.imem[0] = 32'h00A00093; // ADDI x1, x0, 10
        
        // ADDI x2, x0, 5    -> Load 5 into x2  
        cpu.imem.imem[1] = 32'h00500113; // ADDI x2, x0, 5
        
        // ADD x3, x1, x2    -> x3 = x1 + x2 = 15
        cpu.imem.imem[2] = 32'h002081B3; // ADD x3, x1, x2
        
        // NOP (ADDI x0, x0, 0)
        cpu.imem.imem[3] = 32'h00000013; 
        cpu.imem.imem[4] = 32'h00000013;
        cpu.imem.imem[5] = 32'h00000013;
        
        $display("========================================");
        $display("SIMPLE ADD INSTRUCTION DEBUG");
        $display("========================================");
        $display("Test: ADDI x1,x0,10; ADDI x2,x0,5; ADD x3,x1,x2");
        $display("Expected: x1=10, x2=5, x3=15");
        $display("========================================");
        
        // Wait for pipeline to execute
        repeat(15) @(posedge clk);
        
        // Check results
        $display("Cycle %0d Results:", $time/10);
        $display("x1 = %h (expected: %h)", cpu.register_file.registers[1], 32'h0000000A);
        $display("x2 = %h (expected: %h)", cpu.register_file.registers[2], 32'h00000005);
        $display("x3 = %h (expected: %h)", cpu.register_file.registers[3], 32'h0000000F);
        
        // Check if test passed
        if (cpu.register_file.registers[1] == 32'h0000000A && 
            cpu.register_file.registers[2] == 32'h00000005 && 
            cpu.register_file.registers[3] == 32'h0000000F) begin
            $display("✅ ADD TEST PASSED!");
        end else begin
            $display("❌ ADD TEST FAILED!");
            $display("  Problem detected in register-register ADD operation");
        end
        
        $display("========================================");
        $finish;
    end
    
endmodule
