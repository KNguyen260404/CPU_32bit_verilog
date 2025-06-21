module Immediate_Generator (
    input wire [31:0] instruction,
    input wire [2:0] imm_type,
    output reg [31:0] immediate
);

    // Define immediate type constants
    localparam I_TYPE = 3'b000;
    localparam S_TYPE = 3'b001;
    localparam B_TYPE = 3'b010;
    localparam U_TYPE = 3'b011;
    localparam J_TYPE = 3'b100;

    // Combinational logic for immediate generation
    always @(*) begin
        case (imm_type)
            // I-type: sign-extended 12-bit immediate
            // Format: imm[11:0] rs1 funct3 rd opcode
            I_TYPE: begin
                // Make sure sign extension is done properly for I-type
                // For negative values, we need to properly sign extend bit 31
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                
                // Check if this is ADDI with opcode 0010011 and funct3 000
                if (instruction[6:0] == 7'b0010011 && instruction[14:12] == 3'b000) begin
                    // Ensure proper sign extension for ADDI
                    immediate = {{20{instruction[31]}}, instruction[31:20]};
                end
            end
            
            // S-type: sign-extended 12-bit immediate for store
            // Format: imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
            // In S-type, the immediate is encoded in this order in the instruction:
            // instruction[31:25] -> imm[11:5]
            // instruction[11:7] -> imm[4:0]
            S_TYPE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            // B-type: sign-extended 13-bit immediate for branch (LSB is always 0)
            // Format: imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode
            B_TYPE: begin
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                             instruction[30:25], instruction[11:8], 1'b0};
            end
            
            // U-type: 20-bit immediate, shifted left by 12 bits
            // Format: imm[31:12] rd opcode
            U_TYPE: begin
                // For LUI and AUIPC, we need the immediate in the upper 20 bits
                // The lower 12 bits are set to 0
                immediate = {instruction[31:12], 12'b0};
                
                // Check if this is for LUI opcode (0110111)
                if (instruction[6:0] == 7'b0110111) begin
                    // For LUI, ensure the value is exactly as specified without sign extension
                    immediate = {instruction[31:12], 12'b0};
                end
            end
            
            // J-type: sign-extended 21-bit immediate for jump (LSB is always 0)
            // Format: imm[20|10:1|11|19:12] rd opcode
            // In J-type, the immediate is encoded in this order in the instruction:
            // instruction[31] -> imm[20] (sign bit)
            // instruction[30:21] -> imm[10:1]
            // instruction[20] -> imm[11]
            // instruction[19:12] -> imm[19:12]
            J_TYPE: begin
                // Fixed bit ordering for J-type immediate
                immediate = {{11{instruction[31]}}, instruction[31], 
                             instruction[19:12], instruction[20], 
                             instruction[30:21], 1'b0};
            end
            
            // Default case
            default: begin
                immediate = 32'h0;
            end
        endcase
    end

endmodule
