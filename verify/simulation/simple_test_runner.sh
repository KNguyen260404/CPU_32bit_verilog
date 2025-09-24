#!/bin/bash

# =============================================================================
# Simple Test Runner for RISC-V CPU (Works with Icarus Verilog - Free)
# =============================================================================

echo "🚀 RISC-V CPU Simple Test Runner"
echo "Using Icarus Verilog (iverilog) - Free Open Source Simulator"
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'  
BLUE='\033[0;34m'
NC='\033[0m'

# Check if iverilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}❌ Icarus Verilog not found!${NC}"
    echo "Install with: sudo apt-get install iverilog gtkwave"
    exit 1
fi

if ! command -v gtkwave &> /dev/null; then
    echo -e "${YELLOW}⚠️  GTKWave not found! Install for waveform viewing: sudo apt-get install gtkwave${NC}"
fi

# Create results directory
mkdir -p results
cd results

echo "📁 Working directory: $(pwd)"
echo ""

# Function to run a single test with Icarus Verilog
run_test() {
    local module=$1
    local testbench_file=$2
    local design_files=$3
    
    echo -e "${BLUE}🧪 Testing $module...${NC}"
    
    # Compile with iverilog
    echo "   Compiling..."
    iverilog -o ${module}_test ${design_files} ../${testbench_file} 2> ${module}_compile.log
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}   ❌ Compilation failed for $module${NC}"
        echo "   Check ${module}_compile.log for errors"
        return 1
    fi
    
    # Run simulation
    echo "   Running simulation..."
    vvp ${module}_test > ${module}_sim.log 2>&1
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}   ❌ Simulation failed for $module${NC}"
        echo "   Check ${module}_sim.log for errors"
        return 1
    fi
    
    # Check results
    if grep -q "ALL TESTS PASSED\|🎉.*PASSED" ${module}_sim.log; then
        echo -e "${GREEN}   ✅ $module test PASSED${NC}"
        
        # Check for VCD file
        if [ -f "${module}_tb.vcd" ]; then
            echo -e "${GREEN}   📊 VCD generated: ${module}_tb.vcd${NC}"
            return 0
        else
            echo -e "${YELLOW}   ⚠️  No VCD file generated${NC}"
            return 0
        fi
    elif grep -q "FAIL\|ERROR\|❌" ${module}_sim.log; then
        echo -e "${RED}   ❌ $module test FAILED${NC}"
        echo "   Check ${module}_sim.log for details"
        return 1
    else
        echo -e "${YELLOW}   ⚠️  $module test result unclear${NC}"
        echo "   Check ${module}_sim.log for details"
        return 1
    fi
}

# Test counter
total_tests=0
passed_tests=0

echo "Starting individual module tests..."
echo ""

# Test 1: ALU
echo "Test 1/6: ALU Module"
run_test "alu" "alu_tb.v" "../src/alu.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Test 2: Control Unit
echo "Test 2/6: Control Unit Module"
run_test "control_unit" "control_unit_tb.v" "../src/control_unit.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Test 3: Register File
echo "Test 3/6: Register File Module" 
run_test "register_file" "register_file_tb.v" "../src/register_file.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Test 4: Immediate Generator
echo "Test 4/6: Immediate Generator Module"
run_test "immediate_generator" "immediate_generator_tb.v" "../src/immediate_generator.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Test 5: Branch Decision
echo "Test 5/6: Branch Decision Module"
run_test "branch_decision" "branch_decision_tb.v" "../src/branch_decision.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Test 6: Data Extension
echo "Test 6/6: Data Extension Module"
run_test "data_extension" "data_extension_tb.v" "../src/data_extension.v"
if [ $? -eq 0 ]; then ((passed_tests++)); fi
((total_tests++))
echo ""

# Summary
echo "=================================================="
echo -e "${BLUE}📊 TEST SUMMARY${NC}"
echo "=================================================="
echo "Total Tests:    $total_tests"
echo "Passed Tests:   $passed_tests"
echo "Failed Tests:   $((total_tests - passed_tests))"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! CPU modules are working correctly.${NC}"
    test_result=0
else
    echo -e "${RED}❌ Some tests failed. Check logs for details.${NC}"
    test_result=1
fi

# List generated files
echo ""
echo "Generated Files:"
echo "📄 Logs:"
ls -la *.log 2>/dev/null | sed 's/^/   /'
echo "📊 VCD Waveforms:"  
ls -la *.vcd 2>/dev/null | sed 's/^/   /'
echo "🔧 Compiled Tests:"
ls -la *_test 2>/dev/null | sed 's/^/   /'

echo ""
echo "=================================================="
echo "🌊 WAVEFORM VIEWING INSTRUCTIONS"
echo "=================================================="
echo "To view waveforms (if GTKWave installed):"
echo ""

if ls *.vcd 1> /dev/null 2>&1; then
    for vcd_file in *.vcd; do
        echo "   gtkwave $vcd_file &"
    done
else
    echo "   No VCD files found"
fi

echo ""
echo "Waveform Analysis Tips:"
echo "1. Look for clean signal transitions (no glitches)"
echo "2. Verify no X/Z values in critical signals"  
echo "3. Check timing relationships between input/output"
echo "4. Verify expected signal values for test cases"

echo ""
if [ -f "../analyze_waveform.py" ]; then
    echo "For automated waveform analysis:"
    echo "   cd .."
    echo "   python3 analyze_waveform.py --vcd-dir results"
fi

echo ""
echo "=================================================="
if [ $test_result -eq 0 ]; then
    echo -e "${GREEN}🚀 Ready for next step: System-level testing!${NC}"
else
    echo -e "${RED}🔧 Fix failing modules before proceeding.${NC}"
fi
echo "=================================================="

exit $test_result

