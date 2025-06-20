module Register_File (
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire [4:0] rd_addr,
    input wire [31:0] write_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    // Register file with 32 registers of 32 bits each
    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous read (combinational)
    assign rs1_data = (rs1_addr == 5'b00000) ? 32'h00000000 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b00000) ? 32'h00000000 : registers[rs2_addr];

    // Synchronous write
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h00000000;
            end
        end else begin
            // Write to register if reg_write is enabled and rd_addr is not x0
            if (reg_write && (rd_addr != 5'b00000)) begin
                registers[rd_addr] <= write_data;
            end
        end
    end

endmodule
