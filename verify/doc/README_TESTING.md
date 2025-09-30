# 🚀 RISC-V 5-Stage CPU Testing Guide

## 📋 Tổng quan
Hệ thống testing hoàn chỉnh cho RISC-V 5-Stage CPU với 3 loại testbench khác nhau:

1. **Simple Testbench** - Test cơ bản, nhanh và đáng tin cậy ✅
2. **Comprehensive Testbench** - Test toàn diện với simulation ⚠️
3. **Edge Case Testbench** - Test các trường hợp đặc biệt 🔍

## 🛠️ Yêu cầu hệ thống

### Required Tools:
```bash
# Ubuntu/Debian
sudo apt-get install iverilog gtkwave

# MacOS với Homebrew
brew install icarus-verilog gtkwave

# Arch Linux
sudo pacman -S iverilog gtkwave
```

### File Structure:
```
verify/
├── testbench/
│   ├── riscv_5stage_cpu_simple_tb.v      # Simple testbench (recommended)
│   ├── riscv_5stage_cpu_comprehensive_tb.v # Comprehensive testbench
│   ├── riscv_5stage_cpu_edge_tb.v        # Edge case testbench
│   └── riscv_5stage_cpu_tb.v             # Original basic testbench
├── simulation/
│   ├── Makefile_simple                   # Makefile for all tests
│   ├── run_tests.sh                      # Easy test runner script
│   └── analyze_waveform.py               # Waveform analysis (existing)
├── results/                              # Generated test results
└── README_TESTING.md                     # This file
```

## 🚀 Quick Start

### Method 1: Using Script (Easiest)
```bash
cd verify/simulation/

# Make script executable
chmod +x run_tests.sh

# Run simple test (recommended)
./run_tests.sh simple

# Run all tests
./run_tests.sh

# Quick syntax check + simple test
./run_tests.sh quick

# Help
./run_tests.sh --help
```

### Method 2: Using Makefile
```bash
cd verify/simulation/

# Simple test (recommended)
make -f Makefile_simple simple

# All tests
make -f Makefile_simple complete

# Edge case test
make -f Makefile_simple edge

# Help
make -f Makefile_simple help
```

## 📊 Test Types Explained

### 1. Simple Testbench ⭐ RECOMMENDED
- **File**: `riscv_5stage_cpu_simple_tb.v`
- **Purpose**: Basic functionality test
- **Features**:
  - Actually loads instructions into memory
  - Tests arithmetic, load/store, branches
  - Real performance monitoring
  - Reliable and fast

**What it tests:**
- ✅ Basic arithmetic operations (ADD, SUB, AND, OR)
- ✅ Load/store operations
- ✅ Branch operations
- ✅ Performance counters
- ✅ Debug interface

**Usage:**
```bash
./run_tests.sh simple
# or
make -f Makefile_simple simple
```

### 2. Comprehensive Testbench ⚠️ SIMULATION ONLY
- **File**: `riscv_5stage_cpu_comprehensive_tb.v`
- **Purpose**: Complex program testing
- **Features**:
  - Multiple test suites
  - Simulated verification (limited by debug interface)
  - Performance analysis

**What it tests:**
- 🔄 Arithmetic operations program
- 🔄 Load/Store operations program
- 🔄 Branch operations program
- 🔄 Jump operations program
- 🔄 Pipeline hazard tests
- 🔄 Fibonacci sequence
- 🔄 Sorting algorithm

**Usage:**
```bash
./run_tests.sh comp
# or
make -f Makefile_simple comp
```

### 3. Edge Case Testbench 🔍 SPECIALIZED
- **File**: `riscv_5stage_cpu_edge_tb.v`
- **Purpose**: Edge cases and corner conditions
- **Features**:
  - Tests register x0 behavior
  - Pipeline hazard detection
  - Reset behavior verification
  - Branch edge cases

**What it tests:**
- 🔍 Register x0 always stays 0
- 🔍 RAW pipeline hazards
- 🔍 Load-use hazards
- 🔍 Branch edge cases
- 🔍 Reset behavior
- 🔍 Memory edge cases

**Usage:**
```bash
./run_tests.sh edge
# or
make -f Makefile_simple edge
```

## 📈 Performance Monitoring

All testbenches provide performance metrics:
- **Cycle Count**: Total clock cycles
- **Instruction Count**: Instructions executed
- **Stall Count**: Pipeline stalls
- **Branch Count**: Branch instructions executed
- **IPC**: Instructions Per Cycle

**Good Performance Targets:**
- IPC > 0.8: Excellent 🎉
- IPC > 0.6: Good ✅
- IPC > 0.4: Fair ⚠️
- IPC ≤ 0.4: Needs improvement ❌

## 🔍 Waveform Viewing

### Generate and view waveforms:
```bash
# Run test first
./run_tests.sh simple

# View waveforms
make -f Makefile_simple view_simple
# or manually:
gtkwave verify/results/riscv_cpu_simple.vcd
```

### Available waveform files:
- `riscv_cpu_simple.vcd` - Simple testbench
- `riscv_cpu_comprehensive.vcd` - Comprehensive testbench  
- `riscv_cpu_edge.vcd` - Edge case testbench

## 🐛 Troubleshooting

### Common Issues:

#### 1. "iverilog not found"
```bash
# Ubuntu/Debian
sudo apt-get install iverilog

# Check installation
iverilog -V
```

#### 2. "Permission denied" for script
```bash
chmod +x verify/simulation/run_tests.sh
```

#### 3. "No such file or directory"
Make sure you're in the correct directory:
```bash
cd verify/simulation/
pwd  # Should end with .../verify/simulation
```

#### 4. Compilation errors
Check syntax first:
```bash
make -f Makefile_simple syntax
```

#### 5. No waveform files generated
Make sure you ran the test first:
```bash
./run_tests.sh simple
ls -la ../results/  # Check for .vcd files
```

## 📋 Test Results Interpretation

### Success Indicators:
- ✅ All tests pass
- ✅ PC advances correctly
- ✅ Performance counters increment
- ✅ No compilation errors

### Warning Signs:
- ⚠️ Low IPC (< 0.4)
- ⚠️ No stalls detected (may indicate missing hazard detection)
- ⚠️ Simulation timeout

### Failure Indicators:
- ❌ Compilation errors
- ❌ PC doesn't advance
- ❌ Zero instructions executed
- ❌ Test assertion failures

## 🔧 Advanced Usage

### Custom Test Programs:
Edit the testbench files to add your own instruction sequences:
```verilog
// In simple_tb.v, modify load_test_programs() task
dut.u_imem.imem[0] = 32'hYourInstruction;
```

### Debug Interface Usage:
```verilog
debug_select = 8'h00;  // Read PC
debug_select = 8'h10;  // Read current instruction  
debug_select = 8'h20;  // Read ALU result
debug_select = 8'h30;  // Read memory data
```

### Performance Analysis:
```bash
# Run with performance focus
./run_tests.sh simple
# Check cycle count, IPC, stall rate in output
```

## 📞 Support

### For Issues:
1. Check this README first
2. Verify tools are installed correctly
3. Check file permissions
4. Try simple test first before complex ones
5. Look at generated .vcd files for debugging

### Quick Commands Reference:
```bash
# Fastest test
./run_tests.sh quick

# Most reliable test  
./run_tests.sh simple

# Complete test suite
./run_tests.sh all

# Clean up
make -f Makefile_simple clean

# Help
./run_tests.sh --help
make -f Makefile_simple help
```

---
**📝 Note**: Simple testbench là lựa chọn tốt nhất cho việc testing hàng ngày. Comprehensive testbench có thể có limitations do debug interface. Edge case testbench dùng để test các trường hợp đặc biệt.

**🎯 Recommendation**: Bắt đầu với `./run_tests.sh simple` để đảm bảo CPU hoạt động cơ bản đúng, sau đó tiến tới các tests phức tạp hơn.
