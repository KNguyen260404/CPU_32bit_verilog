module ForwardingUnit (
    input [4:0] rs1_ex,
    input [4:0] rs2_ex,
    input [4:0] rd_mem,
    input [4:0] rd_wb,
    input reg_write_mem,
    input reg_write_wb,
    
    output [1:0] forward_a,
    output [1:0] forward_b
);

    // Forwarding logic for ALU input A
    assign forward_a = (reg_write_mem & (rd_mem != 0) & (rd_mem == rs1_ex)) ? 2'b10 :
                      (reg_write_wb & (rd_wb != 0) & (rd_wb == rs1_ex)) ? 2'b01 :
                      2'b00;
    
    // Forwarding logic for ALU input B
    assign forward_b = (reg_write_mem & (rd_mem != 0) & (rd_mem == rs2_ex)) ? 2'b10 :
                      (reg_write_wb & (rd_wb != 0) & (rd_wb == rs2_ex)) ? 2'b01 :
                      2'b00;

endmodule
