module ALUControl_Fast(
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire funct7_bit30,
    output reg [3:0] alu_control
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0010; // ADD for load/store
            2'b01: alu_control = 4'b0110; // SUB for branch
            2'b10: begin // R-type and I-type ALU operations
                case (funct3)
                    3'b000: alu_control = (funct7_bit30) ? 4'b0110 : 4'b0010; // SUB : ADD
                    3'b001: alu_control = 4'b0100; // SLL
                    3'b010: alu_control = 4'b0111; // SLT
                    3'b011: alu_control = 4'b1000; // SLTU
                    3'b100: alu_control = 4'b0001; // XOR
                    3'b101: alu_control = (funct7_bit30) ? 4'b0101 : 4'b0011; // SRA : SRL
                    3'b110: alu_control = 4'b0000; // OR
                    3'b111: alu_control = 4'b1001; // AND
                endcase
            end
            2'b11: alu_control = 4'b0010; // ADD for JAL/JALR
        endcase
    end

endmodule
