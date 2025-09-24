# RISC-V 5-Stage CPU Testbench Suite

## Tổng quan
Đây là bộ testbench hoàn chỉnh để verify tất cả các module của RISC-V 5-stage CPU. Mỗi module có testbench riêng để test độc lập, cùng với một testbench tổng thể để test integration.

## Danh sách Testbenches

### 1. Module-Level Testbenches

#### 1.1 ALU Testbench (`alu_tb.v`)
- **Mục đích**: Test tất cả các phép toán ALU
- **Coverage**: 
  - Arithmetic: ADD, SUB
  - Logic: AND, OR, XOR
  - Comparison: SLT, SLTU
  - Shift: SLL, SRL, SRA
  - Zero flag verification
  - Corner cases và randomized testing
- **Chạy**: `alu_tb`
- **Thời gian**: ~1000 test cases, 10ms simulation time

#### 1.2 Control Unit Testbench (`control_unit_tb.v`)
- **Mục đích**: Test instruction decoding và control signal generation
- **Coverage**:
  - Tất cả RISC-V instruction types (R, I, S, B, U, J)
  - Control signal correctness
  - Invalid instruction handling
- **Chạy**: `control_unit_tb`
- **Thời gian**: ~100 test cases, 5ms simulation time

#### 1.3 Register File Testbench (`register_file_tb.v`)
- **Mục đích**: Test 32-register file functionality
- **Coverage**:
  - Dual read ports, single write port
  - x0 hardwired to zero verification
  - Read-after-write hazards
  - Simultaneous read/write testing
  - Reset behavior
  - Debug interface
- **Chạy**: `register_file_tb`
- **Thời gian**: ~200 test cases, 8ms simulation time

#### 1.4 Immediate Generator Testbench (`immediate_generator_tb.v`)
- **Mục đích**: Test immediate value generation for all instruction types
- **Coverage**:
  - I-type, S-type, B-type, U-type, J-type immediates
  - Sign extension verification
  - Boundary conditions
- **Chạy**: `immediate_generator_tb`
- **Thời gian**: ~50 test cases, 2ms simulation time

#### 1.5 Branch Decision Testbench (`branch_decision_tb.v`)
- **Mục đích**: Test branch condition evaluation
- **Coverage**:
  - All branch types: BEQ, BNE, BLT, BGE, BLTU, BGEU
  - Signed/unsigned comparison
  - Corner cases with boundary values
- **Chạy**: `branch_decision_tb`
- **Thời gian**: ~60 test cases, 3ms simulation time

#### 1.6 Data Extension Testbench (`data_extension_tb.v`)
- **Mục đích**: Test load data extension for different sizes
- **Coverage**:
  - Load types: LB, LH, LW, LBU, LHU
  - Signed/unsigned extension
  - Byte selection logic
- **Chạy**: `data_extension_tb`
- **Thời gian**: ~80 test cases, 4ms simulation time

### 2. System-Level Testbenches

#### 2.1 Original Basic Testbench (`riscv_5stage_cpu_tb.v`)
- **Mục đích**: Basic functionality testing và performance monitoring
- **Features**:
  - Clock and reset testing
  - Debug interface verification
  - Performance counter monitoring
- **Chạy**: `riscv_5stage_cpu_tb`
- **Thời gian**: 1000 cycles, 10ms simulation time

#### 2.2 Comprehensive System Testbench (`riscv_5stage_cpu_comprehensive_tb.v`)
- **Mục đích**: Complete system verification với real programs
- **Test Suites**:
  1. **Arithmetic Program**: Basic ALU operations
  2. **Load/Store Program**: Memory access testing
  3. **Branch Program**: Control flow testing
  4. **Jump Program**: Function call testing
  5. **Pipeline Hazard Tests**: RAW, WAR, WAW hazards
  6. **Fibonacci Program**: Complex algorithm testing
  7. **Sorting Program**: Memory-intensive testing
  8. **Compliance Tests**: Full ISA coverage
- **Features**:
  - Real RISC-V assembly program execution
  - Pipeline behavior verification
  - Performance analysis (IPC, stall rate)
  - Debug interface utilization
  - Comprehensive ISA testing
- **Chạy**: `riscv_5stage_cpu_comprehensive_tb`
- **Thời gian**: 5000+ cycles, 50ms simulation time

## Cách sử dụng

### 1. Chạy Individual Module Tests
```bash
# Compile và chạy ALU testbench
vlog alu.v alu_tb.v
vsim -c alu_tb -do "run -all; quit"

# Compile và chạy Control Unit testbench  
vlog control_unit.v control_unit_tb.v
vsim -c control_unit_tb -do "run -all; quit"

# Tương tự cho các module khác...
```

### 2. Chạy System-Level Tests
```bash
# Compile toàn bộ CPU design
vlog src/*.v verify/riscv_5stage_cpu_comprehensive_tb.v
vsim -c riscv_5stage_cpu_comprehensive_tb -do "run -all; quit"
```

### 3. Batch Testing Script
Tạo script `run_all_tests.sh`:
```bash
#!/bin/bash
echo "Running all RISC-V CPU testbenches..."

# Module tests
echo "Testing ALU..."
vsim -batch -do "vlog src/alu.v verify/alu_tb.v; vsim alu_tb; run -all; quit" &

echo "Testing Control Unit..."
vsim -batch -do "vlog src/control_unit.v verify/control_unit_tb.v; vsim control_unit_tb; run -all; quit" &

echo "Testing Register File..."
vsim -batch -do "vlog src/register_file.v verify/register_file_tb.v; vsim register_file_tb; run -all; quit" &

# Wait for all tests to complete
wait

echo "All tests completed!"
```

## Test Coverage Analysis

### Module Coverage
- **ALU**: ✅ 100% operation coverage
- **Control Unit**: ✅ 100% instruction coverage  
- **Register File**: ✅ 100% register coverage
- **Immediate Generator**: ✅ 100% immediate type coverage
- **Branch Decision**: ✅ 100% branch type coverage
- **Data Extension**: ✅ 100% load type coverage

### System Coverage
- **Instruction Set**: ✅ Full RV32I base instruction set
- **Pipeline Stages**: ✅ All 5 stages tested
- **Hazard Handling**: ✅ Data, control, structural hazards
- **Memory System**: ✅ Instruction and data memory
- **Debug Interface**: ✅ All debug features
- **Performance**: ✅ IPC, stall rate, branch prediction

## Expected Results

### Performance Targets
- **IPC (Instructions Per Cycle)**: > 0.8 for compute-intensive code
- **Stall Rate**: < 20% for typical programs
- **Branch Prediction Accuracy**: > 85%
- **Memory Latency**: < 2 cycles average

### Pass Criteria
- ✅ All individual module tests pass
- ✅ System tests execute without errors
- ✅ Performance targets met
- ✅ No pipeline violations detected
- ✅ Memory consistency maintained

## Debugging Guide

### Common Issues
1. **Pipeline Stalls**: Check hazard detection logic
2. **Branch Misprediction**: Verify branch decision unit
3. **Memory Errors**: Check data extension and alignment
4. **Register Corruption**: Verify forwarding logic

### Debug Features
- **VCD Waveforms**: Automatically generated for all tests
- **Instruction Trace**: Optional detailed execution trace
- **Performance Counters**: Real-time pipeline statistics
- **Debug Interface**: Register and memory inspection

### Waveform Analysis
```bash
# View waveforms in GTKWave
gtkwave alu_tb.vcd &
gtkwave riscv_cpu_comprehensive.vcd &
```

## Test Maintenance

### Adding New Tests
1. Create new testbench file in `verify/` directory
2. Follow naming convention: `module_name_tb.v`
3. Include comprehensive coverage and self-checking
4. Update this README with test description

### Modifying Existing Tests
1. Maintain backward compatibility
2. Update expected results if design changes
3. Document any new features or coverage
4. Re-run full test suite to verify

## Integration with CI/CD

### Automated Testing
```yaml
# Example GitHub Actions workflow
name: RISC-V CPU Testing
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Install ModelSim
      run: # Install simulator
    - name: Run Module Tests
      run: ./scripts/run_module_tests.sh
    - name: Run System Tests  
      run: ./scripts/run_system_tests.sh
    - name: Generate Coverage Report
      run: ./scripts/generate_coverage.sh
```

## Conclusion
Bộ testbench này cung cấp verification hoàn chỉnh cho RISC-V 5-stage CPU, đảm bảo tính đúng đắn của thiết kế trước khi synthesis và implementation. Tất cả các testbench đều được thiết kế để tự động kiểm tra và báo cáo kết quả chi tiết.
