// =============================================================================
// Control Unit Testbench - Comprehensive Verification
// =============================================================================
// Description: Tests all RISC-V instruction types and control signal generation
// Author: Auto-generated testbench
// Date: September 23, 2025
// Features: - All instruction types testing
//          - Control signal verification
//          - Invalid instruction handling
//          - Self-checking testbench
// =============================================================================

`timescale 1ns / 1ps

module control_unit_tb;

    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10;
    parameter VERBOSE_MODE = 1;
    
    // =================================================================
    // Test Signal Declarations
    // =================================================================
    reg [6:0]   opcode;
    reg [2:0]   funct3;
    reg [6:0]   funct7;
    
    // Control outputs
    wire        jal_d;
    wire        jalr_d;
    wire        reg_write_d;
    wire        mem_to_reg_d;
    wire [3:0]  mem_write_d;
    wire        load_npc_d;
    wire [1:0]  reg_read_d;
    wire [2:0]  branch_type_d;
    wire [3:0]  alu_control_d;
    wire [1:0]  alu_src1_d;
    wire [1:0]  alu_src2_d;
    wire [2:0]  imm_type;
    wire [2:0]  load_type_d;
    
    // Test control
    reg clk;
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // =================================================================
    // RISC-V Constants (matching control_unit.v)
    // =================================================================
    // Opcodes
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_OP_IMM = 7'b0010011;
    localparam OPCODE_OP     = 7'b0110011;
    
    // Funct3
    localparam FUNCT3_ADD_SUB = 3'b000;
    localparam FUNCT3_SLL     = 3'b001;
    localparam FUNCT3_SLT     = 3'b010;
    localparam FUNCT3_SLTU    = 3'b011;
    localparam FUNCT3_XOR     = 3'b100;
    localparam FUNCT3_SRL_SRA = 3'b101;
    localparam FUNCT3_OR      = 3'b110;
    localparam FUNCT3_AND     = 3'b111;
    
    // Load/Store Funct3
    localparam FUNCT3_LB  = 3'b000;
    localparam FUNCT3_LH  = 3'b001;
    localparam FUNCT3_LW  = 3'b010;
    localparam FUNCT3_LBU = 3'b100;
    localparam FUNCT3_LHU = 3'b101;
    localparam FUNCT3_SB  = 3'b000;
    localparam FUNCT3_SH  = 3'b001;
    localparam FUNCT3_SW  = 3'b010;
    
    // Branch Funct3
    localparam FUNCT3_BEQ  = 3'b000;
    localparam FUNCT3_BNE  = 3'b001;
    localparam FUNCT3_BLT  = 3'b100;
    localparam FUNCT3_BGE  = 3'b101;
    localparam FUNCT3_BLTU = 3'b110;
    localparam FUNCT3_BGEU = 3'b111;
    
    // ALU Operations
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;
    
    // Immediate Types
    localparam IMM_TYPE_I = 3'b000;
    localparam IMM_TYPE_S = 3'b001;
    localparam IMM_TYPE_B = 3'b010;
    localparam IMM_TYPE_U = 3'b011;
    localparam IMM_TYPE_J = 3'b100;
    
    // ALU Sources
    localparam ALU_SRC_REG = 2'b00;
    localparam ALU_SRC_IMM = 2'b01;
    localparam ALU_SRC_PC  = 2'b10;
    
    // Register Read
    localparam REG_READ_NONE = 2'b00;
    localparam REG_READ_RS1  = 2'b01;
    localparam REG_READ_RS2  = 2'b10;
    localparam REG_READ_BOTH = 2'b11;
    
    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    control_unit dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .jal_d(jal_d),
        .jalr_d(jalr_d),
        .reg_write_d(reg_write_d),
        .mem_to_reg_d(mem_to_reg_d),
        .mem_write_d(mem_write_d),
        .load_npc_d(load_npc_d),
        .reg_read_d(reg_read_d),
        .branch_type_d(branch_type_d),
        .alu_control_d(alu_control_d),
        .alu_src1_d(alu_src1_d),
        .alu_src2_d(alu_src2_d),
        .imm_type(imm_type),
        .load_type_d(load_type_d)
    );
    
    // =================================================================
    // Clock Generation
    // =================================================================
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end
    
    // =================================================================
    // Test Execution Control
    // =================================================================
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        opcode = 7'h0;
        funct3 = 3'h0;
        funct7 = 7'h0;
        
        $display("========================================");
        $display("CONTROL UNIT TESTBENCH STARTING");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Wait for settling
        #(CLOCK_PERIOD * 2);
        
        // Run test suites
        run_lui_auipc_tests();
        run_jal_jalr_tests();
        run_branch_tests();
        run_load_tests();
        run_store_tests();
        run_op_imm_tests();
        run_op_reg_tests();
        run_invalid_instruction_tests();
        
        // Display results
        display_test_summary();
        
        #100;
        $finish;
    end
    
    // =================================================================
    // Test Suite: LUI and AUIPC Instructions
    // =================================================================
    task run_lui_auipc_tests();
        begin
            $display("\n[%0t] Running LUI and AUIPC Tests...", $time);
            
            // LUI rd, imm
            test_control_signals(
                OPCODE_LUI, 3'bxxx, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_NONE, 3'bxxx, 
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_U, 3'bxxx,
                "LUI instruction"
            );
            
            // AUIPC rd, imm  
            test_control_signals(
                OPCODE_AUIPC, 3'bxxx, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_NONE, 3'bxxx,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_U, 3'bxxx,
                "AUIPC instruction"
            );
            
            $display("LUI and AUIPC Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: JAL and JALR Instructions
    // =================================================================
    task run_jal_jalr_tests();
        begin
            $display("\n[%0t] Running JAL and JALR Tests...", $time);
            
            // JAL rd, imm
            test_control_signals(
                OPCODE_JAL, 3'bxxx, 7'bxxxxxxx,
                1'b1, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b1, REG_READ_NONE, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, 2'b10, IMM_TYPE_J, 3'bxxx,
                "JAL instruction"
            );
            
            // JALR rd, rs1, imm
            test_control_signals(
                OPCODE_JALR, 3'b000, 7'b0000000,
                1'b0, 1'b1, 1'b1, 1'b0, 4'b0000, 1'b1, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, 2'b10, IMM_TYPE_I, 3'bxxx,
                "JALR instruction"
            );
            
            $display("JAL and JALR Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Branch Instructions
    // =================================================================
    task run_branch_tests();
        begin
            $display("\n[%0t] Running Branch Tests...", $time);
            
            // BEQ rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BEQ, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BEQ,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BEQ instruction"
            );
            
            // BNE rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BNE, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BNE,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BNE instruction"
            );
            
            // BLT rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BLT, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BLT,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BLT instruction"
            );
            
            // BGE rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BGE, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BGE,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BGE instruction"
            );
            
            // BLTU rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BLTU, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BLTU,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BLTU instruction"
            );
            
            // BGEU rs1, rs2, imm
            test_control_signals(
                OPCODE_BRANCH, FUNCT3_BGEU, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, FUNCT3_BGEU,
                ALU_ADD, ALU_SRC_PC, ALU_SRC_IMM, IMM_TYPE_B, 3'bxxx,
                "BGEU instruction"
            );
            
            $display("Branch Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Load Instructions
    // =================================================================
    task run_load_tests();
        begin
            $display("\n[%0t] Running Load Tests...", $time);
            
            // LB rd, imm(rs1)
            test_control_signals(
                OPCODE_LOAD, FUNCT3_LB, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, FUNCT3_LB,
                "LB instruction"
            );
            
            // LH rd, imm(rs1)
            test_control_signals(
                OPCODE_LOAD, FUNCT3_LH, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, FUNCT3_LH,
                "LH instruction"
            );
            
            // LW rd, imm(rs1)
            test_control_signals(
                OPCODE_LOAD, FUNCT3_LW, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, FUNCT3_LW,
                "LW instruction"
            );
            
            // LBU rd, imm(rs1)
            test_control_signals(
                OPCODE_LOAD, FUNCT3_LBU, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, FUNCT3_LBU,
                "LBU instruction"
            );
            
            // LHU rd, imm(rs1)
            test_control_signals(
                OPCODE_LOAD, FUNCT3_LHU, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, FUNCT3_LHU,
                "LHU instruction"
            );
            
            $display("Load Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Store Instructions
    // =================================================================
    task run_store_tests();
        begin
            $display("\n[%0t] Running Store Tests...", $time);
            
            // SB rs2, imm(rs1)
            test_control_signals(
                OPCODE_STORE, FUNCT3_SB, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0001, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_S, 3'bxxx,
                "SB instruction"
            );
            
            // SH rs2, imm(rs1)
            test_control_signals(
                OPCODE_STORE, FUNCT3_SH, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0011, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_S, 3'bxxx,
                "SH instruction"
            );
            
            // SW rs2, imm(rs1)
            test_control_signals(
                OPCODE_STORE, FUNCT3_SW, 7'bxxxxxxx,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b1111, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_S, 3'bxxx,
                "SW instruction"
            );
            
            $display("Store Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Immediate Operations
    // =================================================================
    task run_op_imm_tests();
        begin
            $display("\n[%0t] Running Immediate Operation Tests...", $time);
            
            // ADDI rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_ADD_SUB, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "ADDI instruction"
            );
            
            // SLTI rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_SLT, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_SLT, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "SLTI instruction"
            );
            
            // SLTIU rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_SLTU, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_SLTU, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "SLTIU instruction"
            );
            
            // XORI rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_XOR, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_XOR, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "XORI instruction"
            );
            
            // ORI rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_OR, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_OR, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "ORI instruction"
            );
            
            // ANDI rd, rs1, imm
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_AND, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_AND, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "ANDI instruction"
            );
            
            // SLLI rd, rs1, shamt
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_SLL, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_SLL, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "SLLI instruction"
            );
            
            // SRLI rd, rs1, shamt
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_SRL_SRA, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_SRL, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "SRLI instruction"
            );
            
            // SRAI rd, rs1, shamt
            test_control_signals(
                OPCODE_OP_IMM, FUNCT3_SRL_SRA, 7'b0100000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_RS2, 3'bxxx,
                ALU_SRA, ALU_SRC_REG, ALU_SRC_IMM, IMM_TYPE_I, 3'bxxx,
                "SRAI instruction"
            );
            
            $display("Immediate Operation Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Register-Register Operations  
    // =================================================================
    task run_op_reg_tests();
        begin
            $display("\n[%0t] Running Register-Register Operation Tests...", $time);
            
            // ADD rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_ADD_SUB, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "ADD instruction"
            );
            
            // SUB rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_ADD_SUB, 7'b0100000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SUB, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SUB instruction"
            );
            
            // SLT rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_SLT, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SLT, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SLT instruction"
            );
            
            // SLTU rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_SLTU, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SLTU, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SLTU instruction"
            );
            
            // XOR rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_XOR, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_XOR, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "XOR instruction"
            );
            
            // OR rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_OR, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_OR, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "OR instruction"
            );
            
            // AND rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_AND, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_AND, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "AND instruction"
            );
            
            // SLL rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_SLL, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SLL, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SLL instruction"
            );
            
            // SRL rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_SRL_SRA, 7'b0000000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SRL, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SRL instruction"
            );
            
            // SRA rd, rs1, rs2
            test_control_signals(
                OPCODE_OP, FUNCT3_SRL_SRA, 7'b0100000,
                1'b0, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, REG_READ_BOTH, 3'bxxx,
                ALU_SRA, ALU_SRC_REG, ALU_SRC_REG, 3'bxxx, 3'bxxx,
                "SRA instruction"
            );
            
            $display("Register-Register Operation Tests Completed");
        end
    endtask
    
    // =================================================================
    // Test Suite: Invalid Instructions
    // =================================================================
    task run_invalid_instruction_tests();
        begin
            $display("\n[%0t] Running Invalid Instruction Tests...", $time);
            
            // Invalid opcode
            test_control_signals(
                7'b1111111, 3'b000, 7'b0000000,
                1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, REG_READ_NONE, 3'b000,
                ALU_ADD, ALU_SRC_REG, ALU_SRC_REG, IMM_TYPE_I, 3'b010,
                "Invalid opcode - should produce default values"
            );
            
            $display("Invalid Instruction Tests Completed");
        end
    endtask
    
    // =================================================================
    // Helper Task: Test Control Signal Generation
    // =================================================================
    task test_control_signals(
        input [6:0]  test_opcode,
        input [2:0]  test_funct3,
        input [6:0]  test_funct7,
        input        exp_jal_d,
        input        exp_jalr_d,
        input        exp_reg_write_d,
        input        exp_mem_to_reg_d,
        input [3:0]  exp_mem_write_d,
        input        exp_load_npc_d,
        input [1:0]  exp_reg_read_d,
        input [2:0]  exp_branch_type_d,
        input [3:0]  exp_alu_control_d,
        input [1:0]  exp_alu_src1_d,
        input [1:0]  exp_alu_src2_d,
        input [2:0]  exp_imm_type,
        input [2:0]  exp_load_type_d,
        input [200*8:1] test_name
    );
        reg test_passed;
        begin
            test_count = test_count + 1;
            test_passed = 1'b1;
            
            // Apply inputs
            opcode = test_opcode;
            funct3 = test_funct3;
            funct7 = test_funct7;
            
            // Wait for propagation
            #1;
            
            // Check each signal (skip don't care values marked with 'x')
            if (exp_jal_d !== 1'bx && jal_d !== exp_jal_d) test_passed = 1'b0;
            if (exp_jalr_d !== 1'bx && jalr_d !== exp_jalr_d) test_passed = 1'b0;
            if (exp_reg_write_d !== 1'bx && reg_write_d !== exp_reg_write_d) test_passed = 1'b0;
            if (exp_mem_to_reg_d !== 1'bx && mem_to_reg_d !== exp_mem_to_reg_d) test_passed = 1'b0;
            if (exp_mem_write_d !== 4'bxxxx && mem_write_d !== exp_mem_write_d) test_passed = 1'b0;
            if (exp_load_npc_d !== 1'bx && load_npc_d !== exp_load_npc_d) test_passed = 1'b0;
            if (exp_reg_read_d !== 2'bxx && reg_read_d !== exp_reg_read_d) test_passed = 1'b0;
            if (exp_branch_type_d !== 3'bxxx && branch_type_d !== exp_branch_type_d) test_passed = 1'b0;
            if (exp_alu_control_d !== 4'bxxxx && alu_control_d !== exp_alu_control_d) test_passed = 1'b0;
            if (exp_alu_src1_d !== 2'bxx && alu_src1_d !== exp_alu_src1_d) test_passed = 1'b0;
            if (exp_alu_src2_d !== 2'bxx && alu_src2_d !== exp_alu_src2_d) test_passed = 1'b0;
            if (exp_imm_type !== 3'bxxx && imm_type !== exp_imm_type) test_passed = 1'b0;
            if (exp_load_type_d !== 3'bxxx && load_type_d !== exp_load_type_d) test_passed = 1'b0;
            
            // Report result
            if (test_passed) begin
                pass_count = pass_count + 1;
                if (VERBOSE_MODE) begin
                    $display("  ✅ PASS: %0s", test_name);
                end
            end else begin
                fail_count = fail_count + 1;
                $display("  ❌ FAIL: %0s", test_name);
                $display("      Opcode: 0x%02h, Funct3: 0x%01h, Funct7: 0x%02h", 
                         test_opcode, test_funct3, test_funct7);
                display_signal_comparison(exp_jal_d, jal_d, "jal_d");
                display_signal_comparison(exp_jalr_d, jalr_d, "jalr_d");
                display_signal_comparison(exp_reg_write_d, reg_write_d, "reg_write_d");
                display_signal_comparison(exp_mem_to_reg_d, mem_to_reg_d, "mem_to_reg_d");
                if (exp_mem_write_d !== 4'bxxxx && mem_write_d !== exp_mem_write_d)
                    $display("        mem_write_d: Expected 0x%01h, Got 0x%01h", exp_mem_write_d, mem_write_d);
                display_signal_comparison(exp_load_npc_d, load_npc_d, "load_npc_d");
                if (exp_reg_read_d !== 2'bxx && reg_read_d !== exp_reg_read_d)
                    $display("        reg_read_d: Expected 0x%01h, Got 0x%01h", exp_reg_read_d, reg_read_d);
                if (exp_branch_type_d !== 3'bxxx && branch_type_d !== exp_branch_type_d)
                    $display("        branch_type_d: Expected 0x%01h, Got 0x%01h", exp_branch_type_d, branch_type_d);
                if (exp_alu_control_d !== 4'bxxxx && alu_control_d !== exp_alu_control_d)
                    $display("        alu_control_d: Expected 0x%01h, Got 0x%01h", exp_alu_control_d, alu_control_d);
                if (exp_alu_src1_d !== 2'bxx && alu_src1_d !== exp_alu_src1_d)
                    $display("        alu_src1_d: Expected 0x%01h, Got 0x%01h", exp_alu_src1_d, alu_src1_d);
                if (exp_alu_src2_d !== 2'bxx && alu_src2_d !== exp_alu_src2_d)
                    $display("        alu_src2_d: Expected 0x%01h, Got 0x%01h", exp_alu_src2_d, alu_src2_d);
                if (exp_imm_type !== 3'bxxx && imm_type !== exp_imm_type)
                    $display("        imm_type: Expected 0x%01h, Got 0x%01h", exp_imm_type, imm_type);
                if (exp_load_type_d !== 3'bxxx && load_type_d !== exp_load_type_d)
                    $display("        load_type_d: Expected 0x%01h, Got 0x%01h", exp_load_type_d, load_type_d);
            end
        end
    endtask
    
    // Helper task for single bit signal comparison
    task display_signal_comparison(
        input exp_val,
        input act_val,
        input [100*8:1] signal_name
    );
        begin
            if (exp_val !== 1'bx && act_val !== exp_val) begin
                $display("        %0s: Expected %0b, Got %0b", signal_name, exp_val, act_val);
            end
        end
    endtask
    
    // =================================================================
    // Test Summary Display
    // =================================================================
    task display_test_summary();
        real pass_rate;
        begin
            $display("\n========================================");
            $display("CONTROL UNIT TESTBENCH SUMMARY");
            $display("========================================");
            $display("Total Tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (test_count > 0) begin
                pass_rate = ($itor(pass_count) / $itor(test_count)) * 100.0;
                $display("Pass Rate:    %0.1f%%", pass_rate);
                
                if (fail_count == 0) begin
                    $display("🎉 ALL TESTS PASSED! Control Unit implementation is correct.");
                end else begin
                    $display("⚠️  Some tests failed. Review Control Unit implementation.");
                end
            end
            
            $display("========================================");
            $display("Simulation completed at time: %0t", $time);
        end
    endtask
    
    // =================================================================
    // Waveform Dumping
    // =================================================================
    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
    end

endmodule
