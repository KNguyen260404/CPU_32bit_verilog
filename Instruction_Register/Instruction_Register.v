module Instruction_Register (
    input wire clk,
    input wire reset,
    input wire ir_write,
    input wire [31:0] instruction_in,
    output wire [31:0] instruction_out,
    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [2:0] funct3,
    output wire [6:0] funct7
);

    // Internal register to store the instruction
    reg [31:0] instruction_reg;

    // Synchronous update of instruction register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_reg <= 32'h0; // Reset to NOP instruction
        end else if (ir_write) begin
            instruction_reg <= instruction_in; // Update when ir_write is enabled
        end
    end

    // Output the full instruction
    assign instruction_out = instruction_reg;

    // Decode instruction fields based on RISC-V format
    // RISC-V instruction format: [31:25](funct7) [24:20](rs2) [19:15](rs1) [14:12](funct3) [11:7](rd) [6:0](opcode)
    assign opcode = instruction_reg[6:0];
    assign rd = instruction_reg[11:7];
    assign rs1 = instruction_reg[19:15];
    assign rs2 = instruction_reg[24:20];
    assign funct3 = instruction_reg[14:12];
    assign funct7 = instruction_reg[31:25];

endmodule
