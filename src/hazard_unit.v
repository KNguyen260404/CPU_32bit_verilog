// Hazard Detection and Forwarding Unit
// Handles data hazards, control hazards, and forwarding logic
// Based on Blog.md section 2.1 item 9)

// =============================================================================
// Local Constants (moved from riscv_constants.vh)
// =============================================================================
`define REG_ADDR_WIDTH      5           // 5-bit register address (32 regs)  

// Forwarding Unit Constants (2-bit encoding)
`define FORWARD_NONE        2'b00           // No forwarding
`define FORWARD_WB          2'b01           // Forward from WB stage
`define FORWARD_MEM         2'b10           // Forward from MEM stage

module hazard_unit (
    input  wire                         clk,    // unused but kept for interface
    input  wire                         rst_n,
    
    // Pipeline stage register addresses
    input  wire [`REG_ADDR_WIDTH-1:0]  rs1_d,          // Rs1D - unused in current implementation
    input  wire [`REG_ADDR_WIDTH-1:0]  rs2_d,          // Rs2D - unused in current implementation  
    input  wire [`REG_ADDR_WIDTH-1:0]  rs1_e,          // Rs1E - EX stage rs1
    input  wire [`REG_ADDR_WIDTH-1:0]  rs2_e,          // Rs2E - EX stage rs2
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_e,           // RdE - EX stage rd
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_m,           // RdM - MEM stage rd  
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_w,           // RdW - WB stage rd
    
    // Control signals for hazard detection
    input  wire [1:0]                   reg_read_e,     // RegReadE[1:0] - which regs are read in EX
    input  wire                         mem_to_reg_e,   // MemToRegE - EX stage loads from memory
    input  wire                         reg_write_m,    // RegWriteM - MEM stage writes to reg
    input  wire                         reg_write_w,    // RegWriteW - WB stage writes to reg
    
    // Control hazard signals
    input  wire                         branch_e,       // BranchE - branch taken in EX
    input  wire                         jalr_e,         // JalrE - JALR in EX  
    input  wire                         jal_d,          // JalD - JAL in ID
    
    // Cache miss signals (for future extension)
    input  wire                         icache_miss,
    input  wire                         dcache_miss,
    
    // Stall outputs for each stage
    output reg                          stall_f,        // StallF
    output reg                          stall_d,        // StallD  
    output reg                          stall_e,        // StallE
    output reg                          stall_m,        // StallM
    output reg                          stall_w,        // StallW
    
    // Flush outputs for each stage
    output reg                          flush_f,        // FlushF
    output reg                          flush_d,        // FlushD
    output reg                          flush_e,        // FlushE  
    output reg                          flush_m,        // FlushM
    output reg                          flush_w,        // FlushW
    
    // Forwarding control
    output reg  [1:0]                   forward_1e,     // Forward1E - operand 1 forwarding
    output reg  [1:0]                   forward_2e      // Forward2E - operand 2 forwarding
);

    // Internal hazard detection signals
    wire load_use_hazard;
    wire control_hazard;
    
    // Load-use hazard detection
    // Occurs when EX stage instruction loads from memory and next instruction uses the result
    assign load_use_hazard = mem_to_reg_e && 
                           ((reg_read_e[1] && (rs1_e == rd_e) && (rd_e != 5'b00000)) ||
                            (reg_read_e[0] && (rs2_e == rd_e) && (rd_e != 5'b00000)));
    
    // Control hazard detection  
    // Occurs when branch/jump changes PC
    assign control_hazard = branch_e || jalr_e || jal_d;
    
    // Forwarding logic for operand 1
    always @(*) begin
        // Check MEM stage forwarding first (more recent)
        if (reg_write_m && (rd_m != 5'b00000) && (rd_m == rs1_e)) begin
            forward_1e = `FORWARD_MEM;
        end
        // Check WB stage forwarding  
        else if (reg_write_w && (rd_w != 5'b00000) && (rd_w == rs1_e)) begin
            forward_1e = `FORWARD_WB;
        end
        // No forwarding needed
        else begin
            forward_1e = `FORWARD_NONE;
        end
    end
    
    // Forwarding logic for operand 2
    always @(*) begin
        // Check MEM stage forwarding first (more recent)  
        if (reg_write_m && (rd_m != 5'b00000) && (rd_m == rs2_e)) begin
            forward_2e = `FORWARD_MEM;
        end
        // Check WB stage forwarding
        else if (reg_write_w && (rd_w != 5'b00000) && (rd_w == rs2_e)) begin
            forward_2e = `FORWARD_WB;  
        end
        // No forwarding needed
        else begin
            forward_2e = `FORWARD_NONE;
        end
    end
    
    // Stall logic - Combinational (Following DES pattern)
    always @(*) begin
        if (!rst_n) begin
            // Reset state: no stalls
            stall_f = 1'b0;
            stall_d = 1'b0;
            stall_e = 1'b0;
            stall_m = 1'b0;
            stall_w = 1'b0;
        end else if (load_use_hazard) begin
            // Stall IF, ID, EX for load-use hazard (1 cycle penalty)
            stall_f = 1'b1;
            stall_d = 1'b1; 
            stall_e = 1'b0; // Let EX continue to resolve the load
            stall_m = 1'b0;
            stall_w = 1'b0;
        end else if (icache_miss || dcache_miss) begin
            // Stall entire pipeline for cache misses
            stall_f = 1'b1;
            stall_d = 1'b1;
            stall_e = 1'b1;
            stall_m = 1'b1;
            stall_w = 1'b1;
        end else begin
            // No stalls
            stall_f = 1'b0;
            stall_d = 1'b0;
            stall_e = 1'b0;
            stall_m = 1'b0;
            stall_w = 1'b0;
        end
    end
    
    // Flush logic - Combinational (Following DES pattern)
    always @(*) begin
        if (!rst_n) begin
            // Reset state: flush all stages to clear pipeline
            flush_f = 1'b1; 
            flush_d = 1'b1;
            flush_e = 1'b1;
            flush_m = 1'b1;
            flush_w = 1'b1;
        end else if (control_hazard) begin
            // Flush IF, ID for control hazards (branch misprediction penalty)
            flush_f = 1'b1;
            flush_d = 1'b1;
            flush_e = 1'b0; // EX stage resolves the branch
            flush_m = 1'b0;
            flush_w = 1'b0;
        end else if (load_use_hazard) begin
            // Insert bubble (NOP) in EX stage for load-use hazard
            flush_f = 1'b0;
            flush_d = 1'b0;
            flush_e = 1'b1; // Convert EX stage to NOP
            flush_m = 1'b0;
            flush_w = 1'b0;
        end else begin
            // No flushes
            flush_f = 1'b0;
            flush_d = 1'b0; 
            flush_e = 1'b0;
            flush_m = 1'b0;
            flush_w = 1'b0;
        end
    end

endmodule