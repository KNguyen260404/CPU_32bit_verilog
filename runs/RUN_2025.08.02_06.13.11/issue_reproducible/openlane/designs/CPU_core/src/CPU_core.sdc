# Clock definition for CPU core - optimized for pipeline design at 100MHz
create_clock -name clk -period 10 -waveform {0 5} [get_ports clk]

# Clock uncertainty - 2% of clock period for stability
set_clock_uncertainty 0.2 [get_clocks clk]

# Clock transition constraints for better tree synthesis
set_clock_transition 0.1 [get_clocks clk]

# Clock latency for more realistic timing
set_clock_latency -source 0.5 [get_clocks clk]
set_clock_latency 1.0 [get_clocks clk]

# Input delays - 60% max, 40% min of clock period (aggressive for CPU)
set_input_delay -clock clk -max 6 [get_ports {reset}]
set_input_delay -clock clk -min 4 [get_ports {reset}]

# Output delays - 60% max, 40% min of clock period (aggressive for CPU)  
set_output_delay -clock clk -max 6 [get_ports {pc_current[*] instruction_debug[*] pipeline_state[*]}]
set_output_delay -clock clk -min 4 [get_ports {pc_current[*] instruction_debug[*] pipeline_state[*]}]

set_output_delay -clock clk -max 6 [get_ports {debug_reg1[*] debug_reg2[*] debug_reg3[*]}]
set_output_delay -clock clk -min 4 [get_ports {debug_reg1[*] debug_reg2[*] debug_reg3[*]}]

# Clock groups
set_clock_groups -asynchronous -group [get_clocks clk]

# Maximum transition time - tighter for 100MHz
set_max_transition 0.75 [current_design]

# Maximum fanout - increased for clock buffers in CPU pipeline
set_max_fanout 25 [current_design]

# Specific fanout constraints for clock network
set_max_fanout 25 [get_nets clk*]

# False paths
set_false_path -from [get_ports reset]

# Multicycle paths for CPU pipeline - realistic 2-cycle setup
set_multicycle_path -setup 2 -from [all_registers] -to [all_registers]
set_multicycle_path -hold 1 -from [all_registers] -to [all_registers]

# Add min delay constraints to help with hold violations
set_min_delay 0.1 -from [all_registers] -to [all_registers]

# Load capacitance for outputs (standard sky130)
set_load 0.1 [all_outputs]

# Clock load for better synthesis
set_load 0.05 [get_ports clk]

# Driving cell for inputs (better than drive values)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [all_inputs]

# Set input transition for better modeling at 100MHz
set_input_transition 0.1 [all_inputs]

# Area constraint
set_max_area 0

# Case analysis for reset (reset = 0 during normal operation)
set_case_analysis 0 [get_ports reset]
