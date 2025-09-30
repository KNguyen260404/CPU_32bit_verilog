# =============================================================================
# Makefile for RISC-V CPU Testbenches - Icarus Verilog
# =============================================================================

# Simulator (Icarus Verilog)
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
SRC_DIR = ../../src
TB_DIR = ../testbench
RESULTS_DIR = ../results

# Design source files
ALU_SRC = $(SRC_DIR)/alu.v
BRANCH_SRC = $(SRC_DIR)/branch_decision.v
CONTROL_SRC = $(SRC_DIR)/control_unit.v
DATA_EXT_SRC = $(SRC_DIR)/data_extension.v
DATA_MEM_SRC = $(SRC_DIR)/data_memory.v
FORWARD_SRC = $(SRC_DIR)/forwarding_unit.v
HAZARD_SRC = $(SRC_DIR)/hazard_unit.v
IMM_GEN_SRC = $(SRC_DIR)/immediate_generator.v
INST_MEM_SRC = $(SRC_DIR)/instruction_memory.v
NPC_GEN_SRC = $(SRC_DIR)/npc_generator.v
REGFILE_SRC = $(SRC_DIR)/register_file.v
RESET_SYNC_SRC = $(SRC_DIR)/reset_synchronizer.v
CPU_TOP_SRC = $(SRC_DIR)/riscv_5stage_cpu.v

# Testbench files
ALU_TB = $(TB_DIR)/alu_tb.v
BRANCH_TB = $(TB_DIR)/branch_decision_tb.v
CONTROL_TB = $(TB_DIR)/control_unit_tb.v
DATA_EXT_TB = $(TB_DIR)/data_extension_tb.v
DATA_MEM_TB = $(TB_DIR)/data_memory_tb.v
FORWARD_TB = $(TB_DIR)/forwarding_unit_tb.v
HAZARD_TB = $(TB_DIR)/hazard_unit_tb.v
IMM_GEN_TB = $(TB_DIR)/immediate_generator_tb.v
INST_MEM_TB = $(TB_DIR)/instruction_memory_tb.v
NPC_GEN_TB = $(TB_DIR)/npc_generator_tb.v
REGFILE_TB = $(TB_DIR)/register_file_tb.v
RESET_SYNC_TB = $(TB_DIR)/reset_synchronizer_tb.v
CPU_SIMPLE_TB = $(TB_DIR)/riscv_5stage_cpu_simple_tb.v
CPU_COMP_TB = $(TB_DIR)/riscv_5stage_cpu_comprehensive_tb.v

# Default target
all: setup all_tests summary

# Setup results directory
setup:
	@echo "Setting up test environment..."
	@mkdir -p $(RESULTS_DIR)

# All individual module tests
all_tests: alu_test branch_test control_test data_ext_test data_mem_test \
           forward_test hazard_test immgen_test inst_mem_test npc_test \
           regfile_test reset_test

# Individual module tests
alu_test: setup
	@echo "=========================================="
	@echo "Testing ALU Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/alu_test $(ALU_SRC) $(ALU_TB)
	cd $(RESULTS_DIR) && $(VVP) alu_test
	@echo "ALU test completed. Check alu_tb.vcd"

branch_test: setup
	@echo "=========================================="
	@echo "Testing Branch Decision Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/branch_decision_test $(BRANCH_SRC) $(BRANCH_TB)
	cd $(RESULTS_DIR) && $(VVP) branch_decision_test
	@echo "Branch Decision test completed. Check branch_decision_tb.vcd"

control_test: setup
	@echo "=========================================="
	@echo "Testing Control Unit Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/control_unit_test $(CONTROL_SRC) $(CONTROL_TB)
	cd $(RESULTS_DIR) && $(VVP) control_unit_test
	@echo "Control Unit test completed. Check control_unit_tb.vcd"

data_ext_test: setup
	@echo "=========================================="
	@echo "Testing Data Extension Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/data_extension_test $(DATA_EXT_SRC) $(DATA_EXT_TB)
	cd $(RESULTS_DIR) && $(VVP) data_extension_test
	@echo "Data Extension test completed. Check data_extension_tb.vcd"

data_mem_test: setup
	@echo "=========================================="
	@echo "Testing Data Memory Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/data_memory_test $(DATA_MEM_SRC) $(DATA_MEM_TB)
	cd $(RESULTS_DIR) && $(VVP) data_memory_test
	@echo "Data Memory test completed. Check data_memory_tb.vcd"

forward_test: setup
	@echo "=========================================="
	@echo "Testing Forwarding Unit Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/forwarding_unit_test $(FORWARD_SRC) $(FORWARD_TB)
	cd $(RESULTS_DIR) && $(VVP) forwarding_unit_test
	@echo "Forwarding Unit test completed. Check forwarding_unit_tb.vcd"

hazard_test: setup
	@echo "=========================================="
	@echo "Testing Hazard Unit Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/hazard_unit_test $(HAZARD_SRC) $(HAZARD_TB)
	cd $(RESULTS_DIR) && $(VVP) hazard_unit_test
	@echo "Hazard Unit test completed. Check hazard_unit_tb.vcd"

immgen_test: setup
	@echo "=========================================="
	@echo "Testing Immediate Generator Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/immediate_generator_test $(IMM_GEN_SRC) $(IMM_GEN_TB)
	cd $(RESULTS_DIR) && $(VVP) immediate_generator_test
	@echo "Immediate Generator test completed. Check immediate_generator_tb.vcd"

inst_mem_test: setup
	@echo "=========================================="
	@echo "Testing Instruction Memory Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/instruction_memory_test $(INST_MEM_SRC) $(INST_MEM_TB)
	cd $(RESULTS_DIR) && $(VVP) instruction_memory_test
	@echo "Instruction Memory test completed. Check instruction_memory_tb.vcd"

npc_test: setup
	@echo "=========================================="
	@echo "Testing NPC Generator Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/npc_generator_test $(NPC_GEN_SRC) $(NPC_GEN_TB)
	cd $(RESULTS_DIR) && $(VVP) npc_generator_test
	@echo "NPC Generator test completed. Check npc_generator_tb.vcd"

regfile_test: setup
	@echo "=========================================="
	@echo "Testing Register File Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/register_file_test $(REGFILE_SRC) $(REGFILE_TB)
	cd $(RESULTS_DIR) && $(VVP) register_file_test
	@echo "Register File test completed. Check register_file_tb.vcd"

reset_test: setup
	@echo "=========================================="
	@echo "Testing Reset Synchronizer Module"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/reset_synchronizer_test $(RESET_SYNC_SRC) $(RESET_SYNC_TB)
	cd $(RESULTS_DIR) && $(VVP) reset_synchronizer_test
	@echo "Reset Synchronizer test completed. Check reset_synchronizer_tb.vcd"

# System-level tests
cpu_simple_test: setup
	@echo "=========================================="
	@echo "Testing CPU - Simple Test"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/simple_test $(CPU_TOP_SRC) $(ALU_SRC) $(BRANCH_SRC) $(CONTROL_SRC) \
		$(DATA_EXT_SRC) $(DATA_MEM_SRC) $(FORWARD_SRC) $(HAZARD_SRC) $(IMM_GEN_SRC) \
		$(INST_MEM_SRC) $(NPC_GEN_SRC) $(REGFILE_SRC) $(RESET_SYNC_SRC) $(CPU_SIMPLE_TB)
	cd $(RESULTS_DIR) && $(VVP) simple_test
	@echo "CPU Simple test completed. Check riscv_cpu_simple.vcd"

cpu_comprehensive_test: setup
	@echo "=========================================="
	@echo "Testing CPU - Comprehensive Test"
	@echo "=========================================="
	$(IVERILOG) -o $(RESULTS_DIR)/comp_test $(CPU_TOP_SRC) $(ALU_SRC) $(BRANCH_SRC) $(CONTROL_SRC) \
		$(DATA_EXT_SRC) $(DATA_MEM_SRC) $(FORWARD_SRC) $(HAZARD_SRC) $(IMM_GEN_SRC) \
		$(INST_MEM_SRC) $(NPC_GEN_SRC) $(REGFILE_SRC) $(RESET_SYNC_SRC) $(CPU_COMP_TB)
	cd $(RESULTS_DIR) && $(VVP) comp_test
	@echo "CPU Comprehensive test completed. Check riscv_cpu_comprehensive.vcd"

# Quick individual tests (aliases)
alu: alu_test
branch: branch_test  
control: control_test
data_ext: data_ext_test
data_mem: data_mem_test
forward: forward_test
hazard: hazard_test
immgen: immgen_test
inst_mem: inst_mem_test
npc: npc_test
regfile: regfile_test
reset: reset_test
cpu_simple: cpu_simple_test
cpu_comp: cpu_comprehensive_test

# View waveforms
wave_alu:
	@cd $(RESULTS_DIR) && $(GTKWAVE) alu_tb.vcd &

wave_branch:
	@cd $(RESULTS_DIR) && $(GTKWAVE) branch_decision_tb.vcd &

wave_control:
	@cd $(RESULTS_DIR) && $(GTKWAVE) control_unit_tb.vcd &

wave_data_ext:
	@cd $(RESULTS_DIR) && $(GTKWAVE) data_extension_tb.vcd &

wave_data_mem:
	@cd $(RESULTS_DIR) && $(GTKWAVE) data_memory_tb.vcd &

wave_forward:
	@cd $(RESULTS_DIR) && $(GTKWAVE) forwarding_unit_tb.vcd &

wave_hazard:
	@cd $(RESULTS_DIR) && $(GTKWAVE) hazard_unit_tb.vcd &

wave_immgen:
	@cd $(RESULTS_DIR) && $(GTKWAVE) immediate_generator_tb.vcd &

wave_inst_mem:
	@cd $(RESULTS_DIR) && $(GTKWAVE) instruction_memory_tb.vcd &

wave_npc:
	@cd $(RESULTS_DIR) && $(GTKWAVE) npc_generator_tb.vcd &

wave_regfile:
	@cd $(RESULTS_DIR) && $(GTKWAVE) register_file_tb.vcd &

wave_reset:
	@cd $(RESULTS_DIR) && $(GTKWAVE) reset_synchronizer_tb.vcd &

wave_cpu_simple:
	@cd $(RESULTS_DIR) && $(GTKWAVE) riscv_cpu_simple.vcd &

wave_cpu_comp:
	@cd $(RESULTS_DIR) && $(GTKWAVE) riscv_cpu_comprehensive.vcd &

# Summary of test results
summary:
	@echo ""
	@echo "=========================================="
	@echo "TEST SUMMARY - RISC-V 5-Stage CPU"
	@echo "=========================================="
	@echo "Generated VCD files in $(RESULTS_DIR):"
	@cd $(RESULTS_DIR) && ls -la *.vcd 2>/dev/null || echo "No VCD files found"
	@echo ""
	@echo "Test executables:"
	@cd $(RESULTS_DIR) && ls -la *_test 2>/dev/null || echo "No test executables found"
	@echo ""
	@echo "To view waveforms, use:"
	@echo "  Individual modules:"
	@echo "    make wave_alu        - ALU module"
	@echo "    make wave_branch     - Branch Decision module"
	@echo "    make wave_control    - Control Unit module"
	@echo "    make wave_data_ext   - Data Extension module"
	@echo "    make wave_data_mem   - Data Memory module"
	@echo "    make wave_forward    - Forwarding Unit module"
	@echo "    make wave_hazard     - Hazard Unit module"
	@echo "    make wave_immgen     - Immediate Generator module"
	@echo "    make wave_inst_mem   - Instruction Memory module"
	@echo "    make wave_npc        - NPC Generator module"
	@echo "    make wave_regfile    - Register File module"
	@echo "    make wave_reset      - Reset Synchronizer module"
	@echo "  System level:"
	@echo "    make wave_cpu_simple - Simple CPU test"
	@echo "    make wave_cpu_comp   - Comprehensive CPU test"

# Clean up
clean:
	@echo "Cleaning up..."
	@rm -rf $(RESULTS_DIR)/*.vcd
	@rm -rf $(RESULTS_DIR)/*_test
	@echo "Cleaned VCD files and test executables"

clean_all:
	@echo "Deep cleaning..."
	@rm -rf $(RESULTS_DIR)/*
	@echo "Cleaned entire results directory"

# Analysis and debugging
analyze:
	@echo "Running waveform analysis..."
	@python3 analyze_waveform.py

# Help
help:
	@echo "=========================================="
	@echo "RISC-V 5-Stage CPU Makefile Help"
	@echo "=========================================="
	@echo "Build targets:"
	@echo "  all           - Run all individual module tests"
	@echo "  all_tests     - Same as 'all'"
	@echo ""
	@echo "Individual module tests:"
	@echo "  alu           - Test ALU module"
	@echo "  branch        - Test Branch Decision module"
	@echo "  control       - Test Control Unit module"
	@echo "  data_ext      - Test Data Extension module"
	@echo "  data_mem      - Test Data Memory module"
	@echo "  forward       - Test Forwarding Unit module"
	@echo "  hazard        - Test Hazard Unit module"
	@echo "  immgen        - Test Immediate Generator module"
	@echo "  inst_mem      - Test Instruction Memory module"
	@echo "  npc           - Test NPC Generator module"
	@echo "  regfile       - Test Register File module"
	@echo "  reset         - Test Reset Synchronizer module"
	@echo ""
	@echo "System-level tests:"
	@echo "  cpu_simple    - Test CPU with simple testbench"
	@echo "  cpu_comp      - Test CPU with comprehensive testbench"
	@echo ""
	@echo "Waveform viewers (GTKWave):"
	@echo "  wave_*        - Open waveform for specific module"
	@echo "  wave_cpu_*    - Open CPU system waveforms"
	@echo ""
	@echo "Utilities:"
	@echo "  summary       - Show test results summary"
	@echo "  analyze       - Run waveform analysis script"
	@echo "  clean         - Clean VCD and executable files"
	@echo "  clean_all     - Deep clean entire results directory"
	@echo "  help          - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make all              # Run all individual tests"
	@echo "  make alu              # Test only ALU"
	@echo "  make cpu_simple       # Test CPU system (simple)"
	@echo "  make wave_alu         # View ALU waveform"
	@echo "  make summary          # Show results"

.PHONY: all setup all_tests summary clean clean_all analyze help \
        alu branch control data_ext data_mem forward hazard immgen inst_mem npc regfile reset \
        alu_test branch_test control_test data_ext_test data_mem_test forward_test \
        hazard_test immgen_test inst_mem_test npc_test regfile_test reset_test \
        cpu_simple cpu_comp cpu_simple_test cpu_comprehensive_test \
        wave_alu wave_branch wave_control wave_data_ext wave_data_mem wave_forward \
        wave_hazard wave_immgen wave_inst_mem wave_npc wave_regfile wave_reset \
        wave_cpu_simple wave_cpu_comp

