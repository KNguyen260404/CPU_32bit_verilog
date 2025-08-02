module Timing_Analysis_tb;
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
        $dumpfile("timing_analysis.vcd");
        $dumpvars(0, Timing_Analysis_tb);
        
        $display("TIMING ANALYSIS FOR ADD INSTRUCTION");
        $display("=====================================");
        
        clk = 0; reset = 1;
        #10; reset = 0; #5;
        
        // Clear memory
        for (i = 0; i < 1024; i = i + 1) begin
            dut.imem.imem[i] = 32'h00000013; // nop
        end
        
        // Load ADD test (like comprehensive test)
        dut.imem.imem[0] = 32'h00a00093;  // addi x1, x0, 10
        dut.imem.imem[1] = 32'h00500113;  // addi x2, x0, 5  
        dut.imem.imem[2] = 32'h002081b3;  // add x3, x1, x2
        
        // Reset like comprehensive test
        #5; reset = 1; #20; reset = 0; #20;
        
        // Monitor at different timings
        #50;  $display("Time  50ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 100ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 150ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 200ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 250ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 300ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 350ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        #50;  $display("Time 400ns: x1=%h x2=%h x3=%h PC=%h", dut.register_file.registers[1], dut.register_file.registers[2], dut.register_file.registers[3], pc_current);
        
        if (dut.register_file.registers[3] == 32'h0000000f) begin
            $display("✅ ADD completed successfully");
        end else begin
            $display("❌ ADD never completed - pipeline issue");
        end
        
        $finish;
    end
endmodule
