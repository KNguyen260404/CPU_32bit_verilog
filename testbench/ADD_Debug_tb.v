module ADD_Debug_tb;
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
    
    integer i, cycle;
    
    initial begin
        $dumpfile("add_debug.vcd");
        $dumpvars(0, ADD_Debug_tb);
        
        cycle = 0;
        clk = 0; reset = 1;
        #20; reset = 0; #10;
        
        $display("ADD INSTRUCTION DEBUG - CYCLE BY CYCLE");
        $display("=====================================");
        
        // Clear memory
        for (i = 0; i < 1024; i = i + 1) begin
            dut.imem.imem[i] = 32'h00000013; // nop
        end
        
        // Load ONLY ADD test instructions
        dut.imem.imem[0] = 32'h00a00093;  // addi x1, x0, 10
        dut.imem.imem[1] = 32'h00500113;  // addi x2, x0, 5
        dut.imem.imem[2] = 32'h002081b3;  // add x3, x1, x2
        dut.imem.imem[3] = 32'h00000013;  // nop
        dut.imem.imem[4] = 32'h00000013;  // nop
        
        // Final reset
        #5; reset = 1; #20; reset = 0; #10;
        
        $display("Instructions loaded:");
        $display("  [0] = %h (ADDI x1, x0, 10)", dut.imem.imem[0]);
        $display("  [1] = %h (ADDI x2, x0, 5)",  dut.imem.imem[1]);
        $display("  [2] = %h (ADD x3, x1, x2)",  dut.imem.imem[2]);
        $display("");
        
        // Monitor execution cycle by cycle
        for (cycle = 1; cycle <= 15; cycle = cycle + 1) begin
            @(posedge clk);
            
            $display("CYCLE %2d: PC=%h INST=%h x1=%h x2=%h x3=%h", 
                    cycle, pc_current, instruction_debug,
                    dut.register_file.registers[1],
                    dut.register_file.registers[2], 
                    dut.register_file.registers[3]);
            
            // Debug pipeline registers for ADD instruction
            if (dut.if_id_instruction == 32'h002081b3) begin
                $display("         ADD in ID stage");
            end
            if (dut.id_ex_control[11:0] != 12'h000 && 
                dut.id_ex_rd_addr == 5'd3) begin
                $display("         ADD in EX stage: rd=x3, control=%h", dut.id_ex_control);
            end
            if (dut.ex_mem_rd_addr == 5'd3 && dut.ex_mem_valid) begin
                $display("         ADD in MEM stage: result=%h", dut.ex_mem_alu_result);
            end
            if (dut.mem_wb_rd_addr == 5'd3 && dut.mem_wb_valid) begin
                $display("         ADD in WB stage: writing %h to x3", dut.mem_wb_alu_result);
            end
        end
        
        $display("");
        $display("FINAL RESULTS:");
        $display("x1 = %h (expected: 0000000a)", dut.register_file.registers[1]);
        $display("x2 = %h (expected: 00000005)", dut.register_file.registers[2]);
        $display("x3 = %h (expected: 0000000f)", dut.register_file.registers[3]);
        
        if (dut.register_file.registers[3] == 32'h0000000f) begin
            $display("✅ ADD INSTRUCTION WORKS!");
        end else begin
            $display("❌ ADD INSTRUCTION FAILED - PIPELINE ISSUE DETECTED");
        end
        
        $finish;
    end
endmodule
