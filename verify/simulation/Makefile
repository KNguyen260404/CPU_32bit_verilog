# =============================================================================
# Makefile for RISC-V CPU Testbenches
# =============================================================================

# Simulator (change this based on your setup)
SIM = vsim
VLOG = vlog
VOPT = vopt

# Directories
SRC_DIR = ../src
VERIFY_DIR = .
RESULTS_DIR = results

# Design files
ALU_SRC = $(SRC_DIR)/alu.v
CONTROL_SRC = $(SRC_DIR)/control_unit.v
REGFILE_SRC = $(SRC_DIR)/register_file.v
IMM_GEN_SRC = $(SRC_DIR)/immediate_generator.v
BRANCH_SRC = $(SRC_DIR)/branch_decision.v
DATA_EXT_SRC = $(SRC_DIR)/data_extension.v
CPU_SRCS = $(SRC_DIR)/*.v

# Testbench files  
ALU_TB = alu_tb.v
CONTROL_TB = control_unit_tb.v
REGFILE_TB = register_file_tb.v
IMM_GEN_TB = immediate_generator_tb.v
BRANCH_TB = branch_decision_tb.v
DATA_EXT_TB = data_extension_tb.v
CPU_TB = riscv_5stage_cpu_comprehensive_tb.v

# Default target
all: setup alu_test control_test regfile_test immgen_test branch_test dataext_test summary

# Setup results directory
setup:
	@echo "Setting up test environment..."
	@mkdir -p $(RESULTS_DIR)
	@cd $(RESULTS_DIR)

# Individual module tests
alu_test: setup
	@echo "=========================================="
	@echo "Testing ALU Module"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(ALU_SRC) ../$(ALU_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim alu_tb; run -all; quit" > alu_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "ALU test completed. Check alu_test.log and alu_tb.vcd"

control_test: setup
	@echo "=========================================="
	@echo "Testing Control Unit Module"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(CONTROL_SRC) ../$(CONTROL_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim control_unit_tb; run -all; quit" > control_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "Control Unit test completed. Check control_test.log and control_unit_tb.vcd"

regfile_test: setup
	@echo "=========================================="
	@echo "Testing Register File Module"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(REGFILE_SRC) ../$(REGFILE_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim register_file_tb; run -all; quit" > regfile_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "Register File test completed. Check regfile_test.log and register_file_tb.vcd"

immgen_test: setup
	@echo "=========================================="
	@echo "Testing Immediate Generator Module"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(IMM_GEN_SRC) ../$(IMM_GEN_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim immediate_generator_tb; run -all; quit" > immgen_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "Immediate Generator test completed. Check immgen_test.log and immediate_generator_tb.vcd"

branch_test: setup
	@echo "=========================================="
	@echo "Testing Branch Decision Module"  
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(BRANCH_SRC) ../$(BRANCH_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim branch_decision_tb; run -all; quit" > branch_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "Branch Decision test completed. Check branch_test.log and branch_decision_tb.vcd"

dataext_test: setup
	@echo "=========================================="
	@echo "Testing Data Extension Module"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(DATA_EXT_SRC) ../$(DATA_EXT_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim data_extension_tb; run -all; quit" > dataext_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "Data Extension test completed. Check dataext_test.log and data_extension_tb.vcd"

cpu_test: setup
	@echo "=========================================="
	@echo "Testing Complete CPU System"
	@echo "=========================================="
	@cd $(RESULTS_DIR) && $(VLOG) ../$(CPU_SRCS) ../$(CPU_TB)
	@cd $(RESULTS_DIR) && $(SIM) -batch -do "vsim riscv_5stage_cpu_comprehensive_tb; run -all; quit" > cpu_test.log 2>&1
	@cd $(RESULTS_DIR) && echo "CPU system test completed. Check cpu_test.log and riscv_cpu_comprehensive.vcd"

# Quick individual tests
alu: alu_test
control: control_test
regfile: regfile_test
immgen: immgen_test
branch: branch_test
dataext: dataext_test
cpu: cpu_test

# View waveforms
wave_alu:
	@cd $(RESULTS_DIR) && gtkwave alu_tb.vcd &

wave_control:
	@cd $(RESULTS_DIR) && gtkwave control_unit_tb.vcd &

wave_regfile:
	@cd $(RESULTS_DIR) && gtkwave register_file_tb.vcd &

wave_immgen:
	@cd $(RESULTS_DIR) && gtkwave immediate_generator_tb.vcd &

wave_branch:
	@cd $(RESULTS_DIR) && gtkwave branch_decision_tb.vcd &

wave_dataext:
	@cd $(RESULTS_DIR) && gtkwave data_extension_tb.vcd &

wave_cpu:
	@cd $(RESULTS_DIR) && gtkwave riscv_cpu_comprehensive.vcd &

# Summary of test results
summary:
	@echo ""
	@echo "=========================================="
	@echo "TEST SUMMARY"
	@echo "=========================================="
	@echo "Generated files in $(RESULTS_DIR):"
	@cd $(RESULTS_DIR) && ls -la *.vcd 2>/dev/null || echo "No VCD files found"
	@echo ""
	@echo "Test logs:"
	@cd $(RESULTS_DIR) && ls -la *.log 2>/dev/null || echo "No log files found"
	@echo ""
	@echo "To view waveforms, use:"
	@echo "  make wave_alu"
	@echo "  make wave_control"
	@echo "  make wave_regfile"
	@echo "  make wave_immgen"
	@echo "  make wave_branch"
	@echo "  make wave_dataext"
	@echo "  make wave_cpu"

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf $(RESULTS_DIR)
	@rm -f *.wlf transcript

# Help
help:
	@echo "Available targets:"
	@echo "  all        - Run all individual module tests"
	@echo "  alu        - Test ALU module only"
	@echo "  control    - Test Control Unit module only"
	@echo "  regfile    - Test Register File module only"
	@echo "  immgen     - Test Immediate Generator module only"
	@echo "  branch     - Test Branch Decision module only"
	@echo "  dataext    - Test Data Extension module only"
	@echo "  cpu        - Test complete CPU system"
	@echo "  wave_*     - Open waveform viewer for specific module"
	@echo "  summary    - Show test results summary"
	@echo "  clean      - Clean up generated files"
	@echo "  help       - Show this help"

.PHONY: all setup summary clean help alu control regfile immgen branch dataext cpu \
        alu_test control_test regfile_test immgen_test branch_test dataext_test cpu_test \
        wave_alu wave_control wave_regfile wave_immgen wave_branch wave_dataext wave_cpu

