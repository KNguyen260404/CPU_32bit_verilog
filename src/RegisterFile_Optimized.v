// Optimized Register File for 1GHz operation
// Dual-port read, single-port write
// Optimized for synthesis and timing closure

module RegisterFile_Optimized(
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire        write_enable,
    input  wire [31:0] write_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    // Debug outputs
    output wire [31:0] debug_reg1,
    output wire [31:0] debug_reg2,
    output wire [31:0] debug_reg3
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];
    
    // Asynchronous read for better timing
    // x0 is always zero in RISC-V
    assign rs1_data = (rs1_addr == 5'b00000) ? 32'h00000000 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b00000) ? 32'h00000000 : registers[rs2_addr];
    
    // Synchronous write
    always @(posedge clk) begin
        if (reset) begin
            // Reset all registers to 0
            // Use generate loop for better synthesis
            registers[0]  <= 32'h00000000;  registers[1]  <= 32'h00000000;
            registers[2]  <= 32'h00000000;  registers[3]  <= 32'h00000000;
            registers[4]  <= 32'h00000000;  registers[5]  <= 32'h00000000;
            registers[6]  <= 32'h00000000;  registers[7]  <= 32'h00000000;
            registers[8]  <= 32'h00000000;  registers[9]  <= 32'h00000000;
            registers[10] <= 32'h00000000;  registers[11] <= 32'h00000000;
            registers[12] <= 32'h00000000;  registers[13] <= 32'h00000000;
            registers[14] <= 32'h00000000;  registers[15] <= 32'h00000000;
            registers[16] <= 32'h00000000;  registers[17] <= 32'h00000000;
            registers[18] <= 32'h00000000;  registers[19] <= 32'h00000000;
            registers[20] <= 32'h00000000;  registers[21] <= 32'h00000000;
            registers[22] <= 32'h00000000;  registers[23] <= 32'h00000000;
            registers[24] <= 32'h00000000;  registers[25] <= 32'h00000000;
            registers[26] <= 32'h00000000;  registers[27] <= 32'h00000000;
            registers[28] <= 32'h00000000;  registers[29] <= 32'h00000000;
            registers[30] <= 32'h00000000;  registers[31] <= 32'h00000000;
        end else begin
            // Write to register if write_enable is high and address is not x0
            if (write_enable && (rd_addr != 5'b00000)) begin
                registers[rd_addr] <= write_data;
                // Debug: Monitor register writes for simulation
                `ifdef SIMULATION
                $display("Time: %0t - Register x%0d = 0x%08h", $time, rd_addr, write_data);
                `endif
            end
        end
    end

    // Debug outputs
    assign debug_reg1 = registers[1];
    assign debug_reg2 = registers[2];
    assign debug_reg3 = registers[3];

endmodule
