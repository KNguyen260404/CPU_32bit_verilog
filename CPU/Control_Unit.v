module Control_Unit(
    input clk,
    input reset,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input zero,
    input negative,
    input branch_result,
    
    output reg pc_write,
    output reg ir_write,
    output reg mar_write,
    output reg mdr_write,
    output reg reg_write,
    output reg a_write,
    output reg b_write,
    output reg alu_out_write,
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] ALUOp,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] PCSource,
    output reg RegDst,
    output reg MemtoReg,
    output reg IorD,
    output reg [2:0] imm_type,
    output reg [2:0] branch_op,
    output reg [3:0] current_state
);

    // RISC-V Opcodes
    localparam R_TYPE     = 7'b0110011;  // R-type instructions (add, sub, and, or, etc.)
    localparam I_TYPE_ALU = 7'b0010011;  // I-type ALU instructions (addi, andi, ori, etc.)
    localparam I_TYPE_LOAD = 7'b0000011; // Load instructions (lw, lh, lb, etc.)
    localparam S_TYPE     = 7'b0100011;  // Store instructions (sw, sh, sb, etc.)
    localparam B_TYPE     = 7'b1100011;  // Branch instructions (beq, bne, blt, etc.)
    localparam J_TYPE_JAL = 7'b1101111;  // Jump and link (jal)
    localparam I_TYPE_JALR = 7'b1100111; // Jump and link register (jalr)
    localparam U_TYPE_LUI = 7'b0110111;  // Load upper immediate (lui)
    localparam U_TYPE_AUIPC = 7'b0010111; // Add upper immediate to PC (auipc)

    // Immediate type encoding
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    // Branch operation encoding
    localparam BEQ  = 3'b000;  // Equal
    localparam BNE  = 3'b001;  // Not equal
    localparam BLT  = 3'b010;  // Less than (signed)
    localparam BGE  = 3'b011;  // Greater than or equal (signed)
    localparam BLTU = 3'b100;  // Less than (unsigned)
    localparam BGEU = 3'b101;  // Greater than or equal (unsigned)

    // FSM States
    localparam IF    = 4'b0000;  // Instruction Fetch
    localparam ID    = 4'b0001;  // Instruction Decode
    localparam EX_R  = 4'b0010;  // Execute R-type
    localparam EX_I  = 4'b0011;  // Execute I-type
    localparam EX_LOAD = 4'b0100; // Execute Load
    localparam EX_STORE = 4'b0101; // Execute Store
    localparam EX_BRANCH = 4'b0110; // Execute Branch
    localparam EX_JAL = 4'b0111;  // Execute JAL
    localparam EX_JALR = 4'b1000; // Execute JALR
    localparam EX_LUI = 4'b1001;  // Execute LUI
    localparam EX_AUIPC = 4'b1010; // Execute AUIPC
    localparam MEM_LOAD = 4'b1011; // Memory access for Load
    localparam MEM_STORE = 4'b1100; // Memory access for Store
    localparam WB_R  = 4'b1101;  // Write Back for R-type
    localparam WB_LOAD = 4'b1110; // Write Back for Load

    // State register
    reg [3:0] next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IF;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IF: next_state = ID;
            
            ID: begin
                case (opcode)
                    R_TYPE:     next_state = EX_R;
                    I_TYPE_ALU: next_state = EX_I;
                    I_TYPE_LOAD: next_state = EX_LOAD;
                    S_TYPE:     next_state = EX_STORE;
                    B_TYPE:     next_state = EX_BRANCH;
                    J_TYPE_JAL: next_state = EX_JAL;
                    I_TYPE_JALR: next_state = EX_JALR;
                    U_TYPE_LUI: next_state = EX_LUI;
                    U_TYPE_AUIPC: next_state = EX_AUIPC;
                    default:    next_state = IF; // Invalid opcode, restart
                endcase
            end
            
            EX_R:      next_state = WB_R;
            EX_I:      next_state = WB_R;
            EX_LOAD:   next_state = MEM_LOAD;
            EX_STORE:  next_state = MEM_STORE;
            EX_BRANCH: next_state = IF;
            EX_JAL:    next_state = WB_R;
            EX_JALR:   next_state = WB_R;
            EX_LUI:    next_state = WB_R; // LUI goes directly to write back
            EX_AUIPC:  next_state = WB_R;
            MEM_LOAD:  next_state = WB_LOAD;
            MEM_STORE: next_state = IF;
            WB_R:      next_state = IF;
            WB_LOAD:   next_state = IF;
            default:   next_state = IF;
        endcase
    end

    // Output logic
    always @(*) begin
        // Default control signals
        pc_write = 0;
        ir_write = 0;
        mar_write = 0;
        mdr_write = 0;
        reg_write = 0;
        a_write = 0;
        b_write = 0;
        alu_out_write = 0;
        mem_read = 0;
        mem_write = 0;
        ALUOp = 2'b00;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b00;
        PCSource = 2'b00;
        RegDst = 0;
        MemtoReg = 0;
        IorD = 0;
        imm_type = 3'b000;
        branch_op = 3'b000;

        case (current_state)
            IF: begin
                // Fetch instruction
                mar_write = 1;     // Update MAR with PC
                mem_read = 1;      // Read from memory
                ir_write = 1;      // Write instruction to IR
                
                // Calculate PC + 4
                ALUSrcA = 2'b00;   // Use PC
                ALUSrcB = 2'b01;   // Use constant 4
                ALUOp = 2'b00;     // Addition
                
                // Update PC with PC + 4
                PCSource = 2'b00;  // PC + 4
                pc_write = 1;      // Always update PC in IF stage
                
                // Memory address source
                IorD = 0;          // Use PC as memory address
            end
            
            ID: begin
                // Decode instruction and read registers
                a_write = 1;       // Store rs1 data
                b_write = 1;       // Store rs2 data
                
                // Set immediate type based on opcode
                case (opcode)
                    I_TYPE_ALU, I_TYPE_LOAD, I_TYPE_JALR: imm_type = IMM_I;
                    S_TYPE:     imm_type = IMM_S;
                    B_TYPE:     imm_type = IMM_B;
                    U_TYPE_LUI, U_TYPE_AUIPC: imm_type = IMM_U;
                    J_TYPE_JAL: imm_type = IMM_J;
                    default:    imm_type = IMM_I;
                endcase
                
                // Set branch operation for branch instructions
                if (opcode == B_TYPE) begin
                    case (funct3)
                        3'b000: branch_op = BEQ;
                        3'b001: branch_op = BNE;
                        3'b100: branch_op = BLT;
                        3'b101: branch_op = BGE;
                        3'b110: branch_op = BLTU;
                        3'b111: branch_op = BGEU;
                        default: branch_op = BEQ;
                    endcase
                end
            end
            
            EX_R: begin
                // R-type execution
                ALUOp = 2'b10;     // R-type ALU operation
                ALUSrcA = 2'b01;   // Use rs1
                ALUSrcB = 2'b00;   // Use rs2
                alu_out_write = 1; // Store ALU result
            end
            
            EX_I: begin
                // I-type execution
                ALUOp = 2'b11;     // I-type ALU operation
                ALUSrcA = 2'b01;   // Use rs1
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store ALU result
                
                // Special handling for ADDI with negative values
                if (funct3 == 3'b000) begin
                    // ADDI - ensure it's treated as signed
                    ALUOp = 2'b11; // I-type ALU operation (will be ADD_SIGNED)
                end
            end
            
            EX_LOAD: begin
                // Load address calculation
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b01;   // Use rs1
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store address in ALU out
            end
            
            EX_STORE: begin
                // Store address calculation
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b01;   // Use rs1
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store address in ALU out
            end
            
            EX_BRANCH: begin
                // Branch target calculation
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b00;   // Use PC
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store branch target
                
                // Update PC if branch condition is met
                PCSource = 2'b01;  // Use ALU output register
                pc_write = branch_result;
            end
            
            EX_JAL: begin
                // JAL execution
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b00;   // Use PC
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store jump target
                
                // Update PC
                PCSource = 2'b01;  // Use ALU output register
                pc_write = 1;
            end
            
            EX_JALR: begin
                // JALR execution
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b01;   // Use rs1
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store jump target
                
                // Update PC
                PCSource = 2'b10;  // Use ALU result with LSB cleared
                pc_write = 1;
            end
            
            EX_LUI: begin
                // LUI execution - Pass immediate directly to register file
                // No ALU operation needed for LUI, immediate is already shifted
                // We'll just set alu_out_write to 0 since we bypass ALU for LUI
                ALUSrcA = 2'b10;   // Use zero (not really used)
                ALUSrcB = 2'b10;   // Use immediate (not really used)
                ALUOp = 2'b00;     // Addition (not really used)
                alu_out_write = 0; // Don't store result in ALU out
                
                // For LUI, we'll directly write the immediate value to the register
                // in the WB_R stage, bypassing the ALU
            end
            
            EX_AUIPC: begin
                // AUIPC execution
                ALUOp = 2'b00;     // Addition
                ALUSrcA = 2'b00;   // Use PC
                ALUSrcB = 2'b10;   // Use immediate
                alu_out_write = 1; // Store result
            end
            
            MEM_LOAD: begin
                // Memory access for load
                mem_read = 1;      // Read from memory
                IorD = 1;          // Use ALU out as address
                mar_write = 1;     // Update MAR with calculated address
                mdr_write = 1;     // Store loaded data in MDR
            end
            
            MEM_STORE: begin
                // Memory access for store
                mem_write = 1;     // Write to memory
                IorD = 1;          // Use ALU out as address
                mar_write = 1;     // Update MAR with calculated address
            end
            
            WB_R: begin
                // Write back for R-type, I-type, JAL, JALR, LUI, AUIPC
                reg_write = 1;     // Write to register file
                
                if (opcode == J_TYPE_JAL || opcode == I_TYPE_JALR) begin
                    MemtoReg = 0;  // Use ALU result (PC + 4)
                end else if (opcode == U_TYPE_LUI) begin
                    // For LUI, the CPU module handles bypassing the ALU
                    // We don't need to do anything special here
                    MemtoReg = 0;  // Not used for LUI
                end else begin
                    MemtoReg = 0;  // Use ALU result
                end
                
                RegDst = 0;        // Use rd field for destination register
            end
            
            WB_LOAD: begin
                // Write back for load
                reg_write = 1;     // Write to register file
                MemtoReg = 1;      // Use memory data
                RegDst = 0;        // Use rd field for destination register
            end
            
            default: begin
                // Default state (should never reach here)
                pc_write = 0;
                ir_write = 0;
                mar_write = 0;
                mdr_write = 0;
                reg_write = 0;
                a_write = 0;
                b_write = 0;
                alu_out_write = 0;
                mem_read = 0;
                mem_write = 0;
                ALUOp = 2'b00;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                PCSource = 2'b00;
                RegDst = 0;
                MemtoReg = 0;
                IorD = 0;
                imm_type = 3'b000;
                branch_op = 3'b000;
            end
        endcase
    end

endmodule
