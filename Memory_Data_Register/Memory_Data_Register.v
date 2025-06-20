module Memory_Data_Register (
    input wire clk,
    input wire reset,
    input wire mdr_write,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);

    // Synchronous update of memory data register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 32'h0; // Reset to 0
        end else if (mdr_write) begin
            data_out <= data_in; // Update when mdr_write is enabled
        end
    end

endmodule
