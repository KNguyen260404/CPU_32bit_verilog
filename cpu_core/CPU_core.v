module CPU_core(
    input wire clk,
    input wire reset,
    output wire [31:0] pc_current,
    output wire [31:0] instruction_debug,
    output wire [3:0] pipeline_state,
    output wire [31:0] debug_reg1,
    output wire [31:0] debug_reg2,
    output wire [31:0] debug_reg3
);

    // ========== PIPELINE REGISTERS ==========
    
    // IF/ID Pipeline Register
    reg [31:0] if_id_instruction;
    reg [31:0] if_id_pc;
    reg        if_id_valid;
    
    // ID/EX Pipeline Register
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1_data;
    reg [31:0] id_ex_rs2_data;
    reg [31:0] id_ex_immediate;
    reg [4:0]  id_ex_rs1_addr;
    reg [4:0]  id_ex_rs2_addr;
    reg [4:0]  id_ex_rd_addr;
    reg [2:0]  id_ex_funct3;
    reg        id_ex_funct7_bit5;  // Only store the bit we actually need
    reg [11:0] id_ex_control;
    reg        id_ex_valid;
    
    // EX/MEM Pipeline Register
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_write_data;
    reg [4:0]  ex_mem_rd_addr;
    reg [7:0]  ex_mem_control;
    reg        ex_mem_valid;
    
    // MEM/WB Pipeline Register
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_read_data;
    reg [4:0]  mem_wb_rd_addr;
    reg [3:0]  mem_wb_control;
    reg        mem_wb_valid;

    // ========== CONTROL SIGNAL EXTRACTION ==========
    
    // ID/EX Control Signals [11:0]
    wire id_reg_write     = id_ex_control[11];
    wire id_mem_to_reg    = id_ex_control[10];
    wire id_mem_read      = id_ex_control[9];
    wire id_mem_write     = id_ex_control[8];
    wire id_branch        = id_ex_control[7];
    wire id_jump          = id_ex_control[6];
    wire [1:0] id_alu_src = id_ex_control[5:4];
    wire [1:0] id_alu_op  = id_ex_control[3:2];
    wire [1:0] id_pc_src  = id_ex_control[1:0];
    
    // EX/MEM Control Signals [7:0]
    wire ex_reg_write     = ex_mem_control[7];
    wire ex_mem_to_reg    = ex_mem_control[6];
    wire ex_mem_read      = ex_mem_control[5];
    wire ex_mem_write     = ex_mem_control[4];
    
    // MEM/WB Control Signals [3:0]
    wire wb_reg_write     = mem_wb_control[3];
    wire wb_mem_to_reg    = mem_wb_control[2];

    // ========== DATAPATH WIRES ==========
    
    // PC and instruction fetch
    wire [31:0] pc_next;
    wire [31:0] instruction_fetch;
    
    // Register file
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] immediate;
    wire [11:0] control_signals;
    
    // ALU
    wire [31:0] alu_result;
    wire [3:0] alu_control;
    wire alu_zero_unused;  // Dummy wire for unused zero output
    wire [31:0] alu_operand_a, alu_operand_b;
    
    // Branch and jump
    wire branch_taken;
    wire [31:0] branch_target;
    
    // Memory
    wire [31:0] memory_read_data;
    
    // Write back
    wire [31:0] write_back_data;
    
    // Forwarding
    wire [1:0] forward_a, forward_b;
    wire [31:0] forwarded_rs1_data, forwarded_rs2_data;
    
    // ========== FORWARDING UNIT ==========
    
    ForwardingUnit forwarding_unit(
        .rs1_ex(id_ex_rs1_addr),
        .rs2_ex(id_ex_rs2_addr),
        .rd_mem(ex_mem_rd_addr),
        .rd_wb(mem_wb_rd_addr),
        .reg_write_mem(ex_reg_write),
        .reg_write_wb(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // ========== INSTRUCTION FETCH STAGE ==========
    
    // Program Counter
    reg [31:0] pc_reg;
    
    // PC Next Logic - Simplified
    assign pc_next = pc_reg + 4;
    
    // PC Update
    always @(posedge clk) begin
        if (reset) begin
            pc_reg <= 32'h00000000;
        end else begin
            pc_reg <= pc_next;
        end
    end
    
    // Instruction Memory (Harvard Architecture)
    InstructionMemory imem(
        .address({pc_reg[31:2], 2'b00}),  // Word-aligned
        .instruction(instruction_fetch)
    );
    
    // IF/ID Pipeline Register Update
    always @(posedge clk) begin
        if (reset) begin
            if_id_instruction <= 32'h00000013;  // nop (addi x0, x0, 0)
            if_id_pc <= 32'h00000000;
            if_id_valid <= 1'b0;
        end else begin
            if_id_instruction <= instruction_fetch;
            if_id_pc <= pc_reg;
            if_id_valid <= 1'b1;
        end
    end

    // ========== INSTRUCTION DECODE STAGE ==========
    
    // Register File
    RegisterFile_Optimized register_file(
        .clk(clk),
        .reset(reset),
        .rs1_addr(if_id_instruction[19:15]),
        .rs2_addr(if_id_instruction[24:20]),
        .rd_addr(mem_wb_rd_addr),
        .write_enable(wb_reg_write & mem_wb_valid),
        .write_data(write_back_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .debug_reg1(debug_reg1),
        .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3)
    );
    
    // Immediate Generator
    ImmediateGenerator_Fast imm_gen(
        .instruction(if_id_instruction),
        .immediate(immediate)
    );
    
    // Control Unit
    ControlUnit_Fast control_unit(
        .opcode(if_id_instruction[6:0]),
        .control_signals(control_signals)
    );
    
    // ID/EX Pipeline Register Update
    always @(posedge clk) begin
        if (reset) begin
            id_ex_pc <= 32'h00000000;
            id_ex_rs1_data <= 32'h00000000;
            id_ex_rs2_data <= 32'h00000000;
            id_ex_immediate <= 32'h00000000;
            id_ex_rs1_addr <= 5'h00;
            id_ex_rs2_addr <= 5'h00;
            id_ex_rd_addr <= 5'h00;
            id_ex_funct3 <= 3'h0;
            id_ex_funct7_bit5 <= 1'b0;
            id_ex_control <= 12'h000;
            id_ex_valid <= 1'b0;
        end else begin
            id_ex_pc <= if_id_pc;
            id_ex_rs1_data <= rs1_data;
            id_ex_rs2_data <= rs2_data;
            id_ex_immediate <= immediate;
            id_ex_rs1_addr <= if_id_instruction[19:15];
            id_ex_rs2_addr <= if_id_instruction[24:20];
            id_ex_rd_addr <= if_id_instruction[11:7];
            id_ex_funct3 <= if_id_instruction[14:12];
            // Only extract funct7 bit 5 for R-type instructions (OP_REG = 0110011)
            // For I-type instructions, this should be 0
            id_ex_funct7_bit5 <= (if_id_instruction[6:0] == 7'b0110011) ? if_id_instruction[30] : 1'b0;
            id_ex_control <= control_signals;
            id_ex_valid <= if_id_valid;
        end
    end

    // ========== EXECUTE STAGE ==========
    
    // Forwarding Muxes
    assign forwarded_rs1_data = (forward_a == 2'b10) ? ex_mem_alu_result :
                                (forward_a == 2'b01) ? write_back_data :
                                id_ex_rs1_data;
                                
    assign forwarded_rs2_data = (forward_b == 2'b10) ? ex_mem_alu_result :
                                (forward_b == 2'b01) ? write_back_data :
                                id_ex_rs2_data;
    
    // ALU Input Selection
    assign alu_operand_a = (id_alu_src[1]) ? id_ex_pc : forwarded_rs1_data;
    assign alu_operand_b = (id_alu_src[0]) ? id_ex_immediate : forwarded_rs2_data;
    
    // Fast ALU (Optimized for 1GHz)
    FastALU alu(
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero_unused)  // Connected to dummy wire
    );
    
    // ALU Control
    ALUControl_Fast alu_ctrl(
        .alu_op(id_alu_op),
        .funct3(id_ex_funct3),
        .funct7_bit30(id_ex_funct7_bit5),
        .alu_control(alu_control)
    );
    
    // Branch Logic
    BranchUnit branch_unit(
        .rs1_data(forwarded_rs1_data),
        .rs2_data(forwarded_rs2_data),
        .funct3(id_ex_funct3),
        .branch_enable(id_branch),
        .branch_taken(branch_taken)
    );
    
    // Branch Target Calculation
    assign branch_target = id_ex_pc + id_ex_immediate;
    
    // EX/MEM Pipeline Register Update
    always @(posedge clk) begin
        if (reset) begin
            ex_mem_alu_result <= 32'h00000000;
            ex_mem_write_data <= 32'h00000000;
            ex_mem_rd_addr <= 5'h00;
            ex_mem_control <= 8'h00;
            ex_mem_valid <= 1'b0;
        end else begin
            ex_mem_alu_result <= alu_result;
            ex_mem_write_data <= forwarded_rs2_data;
            ex_mem_rd_addr <= id_ex_rd_addr;
            ex_mem_control <= {id_reg_write, id_mem_to_reg, id_mem_read, id_mem_write, id_branch, id_jump, id_pc_src};
            ex_mem_valid <= id_ex_valid;
        end
    end

    // ========== MEMORY ACCESS STAGE ==========
    
    // Data Memory (Harvard Architecture)
    DataMemory dmem(
        .clk(clk),
        .address({ex_mem_alu_result[31:2], 2'b00}),  // Word-aligned
        .write_data(ex_mem_write_data),
        .mem_read(ex_mem_read),
        .mem_write(ex_mem_write),
        .read_data(memory_read_data)
    );
    
    // MEM/WB Pipeline Register Update
    always @(posedge clk) begin
        if (reset) begin
            mem_wb_alu_result <= 32'h00000000;
            mem_wb_read_data <= 32'h00000000;
            mem_wb_rd_addr <= 5'h00;
            mem_wb_control <= 4'h0;
            mem_wb_valid <= 1'b0;
        end else begin
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_read_data <= memory_read_data;
            mem_wb_rd_addr <= ex_mem_rd_addr;
            mem_wb_control <= {ex_reg_write, ex_mem_to_reg, ex_mem_control[1:0]};
            mem_wb_valid <= ex_mem_valid;
        end
    end

    // ========== WRITE BACK STAGE ==========
    
    // Write Back Data Selection
    assign write_back_data = wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result;

    // ========== DEBUG SIGNALS ==========
    
    assign pc_current = pc_reg;
    assign instruction_debug = if_id_instruction;
    assign pipeline_state = {if_id_valid, id_ex_valid, ex_mem_valid, mem_wb_valid};
    
    // Debug register outputs are now connected through RegisterFile_Optimized module ports

endmodule
