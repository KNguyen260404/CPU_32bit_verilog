// Control Unit Module
// Decodes instructions and generates control signals for datapath
// Based on Blog.md section 2.1 item 10)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define OPCODE_WIDTH        7           // 7-bit opcode field
`define FUNCT3_WIDTH        3           // 3-bit funct3 field
`define FUNCT7_WIDTH        7           // 7-bit funct7 field

// RISC-V Opcode Constants (Instruction[6:0])
`define OPCODE_LUI          7'b0110111      // Load Upper Immediate
`define OPCODE_AUIPC        7'b0010111      // Add Upper Immediate to PC
`define OPCODE_JAL          7'b1101111      // Jump And Link
`define OPCODE_JALR         7'b1100111      // Jump And Link Register
`define OPCODE_BRANCH       7'b1100011      // Branch operations
`define OPCODE_LOAD         7'b0000011      // Load operations
`define OPCODE_STORE        7'b0100011      // Store operations
`define OPCODE_OP_IMM       7'b0010011      // Immediate operations
`define OPCODE_OP           7'b0110011      // Register-register operations

// Funct3 Constants for ALU/Branch Operations (Instruction[14:12])
`define FUNCT3_ADD_SUB      3'b000          // ADD/SUB
`define FUNCT3_SLL          3'b001          // Shift Left Logical
`define FUNCT3_SLT          3'b010          // Set Less Than
`define FUNCT3_SLTU         3'b011          // Set Less Than Unsigned
`define FUNCT3_XOR          3'b100          // XOR
`define FUNCT3_SRL_SRA      3'b101          // Shift Right Logical/Arithmetic
`define FUNCT3_OR           3'b110          // OR
`define FUNCT3_AND          3'b111          // AND

// Funct3 Constants for Store Operations  
`define FUNCT3_SB           3'b000          // Store Byte
`define FUNCT3_SH           3'b001          // Store Halfword
`define FUNCT3_SW           3'b010          // Store Word

// ALU Operation Constants (4-bit encoding)
`define ALU_ADD             4'b0000         // Addition
`define ALU_SUB             4'b0001         // Subtraction
`define ALU_AND             4'b0010         // Bitwise AND
`define ALU_OR              4'b0011         // Bitwise OR
`define ALU_XOR             4'b0100         // Bitwise XOR
`define ALU_SLT             4'b0101         // Set Less Than (signed)
`define ALU_SLTU            4'b0110         // Set Less Than Unsigned
`define ALU_SLL             4'b0111         // Shift Left Logical
`define ALU_SRL             4'b1000         // Shift Right Logical
`define ALU_SRA             4'b1001         // Shift Right Arithmetic

// Immediate Type Constants (3-bit encoding)
`define IMM_TYPE_I          3'b000          // I-type immediate (12-bit)
`define IMM_TYPE_S          3'b001          // S-type immediate (12-bit)
`define IMM_TYPE_B          3'b010          // B-type immediate (12-bit)
`define IMM_TYPE_U          3'b011          // U-type immediate (20-bit)
`define IMM_TYPE_J          3'b100          // J-type immediate (20-bit)

// ALU Source Selection Constants (2-bit encoding)
`define ALU_SRC_REG         2'b00           // Register data
`define ALU_SRC_IMM         2'b01           // Immediate data
`define ALU_SRC_PC          2'b10           // PC value

// Memory Access Size Constants (4-bit encoding)
`define MEM_SIZE_BYTE       4'b0001         // Byte access
`define MEM_SIZE_HALF       4'b0011         // Halfword access  
`define MEM_SIZE_WORD       4'b1111         // Word access

module control_unit (
    // Instruction fields
    input  wire [`OPCODE_WIDTH-1:0]    opcode,         // Op
    input  wire [`FUNCT3_WIDTH-1:0]    funct3,         // Fn3  
    input  wire [`FUNCT7_WIDTH-1:0]    funct7,         // Fn7
    
    // Control outputs for ID stage
    output reg                          jal_d,          // JalD - JAL instruction
    output reg                          jalr_d,         // JalrD - JALR instruction  
    output reg                          reg_write_d,    // RegWriteD - write to register
    output reg                          mem_to_reg_d,   // MemToRegD - load from memory
    output reg  [3:0]                   mem_write_d,    // MemWriteD[3:0] - byte write enables
    output reg                          load_npc_d,     // LoadNpcD - load PC+4 to rd
    output reg  [1:0]                   reg_read_d,     // RegReadD[1:0] - which regs are read
    output reg  [2:0]                   branch_type_d,  // BranchTypeD - branch comparison type
    output reg  [3:0]                   alu_control_d,  // AluContrlD - ALU operation
    output reg  [1:0]                   alu_src1_d,     // AluSrc1D - ALU operand 1 source
    output reg  [1:0]                   alu_src2_d,     // AluSrc2D - ALU operand 2 source  
    output reg  [2:0]                   imm_type,       // ImmType - immediate encoding type
    output reg  [2:0]                   load_type_d     // LoadTypeD - load operation type
);

    // ========== Main Control Logic (Following DES pattern) ==========
    always @(*) begin
        // Default values - Reset state (Following DES pattern)
        jal_d = 1'b0;
        jalr_d = 1'b0;
        reg_write_d = 1'b0;
        mem_to_reg_d = 1'b0;
        mem_write_d = 4'b0000;
        load_npc_d = 1'b0;
        reg_read_d = 2'b00;
        branch_type_d = 3'b000;
        alu_control_d = `ALU_ADD;
        alu_src1_d = 2'b00; // Register
        alu_src2_d = 2'b00; // Register  
        imm_type = `IMM_TYPE_I;
        load_type_d = 3'b010; // Default to LW
        
        case (opcode)
            `OPCODE_LUI: begin
                // LUI rd, imm
                reg_write_d = 1'b1;
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b00; // Zero  
                alu_src2_d = 2'b01; // Immediate
                imm_type = `IMM_TYPE_U;
                reg_read_d = 2'b00; // No registers read
            end
            
            `OPCODE_AUIPC: begin
                // AUIPC rd, imm  
                reg_write_d = 1'b1;
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b10; // PC
                alu_src2_d = 2'b01; // Immediate
                imm_type = `IMM_TYPE_U;
                reg_read_d = 2'b00; // No registers read
            end
            
            `OPCODE_JAL: begin
                // JAL rd, imm - Store PC+4 in rd
                jal_d = 1'b1;
                reg_write_d = 1'b1;
                load_npc_d = 1'b1; // Write PC+4 to rd
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b00; // Don't care for operand1
                alu_src2_d = 2'b10; // PC+4 as operand2
                imm_type = `IMM_TYPE_J;
                reg_read_d = 2'b00; // No registers read
            end
            
            `OPCODE_JALR: begin
                // JALR rd, rs1, imm - Store PC+4 in rd
                jalr_d = 1'b1;
                reg_write_d = 1'b1;
                load_npc_d = 1'b1; // Write PC+4 to rd
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b00; // Don't care for operand1
                alu_src2_d = 2'b10; // PC+4 as operand2
                imm_type = `IMM_TYPE_I;
                reg_read_d = 2'b10; // Read rs1
            end
            
            `OPCODE_BRANCH: begin
                // Branch instructions
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b10; // PC
                alu_src2_d = 2'b01; // Immediate  
                imm_type = `IMM_TYPE_B;
                reg_read_d = 2'b11; // Read rs1 and rs2
                branch_type_d = funct3; // Branch type from funct3
            end
            
            `OPCODE_LOAD: begin
                // Load instructions
                reg_write_d = 1'b1;
                mem_to_reg_d = 1'b1;
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b00; // Register rs1
                alu_src2_d = 2'b01; // Immediate
                imm_type = `IMM_TYPE_I;
                reg_read_d = 2'b10; // Read rs1
                load_type_d = funct3; // Pass funct3 for load type (LB, LH, LW, LBU, LHU)
            end
            
            `OPCODE_STORE: begin
                // Store instructions
                alu_control_d = `ALU_ADD;
                alu_src1_d = 2'b00; // Register rs1
                alu_src2_d = 2'b01; // Immediate
                imm_type = `IMM_TYPE_S;
                reg_read_d = 2'b11; // Read rs1 and rs2
                
                // Generate byte write enables based on funct3
                case (funct3)
                    `FUNCT3_SB: mem_write_d = 4'b0001; // Store byte
                    `FUNCT3_SH: mem_write_d = 4'b0011; // Store halfword
                    `FUNCT3_SW: mem_write_d = 4'b1111; // Store word
                    default:    mem_write_d = 4'b0000;
                endcase
            end
            
            `OPCODE_OP_IMM: begin
                // Immediate arithmetic instructions
                reg_write_d = 1'b1;
                alu_src1_d = 2'b00; // Register rs1
                alu_src2_d = 2'b01; // Immediate
                imm_type = `IMM_TYPE_I;
                reg_read_d = 2'b10; // Read rs1
                
                // ALU control based on funct3 and funct7
                case (funct3)
                    `FUNCT3_ADD_SUB: alu_control_d = `ALU_ADD;
                    `FUNCT3_SLT:     alu_control_d = `ALU_SLT;
                    `FUNCT3_SLTU:    alu_control_d = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_control_d = `ALU_XOR;
                    `FUNCT3_OR:      alu_control_d = `ALU_OR;
                    `FUNCT3_AND:     alu_control_d = `ALU_AND;
                    `FUNCT3_SLL:     alu_control_d = `ALU_SLL;
                    `FUNCT3_SRL_SRA: begin
                        if (funct7[5]) alu_control_d = `ALU_SRA;
                        else           alu_control_d = `ALU_SRL;
                    end
                    default: alu_control_d = `ALU_ADD;
                endcase
            end
            
            `OPCODE_OP: begin
                // Register-register arithmetic instructions
                reg_write_d = 1'b1;
                alu_src1_d = 2'b00; // Register rs1
                alu_src2_d = 2'b00; // Register rs2
                reg_read_d = 2'b11; // Read rs1 and rs2
                
                // ALU control based on funct3 and funct7
                case (funct3)
                    `FUNCT3_ADD_SUB: begin
                        if (funct7[5]) alu_control_d = `ALU_SUB;
                        else           alu_control_d = `ALU_ADD;
                    end
                    `FUNCT3_SLT:     alu_control_d = `ALU_SLT;
                    `FUNCT3_SLTU:    alu_control_d = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_control_d = `ALU_XOR;
                    `FUNCT3_OR:      alu_control_d = `ALU_OR;
                    `FUNCT3_AND:     alu_control_d = `ALU_AND;
                    `FUNCT3_SLL:     alu_control_d = `ALU_SLL;
                    `FUNCT3_SRL_SRA: begin
                        if (funct7[5]) alu_control_d = `ALU_SRA;
                        else           alu_control_d = `ALU_SRL;
                    end
                    default: alu_control_d = `ALU_ADD;
                endcase
            end
            
            default: begin
                // NOP or unsupported instruction
                // All outputs remain at default values
            end
        endcase
    end

endmodule