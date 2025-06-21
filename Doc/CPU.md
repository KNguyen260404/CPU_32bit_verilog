## Thiết kế CPU bằng Verilog: Các module cần thiết

Thiết kế một CPU bằng Verilog là một bài toán lớn và thú vị. CPU là một hệ thống phức tạp, thường được thiết kế theo kiểu **modular (chia module)** để dễ quản lý, phát triển và kiểm tra. Dưới đây là các **module chính** cần có để thiết kế một **CPU kiểu RISC đơn giản (giống MIPS hoặc RISC-V)**.

---

### 🔧 Các module cơ bản cần có trong CPU:

#### 1. Program Counter (PC)
- **Chức năng**: Giữ địa chỉ lệnh hiện tại đang thực thi.
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `reset`: Tín hiệu reset (1 bit)
  - `pc_next`: Địa chỉ tiếp theo (32 bit)
  - `pc_write`: Tín hiệu cho phép ghi PC (1 bit, tùy chọn)
- **Đầu ra**:
  - `pc_current`: Địa chỉ hiện tại (32 bit)
- **Specifications**:
  - Khi `reset=1`, PC sẽ reset về 0x00000000
  - Khi `clk` lên xung và `pc_write=1` (hoặc không có tín hiệu `pc_write`), PC sẽ cập nhật giá trị mới từ `pc_next`
  - Độ rộng mặc định là 32 bit (có thể điều chỉnh qua tham số)

#### 2. Instruction Memory
- **Chức năng**: Lưu các lệnh máy (instruction) đã được nạp sẵn (giả lập ROM).
- **Đầu vào**:
  - `address`: Địa chỉ lệnh từ PC (32 bit)
- **Đầu ra**:
  - `instruction`: Mã lệnh đọc được (32 bit)
- **Specifications**:
  - Kích thước bộ nhớ: 1024 words (4KB), có thể tùy chỉnh
  - Chỉ đọc (read-only)
  - Không đồng bộ (combinational logic)
  - Khởi tạo từ file hex hoặc binary

#### 3. Instruction Decoder / Control Unit
- **Chức năng**: Giải mã lệnh và tạo tín hiệu điều khiển.
- **Đầu vào**:
  - `instruction`: Mã lệnh cần giải mã (32 bit)
- **Đầu ra**:
  - `opcode`: Mã hoạt động (7 bit cho RISC-V)
  - `rd`: Địa chỉ thanh ghi đích (5 bit)
  - `rs1`: Địa chỉ thanh ghi nguồn 1 (5 bit)
  - `rs2`: Địa chỉ thanh ghi nguồn 2 (5 bit)
  - `funct3`: Mã hàm phụ 3-bit (3 bit)
  - `funct7`: Mã hàm phụ 7-bit (7 bit)
  - `RegWrite`: Cho phép ghi vào thanh ghi (1 bit)
  - `MemtoReg`: Chọn dữ liệu từ bộ nhớ hay ALU (1 bit)
  - `MemRead`: Cho phép đọc bộ nhớ (1 bit)
  - `MemWrite`: Cho phép ghi bộ nhớ (1 bit)
  - `ALUSrc`: Chọn nguồn toán hạng B cho ALU (1 bit)
  - `ALUOp`: Mã phép toán ALU (2 bit)
  - `Branch`: Tín hiệu lệnh rẽ nhánh (1 bit)
  - `Jump`: Tín hiệu lệnh nhảy (1 bit)
- **Specifications**:
  - Hỗ trợ các lệnh cơ bản: R-type, I-type, S-type, B-type, U-type, J-type
  - Giải mã đồng thời các trường của lệnh và tạo tín hiệu điều khiển

#### 4. Register File
- **Chức năng**: Lưu trữ các thanh ghi của CPU.
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `reset`: Tín hiệu reset (1 bit)
  - `reg_write`: Cho phép ghi vào thanh ghi (1 bit)
  - `rs1_addr`: Địa chỉ thanh ghi đọc 1 (5 bit)
  - `rs2_addr`: Địa chỉ thanh ghi đọc 2 (5 bit)
  - `rd_addr`: Địa chỉ thanh ghi ghi (5 bit)
  - `write_data`: Dữ liệu cần ghi (32 bit)
- **Đầu ra**:
  - `rs1_data`: Dữ liệu đọc từ thanh ghi 1 (32 bit)
  - `rs2_data`: Dữ liệu đọc từ thanh ghi 2 (32 bit)
- **Specifications**:
  - 32 thanh ghi x 32 bit (x0 đến x31 cho RISC-V)
  - Thanh ghi x0 luôn bằng 0
  - Đọc không đồng bộ (combinational)
  - Ghi đồng bộ theo xung `clk` khi `reg_write=1`

#### 5. ALU (Arithmetic Logic Unit)
- **Chức năng**: Thực hiện các phép toán số học và logic.
- **Đầu vào**:
  - `operand_a`: Toán hạng A (32 bit)
  - `operand_b`: Toán hạng B (32 bit)
  - `alu_control`: Mã phép toán (4 bit)
- **Đầu ra**:
  - `result`: Kết quả phép toán (32 bit)
  - `zero`: Cờ báo kết quả bằng 0 (1 bit)
  - `overflow`: Cờ báo tràn số (1 bit, tùy chọn)
  - `negative`: Cờ báo kết quả âm (1 bit, tùy chọn)
- **Specifications**:
  - Hỗ trợ các phép toán: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
  - Mã phép toán 4 bit để hỗ trợ 10-16 phép toán

#### 6. Immediate Generator
- **Chức năng**: Giải mã giá trị immediate từ lệnh.
- **Đầu vào**:
  - `instruction`: Mã lệnh (32 bit)
  - `imm_type`: Loại immediate (3 bit, tùy chọn)
- **Đầu ra**:
  - `immediate`: Giá trị immediate đã mở rộng dấu (32 bit)  
- **Specifications**:
  - Hỗ trợ các định dạng immediate: I-type, S-type, B-type, U-type, J-type
  - Tự động mở rộng dấu (sign extension)

#### 7. ALU Control Unit
- **Chức năng**: Xác định phép toán ALU cụ thể.
- **Đầu vào**:
  - `ALUOp`: Mã phép toán từ control unit (2 bit)
  - `funct3`: Mã hàm phụ 3-bit từ instruction (3 bit)   
  - `funct7`: Mã hàm phụ 7-bit từ instruction (7 bit)
- **Đầu ra**:
  - `alu_control`: Mã điều khiển ALU (4 bit)
- **Specifications**:
  - Dựa vào `ALUOp`, `funct3` và `funct7` để xác định chính xác phép toán ALU
  - Hỗ trợ các lệnh R-type, I-type, load/store, branch

#### 8. Data Memory
- **Chức năng**: Lưu trữ dữ liệu (RAM).
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `address`: Địa chỉ bộ nhớ (32 bit)
  - `write_data`: Dữ liệu cần ghi (32 bit)
  - `mem_write`: Cho phép ghi (1 bit)
  - `mem_read`: Cho phép đọc (1 bit)
- **Đầu ra**:
  - `read_data`: Dữ liệu đọc được (32 bit)
- **Specifications**:
  - Kích thước bộ nhớ: 1024 words (4KB), có thể tùy chỉnh
  - Đọc không đồng bộ (combinational) khi `mem_read=1`
  - Ghi đồng bộ theo xung `clk` khi `mem_write=1`
  - Hỗ trợ đọc/ghi byte, half-word, word (tùy chọn)

#### 9. Branch Comparator / Branch Logic
- **Chức năng**: Xử lý các lệnh rẽ nhánh.
- **Đầu vào**:
  - `rs1_data`: Dữ liệu từ thanh ghi 1 (32 bit)
  - `rs2_data`: Dữ liệu từ thanh ghi 2 (32 bit)
  - `branch`: Tín hiệu lệnh rẽ nhánh (1 bit)
  - `funct3`: Loại phép so sánh (3 bit)
- **Đầu ra**:
  - `branch_taken`: Kết quả quyết định nhảy (1 bit)
- **Specifications**:
  - Hỗ trợ các lệnh: BEQ, BNE, BLT, BGE, BLTU, BGEU
  - Kết hợp với tín hiệu `branch` để quyết định có nhảy hay không

#### 10. MUX (Multiplexers)
- **Chức năng**: Chọn đường đi dữ liệu.
- **Đầu vào**:
  - `input0`: Đầu vào 0 (32 bit)
  - `input1`: Đầu vào 1 (32 bit)
  - `select`: Tín hiệu chọn (1 bit)
- **Đầu ra**:
  - `output`: Đầu ra được chọn (32 bit)
- **Specifications**:
  - Nhiều MUX được sử dụng trong datapath
  - Các MUX chính: ALUSrc MUX, MemtoReg MUX, PC Source MUX

---

### 🧠 Các module bổ sung (tùy chọn)

#### 1. Forwarding Unit
- **Chức năng**: Giải quyết data hazard trong pipeline.
- **Đầu vào**:
  - `rs1_addr_ex`: Địa chỉ thanh ghi nguồn 1 ở stage EX (5 bit)
  - `rs2_addr_ex`: Địa chỉ thanh ghi nguồn 2 ở stage EX (5 bit)
  - `rd_addr_mem`: Địa chỉ thanh ghi đích ở stage MEM (5 bit)
  - `rd_addr_wb`: Địa chỉ thanh ghi đích ở stage WB (5 bit)
  - `reg_write_mem`: Tín hiệu ghi thanh ghi ở stage MEM (1 bit)
  - `reg_write_wb`: Tín hiệu ghi thanh ghi ở stage WB (1 bit)
- **Đầu ra**:
  - `forward_a`: Điều khiển forwarding cho toán hạng A (2 bit)
  - `forward_b`: Điều khiển forwarding cho toán hạng B (2 bit)
- **Specifications**:
  - Phát hiện data hazard và tạo tín hiệu điều khiển forwarding
  - Ưu tiên forwarding từ giai đoạn gần hơn (MEM trước WB)

#### 2. Hazard Detection Unit
- **Chức năng**: Phát hiện và xử lý load-use hazard.
- **Đầu vào**:
  - `rs1_addr_id`: Địa chỉ thanh ghi nguồn 1 ở stage ID (5 bit)
  - `rs2_addr_id`: Địa chỉ thanh ghi nguồn 2 ở stage ID (5 bit)
  - `rd_addr_ex`: Địa chỉ thanh ghi đích ở stage EX (5 bit)
  - `mem_read_ex`: Tín hiệu đọc bộ nhớ ở stage EX (1 bit)
- **Đầu ra**:
  - `stall`: Tín hiệu dừng pipeline (1 bit)
- **Specifications**:
  - Phát hiện load-use hazard và tạo tín hiệu stall
  - Khi `stall=1`, PC và IF/ID register không cập nhật, ID/EX register được xóa

#### 3. Pipeline Registers
- **Chức năng**: Lưu trữ trạng thái giữa các stage của pipeline.
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `reset`: Tín hiệu reset (1 bit)
  - `stall`: Tín hiệu dừng (1 bit, tùy chọn)
  - `flush`: Tín hiệu xóa (1 bit, tùy chọn)
  - Các tín hiệu đầu vào từ stage trước
- **Đầu ra**:
  - Các tín hiệu đầu ra cho stage tiếp theo
- **Specifications**:
  - IF/ID Register: Lưu PC và instruction
  - ID/EX Register: Lưu tín hiệu điều khiển, giá trị thanh ghi, immediate, địa chỉ thanh ghi
  - EX/MEM Register: Lưu tín hiệu điều khiển, kết quả ALU, dữ liệu ghi bộ nhớ, địa chỉ thanh ghi đích
  - MEM/WB Register: Lưu tín hiệu điều khiển, dữ liệu từ bộ nhớ, kết quả ALU, địa chỉ thanh ghi đích

#### 4. CSR/Interrupt Unit
- **Chức năng**: Xử lý ngắt và truy cập thanh ghi điều khiển/trạng thái.
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `reset`: Tín hiệu reset (1 bit)
  - `interrupt`: Tín hiệu ngắt từ bên ngoài (1 bit)
  - `instruction`: Mã lệnh CSR (32 bit)
  - `rs1_data`: Dữ liệu từ thanh ghi nguồn (32 bit)
  - `pc_current`: Giá trị PC hiện tại (32 bit)
- **Đầu ra**:
  - `csr_data`: Dữ liệu đọc từ CSR (32 bit)
  - `trap_vector`: Địa chỉ xử lý ngắt (32 bit)
  - `trap_taken`: Tín hiệu có ngắt xảy ra (1 bit)
- **Specifications**:
  - Hỗ trợ các lệnh CSR: CSRRW, CSRRS, CSRRC
  - Lưu trữ các thanh ghi CSR: mtvec, mepc, mcause, ...
  - Xử lý ngắt và ngoại lệ

#### 5. Cache (I-Cache, D-Cache)
- **Chức năng**: Bộ nhớ đệm tốc độ cao.
- **Đầu vào**:
  - `clk`: Tín hiệu xung nhịp (1 bit)
  - `reset`: Tín hiệu reset (1 bit)
  - `address`: Địa chỉ truy cập (32 bit)
  - `write_data`: Dữ liệu cần ghi (32 bit, chỉ cho D-Cache)
  - `write_enable`: Cho phép ghi (1 bit, chỉ cho D-Cache)
  - `read_enable`: Cho phép đọc (1 bit)
- **Đầu ra**:
  - `read_data`: Dữ liệu đọc được (32 bit)
  - `hit`: Tín hiệu cache hit (1 bit)
  - `miss`: Tín hiệu cache miss (1 bit)
- **Specifications**:
  - Kích thước cache: 1KB-4KB
  - Kiến trúc: Direct-mapped hoặc 2-way set associative
  - Chính sách thay thế: LRU
  - Chính sách ghi: Write-through hoặc write-back

---

### 🏗️ Sơ đồ luồng dữ liệu (Datapath)

Nếu bạn đang làm CPU **single-cycle**, bạn sẽ có một datapath đơn với các module trên nối trực tiếp.

Nếu bạn làm CPU **multi-cycle hoặc pipelined**, các module trên sẽ chia ra theo từng stage và có thêm register trung gian.

#### Single-Cycle Datapath
```
PC → Instruction Memory → Decoder/Control → Register File → ALU → Data Memory → Register File
 ↑                           ↓                  ↓           ↑      ↓
 └───────────────────────────┴──────────────────┴───────────┴──────┘
```

#### 5-Stage Pipeline Datapath
```
IF Stage:    PC → Instruction Memory → IF/ID Register
ID Stage:    IF/ID Register → Decoder/Control + Register File → ID/EX Register
EX Stage:    ID/EX Register → ALU + ALU Control → EX/MEM Register
MEM Stage:   EX/MEM Register → Data Memory → MEM/WB Register
WB Stage:    MEM/WB Register → Register File
``` 

---

### 📋 Testplan

#### 1. Unit Testing
- **Program Counter**: Kiểm tra reset, cập nhật giá trị mới, stall
- **Instruction Memory**: Kiểm tra đọc instruction từ các địa chỉ khác nhau
- **Register File**: Kiểm tra đọc/ghi các thanh ghi, x0 luôn bằng 0
- **ALU**: Kiểm tra từng phép toán với các giá trị biên
- **Control Unit**: Kiểm tra tín hiệu điều khiển cho từng loại lệnh
- **Data Memory**: Kiểm tra đọc/ghi byte, half-word, word

#### 2. Integration Testing
- **Fetch Stage**: PC + Instruction Memory
- **Decode Stage**: Decoder + Register File
- **Execute Stage**: ALU + ALU Control
- **Memory Stage**: Data Memory
- **Writeback Stage**: Kết nối từ Data Memory/ALU về Register File

#### 3. System Testing
- **Chương trình đơn giản**: Cộng, trừ, AND, OR, XOR
- **Chương trình rẽ nhánh**: Kiểm tra các lệnh branch
- **Chương trình load/store**: Kiểm tra truy cập bộ nhớ
- **Chương trình tổng hợp**: Tính tổng mảng, tìm giá trị lớn nhất/nhỏ nhất
- **Benchmark**: Chạy thuật toán sắp xếp, tính giai thừa, Fibonacci

#### 4. Testbench
```verilog
module cpu_tb;
    reg clk;
    reg reset;
    
    // Khởi tạo CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Tạo xung clock
    always begin
        #5 clk = ~clk;
    end
    
    // Testcase
    initial begin
        // Khởi tạo
        clk = 0;
        reset = 1;
        
        // Reset
        #10 reset = 0;
        
        // Chạy mô phỏng
        #1000;
        
        // Kết thúc
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time=%0t, PC=%h, Instruction=%h", $time, uut.pc_current, uut.instruction);
    end
    
    // Dump waveform
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);
    end
endmodule
```

### 💡 Gợi ý bước khởi đầu:

1. **Bắt đầu với CPU đơn chu kỳ (single-cycle)**:
   - Triển khai từng module riêng lẻ và kiểm thử
   - Kết nối các module lại với nhau theo datapath
   - Kiểm thử với các chương trình đơn giản

2. **Mô phỏng với một tập lệnh nhỏ**:
   - Các lệnh số học: `add`, `sub`, `and`, `or`, `xor`
   - Các lệnh load/store: `lw`, `sw`
   - Các lệnh rẽ nhánh: `beq`, `bne`
   - Các lệnh nhảy: `jal`, `jalr`

3. **Tự tạo chương trình đơn giản để test**:
   - Chương trình tính tổng: `sum = a + b + c + d`
   - Chương trình tìm max: `max = (a > b) ? a : b`
   - Chương trình vòng lặp: Tính tổng mảng

4. **Mở rộng sang CPU pipeline**:
   - Thêm các pipeline register
   - Triển khai forwarding unit
   - Triển khai hazard detection unit
   - Xử lý control hazard

