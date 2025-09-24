# 🚀 Quick Start - Chạy test ngay!

## Phương pháp 1: Python Demo Script (Khuyến nghị)
```bash
cd verify/
python3 demo_alu_test.py
```

## Phương pháp 2: Shell Script (Linux/WSL)
```bash
cd verify/
bash simple_test_runner.sh
```

## Phương pháp 3: Makefile (Professional)
```bash
cd verify/
make alu          # Test ALU only
make all          # Test all modules
make wave_alu     # View ALU waveform
```

## Phương pháp 4: Manual (Bất kỳ simulator nào)
```bash
cd verify/results/
iverilog -o alu_test ../src/alu.v ../alu_tb.v
vvp alu_test
gtkwave alu_tb.vcd &
```

---

## 📊 Expected Results

### ✅ PASS - Khi test thành công:
```
========================================
ALU TESTBENCH STARTING
========================================
Running Basic Arithmetic Tests...
  ✅ PASS: ADD: Normal case
  ✅ PASS: SUB: Normal case
...
🎉 ALL TESTS PASSED! ALU implementation is correct.
```

### 📊 VCD Files được tạo:
```
results/
├── alu_tb.vcd              # ALU waveform  
├── control_unit_tb.vcd     # Control unit waveform
├── register_file_tb.vcd    # Register file waveform
└── ...
```

---

## 🌊 Phân tích Waveform

### 1. Mở waveform viewer:
```bash
gtkwave results/alu_tb.vcd &
```

### 2. Signals quan trọng cần xem:
- **operand1[31:0]**: Input đầu tiên
- **operand2[31:0]**: Input thứ hai  
- **alu_control[3:0]**: Mã lệnh ALU (0000=ADD, 0001=SUB, ...)
- **alu_result[31:0]**: Kết quả output
- **zero_flag**: Cờ báo kết quả = 0

### 3. Pattern đúng trong waveform:

#### ADD Operation (alu_control = 0000):
```
Time:        0ns    10ns    20ns    30ns
operand1:    100     200     300     400
operand2:    100     100     200     200  
alu_result:  200     300     500     600
zero_flag:    0       0       0       0
```

#### SUB Operation (alu_control = 0001):  
```
Time:        40ns    50ns    60ns    70ns
operand1:    300     200     100     100
operand2:    300     100     200     100
alu_result:    0     100    -100       0
zero_flag:     1       0       0       1
```

### 4. ✅ Kiểm tra điều gì:
- **Timing**: Result thay đổi ngay sau khi inputs thay đổi
- **Correctness**: ADD: 100+200=300, SUB: 300-300=0
- **Zero flag**: = 1 khi result = 0, = 0 khi result ≠ 0
- **No glitches**: Signals stable, không có X hoặc Z
- **All operations**: ADD, SUB, AND, OR, XOR, SLT, shifts

### 5. ❌ Red flags trong waveform:
- **X values**: Uninitialized signals (bad)
- **Z values**: Tri-state conflicts (bad)
- **Glitches**: Multiple transitions in short time
- **Wrong results**: 100+200≠300 
- **Zero flag error**: Result=0 but zero_flag=0

---

## 🔧 Troubleshooting

### Problem 1: "Simulator not found"
```bash
# Install Icarus Verilog (free)
sudo apt-get install iverilog gtkwave

# Or use WSL on Windows
wsl --install
```

### Problem 2: "Compilation error"
```
Check:
1. All .v files exist in src/
2. No syntax errors in Verilog code  
3. Correct file paths
```

### Problem 3: "No VCD file"
```verilog
// Make sure testbench has:
initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
end
```

### Problem 4: "Test failed"
```
Check test log for specific failures:
- Wrong ALU results
- Missing signals
- Timing issues
```

---

## 📈 Automated Analysis
```bash
# Run analysis script
python3 analyze_waveform.py --vcd-dir results --module all

# View report
cat waveform_analysis_report.txt
```

---

## 🎯 Next Steps

### Module Tests (Individual):
1. ✅ ALU - Arithmetic operations
2. ✅ Control Unit - Instruction decoding
3. ✅ Register File - 32 registers with x0=0
4. ✅ Immediate Generator - All immediate types
5. ✅ Branch Decision - All branch conditions
6. ✅ Data Extension - Load data formatting

### System Test (Integration):
```bash
# Full CPU test with real programs
make cpu_test
gtkwave results/riscv_cpu_comprehensive.vcd &
```

---

## ✅ Success Criteria

**Individual module test PASSED when:**
- All test cases pass (no FAIL messages)
- VCD file generated successfully
- Waveform shows correct behavior
- No X/Z values in critical signals

**Ready for next step when:**
- All 6 individual modules pass
- Waveforms look clean and correct
- Performance targets met

---

## 🆘 Need Help?

1. **Check logs**: `cat results/*.log`
2. **View source**: `ls src/*.v` 
3. **Manual test**: Copy commands from scripts
4. **Waveform debug**: Look for timing/logic errors

**Common solutions:**
- Install simulator: `sudo apt-get install iverilog gtkwave`
- Check paths: Make sure src/ files exist
- Fix permissions: `chmod +x *.sh`

---

## 🎉 Ready to Test!

Choose your preferred method above and start testing!
Each method will create VCD files for waveform analysis.

**Happy testing! 🚀**

