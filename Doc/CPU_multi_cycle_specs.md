# Đặc tả kỹ thuật CPU Multi-Cycle

## 1. Tổng quan

### 1.1 Mục đích
Thiết kế và triển khai một CPU 32-bit multi-cycle dựa trên kiến trúc RISC-V, có khả năng thực thi các lệnh cơ bản của bộ lệnh RV32I.

### 1.2 Phạm vi
- Thiết kế và triển khai các module cơ bản của CPU multi-cycle
- Tạo testbench và kiểm thử chức năng cho từng module
- Tích hợp các module thành CPU hoàn chỉnh
- Kiểm thử CPU với các chương trình đơn giản

### 1.3 Đặc điểm chính
- Kiến trúc: RISC-V RV32I
- Độ rộng dữ liệu: 32 bit
- Kiến trúc bộ nhớ: Von Neumann (bộ nhớ lệnh và dữ liệu kết hợp)
- Chu kỳ lệnh: 3-5 chu kỳ xung nhịp (tùy loại lệnh)
- Tần số hoạt động: 50-100MHz (tùy công nghệ FPGA/ASIC)
- Ngôn ngữ mô tả phần cứng: Verilog

## 2. Kiến trúc hệ thống

### 2.1 Sơ đồ khối tổng quát
CPU multi-cycle được thiết kế theo mô hình máy trạng thái hữu hạn (FSM) với các trạng thái chính:
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)
- Next Instruction (NEXT)

### 2.2 Datapath
Datapath bao gồm các thành phần chính:
- Program Counter và các thanh ghi trung gian (IR, MAR, MDR, A, B, ALUOut)
- Register File (32 thanh ghi 32-bit)
- ALU và ALU Control
- Immediate Generator
- Bộ nhớ kết hợp (lệnh và dữ liệu)
- Branch Comparator
- Các multiplexer điều khiển luồng dữ liệu

### 2.3 Control Unit
Control Unit FSM điều khiển toàn bộ hoạt động của CPU thông qua các tín hiệu điều khiển dựa trên trạng thái hiện tại và mã lệnh.

## 3. Đặc tả chi tiết các module

### 3.1 Bảng đầu vào/đầu ra của các module chính

#### 3.1.1 CPU Top-Level

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| intr        | Input | 1 bit   | Tín hiệu ngắt (tùy chọn)             |
| mem_addr    | Output| 32 bit  | Địa chỉ bộ nhớ ngoài (tùy chọn)      |
| mem_data_in | Input | 32 bit  | Dữ liệu từ bộ nhớ ngoài (tùy chọn)   |
| mem_data_out| Output| 32 bit  | Dữ liệu ghi ra bộ nhớ ngoài (tùy chọn)|
| mem_read    | Output| 1 bit   | Tín hiệu đọc bộ nhớ ngoài (tùy chọn) |
| mem_write   | Output| 1 bit   | Tín hiệu ghi bộ nhớ ngoài (tùy chọn) |

#### 3.1.2 Program Counter (PC)

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| pc_write    | Input | 1 bit   | Cho phép cập nhật PC                 |
| pc_next     | Input | 32 bit  | Giá trị PC tiếp theo                 |
| pc_current  | Output| 32 bit  | Giá trị PC hiện tại                  |

#### 3.1.3 Instruction Register (IR)

| Tín hiệu        | Loại  | Độ rộng | Mô tả                                |
|-----------------|-------|---------|--------------------------------------|
| clk             | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset           | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| ir_write        | Input | 1 bit   | Cho phép cập nhật IR                 |
| instruction_in  | Input | 32 bit  | Lệnh đầu vào từ bộ nhớ              |
| instruction_out | Output| 32 bit  | Lệnh đầu ra                          |
| opcode          | Output| 7 bit   | Mã hoạt động của lệnh                |
| rd              | Output| 5 bit   | Địa chỉ thanh ghi đích               |
| rs1             | Output| 5 bit   | Địa chỉ thanh ghi nguồn 1            |
| rs2             | Output| 5 bit   | Địa chỉ thanh ghi nguồn 2            |
| funct3          | Output| 3 bit   | Mã hàm phụ 3-bit                     |
| funct7          | Output| 7 bit   | Mã hàm phụ 7-bit                     |

#### 3.1.4 Memory Address Register (MAR)

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| mar_write   | Input | 1 bit   | Cho phép cập nhật MAR                |
| address_in  | Input | 32 bit  | Địa chỉ đầu vào                      |
| address_out | Output| 32 bit  | Địa chỉ đầu ra                       |

#### 3.1.5 Memory Data Register (MDR)

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| mdr_write   | Input | 1 bit   | Cho phép cập nhật MDR                |
| data_in     | Input | 32 bit  | Dữ liệu đầu vào                      |
| data_out    | Output| 32 bit  | Dữ liệu đầu ra                       |

#### 3.1.6 Register A và Register B

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| reg_write   | Input | 1 bit   | Cho phép cập nhật thanh ghi          |
| data_in     | Input | 32 bit  | Dữ liệu đầu vào                      |
| data_out    | Output| 32 bit  | Dữ liệu đầu ra                       |

#### 3.1.7 ALU Output Register

| Tín hiệu       | Loại  | Độ rộng | Mô tả                                |
|----------------|-------|---------|--------------------------------------|
| clk            | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset          | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| alu_out_write  | Input | 1 bit   | Cho phép cập nhật ALUOut             |
| result_in      | Input | 32 bit  | Kết quả đầu vào từ ALU               |
| result_out     | Output| 32 bit  | Kết quả đầu ra                       |

#### 3.1.8 Register File

| Tín hiệu    | Loại  | Độ rộng | Mô tả                                |
|-------------|-------|---------|--------------------------------------|
| clk         | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset       | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| reg_write   | Input | 1 bit   | Cho phép ghi vào thanh ghi           |
| rs1_addr    | Input | 5 bit   | Địa chỉ thanh ghi nguồn 1            |
| rs2_addr    | Input | 5 bit   | Địa chỉ thanh ghi nguồn 2            |
| rd_addr     | Input | 5 bit   | Địa chỉ thanh ghi đích               |
| write_data  | Input | 32 bit  | Dữ liệu ghi vào thanh ghi            |
| rs1_data    | Output| 32 bit  | Dữ liệu đọc từ thanh ghi nguồn 1     |
| rs2_data    | Output| 32 bit  | Dữ liệu đọc từ thanh ghi nguồn 2     |

#### 3.1.9 ALU (Arithmetic Logic Unit)

| Tín hiệu     | Loại  | Độ rộng | Mô tả                                |
|--------------|-------|---------|--------------------------------------|
| operand_a    | Input | 32 bit  | Toán hạng A                          |
| operand_b    | Input | 32 bit  | Toán hạng B                          |
| alu_control  | Input | 4 bit   | Mã phép toán                         |
| result       | Output| 32 bit  | Kết quả phép toán                    |
| zero         | Output| 1 bit   | Cờ báo kết quả bằng 0                |
| negative     | Output| 1 bit   | Cờ báo kết quả âm                    |
| overflow     | Output| 1 bit   | Cờ báo tràn số                       |

#### 3.1.10 ALU Control

| Tín hiệu     | Loại  | Độ rộng | Mô tả                                |
|--------------|-------|---------|--------------------------------------|
| ALUOp        | Input | 2 bit   | Mã phép toán từ Control Unit         |
| funct3       | Input | 3 bit   | Mã hàm phụ 3-bit từ lệnh             |
| funct7       | Input | 7 bit   | Mã hàm phụ 7-bit từ lệnh             |
| alu_control  | Output| 4 bit   | Mã điều khiển ALU                    |

#### 3.1.11 Immediate Generator

| Tín hiệu     | Loại  | Độ rộng | Mô tả                                |
|--------------|-------|---------|--------------------------------------|
| instruction  | Input | 32 bit  | Lệnh đầu vào                         |
| imm_type     | Input | 3 bit   | Loại immediate (I/S/B/U/J)           |
| immediate    | Output| 32 bit  | Giá trị immediate đã mở rộng dấu     |

#### 3.1.12 Memory

| Tín hiệu     | Loại  | Độ rộng | Mô tả                                |
|--------------|-------|---------|--------------------------------------|
| clk          | Input | 1 bit   | Tín hiệu xung nhịp                   |
| address      | Input | 32 bit  | Địa chỉ bộ nhớ                       |
| write_data   | Input | 32 bit  | Dữ liệu cần ghi                      |
| mem_write    | Input | 1 bit   | Cho phép ghi bộ nhớ                  |
| mem_read     | Input | 1 bit   | Cho phép đọc bộ nhớ                  |
| read_data    | Output| 32 bit  | Dữ liệu đọc được                     |

#### 3.1.13 Branch Comparator

| Tín hiệu      | Loại  | Độ rộng | Mô tả                                |
|---------------|-------|---------|--------------------------------------|
| rs1_data      | Input | 32 bit  | Dữ liệu từ thanh ghi nguồn 1         |
| rs2_data      | Input | 32 bit  | Dữ liệu từ thanh ghi nguồn 2         |
| branch_op     | Input | 3 bit   | Loại phép so sánh                    |
| branch_result | Output| 1 bit   | Kết quả so sánh                      |

#### 3.1.14 Control Unit FSM

| Tín hiệu        | Loại  | Độ rộng | Mô tả                                |
|-----------------|-------|---------|--------------------------------------|
| clk             | Input | 1 bit   | Tín hiệu xung nhịp                   |
| reset           | Input | 1 bit   | Tín hiệu reset đồng bộ               |
| opcode          | Input | 7 bit   | Mã hoạt động từ IR                   |
| funct3          | Input | 3 bit   | Mã hàm phụ 3-bit từ IR               |
| funct7          | Input | 7 bit   | Mã hàm phụ 7-bit từ IR               |
| zero            | Input | 1 bit   | Cờ zero từ ALU                       |
| negative        | Input | 1 bit   | Cờ negative từ ALU                   |
| branch_result   | Input | 1 bit   | Kết quả từ Branch Comparator         |
| pc_write        | Output| 1 bit   | Cho phép ghi PC                      |
| ir_write        | Output| 1 bit   | Cho phép ghi IR                      |
| mar_write       | Output| 1 bit   | Cho phép ghi MAR                     |
| mdr_write       | Output| 1 bit   | Cho phép ghi MDR                     |
| reg_write       | Output| 1 bit   | Cho phép ghi Register File           |
| a_write         | Output| 1 bit   | Cho phép ghi Register A              |
| b_write         | Output| 1 bit   | Cho phép ghi Register B              |
| alu_out_write   | Output| 1 bit   | Cho phép ghi ALU Output Register     |
| mem_read        | Output| 1 bit   | Cho phép đọc Memory                  |
| mem_write       | Output| 1 bit   | Cho phép ghi Memory                  |
| ALUOp           | Output| 2 bit   | Mã phép toán cho ALU Control         |
| ALUSrcA         | Output| 2 bit   | Chọn nguồn toán hạng A cho ALU       |
| ALUSrcB         | Output| 2 bit   | Chọn nguồn toán hạng B cho ALU       |
| PCSource        | Output| 2 bit   | Chọn nguồn cập nhật PC               |
| RegDst          | Output| 1 bit   | Chọn địa chỉ thanh ghi đích          |
| MemtoReg        | Output| 1 bit   | Chọn nguồn dữ liệu ghi vào thanh ghi |
| IorD            | Output| 1 bit   | Chọn nguồn địa chỉ bộ nhớ            |
| imm_type        | Output| 3 bit   | Loại immediate cần tạo               |
| branch_op       | Output| 3 bit   | Loại phép so sánh cho Branch Comparator |
| current_state   | Output| 4 bit   | Trạng thái hiện tại của FSM          |

## 4. Đặc tả chức năng

### 4.1 Tập lệnh hỗ trợ
CPU hỗ trợ các lệnh cơ bản của bộ lệnh RV32I:

#### Lệnh số học và logic
- ADD, SUB, AND, OR, XOR, SLL, SRL, SRA
- ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI
- SLT, SLTU, SLTI, SLTIU

#### Lệnh truy cập bộ nhớ
- LW, LH, LB, LHU, LBU (Load)
- SW, SH, SB (Store)

#### Lệnh rẽ nhánh và nhảy
- BEQ, BNE, BLT, BGE, BLTU, BGEU (Branch)
- JAL, JALR (Jump)

#### Lệnh khác
- LUI, AUIPC

### 4.2 Chu kỳ lệnh
Số chu kỳ xung nhịp cho mỗi loại lệnh:

| Loại lệnh          | Số chu kỳ | Các giai đoạn                     |
|--------------------|-----------|-----------------------------------|
| R-type (ADD, SUB...) | 4         | IF → ID → EX → WB → NEXT          |
| I-type (ADDI...)     | 4         | IF → ID → EX → WB → NEXT          |
| Load (LW, LH, LB...) | 5         | IF → ID → EX → MEM → WB → NEXT    |
| Store (SW, SH, SB)   | 4         | IF → ID → EX → MEM → NEXT         |
| Branch (không nhảy)  | 3         | IF → ID → EX → NEXT               |
| Branch (có nhảy)     | 3         | IF → ID → EX → NEXT               |
| Jump (JAL, JALR)     | 3         | IF → ID → EX → NEXT               |

### 4.3 Hoạt động của các giai đoạn

#### Instruction Fetch (IF)
- MAR ← PC
- MDR ← MEM[MAR]
- IR ← MDR
- PC ← PC + 4 (tạm thời)

#### Instruction Decode (ID)
- Giải mã lệnh từ IR
- A ← RF[rs1]
- B ← RF[rs2]
- Tạo giá trị immediate

#### Execute (EX)
- ALUOut ← ALU(A/PC, B/Imm)
- Thiết lập các cờ (zero, negative, overflow)
- Tính toán địa chỉ đích cho branch/jump

#### Memory Access (MEM)
- Cho lệnh load/store:
  - MAR ← ALUOut
  - Load: MDR ← MEM[MAR]
  - Store: MEM[MAR] ← B

#### Write Back (WB)
- Lệnh R/I-type: RF[rd] ← ALUOut
- Lệnh load: RF[rd] ← MDR

#### Next Instruction (NEXT)
- Cập nhật PC dựa trên loại lệnh và điều kiện
- PC ← PC (đã tăng ở IF) nếu không nhảy
- PC ← Branch target nếu điều kiện rẽ nhánh đúng
- PC ← Jump target cho lệnh jump

## 5. Đặc tả hiệu năng

### 5.1 Thời gian
- Chu kỳ xung nhịp tối thiểu: 10ns (100MHz)
- Thời gian thực thi trung bình mỗi lệnh: 3-5 chu kỳ xung nhịp
- Thời gian trễ tối đa cho đường tới hạn: 8ns

### 5.2 Tài nguyên phần cứng (ước tính cho FPGA)
- LUTs: 2,000-5,000
- Flip-Flops: 1,000-2,000
- Block RAMs: 2-4
- DSP Slices: 0-2

### 5.3 Tiêu thụ điện năng
- Tiêu thụ năng lượng động: 100-200mW (tùy công nghệ)
- Tiêu thụ năng lượng tĩnh: 10-20mW (tùy công nghệ)

## 6. Giao diện và tích hợp

### 6.1 Giao diện bên ngoài
- Tín hiệu clock và reset
- Giao diện bộ nhớ ngoài (tùy chọn)
- Giao diện ngắt (tùy chọn)
- Giao diện debug (tùy chọn)

### 6.2 Giao thức truyền thông
- Giao thức handshaking đơn giản cho giao tiếp với bộ nhớ ngoài
- Giao thức ngắt cơ bản (tùy chọn)

## 7. Kiểm thử và xác minh

### 7.1 Phương pháp kiểm thử
- Kiểm thử đơn vị cho từng module
- Kiểm thử tích hợp cho các nhóm module
- Kiểm thử hệ thống cho toàn bộ CPU
- Kiểm thử hồi quy sau mỗi thay đổi

### 7.2 Môi trường kiểm thử
- Mô phỏng: ModelSim/Questa/VCS
- Tổng hợp: Xilinx Vivado/Intel Quartus
- FPGA Prototyping: Xilinx/Intel FPGA

### 7.3 Testbench và test cases
- Testbench cho từng module riêng biệt
- Testbench tích hợp cho toàn bộ CPU
- Bộ test cases cho các lệnh và chương trình đơn giản

## 8. Lộ trình triển khai

### 8.1 Giai đoạn 1: Thiết kế và triển khai module
- Thiết kế chi tiết từng module
- Triển khai code Verilog cho từng module
- Kiểm thử đơn vị cho từng module

### 8.2 Giai đoạn 2: Tích hợp và kiểm thử
- Tích hợp các module thành CPU hoàn chỉnh
- Kiểm thử tích hợp và gỡ lỗi
- Tối ưu hóa hiệu năng

### 8.3 Giai đoạn 3: Triển khai và kiểm thử hệ thống
- Triển khai CPU trên FPGA (tùy chọn)
- Kiểm thử với các chương trình thực tế
- Đánh giá hiệu năng và tài nguyên

### 8.4 Giai đoạn 4: Tài liệu và hoàn thiện
- Hoàn thiện tài liệu thiết kế
- Tạo hướng dẫn sử dụng
- Tạo báo cáo kỹ thuật

## 9. Tài liệu tham khảo

1. RISC-V Instruction Set Manual, Volume I: User-Level ISA
2. David A. Patterson and John L. Hennessy, "Computer Organization and Design: The Hardware/Software Interface"
3. Harris, D. and Harris, S., "Digital Design and Computer Architecture: RISC-V Edition"
4. Verilog HDL: A Guide to Digital Design and Synthesis by Samir Palnitkar 