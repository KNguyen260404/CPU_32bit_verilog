# Hướng dẫn chạy test và phân tích waveform

## 🚀 Quick Start - Chạy test ngay

### Bước 1: Setup môi trường
```bash
cd verify/
chmod +x run_individual_tests.sh
chmod +x analyze_waveform.py
```

### Bước 2: Chạy test từng module
```bash
# Sử dụng Makefile (khuyến nghị)
make all          # Chạy tất cả tests
make alu          # Chỉ test ALU
make control      # Chỉ test Control Unit
make regfile      # Chỉ test Register File

# Hoặc sử dụng script
./run_individual_tests.sh
```

### Bước 3: Xem kết quả và waveform
```bash
cd results/
ls *.vcd          # Xem các file VCD được tạo
ls *.log          # Xem test logs
```

### Bước 4: Mở waveform viewer
```bash
# Với GTKWave
make wave_alu     # Xem ALU waveform
make wave_control # Xem Control Unit waveform

# Hoặc manual
gtkwave results/alu_tb.vcd &
gtkwave results/control_unit_tb.vcd &
```

### Bước 5: Phân tích waveform tự động
```bash
python3 analyze_waveform.py --vcd-dir results --module all
cat waveform_analysis_report.txt
```

---

## 📊 Chi tiết từng testbench

### 1. ALU Testbench (`alu_tb.v`)

#### Chạy test:
```bash
make alu
```

#### Signals quan trọng để xem:
- `operand1[31:0]` - Input operand 1
- `operand2[31:0]` - Input operand 2  
- `alu_control[3:0]` - ALU operation control
- `alu_result[31:0]` - ALU output result
- `zero_flag` - Zero detection flag

#### Phân tích waveform:
```bash
gtkwave results/alu_tb.vcd &
```

**Điều cần kiểm tra:**
- ✅ `alu_result` thay đổi correctly khi `operand1`, `operand2`, `alu_control` thay đổi
- ✅ `zero_flag` = 1 khi `alu_result` = 0
- ✅ Không có giá trị X hoặc Z trong output
- ✅ Timing: result thay đổi ngay sau khi input thay đổi (combinational logic)

**Ví dụ kiểm tra:**
- ADD operation: operand1=100, operand2=200 → result=300
- SUB operation: operand1=300, operand2=300 → result=0, zero_flag=1
- SLT operation: operand1=-1, operand2=1 → result=1 (signed comparison)

### 2. Control Unit Testbench (`control_unit_tb.v`)

#### Chạy test:
```bash
make control
```

#### Signals quan trọng:
- `opcode[6:0]` - Instruction opcode
- `funct3[2:0]` - Function 3 field
- `funct7[6:0]` - Function 7 field
- `reg_write_d` - Register write enable
- `mem_write_d[3:0]` - Memory write enables
- `alu_control_d[3:0]` - ALU control output
- `imm_type[2:0]` - Immediate type
- `branch_type_d[2:0]` - Branch type

#### Phân tích waveform:
```bash
gtkwave results/control_unit_tb.vcd &
```

**Điều cần kiểm tra:**
- ✅ Control signals thay đổi correctly cho từng instruction type
- ✅ R-type: reg_write=1, alu_control correct, mem_write=0
- ✅ I-type: reg_write=1, imm_type=I, alu_src2=immediate
- ✅ S-type: reg_write=0, mem_write≠0, imm_type=S
- ✅ B-type: reg_write=0, branch_type correct, imm_type=B
- ✅ Invalid opcodes → default values

### 3. Register File Testbench (`register_file_tb.v`)

#### Chạy test:
```bash
make regfile
```

#### Signals quan trọng:
- `clk` - Clock signal
- `rst_n` - Reset (active low)
- `rs1_addr[4:0]`, `rs2_addr[4:0]` - Read addresses
- `rs1_data[31:0]`, `rs2_data[31:0]` - Read data outputs
- `reg_write` - Write enable
- `rd_addr[4:0]` - Write address
- `rd_data[31:0]` - Write data

#### Phân tích waveform:
```bash
gtkwave results/register_file_tb.vcd &
```

**Điều cần kiểm tra:**
- ✅ `rs1_data`, `rs2_data` = 0 khi reading address 0 (x0 hardwired)
- ✅ Write data appears on read ports after positive clock edge
- ✅ Read operations are asynchronous (no clock dependency)  
- ✅ Write to x0 doesn't change x0 value (always 0)
- ✅ Simultaneous read/write works correctly
- ✅ Reset clears all registers (if RESET_ALL_REGS=1)

### 4. Branch Decision Testbench (`branch_decision_tb.v`)

#### Chạy test:
```bash
make branch
```

#### Signals quan trọng:
- `operand1[31:0]` - First comparison operand
- `operand2[31:0]` - Second comparison operand
- `branch_type[2:0]` - Branch condition type
- `branch_taken` - Branch decision output

#### Phân tích waveform:
```bash
gtkwave results/branch_decision_tb.vcd &
```

**Điều cần kiểm tra:**
- ✅ BEQ: branch_taken=1 khi operand1 = operand2
- ✅ BNE: branch_taken=1 khi operand1 ≠ operand2
- ✅ BLT: branch_taken=1 khi operand1 < operand2 (signed)
- ✅ BLTU: branch_taken=1 khi operand1 < operand2 (unsigned)
- ✅ Edge cases: 0x80000000 vs 0x7FFFFFFF cho signed/unsigned

---

## 🔧 Troubleshooting

### Lỗi phổ biến:

#### 1. "Error: Module not found"
```bash
# Đảm bảo design files có trong src/
ls ../src/*.v

# Kiểm tra include paths trong testbench
grep "include" *.v
```

#### 2. "VCD file không được tạo"
- Kiểm tra `$dumpfile()` và `$dumpvars()` trong testbench
- Đảm bảo simulator support VCD output
- Check quyền write trong results/ directory

#### 3. "Simulator not found" 
```bash
# Install ModelSim/QuestaSim hoặc sử dụng Icarus Verilog
sudo apt-get install iverilog gtkwave

# Sửa Makefile để sử dụng iverilog
SIM = iverilog
VLOG = iverilog
```

#### 4. "Unknown signals in waveform"
- Signals có giá trị X hoặc Z → check for uninitialized variables
- Missing clock → check clock generation
- Incorrect timing → check setup/hold times

### Debug tips:

#### 1. Kiểm tra test logs:
```bash
grep "PASS\|FAIL" results/*.log
grep "ERROR\|WARNING" results/*.log
```

#### 2. Tăng simulation time:
```verilog
// Trong testbench, tăng timeout
#10000;  // Run for 10000 time units
```

#### 3. Enable verbose output:
```verilog
// Set VERBOSE_MODE = 1 trong testbench parameters
parameter VERBOSE_MODE = 1;
```

---

## 📈 Expected Waveform Patterns

### ALU Waveform:
```
Time:     0    10    20    30    40    50
operand1: 100   200   300   400   500
operand2: 100   100   300   100   500  
control:  ADD   SUB   SUB   ADD   SUB
result:   200   100    0    500    0
zero_flag: 0     0     1     0     1
```

### Control Unit Waveform:
```
Time:     0      10      20      30
opcode:   ADD    ADDI    LW      SW
reg_write: 1      1       1       0
mem_write: 0      0       0      1111
alu_ctrl: ADD    ADD     ADD     ADD
imm_type:  X      I       I       S
```

### Register File Waveform:
```
Time:     0    10    20    30    40
clk:      0     1     0     1     0
reg_write: 0     1     0     1     0
rd_addr:   1     1     2     2     X
rd_data:  100   100   200   200    X
rs1_addr:  0     1     1     2     X
rs1_data:  0    100   100   200    X
```

---

## ✅ Verification Checklist

### Individual Modules:
- [ ] ALU: All operations tested, correct results
- [ ] Control: All instruction types, correct control signals
- [ ] RegFile: x0 hardwired, read/write works
- [ ] ImmGen: All immediate types, correct extension
- [ ] Branch: All branch types, signed/unsigned correct
- [ ] DataExt: All load types, correct extension

### System Level:
- [ ] CPU boots correctly (PC starts at 0)
- [ ] Instructions execute in order
- [ ] Pipeline stages advance correctly
- [ ] Hazards are detected and handled
- [ ] Memory operations work correctly
- [ ] Performance counters increment

### Waveform Quality:
- [ ] No X/Z values in critical signals
- [ ] Clock edges are clean and regular
- [ ] Setup/hold times are met
- [ ] Signal transitions are clean (no glitches)

---

## 🎉 Success Criteria

**Test PASSED khi:**
- Tất cả testbench reports "ALL TESTS PASSED"
- Waveforms không có X/Z values ở critical signals
- Timing requirements được đáp ứng
- Performance targets đạt được (IPC > 0.8)

**Ready for synthesis khi:**
- All individual modules pass
- System testbench passes
- Waveform analysis passes
- No critical warnings trong synthesis

---

**Happy Testing! 🚀**

