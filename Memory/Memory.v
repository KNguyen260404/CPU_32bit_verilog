module Memory (
    input wire clk,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire mem_write,
    input wire mem_read,
    input wire [1:0] size,  // 00: byte, 01: half-word, 10: word
    output reg [31:0] read_data
);

    // Define memory size (8KB = 2048 words)
    parameter MEM_SIZE = 2048;
    
    // Memory array (byte addressable)
    reg [7:0] memory [0:MEM_SIZE*4-1];
    
    // Declare the loop variable outside the initial block
    integer i;
    
    // Read operation (combinational)
    always @(*) begin
        if (mem_read) begin
            case (size)
                2'b00: begin // Byte
                    read_data = {{24{memory[address][7]}}, memory[address]};
                end
                2'b01: begin // Half-word
                    read_data = {{16{memory[address+1][7]}}, memory[address+1], memory[address]};
                end
                2'b10: begin // Word
                    read_data = {memory[address+3], memory[address+2], memory[address+1], memory[address]};
                end
                default: begin
                    read_data = {memory[address+3], memory[address+2], memory[address+1], memory[address]};
                end
            endcase
        end else begin
            read_data = 32'h0;
        end
    end
    
    // Write operation (synchronous)
    always @(posedge clk) begin
        if (mem_write) begin
            case (size)
                2'b00: begin // Byte
                    memory[address] <= write_data[7:0];
                end
                2'b01: begin // Half-word
                    memory[address] <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                end
                2'b10: begin // Word
                    memory[address] <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                    memory[address+2] <= write_data[23:16];
                    memory[address+3] <= write_data[31:24];
                end
                default: begin
                    memory[address] <= write_data[7:0];
                    memory[address+1] <= write_data[15:8];
                    memory[address+2] <= write_data[23:16];
                    memory[address+3] <= write_data[31:24];
                end
            endcase
        end
    end
    
    // Initialize memory (optional)
    // Can be used to load a program or initial data
    initial begin
        for (i = 0; i < MEM_SIZE*4; i = i + 1) begin
            memory[i] = 8'h0;
        end
        
        // Example: Load a simple program (optional)
        // memory[0] = 8'h13; // addi x0, x0, 0 (NOP)
        // memory[1] = 8'h01;
        // memory[2] = 8'h00;
        // memory[3] = 8'h00;
    end

endmodule
