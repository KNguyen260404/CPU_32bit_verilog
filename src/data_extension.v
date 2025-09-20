// Data Extension Module
// Handles load data extension for different load sizes (LB, LH, LW, LBU, LHU)
// Based on Blog.md section 2.1 item 8)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define DATA_WIDTH          32          // 32-bit data bus

// Funct3 Constants for Load Operations
`define FUNCT3_LB           3'b000          // Load Byte
`define FUNCT3_LH           3'b001          // Load Halfword
`define FUNCT3_LW           3'b010          // Load Word
`define FUNCT3_LBU          3'b100          // Load Byte Unsigned
`define FUNCT3_LHU          3'b101          // Load Halfword Unsigned

module data_extension (
    // 32-bit word from data memory
    input  wire [`DATA_WIDTH-1:0]  memory_data,
    
    // Address bits [1:0] to select byte/halfword within word
    input  wire [1:0]               byte_select,
    
    // Load instruction funct3 to determine extension type
    input  wire [2:0]               load_type,
    
    // Extended data output for register write
    output reg  [`DATA_WIDTH-1:0]  extended_data
);

    // Extract byte and halfword from memory data based on address
    wire [7:0]  selected_byte;
    wire [15:0] selected_halfword;
    
    // Byte selection mux
    always @(*) begin
        case (byte_select)
            2'b00: selected_byte = memory_data[7:0];
            2'b01: selected_byte = memory_data[15:8];
            2'b10: selected_byte = memory_data[23:16];
            2'b11: selected_byte = memory_data[31:24];
        endcase
    end
    
    // Halfword selection mux  
    assign selected_halfword = byte_select[1] ? memory_data[31:16] : memory_data[15:0];
    
    // Extension logic based on load type
    always @(*) begin
        case (load_type)
            `FUNCT3_LB: begin
                // Load byte with sign extension
                extended_data = {{24{selected_byte[7]}}, selected_byte};
            end
            
            `FUNCT3_LH: begin
                // Load halfword with sign extension
                extended_data = {{16{selected_halfword[15]}}, selected_halfword};
            end
            
            `FUNCT3_LW: begin
                // Load word (no extension needed)
                extended_data = memory_data;
            end
            
            `FUNCT3_LBU: begin
                // Load byte unsigned (zero extension)
                extended_data = {24'h000000, selected_byte};
            end
            
            `FUNCT3_LHU: begin
                // Load halfword unsigned (zero extension)  
                extended_data = {16'h0000, selected_halfword};
            end
            
            default: begin
                // Default to word load
                extended_data = memory_data;
            end
        endcase
    end

endmodule