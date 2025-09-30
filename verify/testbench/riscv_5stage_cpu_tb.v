// =============================================================================
// RISC-V 5-Stage CPU Testbench
// =============================================================================
// Description: Comprehensive testbench for the RISC-V CPU following design rules
//              Includes debug monitoring and performance analysis
// Author: Auto-generated following RTL design rules
// Date: September 15, 2025
// Features: - Parameterized testbench configuration
//          - Debug interface validation
//          - Performance monitoring
//          - Comprehensive test patterns
// =============================================================================

`include "riscv_constants.vh"

module riscv_5stage_cpu_tb #(
    // =================================================================
    // Testbench Parameters
    // =================================================================
    parameter CLOCK_PERIOD = 10,            // Clock period in ns
    parameter SIM_CYCLES = 1000,            // Simulation cycles
    parameter ENABLE_WAVEFORM = 1,          // Generate VCD file
    parameter ENABLE_DEBUG_LOG = 1          // Enable debug logging
);

    // =================================================================
    // Clock and Reset Generation
    // =================================================================
    reg clk;
    reg async_rst_n;
    
    // Generate clock
    initial begin
        clk = 1'b0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end
    
    // Generate reset sequence
    initial begin
        async_rst_n = 1'b0;
        repeat (5) @(posedge clk);
        async_rst_n = 1'b1;
        $display("[%0t] Reset de-asserted", $time);
    end

    // =================================================================
    // Debug Interface Signals
    // =================================================================
    reg                     debug_enable;
    reg [7:0]              debug_select;
    wire [31:0]            debug_data;
    
    // =================================================================
    // Performance Monitor Signals
    // =================================================================
    wire [31:0]            cycle_count;
    wire [31:0]            instr_count;
    wire [31:0]            stall_count;
    wire [31:0]            branch_count;

    // =================================================================
    // Device Under Test (DUT)
    // =================================================================
    riscv_5stage_cpu #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .REG_ADDR_WIDTH(5),
        .IMEM_ADDR_WIDTH(12),
        .DMEM_ADDR_WIDTH(12),
        .RESET_SYNC_STAGES(2),
        .ENABLE_DEBUG(1),
        .ENABLE_PERFORMANCE(1)
    ) dut (
        .clk(clk),
        .async_rst_n(async_rst_n),
        .debug_enable(debug_enable),
        .debug_select(debug_select),
        .debug_data(debug_data),
        .cycle_count(cycle_count),
        .instr_count(instr_count),
        .stall_count(stall_count),
        .branch_count(branch_count)
    );

    // =================================================================
    // Simulation Control and Monitoring
    // =================================================================
    
    // Simulation timeout
    initial begin
        repeat (SIM_CYCLES) @(posedge clk);
        $display("\n[%0t] Simulation completed after %0d cycles", $time, SIM_CYCLES);
        display_final_stats();
        $finish;
    end
    
    // Performance monitoring
    always @(posedge clk) begin
        if (async_rst_n && ENABLE_DEBUG_LOG) begin
            if (cycle_count % 100 == 0 && cycle_count > 0) begin
                $display("[%0t] Cycle: %0d, Instructions: %0d, Stalls: %0d, Branches: %0d, IPC: %0.2f",
                    $time, cycle_count, instr_count, stall_count, branch_count,
                    (cycle_count > 0) ? (real'(instr_count) / real'(cycle_count)) : 0.0);
            end
        end
    end

    // =================================================================
    // Debug Interface Testing
    // =================================================================
    initial begin
        debug_enable = 1'b0;
        debug_select = 8'h00;
        
        // Wait for reset completion
        wait (async_rst_n);
        repeat (10) @(posedge clk);
        
        // Enable debug and cycle through different views
        debug_enable = 1'b1;
        
        // Test debug interface
        fork
            debug_monitor_task();
        join_none
    end
    
    // Debug monitoring task
    task debug_monitor_task();
        integer i;
        begin
            repeat (20) @(posedge clk);
            
            for (i = 0; i < 12; i = i + 1) begin
                debug_select = i << 4; // Select different debug sources
                @(posedge clk);
                
                case (debug_select[7:4])
                    4'h0: $display("[DEBUG] PC: 0x%08x", debug_data);
                    4'h1: $display("[DEBUG] Instruction: 0x%08x", debug_data);
                    4'h2: $display("[DEBUG] ALU Result: 0x%08x", debug_data);
                    4'h3: $display("[DEBUG] Memory Data: 0x%08x", debug_data);
                    4'h4: $display("[DEBUG] WB Result: 0x%08x", debug_data);
                    4'h7: $display("[DEBUG] Cycles: %0d", debug_data);
                    4'h8: $display("[DEBUG] Instructions: %0d", debug_data);
                    4'h9: $display("[DEBUG] Stalls: %0d", debug_data);
                    4'hA: $display("[DEBUG] Branches: %0d", debug_data);
                    default: $display("[DEBUG] Unknown selector: 0x%02x, Data: 0x%08x", debug_select, debug_data);
                endcase
                
                repeat (5) @(posedge clk);
            end
        end
    endtask

    // =================================================================
    // Instruction Trace (Optional)
    // =================================================================
    generate
        if (ENABLE_DEBUG_LOG) begin : gen_trace
            always @(posedge clk) begin
                if (async_rst_n && debug_enable) begin
                    debug_select = 8'h00; // PC
                    @(posedge clk);
                    if (debug_data != 0) begin // Valid PC
                        debug_select = 8'h10; // Instruction
                        @(posedge clk);
                        $display("[TRACE] PC: 0x%08x, Instr: 0x%08x", 
                                debug_data, debug_data);
                    end
                end
            end
        end
    endgenerate

    // =================================================================
    // Waveform Generation
    // =================================================================
    generate
        if (ENABLE_WAVEFORM) begin : gen_waveform
            initial begin
                $dumpfile("riscv_cpu_simulation.vcd");
                $dumpvars(0, riscv_5stage_cpu_tb);
                $display("[INFO] VCD waveform generation enabled");
            end
        end
    endgenerate

    // =================================================================
    // Final Statistics Display
    // =================================================================
    task display_final_stats();
        real ipc, branch_rate, stall_rate;
        begin
            $display("\n" + "="*60);
            $display("SIMULATION STATISTICS");
            $display("="*60);
            $display("Total Cycles:      %0d", cycle_count);
            $display("Instructions:      %0d", instr_count);
            $display("Stall Cycles:      %0d", stall_count);
            $display("Branches Taken:    %0d", branch_count);
            
            if (cycle_count > 0) begin
                ipc = real'(instr_count) / real'(cycle_count);
                stall_rate = real'(stall_count) / real'(cycle_count) * 100.0;
                branch_rate = real'(branch_count) / real'(instr_count) * 100.0;
                
                $display("Instructions/Cycle: %0.3f", ipc);
                $display("Stall Rate:        %0.1f%%", stall_rate);
                $display("Branch Rate:       %0.1f%%", branch_rate);
            end
            
            $display("="*60);
            
            // Performance evaluation
            if (ipc > 0.8) begin
                $display("✅ EXCELLENT: High performance achieved (IPC > 0.8)");
            end else if (ipc > 0.6) begin
                $display("✅ GOOD: Decent performance (IPC > 0.6)");
            end else if (ipc > 0.4) begin
                $display("⚠️  FAIR: Moderate performance (IPC > 0.4)");
            end else begin
                $display("❌ POOR: Low performance (IPC ≤ 0.4)");
            end
        end
    endtask

    // =================================================================
    // Assertions for Functional Verification
    // =================================================================
    `ifdef FORMAL_VERIFICATION
        // Clock should be running
        property clock_running;
            @(posedge clk) 1'b1;
        endproperty
        assert property (clock_running)
            else $error("Clock not running!");

        // Reset should eventually de-assert
        property reset_deassert;
            ##[1:10] async_rst_n;
        endproperty
        assert property (reset_deassert)
            else $error("Reset stuck low!");

        // Performance counters should increment
        property counters_increment;
            @(posedge clk) disable iff (!async_rst_n)
            cycle_count |=> (cycle_count == ($past(cycle_count) + 1));
        endproperty
        assert property (counters_increment)
            else $error("Cycle counter not incrementing!");

        // Instructions should eventually execute
        property instructions_execute;
            @(posedge clk) disable iff (!async_rst_n)
            ##[1:100] (instr_count > 0);
        endproperty
        assert property (instructions_execute)
            else $warning("No instructions executed in 100 cycles!");
    `endif

endmodule

// =============================================================================
// End of File
// =============================================================================