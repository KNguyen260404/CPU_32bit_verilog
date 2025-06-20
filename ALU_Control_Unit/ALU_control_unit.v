module ALU_control_unit (
    input [1:0] ALUOp,         // Control signal from main control unit
    input [2:0] funct3,        // funct3 field from instruction
    input [6:0] funct7,        // funct7 field from instruction
    output reg [4:0] alu_control // Control signal for ALU (expanded to 5 bits)
);

    // ALU control signal breakdown (for 5-bit control)
    // alu_control[4]:   0 = Arithmetic operation, 1 = Logic operation
    // alu_control[3:2]: Operation type for Arithmetic (00: ADD, 01: SUB, 10: MUL, 11: DIV)
    // alu_control[3:0]: Operation type for Logic (see Logic module)
    // alu_control[0]:   Signed flag for arithmetic operations

    // ALUOp encoding
    // 00: Memory access (add)
    // 01: Branch (subtract)
    // 10: R-type (depends on funct3 and funct7)
    // 11: I-type (depends on funct3)

    // RISC-V funct3 codes for R-type and I-type instructions
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLL     = 3'b001;
    localparam F3_SLT     = 3'b010;
    localparam F3_SLTU    = 3'b011;
    localparam F3_XOR     = 3'b100;
    localparam F3_SRL_SRA = 3'b101;
    localparam F3_OR      = 3'b110;
    localparam F3_AND     = 3'b111;

    // RISC-V funct7 codes
    localparam F7_DEFAULT = 7'b0000000;
    localparam F7_SUB_SRA = 7'b0100000;
    localparam F7_MUL_DIV = 7'b0000001; // For M extension

    // ALU operations (matching ALU module)
    // Arithmetic Operations
    localparam ADD_UNSIGNED = 5'b00000;
    localparam ADD_SIGNED   = 5'b00001;
    localparam SUB_UNSIGNED = 5'b00100;
    localparam SUB_SIGNED   = 5'b00101;
    localparam MUL_UNSIGNED = 5'b01000;
    localparam MUL_SIGNED   = 5'b01001;
    localparam DIV_UNSIGNED = 5'b01100;
    localparam DIV_SIGNED   = 5'b01101;

    // Logic Operations
    localparam AND_OP       = 5'b10000;
    localparam OR_OP        = 5'b10001;
    localparam XOR_OP       = 5'b10010;
    localparam NOT_OP       = 5'b10011;
    localparam SLL_OP       = 5'b10100;
    localparam SRL_OP       = 5'b10101;
    localparam SRA_OP       = 5'b10110;
    localparam NOR_OP       = 5'b10111;
    localparam EQ_OP        = 5'b11000;
    localparam NE_OP        = 5'b11001;
    localparam LT_SIGNED    = 5'b11010;
    localparam GE_SIGNED    = 5'b11011;
    localparam LT_UNSIGNED  = 5'b11100;
    localparam GE_UNSIGNED  = 5'b11101;

    // Combinational logic to determine ALU operation
    always @(*) begin
        case (ALUOp)
            2'b00: alu_control = ADD_UNSIGNED; // Memory access operations use unsigned addition
            
            2'b01: begin // Branch operations
                case (funct3)
                    3'b000: alu_control = EQ_OP;  // BEQ
                    3'b001: alu_control = NE_OP;  // BNE
                    3'b100: alu_control = LT_SIGNED;    // BLT
                    3'b101: alu_control = GE_SIGNED;    // BGE
                    3'b110: alu_control = LT_UNSIGNED;  // BLTU
                    3'b111: alu_control = GE_UNSIGNED;  // BGEU
                    default: alu_control = SUB_UNSIGNED; // Default for branch
                endcase
            end
            
            2'b10: begin // R-type instructions
                case (funct3)
                    F3_ADD_SUB: begin
                        if (funct7 == F7_DEFAULT)
                            alu_control = ADD_SIGNED;   // ADD
                        else if (funct7 == F7_SUB_SRA)
                            alu_control = SUB_SIGNED;   // SUB
                        else if (funct7 == F7_MUL_DIV)
                            alu_control = MUL_SIGNED;   // MUL (M extension)
                        else
                            alu_control = ADD_SIGNED;   // Default to ADD
                    end
                    
                    F3_SLL: alu_control = SLL_OP;      // SLL
                    
                    F3_SLT: alu_control = LT_SIGNED;   // SLT
                    
                    F3_SLTU: alu_control = LT_UNSIGNED; // SLTU
                    
                    F3_XOR: begin
                        if (funct7 == F7_MUL_DIV)
                            alu_control = DIV_SIGNED;   // DIV (M extension)
                        else
                            alu_control = XOR_OP;       // XOR
                    end
                    
                    F3_SRL_SRA: begin
                        if (funct7 == F7_DEFAULT)
                            alu_control = SRL_OP;       // SRL
                        else if (funct7 == F7_SUB_SRA)
                            alu_control = SRA_OP;       // SRA
                        else
                            alu_control = SRL_OP;       // Default to SRL
                    end
                    
                    F3_OR: alu_control = OR_OP;        // OR
                    
                    F3_AND: alu_control = AND_OP;      // AND
                    
                    default: alu_control = ADD_SIGNED;  // Default to ADD
                endcase
            end
            
            2'b11: begin // I-type instructions
                case (funct3)
                    F3_ADD_SUB: alu_control = ADD_SIGNED;   // ADDI
                    
                    F3_SLL: alu_control = SLL_OP;      // SLLI
                    
                    F3_SLT: alu_control = LT_SIGNED;   // SLTI
                    
                    F3_SLTU: alu_control = LT_UNSIGNED; // SLTIU
                    
                    F3_XOR: alu_control = XOR_OP;      // XORI
                    
                    F3_SRL_SRA: begin
                        if (funct7[5]) // Check bit 5 of funct7 for I-type shift instructions
                            alu_control = SRA_OP;       // SRAI
                        else
                            alu_control = SRL_OP;       // SRLI
                    end
                    
                    F3_OR: alu_control = OR_OP;        // ORI
                    
                    F3_AND: alu_control = AND_OP;      // ANDI
                    
                    default: alu_control = ADD_SIGNED;  // Default to ADD
                endcase
            end
            
            default: alu_control = ADD_UNSIGNED;        // Default operation
        endcase
    end

endmodule
