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
    // 00: Addition (for address calculation, PC+4, etc.)
    // 01: Subtraction (for branches)
    // 10: R-type instruction (use funct3 and funct7)
    // 11: I-type instruction (use funct3)

    // RISC-V funct3 codes for R-type and I-type instructions
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLL     = 3'b001;
    localparam F3_SLT     = 3'b010;
    localparam F3_SLTU    = 3'b011;
    localparam F3_XOR     = 3'b100;
    localparam F3_SRL_SRA = 3'b101;
    localparam F3_OR      = 3'b110;
    localparam F3_AND     = 3'b111;
    
    // RISC-V funct3 codes for M extension
    localparam F3_MUL     = 3'b000;
    localparam F3_MULH    = 3'b001;
    localparam F3_MULHSU  = 3'b010;
    localparam F3_MULHU   = 3'b011;
    localparam F3_DIV     = 3'b100;
    localparam F3_DIVU    = 3'b101;
    localparam F3_REM     = 3'b110;
    localparam F3_REMU    = 3'b111;

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
    
    // M extension specific operations
    localparam MUL_UNSIGNED = 5'b01000; // Also MULHU
    localparam MUL_SIGNED   = 5'b01001; // Also MUL
    localparam MULHSU      = 5'b01010;
    localparam MULH        = 5'b01011;
    localparam DIV_UNSIGNED = 5'b01100;
    localparam DIV_SIGNED   = 5'b01101;
    localparam REM_UNSIGNED = 5'b01110;
    localparam REM_SIGNED  = 5'b01111;

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
            2'b00: begin
                // Addition operation (for address calculation, PC+4, etc.)
                alu_control = 5'b00001; // ADD_SIGNED (signed addition)
            end
            
            2'b01: begin
                // Subtraction operation (for branches)
                alu_control = 5'b00101; // SUB_SIGNED (signed subtraction)
            end
            
            2'b10: begin
                // R-type instruction - use funct3 and funct7
                case (funct3)
                    3'b000: begin
                        // ADD/SUB
                        if (funct7[5]) begin
                            alu_control = 5'b00101; // SUB_SIGNED (signed subtraction)
                        end else begin
                            alu_control = 5'b00001; // ADD_SIGNED (signed addition)
                        end
                    end
                    
                    3'b001: begin
                        // SLL - Shift Left Logical
                        alu_control = 5'b10000; // LOGIC_SLL
                    end
                    
                    3'b010: begin
                        // SLT - Set Less Than (signed)
                        alu_control = 5'b10100; // LOGIC_SLT
                    end
                    
                    3'b011: begin
                        // SLTU - Set Less Than Unsigned
                        alu_control = 5'b10101; // LOGIC_SLTU
                    end
                    
                    3'b100: begin
                        // XOR
                        alu_control = 5'b10010; // LOGIC_XOR
                    end
                    
                    3'b101: begin
                        // SRL/SRA - Shift Right Logical/Arithmetic
                        if (funct7[5]) begin
                            alu_control = 5'b10011; // LOGIC_SRA (shift right arithmetic)
                        end else begin
                            alu_control = 5'b10001; // LOGIC_SRL (shift right logical)
                        end
                    end
                    
                    3'b110: begin
                        // OR
                        alu_control = 5'b10110; // LOGIC_OR
                    end
                    
                    3'b111: begin
                        // AND
                        alu_control = 5'b10111; // LOGIC_AND
                    end
                    
                    default: begin
                        alu_control = 5'b00001; // Default to ADD_SIGNED
                    end
                endcase
                
                // Check for M extension instructions (funct7 = 0x01)
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_control = MUL_SIGNED;         // MUL
                        3'b001: alu_control = MULH;        // MULH
                        3'b010: alu_control = MULHSU;      // MULHSU
                        3'b011: alu_control = MUL_UNSIGNED;       // MULHU
                        3'b100: alu_control = DIV_SIGNED;  // DIV
                        3'b101: alu_control = DIV_UNSIGNED; // DIVU
                        3'b110: alu_control = REM_SIGNED;  // REM
                        3'b111: alu_control = REM_UNSIGNED; // REMU
                        default: alu_control = 5'b00001;   // Default to ADD_SIGNED
                    endcase
                end
            end
            
            2'b11: begin
                // I-type instruction - use funct3
                case (funct3)
                    3'b000: begin
                        // ADDI - always signed addition
                        alu_control = 5'b00001; // ADD_SIGNED (signed addition)
                    end
                    
                    3'b001: begin
                        // SLLI - Shift Left Logical Immediate
                        alu_control = 5'b10000; // LOGIC_SLL
                    end
                    
                    3'b010: begin
                        // SLTI - Set Less Than Immediate (signed)
                        alu_control = 5'b10100; // LOGIC_SLT
                    end
                    
                    3'b011: begin
                        // SLTIU - Set Less Than Immediate Unsigned
                        alu_control = 5'b10101; // LOGIC_SLTU
                    end
                    
                    3'b100: begin
                        // XORI
                        alu_control = 5'b10010; // LOGIC_XOR
                    end
                    
                    3'b101: begin
                        // SRLI/SRAI - Shift Right Logical/Arithmetic Immediate
                        if (funct7[5]) begin
                            alu_control = 5'b10011; // LOGIC_SRA (shift right arithmetic)
                        end else begin
                            alu_control = 5'b10001; // LOGIC_SRL (shift right logical)
                        end
                    end
                    
                    3'b110: begin
                        // ORI
                        alu_control = 5'b10110; // LOGIC_OR
                    end
                    
                    3'b111: begin
                        // ANDI
                        alu_control = 5'b10111; // LOGIC_AND
                    end
                    
                    default: begin
                        alu_control = 5'b00001; // Default to ADD_SIGNED
                    end
                endcase
            end
            
            default: begin
                alu_control = 5'b00001; // Default to ADD_SIGNED
            end
        endcase
    end

endmodule
