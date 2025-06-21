module Program_Counter(
    input clk,
    input reset,
    input [31:0] pc_next,
    input pc_write,
    output reg [31:0] pc_current
);

    // Initialize PC to 0 on reset or update on clock edge when pc_write is enabled
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_current <= 32'h00000000;  // Reset to 0x00000000
        end else if (pc_write) begin
            pc_current <= pc_next;       // Update PC when pc_write is enabled
        end
    end

endmodule
