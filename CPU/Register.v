module Register (
    input wire clk,              // Tín hiệu xung nhịp
    input wire reset,            // Tín hiệu reset
    input wire reg_write,        // Cho phép ghi vào thanh ghi
    input wire [31:0] data_in,   // Dữ liệu đầu vào
    output reg [31:0] data_out   // Dữ liệu đầu ra
);

    // Cập nhật thanh ghi khi có xung dương và tín hiệu cho phép ghi
    always @(posedge clk) begin
        if (reset) begin
            // Reset thanh ghi về 0
            data_out <= 32'b0;
        end else if (reg_write) begin
            // Ghi dữ liệu khi có tín hiệu cho phép
            data_out <= data_in;
        end
        // Nếu không, giữ nguyên giá trị hiện tại
    end

endmodule
