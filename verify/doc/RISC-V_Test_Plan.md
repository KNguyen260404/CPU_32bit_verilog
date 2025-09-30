# RISC-V 5-Stage CPU Test Plan

## Mục Tiêu Testing
- Verify correctness của từng module độc lập
- Verify integration giữa các modules
- Verify pipeline functionality và hazard handling
- Verify performance characteristics
- Stress testing và corner cases

## 1. ALU Module Testing

### Test Cases:
- **Arithmetic Operations**: ADD, SUB với various operands
- **Logic Operations**: AND, OR, XOR với bit patterns  
- **Comparison Operations**: SLT, SLTU với signed/unsigned values
- **Shift Operations**: SLL, SRL, SRA với các shift amounts
- **Overflow/Underflow**: Test boundary conditions
- **Zero Flag**: Verify zero detection
- **Corner Cases**: Max/min values, zero operands

### Coverage Goals:
- 100% opcode coverage
- All corner case operands
- Timing verification

## 2. Control Unit Testing

### Test Cases:
- **R-Type Instructions**: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
- **I-Type Instructions**: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- **Load Instructions**: LB, LH, LW, LBU, LHU
- **Store Instructions**: SB, SH, SW  
- **Branch Instructions**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Jump Instructions**: JAL, JALR
- **Upper Immediate**: LUI, AUIPC
- **Invalid Opcodes**: Undefined instruction handling

### Coverage Goals:
- All RISC-V instruction types
- Control signal generation correctness
- Illegal instruction detection

## 3. Register File Testing

### Test Cases:
- **Read Operations**: Single/dual port reads
- **Write Operations**: Write-back verification
- **Register x0 Hardwired**: Always returns zero
- **Bypass/Forwarding**: Read-after-write hazards
- **Simultaneous Read/Write**: Same address conflicts
- **All Registers**: Test all 32 registers

### Coverage Goals:
- All register addresses
- Read/write combinations
- Hazard scenarios

## 4. Memory System Testing

### Instruction Memory:
- **Address Range**: Full address space coverage
- **Instruction Fetch**: Various PC values
- **Invalid Addresses**: Out-of-bounds access
- **Reset Behavior**: Initial state verification

### Data Memory:
- **Load/Store Operations**: All data types (byte, half, word)
- **Address Alignment**: Aligned/unaligned access
- **Memory Banking**: Different memory regions
- **Read-after-Write**: Data consistency
- **Invalid Addresses**: Error handling

## 5. Pipeline Hazard Testing

### Data Hazards:
- **RAW (Read After Write)**: Various forwarding scenarios
- **WAR (Write After Read)**: Pipeline ordering
- **WAW (Write After Write)**: Register conflicts
- **Load-Use Hazards**: Memory load dependencies
- **Multiple Dependencies**: Complex forwarding chains

### Control Hazards:
- **Branch Prediction**: Taken/not-taken scenarios
- **Branch Target**: Various target addresses
- **Jump Instructions**: JAL/JALR testing
- **Pipeline Flushes**: Incorrect predictions
- **Return Address**: JAL/JALR linking

### Structural Hazards:
- **Resource Conflicts**: Memory port contention
- **Pipeline Stalls**: Resource unavailability

## 6. Instruction Set Architecture Testing

### Core Instructions:
```assembly
# Arithmetic
ADDI x1, x0, 100    # Load immediate
ADD  x2, x1, x1     # Register add
SUB  x3, x2, x1     # Subtract

# Logic
ANDI x4, x1, 0xFF   # AND immediate
OR   x5, x1, x2     # OR registers
XOR  x6, x1, x2     # XOR registers

# Shifts  
SLLI x7, x1, 2      # Shift left logical
SRL  x8, x2, x1     # Shift right logical
SRA  x9, x2, x1     # Shift right arithmetic

# Memory
SW   x1, 0(x0)      # Store word
LW   x10, 0(x0)     # Load word
SB   x1, 4(x0)      # Store byte
LBU  x11, 4(x0)     # Load byte unsigned

# Branches
BEQ  x1, x2, loop   # Branch if equal
BNE  x1, x0, skip   # Branch if not equal
BLT  x1, x2, less   # Branch if less than

# Jumps
JAL  x1, function   # Jump and link
JALR x0, 0(x1)      # Jump register (return)

# Upper immediate
LUI  x12, 0x12345   # Load upper immediate
AUIPC x13, 0x1000   # Add upper immediate to PC
```

## 7. Performance Testing

### Metrics:
- **Instructions Per Cycle (IPC)**: Target > 0.8
- **Pipeline Efficiency**: Stall rate < 20%
- **Branch Prediction**: Accuracy measurement
- **Memory Throughput**: Load/store performance
- **Power Consumption**: Clock gating effectiveness

## 8. Stress Testing

### High-Frequency Patterns:
- **Pipeline Saturation**: Continuous instruction stream
- **Memory Intensive**: Frequent loads/stores
- **Branch Heavy**: High branch frequency
- **Dependency Chains**: Long RAW sequences
- **Context Switching**: Register file stress

### Corner Cases:
- **Maximum Values**: 0xFFFFFFFF, 0x80000000
- **Zero Operations**: All-zero operands
- **Boundary Conditions**: Address limits
- **Reset During Operation**: Asynchronous reset
- **Clock Edge Cases**: Setup/hold timing

## 9. Verification Methodology

### Testbench Structure:
```verilog
module module_tb;
    // Clock and reset generation
    // DUT instantiation
    // Test stimulus generation
    // Response checking
    // Coverage collection
    // Performance monitoring
endmodule
```

### Assertion-Based Verification:
- Property checks for protocol compliance
- Temporal assertions for pipeline behavior
- Coverage-driven test generation
- Formal verification for critical paths

## 10. Expected Results

### Functional Correctness:
- ✅ All instructions execute correctly
- ✅ Pipeline maintains data integrity  
- ✅ Hazards handled properly
- ✅ Memory system operates correctly
- ✅ Reset/initialization works

### Performance Targets:
- ✅ IPC > 0.8 for compute-intensive code
- ✅ Stall rate < 20% for typical programs
- ✅ Branch prediction accuracy > 85%
- ✅ Memory latency < 2 cycles average

### Coverage Goals:
- ✅ 100% instruction coverage
- ✅ 100% branch coverage  
- ✅ 95% state coverage
- ✅ 90% toggle coverage
- ✅ All corner cases tested

## 11. Test Environment Setup

### Tools Required:
- Verilog simulator (ModelSim/QuestaSim/Vivado)
- Waveform viewer
- Coverage analysis tools
- RISC-V assembler/compiler
- Performance analysis scripts

### Test Data:
- Hand-written assembly tests
- Randomly generated instruction sequences
- Real program traces
- Compliance test suite
- Benchmark programs

Toàn bộ test plan này sẽ được implement qua các individual testbenches và một comprehensive system testbench.
