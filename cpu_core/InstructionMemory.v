module InstructionMemory (
    input [31:0] address,
    output [31:0] instruction
);

    reg [31:0] instruction_mem [0:1023];
    
    // Initialize instruction memory with some test instructions
    initial begin
        // Simple test program: ADDI x1, x0, 5; ADDI x2, x0, 10; ADD x3, x1, x2
        instruction_mem[0] = 32'h00500093;  // ADDI x1, x0, 5
        instruction_mem[1] = 32'h00a00113;  // ADDI x2, x0, 10  
        instruction_mem[2] = 32'h002081b3;  // ADD x3, x1, x2
        instruction_mem[3] = 32'h00000013;  // NOP (ADDI x0, x0, 0)
        // Initialize rest to NOP
        for (integer i = 4; i < 1024; i = i + 1) begin
            instruction_mem[i] = 32'h00000013;  // NOP
        end
    end
    
    assign instruction = instruction_mem[address[11:2]];

endmodule
