module CPU(
    input wire clk,
    input wire reset,
    output wire [31:0] pc_current
);

    // Internal wires for control signals
    wire pc_write, ir_write, mar_write, mdr_write, reg_write, a_write, b_write, alu_out_write;
    wire mem_read, mem_write, RegDst, MemtoReg, IorD;
    wire [1:0] ALUOp, PCSource;
    wire [2:0] imm_type, branch_op;
    wire [3:0] current_state;
    
    // Internal wires for datapath
    wire [31:0] pc_next, memory_address, memory_data_in, memory_data_out;
    wire [31:0] instruction, a_reg_out, b_reg_out, alu_result, alu_out_reg;
    wire [31:0] reg_write_data, reg_read_data1, reg_read_data2;
    wire [31:0] mdr_out, mar_out;
    wire [31:0] immediate;
    
    // ALU operands and control
    wire [31:0] alu_operand_a, alu_operand_b;
    wire [4:0] alu_control;
    wire alu_zero, alu_negative, alu_overflow;
    
    // Branch comparison result
    wire branch_result;
    
    // Instruction fields
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    
    // Register addresses
    wire [4:0] reg_read_addr1, reg_read_addr2, reg_write_addr;
    
    // ALU input sources
    wire [1:0] ALUSrcA, ALUSrcB;
    
    // For ALU input muxes - replace the always blocks with continuous assignments
    wire [31:0] a_input_options [0:3];
    assign a_input_options[0] = pc_current;
    assign a_input_options[1] = a_reg_out;
    assign a_input_options[2] = 32'h0; // For LUI instruction, use 0 as first operand
    assign a_input_options[3] = 32'h0; // Not used
    assign alu_operand_a = a_input_options[ALUSrcA];
    
    wire [31:0] b_input_options [0:3];
    assign b_input_options[0] = b_reg_out;
    assign b_input_options[1] = 32'h4; // PC+4
    assign b_input_options[2] = immediate; // Immediate value
    assign b_input_options[3] = immediate << 2; // Shifted immediate
    assign alu_operand_b = b_input_options[ALUSrcB];
    
    // Instruction decoding - use continuous assignments instead of always block
    assign opcode = instruction[6:0];
    assign rd_addr = instruction[11:7];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    // Program Counter
    Program_Counter pc(
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );
    
    // PC source multiplexer
    MUX4to1 pc_mux(
        .select(PCSource),
        .input0(alu_result),    // PC+4
        .input1(alu_out_reg),   // Branch/Jump target
        .input2({alu_out_reg[31:1], 1'b0}), // JALR (clear LSB)
        .input3(32'h0),         // Not used
        .out(pc_next)
    );
    
    // Memory address multiplexer
    MUX2to1 mem_addr_mux(
        .select(IorD),
        .input0(pc_current),    // PC for instruction fetch
        .input1(alu_out_reg),   // ALU output for data access
        .out(memory_address)
    );
    
    // Memory
    Memory memory(
        .clk(clk),
        .reset(reset),
        .address(memory_address),
        .write_data(b_reg_out),
        .read_data(memory_data_out),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .size(2'b10)  // Always use word size (32-bit)
    );
    
    // Instruction Register
    Instruction_Register ir(
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(memory_data_out),
        .instruction_out(instruction)
    );
    
    // Register File
    Register_File register_file(
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(reg_write_data),
        .rs1_data(reg_read_data1),
        .rs2_data(reg_read_data2)
    );
    
    // Check for specific instructions
    wire is_lui = (opcode == 7'b0110111); // LUI opcode
    wire is_addi = (opcode == 7'b0010011) && (funct3 == 3'b000); // ADDI opcode+funct3
    wire is_signed_op = is_addi || (opcode == 7'b0110011 && funct3 == 3'b000); // ADDI or ADD/SUB
    
    // Create proper LUI immediate (20 bits shifted left by 12)
    wire [31:0] lui_immediate = {instruction[31:12], 12'b0};
    
    // Register write data multiplexer with special handling for LUI
    wire [31:0] reg_write_data_pre;
    
    MUX2to1 reg_data_mux(
        .select(MemtoReg),
        .input0(alu_out_reg),   // ALU result
        .input1(mdr_out),       // Memory data
        .out(reg_write_data_pre)
    );
    
    // Special handling for LUI - pass immediate directly to register
    assign reg_write_data = is_lui ? lui_immediate : reg_write_data_pre;
    
    // A and B registers
    Register a_reg(
        .clk(clk),
        .reset(reset),
        .reg_write(a_write),
        .data_in(reg_read_data1),
        .data_out(a_reg_out)
    );
    
    Register b_reg(
        .clk(clk),
        .reset(reset),
        .reg_write(b_write),
        .data_in(reg_read_data2),
        .data_out(b_reg_out)
    );
    
    // ALU
    ALU alu(
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .shift_amount(instruction[24:20]),
        .result(alu_result),
        .zero(alu_zero),
        .overflow(alu_overflow)
    );
    
    // ALU Control Unit
    ALU_control_unit alu_control_unit(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );
    
    // ALU Output Register
    ALU_output_register alu_out_reg_inst(
        .clk(clk),
        .reset(reset),
        .alu_out_write(alu_out_write),
        .result(alu_result),
        .result_out(alu_out_reg)
    );
    
    // Memory Data Register (MDR)
    Memory_Data_Register mdr(
        .clk(clk),
        .reset(reset),
        .mdr_write(mdr_write),
        .data_in(memory_data_out),
        .data_out(mdr_out)
    );
    
    // Memory Address Register (MAR)
    Memory_Address_Register mar(
        .clk(clk),
        .reset(reset),
        .mar_write(mar_write),
        .address_in(memory_address),
        .address_out(mar_out)
    );
    
    // Branch Comparator
    Branch_Comparator branch_comp(
        .rs1_data(a_reg_out),
        .rs2_data(b_reg_out),
        .branch_op(branch_op),
        .branch_result(branch_result)
    );
    
    // Immediate Generator
    Immediate_Generator imm_gen(
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );
    
    // Control Unit
    Control_Unit control_unit(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero(alu_zero),
        .negative(alu_negative),
        .branch_result(branch_result),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .mar_write(mar_write),
        .mdr_write(mdr_write),
        .reg_write(reg_write),
        .a_write(a_write),
        .b_write(b_write),
        .alu_out_write(alu_out_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .ALUOp(ALUOp),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .PCSource(PCSource),
        .RegDst(RegDst),
        .MemtoReg(MemtoReg),
        .IorD(IorD),
        .imm_type(imm_type),
        .branch_op(branch_op),
        .current_state(current_state)
    );

endmodule
