module ALU_output_register (
    input wire clk,              // Clock signal
    input wire reset,            // Reset signal
    input wire alu_out_write,    // Write enable signal
    input wire [31:0] result,    // Result input from ALU (renamed from result_in to match ALU output)
    output reg [31:0] result_out // Result output
);

    // Update the register on positive clock edge when write is enabled
    always @(posedge clk) begin
        if (reset) begin
            // Reset the register to 0
            result_out <= 32'b0;
        end else if (alu_out_write) begin
            // Store the ALU result when write is enabled
            result_out <= result;
        end
        // Otherwise, maintain the current value
    end

endmodule
