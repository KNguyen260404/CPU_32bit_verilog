// Fast Control Unit for pipeline CPU
// Optimized lookup table instead of complex FSM
// Single cycle decode for 1GHz operation

module ControlUnit_Fast(
    input  wire [6:0] opcode,
    output reg  [11:0] control_signals
);

    // Control signal bit positions [11:0]
    // [11]    - reg_write
    // [10]    - mem_to_reg  
    // [9]     - mem_read
    // [8]     - mem_write
    // [7]     - branch
    // [6]     - jump
    // [5:4]   - alu_src (1: use immediate, 0: use rs2) (1: use PC, 0: use rs1)
    // [3:2]   - alu_op
    // [1:0]   - pc_src

    // RISC-V Opcodes
    localparam OP_LUI     = 7'b0110111;  // Load Upper Immediate
    localparam OP_AUIPC   = 7'b0010111;  // Add Upper Immediate to PC
    localparam OP_JAL     = 7'b1101111;  // Jump and Link
    localparam OP_JALR    = 7'b1100111;  // Jump and Link Register
    localparam OP_BRANCH  = 7'b1100011;  // Branch instructions
    localparam OP_LOAD    = 7'b0000011;  // Load instructions
    localparam OP_STORE   = 7'b0100011;  // Store instructions
    localparam OP_IMM     = 7'b0010011;  // Immediate instructions
    localparam OP_REG     = 7'b0110011;  // Register instructions

    // Fast combinational decode
    always @(*) begin
        case (opcode)
            OP_LUI: begin
                control_signals = 12'b100000001101;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=0, alu_src=00, alu_op=11, pc_src=01
            end
            
            OP_AUIPC: begin
                control_signals = 12'b100000111101;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=0, alu_src=11, alu_op=11, pc_src=01
            end
            
            OP_JAL: begin
                control_signals = 12'b100001000010;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=1, alu_src=00, alu_op=00, pc_src=10
            end
            
            OP_JALR: begin
                control_signals = 12'b100001010010;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=1, alu_src=01, alu_op=00, pc_src=10
            end
            
            OP_BRANCH: begin
                control_signals = 12'b000010010100;
                // reg_write=0, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=1, jump=0, alu_src=01, alu_op=01, pc_src=00
            end
            
            OP_LOAD: begin
                control_signals = 12'b110100010000;
                // reg_write=1, mem_to_reg=1, mem_read=1, mem_write=0
                // branch=0, jump=0, alu_src=01, alu_op=00, pc_src=00
            end
            
            OP_STORE: begin
                control_signals = 12'b000001010000;
                // reg_write=0, mem_to_reg=0, mem_read=0, mem_write=1
                // branch=0, jump=0, alu_src=01, alu_op=00, pc_src=00
            end
            
            OP_IMM: begin
                control_signals = 12'b100000011001;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=0, alu_src=01, alu_op=10, pc_src=01
            end
            
            OP_REG: begin
                control_signals = 12'b100000001000;
                // reg_write=1, mem_to_reg=0, mem_read=0, mem_write=0
                // branch=0, jump=0, alu_src=00, alu_op=10, pc_src=00
            end
            
            default: begin
                control_signals = 12'b000000000000;  // NOP
            end
        endcase
    end

endmodule
