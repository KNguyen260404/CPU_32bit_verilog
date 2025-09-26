#!/bin/bash
# =============================================================================
# RISC-V CPU Quick Demo Script
# =============================================================================
# A simple demonstration of the CPU testbench
# =============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================="
echo "🚀 RISC-V CPU QUICK DEMO"
echo "========================================="
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "Makefile_simple" ]; then
    echo "❌ Please run this script from verify/simulation/ directory"
    exit 1
fi

# Create results directory
mkdir -p ../results

echo -e "${YELLOW}[Step 1]${NC} Checking syntax..."
if make -f Makefile_simple syntax > /dev/null 2>&1; then
    echo "✅ Syntax check passed"
else
    echo "❌ Syntax errors found"
    exit 1
fi

echo -e "${YELLOW}[Step 2]${NC} Running simple testbench..."
echo "This will test basic CPU functionality..."
echo ""

# Run the simple test and capture output
if make -f Makefile_simple simple; then
    echo ""
    echo -e "${GREEN}✅ Demo completed successfully!${NC}"
    echo ""
    echo "🎉 Your RISC-V CPU is working!"
    echo ""
    echo "📊 Generated files:"
    ls -la ../results/ 2>/dev/null | grep -E "\.(vcd|log)$" || echo "   No files found"
    echo ""
    echo "🔍 Next steps:"
    echo "   - View waveforms: make -f Makefile_simple view_simple"
    echo "   - Run more tests: ./run_tests.sh"
    echo "   - Clean up: make -f Makefile_simple clean"
    echo "   - Read guide: cat ../README_TESTING.md"
else
    echo ""
    echo "❌ Demo failed - check CPU implementation"
    exit 1
fi
