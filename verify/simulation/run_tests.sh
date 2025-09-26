#!/bin/bash
# =============================================================================
# RISC-V CPU Test Runner Script
# =============================================================================
# Usage:
#   ./run_tests.sh           - Run all tests
#   ./run_tests.sh simple    - Run simple test only
#   ./run_tests.sh comp      - Run comprehensive test only
#   ./run_tests.sh quick     - Quick syntax check + simple test
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT_DIR="$SCRIPT_DIR/../results"

# Create results directory
mkdir -p "$RESULT_DIR"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "========================================="
    echo "$1"
    echo "========================================="
    echo -e "${NC}"
}

# Check if required tools are installed
check_tools() {
    print_status "Checking required tools..."
    
    if ! command -v iverilog &> /dev/null; then
        print_error "Icarus Verilog (iverilog) not found!"
        print_error "Please install: sudo apt-get install iverilog"
        exit 1
    fi
    
    if ! command -v vvp &> /dev/null; then
        print_error "VVP (vvp) not found!"
        exit 1
    fi
    
    print_status "Tools check passed ✅"
}

# Run syntax check
syntax_check() {
    print_header "SYNTAX CHECK"
    cd "$SCRIPT_DIR"
    
    if make -f Makefile_simple syntax; then
        print_status "Syntax check passed ✅"
        return 0
    else
        print_error "Syntax check failed ❌"
        return 1
    fi
}

# Run simple test
run_simple_test() {
    print_header "SIMPLE TEST"
    cd "$SCRIPT_DIR"
    
    if make -f Makefile_simple simple; then
        print_status "Simple test completed ✅"
        return 0
    else
        print_error "Simple test failed ❌"
        return 1
    fi
}

# Run comprehensive test
run_comprehensive_test() {
    print_header "COMPREHENSIVE TEST"
    cd "$SCRIPT_DIR"
    
    print_warning "Note: Comprehensive test uses simulated verification"
    
    if make -f Makefile_simple comp; then
        print_status "Comprehensive test completed ✅"
        return 0
    else
        print_error "Comprehensive test failed ❌"
        return 1
    fi
}

# Run edge case test
run_edge_test() {
    print_header "EDGE CASE TEST"
    cd "$SCRIPT_DIR"
    
    if make -f Makefile_simple edge; then
        print_status "Edge case test completed ✅"
        return 0
    else
        print_error "Edge case test failed ❌"
        return 1
    fi
}

# Show results summary
show_results() {
    print_header "RESULTS SUMMARY"
    
    if [ -d "$RESULT_DIR" ]; then
        echo "Generated files in $RESULT_DIR:"
        ls -la "$RESULT_DIR/" | grep -E "\.(vcd|log)$" || echo "No result files found"
        
        echo ""
        echo "📊 To view waveforms:"
        echo "   make -f Makefile_simple view_simple"
        echo "   make -f Makefile_simple view_comp"
        echo "   make -f Makefile_simple view_edge"
        echo ""
        echo "🧹 To clean up:"
        echo "   make -f Makefile_simple clean"
    fi
}

# Main execution
main() {
    local test_type="${1:-all}"
    local exit_code=0
    
    print_header "RISC-V CPU TESTBENCH RUNNER"
    
    # Check tools first
    check_tools || exit 1
    
    case "$test_type" in
        "simple")
            syntax_check || exit_code=1
            run_simple_test || exit_code=1
            ;;
        "comp")
            syntax_check || exit_code=1
            run_comprehensive_test || exit_code=1
            ;;
        "edge")
            syntax_check || exit_code=1
            run_edge_test || exit_code=1
            ;;
        "quick")
            syntax_check || exit_code=1
            if [ $exit_code -eq 0 ]; then
                run_simple_test || exit_code=1
            fi
            ;;
        "all"|*)
            syntax_check || exit_code=1
            if [ $exit_code -eq 0 ]; then
                run_simple_test || exit_code=1
            fi
            if [ $exit_code -eq 0 ]; then
                run_comprehensive_test || exit_code=1
            fi
            if [ $exit_code -eq 0 ]; then
                run_edge_test || exit_code=1
            fi
            ;;
    esac
    
    # Show results regardless of success/failure
    show_results
    
    # Final status
    if [ $exit_code -eq 0 ]; then
        print_status "All tests completed successfully! 🎉"
    else
        print_error "Some tests failed. Check output above for details."
    fi
    
    exit $exit_code
}

# Show help if requested
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "RISC-V CPU Test Runner"
    echo ""
    echo "Usage:"
    echo "  $0           - Run all tests"
    echo "  $0 simple    - Run simple test only"
    echo "  $0 comp      - Run comprehensive test only"
    echo "  $0 edge      - Run edge case test only"
    echo "  $0 quick     - Quick test (syntax + simple)"
    echo "  $0 -h        - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 simple    # Quick basic test"
    echo "  $0 edge      # Test edge cases"
    echo "  $0 quick     # Fastest test"
    echo "  $0           # Full test suite (all tests)"
    exit 0
fi

# Run main function
main "$@"
