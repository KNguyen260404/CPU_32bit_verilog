module Branch_Comparator(
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [2:0] branch_op,
    output reg branch_result
);

    // Branch operation codes
    localparam BEQ  = 3'b000;  // Equal
    localparam BNE  = 3'b001;  // Not equal
    localparam BLT  = 3'b010;  // Less than (signed)
    localparam BGE  = 3'b011;  // Greater than or equal (signed)
    localparam BLTU = 3'b100;  // Less than (unsigned)
    localparam BGEU = 3'b101;  // Greater than or equal (unsigned)

    // Combinational logic for branch comparison
    always @(*) begin
        case (branch_op)
            BEQ:  branch_result = (rs1_data == rs2_data);
            BNE:  branch_result = (rs1_data != rs2_data);
            BLT:  branch_result = ($signed(rs1_data) < $signed(rs2_data));
            BGE:  branch_result = ($signed(rs1_data) >= $signed(rs2_data));
            BLTU: branch_result = (rs1_data < rs2_data);
            BGEU: branch_result = (rs1_data >= rs2_data);
            default: branch_result = 1'b0;
        endcase
    end

endmodule
