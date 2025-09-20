// =============================================================================
// Top-Level 5-Stage Pipelined RISC-V CPU
// =============================================================================
// Description: Complete 5-stage pipeline RISC-V CPU with hazard handling
//              Implements proper reset strategy and debug features
//              Following RTL design rules derived from DES example
// Author: Enhanced with RTL design rules
// Date: September 20, 2025
// Features: - Parameterized design for flexibility
//          - Reset synchronizer for robust reset strategy
//          - Built-in debug interface
//          - Performance monitoring capabilities
//          - Comprehensive pipeline control
//          - Modular design following DES patterns
// =============================================================================

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
// Data Width Constants
`define DATA_WIDTH          32          // 32-bit data bus
`define REG_ADDR_WIDTH      5           // 5-bit register address (32 regs)  
`define OPCODE_WIDTH        7           // 7-bit opcode field
`define FUNCT3_WIDTH        3           // 3-bit funct3 field
`define FUNCT7_WIDTH        7           // 7-bit funct7 field

// System Constants
`define RESET_PC            32'h00000000    // Reset PC address

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

// Funct3 Constants for Load Operations
`define FUNCT3_LB           3'b000          // Load Byte
`define FUNCT3_LH           3'b001          // Load Halfword
`define FUNCT3_LW           3'b010          // Load Word
`define FUNCT3_LBU          3'b100          // Load Byte Unsigned
`define FUNCT3_LHU          3'b101          // Load Halfword Unsigned

// Funct3 Constants for Store Operations  
`define FUNCT3_SB           3'b000          // Store Byte
`define FUNCT3_SH           3'b001          // Store Halfword
`define FUNCT3_SW           3'b010          // Store Word

// Funct3 Constants for Branch Operations
`define FUNCT3_BEQ          3'b000          // Branch if Equal
`define FUNCT3_BNE          3'b001          // Branch if Not Equal
`define FUNCT3_BLT          3'b100          // Branch if Less Than
`define FUNCT3_BGE          3'b101          // Branch if Greater or Equal
`define FUNCT3_BLTU         3'b110          // Branch if Less Than Unsigned
`define FUNCT3_BGEU         3'b111          // Branch if Greater or Equal Unsigned

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

// Branch Type Constants (3-bit encoding)
`define BRANCH_EQ           3'b000          // Branch if Equal
`define BRANCH_NE           3'b001          // Branch if Not Equal  
`define BRANCH_LT           3'b100          // Branch if Less Than
`define BRANCH_GE           3'b101          // Branch if Greater or Equal
`define BRANCH_LTU          3'b110          // Branch if Less Than Unsigned
`define BRANCH_GEU          3'b111          // Branch if Greater or Equal Unsigned

// Immediate Type Constants (3-bit encoding)
`define IMM_TYPE_I          3'b000          // I-type immediate (12-bit)
`define IMM_TYPE_S          3'b001          // S-type immediate (12-bit)
`define IMM_TYPE_B          3'b010          // B-type immediate (12-bit)
`define IMM_TYPE_U          3'b011          // U-type immediate (20-bit)
`define IMM_TYPE_J          3'b100          // J-type immediate (20-bit)

// Forwarding Unit Constants (2-bit encoding)
`define FORWARD_NONE        2'b00           // No forwarding
`define FORWARD_WB          2'b01           // Forward from WB stage
`define FORWARD_MEM         2'b10           // Forward from MEM stage

// ALU Source Selection Constants (2-bit encoding)
`define ALU_SRC_REG         2'b00           // Register data
`define ALU_SRC_IMM         2'b01           // Immediate data
`define ALU_SRC_PC          2'b10           // PC value

// Memory Access Size Constants (4-bit encoding)
`define MEM_SIZE_BYTE       4'b0001         // Byte access
`define MEM_SIZE_HALF       4'b0011         // Halfword access  
`define MEM_SIZE_WORD       4'b1111         // Word access

// Register Read Type Constants (2-bit encoding)
`define REG_READ_NONE       2'b00           // No register read
`define REG_READ_RS1        2'b01           // Read RS1 only
`define REG_READ_RS2        2'b10           // Read RS2 only
`define REG_READ_BOTH       2'b11           // Read both RS1 and RS2

// =============================================================================
// Include all required module files
// =============================================================================
`include "reset_synchronizer.v"
`include "npc_generator.v"
`include "instruction_memory.v"
`include "control_unit.v"
`include "register_file.v"
`include "immediate_generator.v"
`include "alu.v"
`include "branch_decision.v"
`include "forwarding_unit.v"
`include "hazard_unit.v"
`include "data_memory.v"
`include "data_extension.v"

module riscv_5stage_cpu #(
    // =================================================================
    // Parameters
    // =================================================================
    parameter DATA_WIDTH = 32,              // Data bus width
    // parameter ADDR_WIDTH = 32,              // Address bus width - unused  
    parameter REG_ADDR_WIDTH = 5,           // Register address width
    parameter IMEM_ADDR_WIDTH = 12,         // Instruction memory address width
    parameter DMEM_ADDR_WIDTH = 12,         // Data memory address width
    parameter RESET_SYNC_STAGES = 2,        // Reset synchronizer stages
    parameter ENABLE_DEBUG = 1,             // Enable debug features
    parameter ENABLE_PERFORMANCE = 1        // Enable performance counters
)(
    // =================================================================
    // Clock and Reset Interface
    // =================================================================
    input  wire                     clk,            // System clock
    input  wire                     async_rst_n,    // Asynchronous reset
    
    // =================================================================
    // Debug Interface (Optional)
    // =================================================================
    input  wire                     debug_enable,
    input  wire [7:0]              debug_select,   // Debug mux select
    output wire [DATA_WIDTH-1:0]    debug_data,     // Debug data output
    
    // =================================================================
    // Performance Interface (Optional)  
    // =================================================================
    output wire [31:0]             cycle_count,    // Total cycles
    output wire [31:0]             instr_count,    // Instructions executed
    output wire [31:0]             stall_count,    // Pipeline stalls
    output wire [31:0]             branch_count    // Branches taken
);

    // =================================================================
    // Internal Reset Signal (Synchronized)
    // =================================================================
    wire sync_rst_n;
    
    reset_synchronizer #(
        .SYNC_STAGES(RESET_SYNC_STAGES),
        .RESET_POLARITY(1'b0)
    ) u_reset_sync (
        .clk(clk),
        .async_rst(~async_rst_n),
        .sync_rst_n(sync_rst_n)
    );

    //=========================================================================
    //|                          PIPELINE STAGE SIGNALS                      |
    //=========================================================================
    
    // ========================= IF STAGE SIGNALS =========================
    reg  [DATA_WIDTH-1:0]      pc_f;                    // Program Counter (Fetch)
    wire [DATA_WIDTH-1:0]      pc_next;                 // Next PC value
    wire [DATA_WIDTH-1:0]      instruction_f;           // Fetched instruction
    wire                       stall_f;                 // IF stage stall signal
    
    // ======================= IF/ID PIPELINE REGISTER ====================  
    reg [DATA_WIDTH-1:0]       pc_d, instruction_d;     // ID stage PC and instruction
    reg                        valid_d;                 // ID stage valid bit
    
    // ========================= ID STAGE SIGNALS =========================
    wire [REG_ADDR_WIDTH-1:0]  rs1_d, rs2_d, rd_d;         // Register addresses
    wire [DATA_WIDTH-1:0]      rs1_data, rs2_data, immediate_d; // Register data & immediate
    wire [DATA_WIDTH-1:0]      pc_plus4_d;                 // PC+4 for jump instructions
    wire                       jal_d, jalr_d, reg_write_d, mem_to_reg_d; // Control signals
    wire [3:0]                mem_write_d;                  // Memory write enables
    wire [1:0]                reg_read_d, alu_src1_d, alu_src2_d; // Source selects
    wire [2:0]                branch_type_d, imm_type;      // Branch type & immediate type
    wire [3:0]                alu_control_d;                // ALU operation control
    wire [2:0]                load_type_d;                  // Load operation type
    wire                       stall_d, flush_d;             // Hazard control signals
    
    // ======================= ID/EX PIPELINE REGISTER ====================
    reg [DATA_WIDTH-1:0]       pc_e, rs1_data_e, rs2_data_e, immediate_e; // Data signals
    reg [DATA_WIDTH-1:0]       pc_plus4_e;                 // PC+4 for jump instructions
    reg [REG_ADDR_WIDTH-1:0]   rs1_e, rs2_e, rd_e;         // Register addresses
    reg                        reg_write_e, mem_to_reg_e, jalr_e; // Control signals
    reg [3:0]                 mem_write_e;                  // Memory control
    reg [1:0]                 alu_src1_e, alu_src2_e;      // ALU source selects
    reg [2:0]                 branch_type_e;                // Branch control
    reg [3:0]                 alu_control_e;                // ALU control
    reg [2:0]                 load_type_e;                  // Load operation type
    reg                        valid_e;                     // Valid bit
    
    // ========================= EX STAGE SIGNALS =========================
    wire [DATA_WIDTH-1:0]      operand1, operand2, alu_result; // ALU operands and result
    wire [DATA_WIDTH-1:0]      branch_target;             // Branch target address
    wire [DATA_WIDTH-1:0]      jalr_target;               // JALR target address
    wire                       branch_taken;               // Branch taken flag
    wire [1:0]                forward_1e, forward_2e;     // Forwarding control signals
    wire                       stall_e, flush_e;           // Hazard control signals
    reg [1:0]                 reg_read_e;                 // Register read enables
    
    // ======================= EX/MEM PIPELINE REGISTER ===================
    reg [DATA_WIDTH-1:0]       alu_result_m, rs2_data_m;  // ALU result and store data
    reg [REG_ADDR_WIDTH-1:0]   rd_m;                      // Destination register
    reg                        reg_write_m, mem_to_reg_m; // Control signals
    reg [3:0]                 mem_write_m;                // Memory write enables
    reg [2:0]                 load_type_m;                // Load operation type
    reg                        valid_m;                   // Valid bit
    
    // ======================== MEM STAGE SIGNALS =========================
    wire [DATA_WIDTH-1:0]      mem_data;                  // Memory read data
    wire                       stall_m, flush_m;          // Hazard control signals
    
    // ======================= MEM/WB PIPELINE REGISTER ===================
    reg [DATA_WIDTH-1:0]       alu_result_w, mem_data_w;  // Results from previous stages
    reg [REG_ADDR_WIDTH-1:0]   rd_w;                      // Destination register
    reg                        reg_write_w, mem_to_reg_w; // Control signals
    reg [2:0]                 load_type_w;                // Load operation type
    reg                        valid_w;                   // Valid bit
    
    // ========================= WB STAGE SIGNALS =========================
    wire [DATA_WIDTH-1:0]      result_w;                  // Final write-back result

    //=========================================================================
    //|                       CONTROL AND DATA PATH MODULES                  |
    //=========================================================================
    
    // ======================== FETCH STAGE MODULES =======================
    
    // 1.---------- Next PC Generator ----------
    npc_generator u_npc_gen (
        .clk(clk),
        .rst_n(sync_rst_n),
        .pc_f(pc_f),
        .branch_e(branch_taken),
        .jalr_e(jalr_e),
        .jal_d(jal_d),
        .branch_target(branch_target),
        .jalr_target(jalr_target),
        .jal_target(pc_d + immediate_d),
        .stall_f(stall_f),
        .pc_next(pc_next)
    );
    
    // PC Register
    always @(posedge clk) begin
        if (!sync_rst_n) begin
            pc_f <= {DATA_WIDTH{1'b0}};
        end else if (!stall_f) begin
            pc_f <= pc_next;
        end
    end
    
    // 2.---------- Instruction Memory ----------
    instruction_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(IMEM_ADDR_WIDTH),
        .MEMORY_STYLE("block"),
        .ENABLE_DEBUG(ENABLE_DEBUG)
    ) u_imem (
        .clk(clk),
        .rst_n(sync_rst_n),
        .pc_f(pc_f),
        .instruction_f(instruction_f),
        .debug_enable(1'b0),
        .debug_addr({12{1'b0}}),
        .debug_data()
    );

    // =================================================================
    // IF/ID Pipeline Register - Simplified for synthesis
    // =================================================================
    always @(posedge clk) begin
        if (!sync_rst_n) begin
            pc_d <= {DATA_WIDTH{1'b0}};
            instruction_d <= 32'h00000013; // NOP
            valid_d <= 1'b0;
        end else if (!stall_d) begin
            if (flush_d) begin
                pc_d <= {DATA_WIDTH{1'b0}};
                instruction_d <= 32'h00000013; // NOP
                valid_d <= 1'b0;
            end else begin
                pc_d <= pc_f;
                instruction_d <= instruction_f;
                valid_d <= 1'b1;
            end
        end
    end

    // ======================= DECODE STAGE MODULES ======================
    
    // 1.---------- Instruction Field Extraction ----------
    assign rs1_d = instruction_d[19:15];
    assign rs2_d = instruction_d[24:20];
    assign rd_d = instruction_d[11:7];
    assign pc_plus4_d = pc_d + 4;
    
    // 2.---------- Control Unit ----------
    control_unit u_control (
        .opcode(instruction_d[6:0]),
        .funct3(instruction_d[14:12]),
        .funct7(instruction_d[31:25]),
        .jal_d(jal_d),
        .jalr_d(jalr_d),
        .reg_write_d(reg_write_d),
        .mem_to_reg_d(mem_to_reg_d),
        .mem_write_d(mem_write_d),
        // .load_npc_d(load_npc_d),  // unused
        .reg_read_d(reg_read_d),
        .branch_type_d(branch_type_d),
        .alu_control_d(alu_control_d),
        .alu_src1_d(alu_src1_d),
        .alu_src2_d(alu_src2_d),
        .imm_type(imm_type),
        .load_type_d(load_type_d)
    );
    
    // 3.---------- Register File ----------
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(REG_ADDR_WIDTH),
        .RAM_STYLE("distributed"),
        .ENABLE_DEBUG(ENABLE_DEBUG)
    ) u_regfile (
        .clk(clk),
        .rst_n(sync_rst_n),
        .rs1_addr(rs1_d),
        .rs2_addr(rs2_d),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .reg_write(reg_write_w),
        .rd_addr(rd_w),
        .rd_data(result_w),
        .debug_enable(1'b0),
        .debug_addr({5{1'b0}}),
        .debug_data()
    );
    
    // 4.---------- Immediate Generator ----------
    immediate_generator u_imm_gen (
        .instruction(instruction_d),
        .imm_type(imm_type),
        .immediate(immediate_d)
    );

    // =================================================================
    // ID/EX Pipeline Register
    // =================================================================
    always @(posedge clk) begin
        if (!sync_rst_n) begin
            pc_e <= {DATA_WIDTH{1'b0}};
            pc_plus4_e <= {DATA_WIDTH{1'b0}};
            rs1_data_e <= {DATA_WIDTH{1'b0}};
            rs2_data_e <= {DATA_WIDTH{1'b0}};
            immediate_e <= {DATA_WIDTH{1'b0}};
            rs1_e <= {REG_ADDR_WIDTH{1'b0}};
            rs2_e <= {REG_ADDR_WIDTH{1'b0}};
            rd_e <= {REG_ADDR_WIDTH{1'b0}};
            reg_write_e <= 1'b0;
            mem_to_reg_e <= 1'b0;
            jalr_e <= 1'b0;
            mem_write_e <= 4'b0000;
            alu_src1_e <= 2'b00;
            alu_src2_e <= 2'b00;
            branch_type_e <= 3'b000;
            alu_control_e <= 4'b0000;
            load_type_e <= 3'b010;
            reg_read_e <= 2'b00;
            valid_e <= 1'b0;
        end else if (!stall_e) begin
            if (flush_e) begin
                pc_e <= {DATA_WIDTH{1'b0}};
                pc_plus4_e <= {DATA_WIDTH{1'b0}};
                rs1_data_e <= {DATA_WIDTH{1'b0}};
                rs2_data_e <= {DATA_WIDTH{1'b0}};
                immediate_e <= {DATA_WIDTH{1'b0}};
                rs1_e <= {REG_ADDR_WIDTH{1'b0}};
                rs2_e <= {REG_ADDR_WIDTH{1'b0}};
                rd_e <= {REG_ADDR_WIDTH{1'b0}};
                reg_write_e <= 1'b0;
                mem_to_reg_e <= 1'b0;
                jalr_e <= 1'b0;
                mem_write_e <= 4'b0000;
                alu_src1_e <= 2'b00;
                alu_src2_e <= 2'b00;
                branch_type_e <= 3'b000;
                alu_control_e <= 4'b0000;
                load_type_e <= 3'b010;
                reg_read_e <= 2'b00;
                valid_e <= 1'b0;
            end else begin
            pc_e <= pc_d;
            pc_plus4_e <= pc_plus4_d;
            rs1_data_e <= rs1_data;
            rs2_data_e <= rs2_data;
            immediate_e <= immediate_d;
            rs1_e <= rs1_d;
            rs2_e <= rs2_d;
            rd_e <= rd_d;
            reg_write_e <= reg_write_d;
            mem_to_reg_e <= mem_to_reg_d;
            jalr_e <= jalr_d;
            mem_write_e <= mem_write_d;
            alu_src1_e <= alu_src1_d;
            alu_src2_e <= alu_src2_d;
            branch_type_e <= branch_type_d;
            alu_control_e <= alu_control_d;
            load_type_e <= load_type_d;
            reg_read_e <= reg_read_d;
            valid_e <= valid_d;
            end
        end
    end

    // ======================= EXECUTE STAGE MODULES ======================
    
    // 1.---------- ALU Operand Selection with Forwarding ----------
    assign operand1 = (forward_1e == 2'b10) ? alu_result_m :
                      (forward_1e == 2'b01) ? result_w :
                      (alu_src1_e == 2'b10) ? pc_e :
                      rs1_data_e;
                      
    assign operand2 = (forward_2e == 2'b10) ? alu_result_m :
                      (forward_2e == 2'b01) ? result_w :
                      (alu_src2_e == 2'b01) ? immediate_e :
                      (alu_src2_e == 2'b10) ? pc_plus4_e :  // For JAL/JALR to store PC+4
                      rs2_data_e;
    
    // 2.---------- ALU ----------
    alu u_alu (
        .operand1(operand1),
        .operand2(operand2),
        .alu_control(alu_control_e),
        .alu_result(alu_result),
        .zero_flag()  // unused
    );
    
    // 3.---------- Branch Decision ----------
    wire branch_condition;
    branch_decision u_branch (
        .operand1(operand1),
        .operand2((forward_2e == 2'b10) ? alu_result_m :
                  (forward_2e == 2'b01) ? result_w : rs2_data_e),
        .branch_type(branch_type_e),
        .branch_taken(branch_condition)
    );
    
    assign branch_taken = branch_condition && valid_e;
    assign branch_target = pc_e + immediate_e;
    
    // JALR target calculation with forwarding support
    assign jalr_target = operand1 + immediate_e;

    // =================================================================
    // EX/MEM Pipeline Register
    // =================================================================
    always @(posedge clk) begin
        if (!sync_rst_n) begin
            alu_result_m <= {DATA_WIDTH{1'b0}};
            rs2_data_m <= {DATA_WIDTH{1'b0}};
            rd_m <= {REG_ADDR_WIDTH{1'b0}};
            reg_write_m <= 1'b0;
            mem_to_reg_m <= 1'b0;
            mem_write_m <= 4'b0000;
            load_type_m <= 3'b010;
            valid_m <= 1'b0;
        end else if (!stall_m) begin
            if (flush_m) begin
                alu_result_m <= {DATA_WIDTH{1'b0}};
                rs2_data_m <= {DATA_WIDTH{1'b0}};
                rd_m <= {REG_ADDR_WIDTH{1'b0}};
                reg_write_m <= 1'b0;
                mem_to_reg_m <= 1'b0;
                mem_write_m <= 4'b0000;
                load_type_m <= 3'b010;
                valid_m <= 1'b0;
            end else begin
            alu_result_m <= alu_result;
            rs2_data_m <= (forward_2e == 2'b10) ? alu_result_m :
                           (forward_2e == 2'b01) ? result_w : rs2_data_e;
            rd_m <= rd_e;
            reg_write_m <= reg_write_e;
            mem_to_reg_m <= mem_to_reg_e;
            mem_write_m <= mem_write_e;
            load_type_m <= load_type_e;
            valid_m <= valid_e;
            end
        end
    end

    // ======================= MEMORY STAGE MODULES =======================
    
    // 1.---------- Data Memory ----------
    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(DMEM_ADDR_WIDTH),
        .RAM_STYLE("block"),
        .ENABLE_DEBUG(ENABLE_DEBUG),
        .READ_LATENCY(0)
    ) u_dmem (
        .clk(clk),
        .rst_n(sync_rst_n),
        .address(alu_result_m),
        .mem_write(|mem_write_m),
        .write_enable(mem_write_m),
        .write_data(rs2_data_m),
        .read_data(mem_data),
        .debug_enable(1'b0),
        .debug_addr({12{1'b0}}),
        .debug_data()
    );

    // =================================================================
    // MEM/WB Pipeline Register
    // =================================================================
    always @(posedge clk) begin
        if (!sync_rst_n) begin
            alu_result_w <= {DATA_WIDTH{1'b0}};
            mem_data_w <= {DATA_WIDTH{1'b0}};
            rd_w <= {REG_ADDR_WIDTH{1'b0}};
            reg_write_w <= 1'b0;
            mem_to_reg_w <= 1'b0;
            load_type_w <= 3'b010;
            valid_w <= 1'b0;
        end else begin
            alu_result_w <= alu_result_m;
            mem_data_w <= mem_data;
            rd_w <= rd_m;
            reg_write_w <= reg_write_m;
            mem_to_reg_w <= mem_to_reg_m;
            load_type_w <= load_type_m;
            valid_w <= valid_m;
        end
    end

    // =================================================================
    // WB Stage - Write Back with Data Extension
    // =================================================================
    wire [DATA_WIDTH-1:0] extended_data_w;
    
    // Data Extension for Load operations
    data_extension u_data_ext (
        .memory_data(mem_data_w),
        .byte_select(alu_result_w[1:0]),  // Address bits for byte/halfword select
        .load_type(load_type_w),          // Load type from pipeline register
        .extended_data(extended_data_w)
    );
    
    assign result_w = mem_to_reg_w ? extended_data_w : alu_result_w;

    //=========================================================================
    //|                         HAZARD CONTROL MODULES                       |
    //=========================================================================
    
    // 1.---------- Hazard Detection Unit ----------
    hazard_unit u_hazard (
        .clk(clk),
        .rst_n(sync_rst_n),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .reg_read_e(reg_read_e),
        .mem_to_reg_e(mem_to_reg_e),
        .reg_write_m(reg_write_m),
        .reg_write_w(reg_write_w),
        .branch_e(branch_taken),
        .jalr_e(jalr_e),
        .jal_d(jal_d),
        .icache_miss(1'b0),
        .dcache_miss(1'b0),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .stall_e(stall_e),
        .stall_m(stall_m),
        .stall_w(),  // unused
        .flush_f(),  // unused
        .flush_d(flush_d),
        .flush_e(flush_e),
        .flush_m(flush_m),
        .flush_w(),  // unused
        .forward_1e(forward_1e),
        .forward_2e(forward_2e)
    );

    // =================================================================
    // Performance Counters (Optional)
    // =================================================================
    generate
        if (ENABLE_PERFORMANCE) begin : gen_performance
            reg [31:0] cycle_counter, instr_counter, stall_counter, branch_counter;
            
            always @(posedge clk) begin
                if (!sync_rst_n) begin
                    cycle_counter <= 32'h0;
                    instr_counter <= 32'h0;
                    stall_counter <= 32'h0;
                    branch_counter <= 32'h0;
                end else begin
                    cycle_counter <= cycle_counter + 1;
                    if (valid_w) instr_counter <= instr_counter + 1;
                    if (stall_f || stall_d || stall_e || stall_m) stall_counter <= stall_counter + 1;
                    if (branch_taken) branch_counter <= branch_counter + 1;
                end
            end
            
            assign cycle_count = cycle_counter;
            assign instr_count = instr_counter;
            assign stall_count = stall_counter;
            assign branch_count = branch_counter;
        end else begin : gen_no_performance
            assign cycle_count = 32'h0;
            assign instr_count = 32'h0;
            assign stall_count = 32'h0;
            assign branch_count = 32'h0;
        end
    endgenerate

    // =================================================================
    // Debug Interface Implementation (Optional)
    // =================================================================
    generate
        if (ENABLE_DEBUG) begin : gen_debug
            reg [DATA_WIDTH-1:0] debug_data_reg;
            
            always @(*) begin
                case (debug_select[7:4])
                    4'h0: debug_data_reg = pc_f;                    // Current PC
                    4'h1: debug_data_reg = instruction_f;           // Current instruction
                    4'h2: debug_data_reg = alu_result;             // ALU result
                    4'h3: debug_data_reg = mem_data;               // Memory data
                    4'h4: debug_data_reg = result_w;               // Write-back result
                    4'h5: debug_data_reg = {28'h0, mem_write_m};   // Memory write enable
                    4'h6: debug_data_reg = {29'h0, branch_taken, valid_e, valid_d}; // Pipeline status
                    4'h7: debug_data_reg = cycle_count;            // Cycle count
                    4'h8: debug_data_reg = instr_count;            // Instruction count
                    4'h9: debug_data_reg = stall_count;            // Stall count
                    4'hA: debug_data_reg = branch_count;           // Branch count
                    default: debug_data_reg = 32'hDEADBEEF;
                endcase
            end
            
            assign debug_data = debug_enable ? debug_data_reg : {DATA_WIDTH{1'b0}};
        end else begin : gen_no_debug
            assign debug_data = {DATA_WIDTH{1'b0}};
        end
    endgenerate

endmodule

// =============================================================================
// End of File
// =============================================================================
