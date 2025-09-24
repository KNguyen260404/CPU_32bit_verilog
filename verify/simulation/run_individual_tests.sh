#!/bin/bash

# =============================================================================
# Script to run individual testbenches and generate VCD files
# =============================================================================

echo "=========================================="
echo "RISC-V CPU Individual Testbench Runner"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create results directory
mkdir -p results
cd results

# Function to run a single test
run_test() {
    local module=$1
    local testbench=$2
    
    echo -e "${YELLOW}Running $module testbench...${NC}"
    
    # Compile design files
    if [[ $module == "alu" ]]; then
        vlog ../src/alu.v ../$testbench
    elif [[ $module == "control_unit" ]]; then
        vlog ../src/control_unit.v ../$testbench
    elif [[ $module == "register_file" ]]; then
        vlog ../src/register_file.v ../$testbench
    elif [[ $module == "immediate_generator" ]]; then
        vlog ../src/immediate_generator.v ../$testbench
    elif [[ $module == "branch_decision" ]]; then
        vlog ../src/branch_decision.v ../$testbench  
    elif [[ $module == "data_extension" ]]; then
        vlog ../src/data_extension.v ../$testbench
    elif [[ $module == "riscv_cpu" ]]; then
        vlog ../src/*.v ../$testbench
    fi
    
    # Run simulation
    vsim -c ${module}_tb -do "run -all; quit" > ${module}_test.log 2>&1
    
    # Check results
    if grep -q "PASS" ${module}_test.log && ! grep -q "FAIL" ${module}_test.log; then
        echo -e "${GREEN}✅ $module test PASSED${NC}"
    else
        echo -e "${RED}❌ $module test FAILED${NC}"
        echo "Check ${module}_test.log for details"
    fi
    
    # Check if VCD file was generated
    if [[ -f "${module}_tb.vcd" ]]; then
        echo -e "${GREEN}📊 VCD file generated: ${module}_tb.vcd${NC}"
    else
        echo -e "${YELLOW}⚠️  No VCD file found for $module${NC}"
    fi
    
    echo "----------------------------------------"
}

# Run all individual testbenches
echo "Starting individual module tests..."
echo ""

run_test "alu" "alu_tb.v"
run_test "control_unit" "control_unit_tb.v" 
run_test "register_file" "register_file_tb.v"
run_test "immediate_generator" "immediate_generator_tb.v"
run_test "branch_decision" "branch_decision_tb.v"
run_test "data_extension" "data_extension_tb.v"

echo ""
echo "Individual tests completed!"
echo ""
echo "VCD files generated in results/ directory:"
ls -la *.vcd 2>/dev/null || echo "No VCD files found"

echo ""
echo "To view waveforms, use:"
echo "  gtkwave results/alu_tb.vcd &"
echo "  gtkwave results/control_unit_tb.vcd &"
echo "  # etc..."

echo ""
echo "Test logs are available in:"
ls -la *_test.log 2>/dev/null || echo "No log files found"

