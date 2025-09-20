# =============================================================================
# RISC-V 5-Stage CPU Timing Constraints (SDC)
# =============================================================================
# Description: Synopsys Design Constraints for RISC-V CPU synthesis
# Author: Auto-generated for OpenLane flow
# Date: September 15, 2025
# Clock Period: 10ns (100MHz target frequency)
# =============================================================================

# =============================================================================
# Clock Definition
# =============================================================================
# Define primary clock with 100MHz frequency (10ns period)
create_clock -name clk -period 10.0 [get_ports clk]

# Set clock uncertainty (jitter + skew budget) - more conservative
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]

# Set clock transition time
set_clock_transition 0.15 [get_clocks clk]

# =============================================================================
# Reset Constraints
# =============================================================================
# Asynchronous reset - no timing constraints needed
# Set as false path to avoid timing analysis
set_false_path -from [get_ports async_rst_n]

# =============================================================================
# Input Constraints
# =============================================================================
# Set input delay for synchronous inputs relative to clock
# Conservative delays: assuming slow external logic (6ns max, 4ns min)
# This provides more setup/hold margin for first silicon
set_input_delay -clock clk -max 6.0 [get_ports debug_enable]
set_input_delay -clock clk -min 4.0 [get_ports debug_enable]

set_input_delay -clock clk -max 6.0 [get_ports debug_select*]
set_input_delay -clock clk -min 4.0 [get_ports debug_select*]

# =============================================================================
# Output Constraints  
# =============================================================================
# Set output delay for all outputs relative to clock
# Using standard convention: max = 60% of period, min = 40% of period
# Clock period = 10ns → max = 6ns, min = 4ns
set_output_delay -clock clk -max 6.0 [get_ports debug_data*]
set_output_delay -clock clk -min 4.0 [get_ports debug_data*]

set_output_delay -clock clk -max 6.0 [get_ports cycle_count*]
set_output_delay -clock clk -min 4.0 [get_ports cycle_count*]

set_output_delay -clock clk -max 6.0 [get_ports instr_count*]
set_output_delay -clock clk -min 4.0 [get_ports instr_count*]

set_output_delay -clock clk -max 6.0 [get_ports stall_count*]
set_output_delay -clock clk -min 4.0 [get_ports stall_count*]

set_output_delay -clock clk -max 6.0 [get_ports branch_count*]
set_output_delay -clock clk -min 4.0 [get_ports branch_count*]

# =============================================================================
# Load Constraints
# =============================================================================
# Set output load capacitance (typical for external logic)
set_load 0.05 [get_ports debug_data*]
set_load 0.05 [get_ports cycle_count*]
set_load 0.05 [get_ports instr_count*] 
set_load 0.05 [get_ports stall_count*]
set_load 0.05 [get_ports branch_count*]

# =============================================================================
# Driving Cell Constraints
# =============================================================================
# Set driving strength for input ports (assuming standard buffer)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_1 -pin Y [get_ports debug_enable]
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_1 -pin Y [get_ports debug_select*]

# Clock driving cell (stronger driver for clock tree)
set_driving_cell -lib_cell sky130_fd_sc_hd__clkbuf_4 -pin X [get_ports clk]

# Reset driving cell (strong enough for reset tree)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 -pin Y [get_ports async_rst_n]

# =============================================================================
# Design Rule Constraints
# =============================================================================
# Maximum transition time constraint
set_max_transition 0.75 [current_design]

# Maximum fanout constraint  
set_max_fanout 20 [current_design]

# Maximum capacitance constraint
set_max_capacitance 0.2 [current_design]

# =============================================================================
# Area and Power Constraints
# =============================================================================
# Set area constraint (optional - let tool optimize)
# set_max_area 0

# Set power optimization (optional)
# set_max_dynamic_power 0

# =============================================================================
# Multi-Cycle and False Path Constraints
# =============================================================================
# Performance counters can be slower (multi-cycle)
# These are not critical timing paths
set_multicycle_path -setup 2 -to [get_ports cycle_count*]
set_multicycle_path -setup 2 -to [get_ports instr_count*]
set_multicycle_path -setup 2 -to [get_ports stall_count*]
set_multicycle_path -setup 2 -to [get_ports branch_count*]

# Debug interface can also be relaxed
set_multicycle_path -setup 2 -to [get_ports debug_data*]

# =============================================================================
# Case Analysis for Static Conditions
# =============================================================================
# If debug is typically disabled, we can set it as constant for optimization
# Uncomment the following line if debug is usually disabled:
# set_case_analysis 0 [get_ports debug_enable]

# =============================================================================
# Environment Conditions
# =============================================================================
# Set operating conditions (if not set by library)
# These may be overridden by the technology library
set_operating_conditions -max_library sky130_fd_sc_hd__tt_025C_1v80 -min_library sky130_fd_sc_hd__tt_025C_1v80

# =============================================================================
# Wire Load Model
# =============================================================================
# Use appropriate wire load model for the technology
# set_wire_load_model -name "conservative" -library sky130_fd_sc_hd

# =============================================================================
# End of Constraints
# =============================================================================
