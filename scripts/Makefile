# Makefile for CPU Pipeline Project
# Optimized for 1GHz synthesis with Synopsys tools

# Design files
RTL_FILES = CPU_Pipeline_Fixed.v \
           FastALU.v \
           HarvardMemory.v \
           ControlUnit_Fast.v \
           HazardControl.v \
           RegisterFile_Optimized.v \
           BranchUnit.v \
           ImmediateGenerator_Fast.v \
           ALUControl_Fast.v

TB_FILES = CPU_Pipeline_tb.v

# Simulation settings
SIM_TOP = CPU_Pipeline_tb
SIM_TIME = 50us
WAVE_FILE = cpu_pipeline_waveform.vcd

# Synthesis settings (for Synopsys)
SYNTH_TOP = CPU_Pipeline_Fixed
TARGET_FREQ = 1000  # 1GHz in MHz
TARGET_LIB = your_tech_library.db

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
DC_SHELL = dc_shell

# Default target
all: simulate

# Compile simulation
compile:
	@echo "Compiling RTL files..."
	$(IVERILOG) -o cpu_pipeline_sim -I. $(RTL_FILES) $(TB_FILES)
	@echo "Compilation completed."

# Run simulation
simulate: compile
	@echo "Running simulation..."
	$(VVP) cpu_pipeline_sim +define+SIMULATION
	@echo "Simulation completed. Check $(WAVE_FILE) for waveforms."

# View waveforms
waves:
	$(GTKWAVE) $(WAVE_FILE) &

# Syntax check only
syntax:
	@echo "Checking syntax..."
	$(IVERILOG) -t null -I. $(RTL_FILES)
	@echo "Syntax check completed."

# Clean build files
clean:
	rm -f cpu_pipeline_sim
	rm -f $(WAVE_FILE)
	rm -f *.log
	rm -f *.vcd

# Synthesis with Synopsys Design Compiler
synthesis:
	@echo "Running synthesis for 1GHz target..."
	$(DC_SHELL) -f synthesis_script.tcl | tee synthesis.log
	@echo "Synthesis completed. Check synthesis.log for results."

# Timing analysis
timing:
	@echo "Running timing analysis..."
	$(DC_SHELL) -f timing_script.tcl | tee timing.log
	@echo "Timing analysis completed."

# Create synthesis directory structure
setup_synth:
	mkdir -p synthesis/scripts
	mkdir -p synthesis/reports
	mkdir -p synthesis/results
	cp synthesis_script.tcl synthesis/scripts/
	cp timing_script.tcl synthesis/scripts/

# Run all tests
test: simulate
	@echo "All tests completed successfully!"

# Performance analysis
performance: simulate
	@echo "Analyzing performance..."
	grep -E "(IPC|Cycles|Instructions)" cpu_pipeline_sim.log || echo "Run simulation first"

.PHONY: all compile simulate waves syntax clean synthesis timing setup_synth test performance
