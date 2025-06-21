module Memory_Address_Register (
    input wire clk,
    input wire reset,
    input wire mar_write,
    input wire [31:0] address_in,
    output reg [31:0] address_out
);

    // Synchronous update of memory address register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            address_out <= 32'h0; // Reset to 0
        end else if (mar_write) begin
            address_out <= address_in; // Update when mar_write is enabled
        end
    end

endmodule
