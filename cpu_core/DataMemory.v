module DataMemory (
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output [31:0] read_data
);

    reg [31:0] data_mem [0:1023];
    
    assign read_data = mem_read ? data_mem[address[11:2]] : 32'h0;
    
    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[address[11:2]] <= write_data;
        end
    end

endmodule
