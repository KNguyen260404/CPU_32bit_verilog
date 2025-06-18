# Câu hỏi và Trả lời về CPU

## Câu hỏi 1: Phân biệt 3 luồng dữ liệu trong CPU

**Hỏi:** Tôi thấy trong CPU sẽ có 3 luồng dữ liệu là Control Bus, Data Bus và Address Bus. Vậy làm thế nào để phân biệt các luồng dữ liệu này, các cách nó vận hành trên CPU?

**Trả lời:** Trong thiết kế CPU, ba luồng dữ liệu chính - Control Bus, Data Bus và Address Bus - đều có vai trò và cách vận hành khác nhau:

### Address Bus
- **Chức năng**: Truyền địa chỉ từ CPU đến bộ nhớ hoặc thiết bị I/O
- **Đặc điểm**: 
  - Một chiều (unidirectional): CPU → bộ nhớ/thiết bị
  - Độ rộng thường là 32-bit hoặc 64-bit
- **Vận hành**: 
  - CPU đặt địa chỉ lên Address Bus khi cần đọc/ghi dữ liệu
  - Xác định vị trí chính xác trong bộ nhớ để truy cập

### Data Bus
- **Chức năng**: Truyền dữ liệu giữa CPU và bộ nhớ hoặc thiết bị I/O
- **Đặc điểm**:
  - Hai chiều (bidirectional): CPU ↔ bộ nhớ/thiết bị
  - Độ rộng thường tương đương với kích thước word (32/64-bit)
- **Vận hành**:
  - Khi đọc: Dữ liệu di chuyển từ bộ nhớ → CPU
  - Khi ghi: Dữ liệu di chuyển từ CPU → bộ nhớ
  - Truyền dữ liệu thực (instruction, data values)

### Control Bus
- **Chức năng**: Điều khiển hoạt động của các thành phần trong hệ thống
- **Đặc điểm**:
  - Hai chiều (bidirectional)
  - Gồm nhiều đường tín hiệu điều khiển riêng biệt
- **Vận hành**:
  - Mang các tín hiệu như Read/Write, Memory/IO, Interrupt
  - Điều phối thời gian và đồng bộ hóa hoạt động
  - Quyết định hướng dữ liệu trên Data Bus

Trong thiết kế Verilog, các bus này được thể hiện qua các port và tín hiệu kết nối giữa các module như PC, Memory, ALU và Register File.

## Câu hỏi 2: Lưu ý khi viết code cho các module CPU

**Hỏi:** Vậy khi viết code cho các module cần lưu ý đến 3 luồng data này không?

**Trả lời:** Đúng vậy, khi viết code Verilog cho các module CPU, bạn cần lưu ý đến 3 luồng dữ liệu này:

1. **Address Bus**
   - Định nghĩa rõ các port địa chỉ (thường là output từ PC, input cho Memory)
   - Đảm bảo độ rộng phù hợp (thường 32-bit)
   - Ví dụ: `output [31:0] address` hoặc `input [31:0] address`

2. **Data Bus**
   - Định nghĩa các port dữ liệu hai chiều khi cần thiết
   - Phân biệt rõ data input và output
   - Ví dụ: `input [31:0] write_data`, `output [31:0] read_data`

3. **Control Bus**
   - Định nghĩa các tín hiệu điều khiển riêng biệt
   - Đặt tên rõ ràng cho từng tín hiệu (mem_read, mem_write, reg_write)
   - Ví dụ: `input mem_write`, `input reg_write`, `output branch_taken`

Khi kết nối các module, cần đảm bảo các tín hiệu được nối đúng đường và đồng bộ với nhau theo timing diagram của CPU. Đặc biệt với Control Bus, cần thiết kế Control Unit để tạo ra các tín hiệu điều khiển chính xác dựa trên mã lệnh.

## Câu hỏi 3: Sự khác nhau về luồng dữ liệu giữa các module

**Hỏi:** Vậy có nghĩa có một số module sẽ có những kiểu data này nhưng một số module khác có thể không có? VD: ALU sẽ có các luồng data như Control Bus và Data Bus nhưng Program Counter thì sẽ có cả 3 luồng data là Control Bus, Data Bus và Address Bus?

**Trả lời:** Đúng vậy! Mỗi module trong CPU sẽ sử dụng các luồng dữ liệu khác nhau tùy theo chức năng của nó:

### 1. Program Counter (PC)
- **Address Bus**: Output địa chỉ lệnh hiện tại (pc_current)
- **Control Bus**: Input tín hiệu điều khiển (reset, pc_write, stall)
- **Data Bus**: Input giá trị PC tiếp theo (pc_next) từ mạch tính toán

### 2. ALU (Arithmetic Logic Unit)
- **Data Bus**: Input operands (operand_a, operand_b) và output kết quả (result)
- **Control Bus**: Input tín hiệu điều khiển (alu_control) và output flags (zero, overflow)
- **Không sử dụng Address Bus** vì không trực tiếp truy cập bộ nhớ

### 3. Register File
- **Address Bus**: Input địa chỉ thanh ghi (rs1_addr, rs2_addr, rd_addr)
- **Data Bus**: Input dữ liệu ghi (write_data) và output dữ liệu đọc (rs1_data, rs2_data)
- **Control Bus**: Input tín hiệu điều khiển (reg_write, reset)

### 4. Data Memory
- **Address Bus**: Input địa chỉ bộ nhớ (address)
- **Data Bus**: Input/output dữ liệu (write_data/read_data)
- **Control Bus**: Input tín hiệu điều khiển (mem_read, mem_write)

### 5. Instruction Memory
- **Address Bus**: Input địa chỉ lệnh từ PC
- **Data Bus**: Output mã lệnh (instruction)
- **Control Bus**: Thường ít hoặc không có (vì chỉ đọc)

### 6. Control Unit
- **Data Bus**: Input mã lệnh (instruction)
- **Control Bus**: Output nhiều tín hiệu điều khiển (RegWrite, MemRead, ALUSrc, v.v.)
- **Không sử dụng Address Bus** vì không truy cập bộ nhớ trực tiếp

### 7. Immediate Generator
- **Data Bus**: Input mã lệnh (instruction) và output giá trị immediate
- **Control Bus**: Input loại immediate cần tạo (imm_type)
- **Không sử dụng Address Bus**

### 8. Branch Comparator
- **Data Bus**: Input dữ liệu từ thanh ghi (rs1_data, rs2_data) và output kết quả so sánh
- **Control Bus**: Input loại so sánh (funct3) và output quyết định nhảy (branch_taken)
- **Không sử dụng Address Bus**

### 9. Forwarding Unit (trong CPU pipeline)
- **Address Bus**: Input địa chỉ thanh ghi nguồn và đích (rs1_addr, rs2_addr, rd_addr)
- **Control Bus**: Output tín hiệu điều khiển forwarding (forward_a, forward_b)
- **Không sử dụng Data Bus** trực tiếp

### 10. Pipeline Registers
- **Data Bus**: Lưu trữ và chuyển tiếp tất cả dữ liệu giữa các stage
- **Control Bus**: Input tín hiệu điều khiển (stall, flush)
- **Address Bus**: Chuyển tiếp địa chỉ giữa các stage

Việc hiểu rõ mỗi module sử dụng luồng dữ liệu nào giúp thiết kế và kết nối chính xác các module trong CPU, đảm bảo dữ liệu được truyền đúng đường và đúng thời điểm.
