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

## Câu hỏi 4: Tại sao tách Control Unit FSM và Branch/Jump Logic ra khỏi sơ đồ khối chính

**Hỏi:** Tại sao trong block-diagram bạn lại vẽ hai khối Control Unit FSM và Branch/Jump logic này ra ngoài?

**Trả lời:** Tôi vẽ Control Unit FSM và Branch/Jump Logic thành các khối riêng biệt bên ngoài khối CPU Multi-Cycle Architecture chính vì một số lý do:

1. **Tính phức tạp và tầm quan trọng**: Cả hai thành phần này đều phức tạp và đủ quan trọng để xứng đáng được nhấn mạnh riêng biệt. Control Unit FSM là "bộ não" của CPU, điều khiển tất cả các hoạt động, trong khi Branch/Jump Logic xử lý các quyết định quan trọng về luồng điều khiển.

2. **Làm rõ cấu trúc FSM**: Bằng cách tách Control Unit FSM ra, tôi có thể hiển thị rõ ràng các trạng thái và chuyển đổi trạng thái của FSM mà không làm rối sơ đồ chính. Điều này giúp người đọc dễ dàng hiểu được cách CPU chuyển từ trạng thái này sang trạng thái khác.

3. **Làm rõ cơ chế Branch/Jump**: Xử lý Branch/Jump là một phần phức tạp trong CPU và ảnh hưởng đến hiệu suất. Bằng cách tách nó ra, tôi có thể hiển thị chi tiết cách các tín hiệu từ ALU flags, opcode, và branch comparator kết hợp lại để quyết định việc nhảy.

4. **Giảm độ phức tạp của sơ đồ chính**: Nếu đưa tất cả vào một sơ đồ, sẽ có quá nhiều mũi tên và kết nối, làm cho sơ đồ trở nên rối và khó hiểu. Việc phân tách giúp mỗi phần dễ đọc hơn.

5. **Nhấn mạnh tính module hóa**: Thiết kế CPU hiện đại thường được module hóa cao, với các thành phần có thể được phát triển và kiểm thử độc lập. Việc tách các khối này ra phản ánh cách tiếp cận thiết kế thực tế.

6. **Chuẩn bị cho mở rộng**: Việc tách Control Unit FSM ra cũng giúp dễ dàng mở rộng sang thiết kế pipeline trong tương lai, nơi mà control unit sẽ phức tạp hơn nhiều với việc xử lý hazard và forwarding.

Tuy nhiên, trong thiết kế thực tế, Control Unit FSM và Branch/Jump Logic vẫn là các phần không thể tách rời của CPU, và chúng kết nối chặt chẽ với các thành phần khác như thể hiện qua các mũi tên kết nối trong sơ đồ.

## Câu hỏi 5: Phân biệt giữa CPU Single-Cycle và Multi-Cycle

**Hỏi:** Phân biệt giữa CPU single cycle và CPU multi cycle? Ưu nhược điểm của mỗi loại?

**Trả lời:** CPU Single-Cycle và Multi-Cycle là hai kiến trúc cơ bản trong thiết kế CPU, với những đặc điểm và ứng dụng khác nhau:

### CPU Single-Cycle

**Đặc điểm:**
- Mỗi lệnh hoàn thành trong một chu kỳ xung nhịp duy nhất
- Tất cả các giai đoạn (fetch, decode, execute, memory access, write back) đều thực hiện trong cùng một chu kỳ
- Đường dẫn dữ liệu (datapath) trực tiếp từ đầu đến cuối

**Ưu điểm:**
1. **Thiết kế đơn giản**: Dễ hiểu, dễ triển khai
2. **Không có hazard**: Không cần xử lý data hazard, control hazard
3. **Điều khiển đơn giản**: Không cần FSM phức tạp
4. **Hiệu suất dự đoán được**: Mỗi lệnh luôn mất đúng 1 chu kỳ

**Nhược điểm:**
1. **Chu kỳ xung nhịp dài**: Phải đủ dài để thực hiện lệnh phức tạp nhất
2. **Lãng phí tài nguyên**: Nhiều thành phần không được sử dụng trong mỗi lệnh
3. **Hiệu suất thấp**: Tần số xung nhịp thấp do đường trễ tới hạn dài
4. **Tiêu thụ điện năng cao**: Nhiều mạch hoạt động đồng thời
5. **Không hiệu quả về chi phí**: Cần nhiều bản sao của các thành phần (như ALU, bộ nhớ)

### CPU Multi-Cycle

**Đặc điểm:**
- Mỗi lệnh được chia thành nhiều giai đoạn, mỗi giai đoạn thực hiện trong một chu kỳ xung nhịp
- Các lệnh khác nhau có thể sử dụng số chu kỳ khác nhau
- Sử dụng thanh ghi trung gian để lưu trữ kết quả giữa các chu kỳ
- Điều khiển bởi máy trạng thái hữu hạn (FSM)

**Ưu điểm:**
1. **Tối ưu tài nguyên**: Tái sử dụng các thành phần phần cứng (như ALU)
2. **Chu kỳ xung nhịp ngắn hơn**: Mỗi chu kỳ chỉ thực hiện một phần của lệnh
3. **Tiết kiệm chi phí**: Cần ít phần cứng hơn
4. **Tiết kiệm năng lượng**: Ít mạch hoạt động đồng thời
5. **Linh hoạt**: Lệnh đơn giản hoàn thành nhanh hơn lệnh phức tạp

**Nhược điểm:**
1. **Thiết kế phức tạp hơn**: Cần FSM để điều khiển các giai đoạn
2. **Hiệu suất trung bình thấp hơn**: Mỗi lệnh cần nhiều chu kỳ
3. **Cần thanh ghi trung gian**: Thêm phần cứng để lưu trữ trạng thái
4. **Điều khiển phức tạp**: Cần tạo tín hiệu điều khiển cho từng giai đoạn
5. **Khó debug**: Lỗi có thể xuất hiện giữa các giai đoạn

### So sánh hiệu năng

1. **Thời gian thực thi lệnh**:
   - Single-Cycle: Mỗi lệnh mất 1 chu kỳ, nhưng chu kỳ dài
   - Multi-Cycle: Mỗi lệnh mất 3-5 chu kỳ, nhưng mỗi chu kỳ ngắn hơn

2. **Tần số xung nhịp tối đa**:
   - Single-Cycle: Thấp hơn (bị giới hạn bởi đường trễ dài nhất)
   - Multi-Cycle: Cao hơn (mỗi chu kỳ chỉ thực hiện một phần nhỏ)

3. **Hiệu suất tổng thể**:
   - Phụ thuộc vào công nghệ và bộ lệnh cụ thể
   - Multi-Cycle thường hiệu quả hơn với bộ lệnh có độ phức tạp khác nhau
   - Single-Cycle hiệu quả hơn cho bộ lệnh đơn giản và đồng nhất

### Ứng dụng thực tế

- **Single-Cycle**: Thường dùng trong hệ thống nhúng đơn giản, vi điều khiển cơ bản
- **Multi-Cycle**: Phổ biến trong các thiết kế giáo dục và hệ thống nhúng phức tạp hơn
- **Các CPU hiện đại**: Thường sử dụng kiến trúc pipeline (phát triển từ multi-cycle) hoặc superscalar

Multi-Cycle là nền tảng quan trọng để hiểu và phát triển lên các kiến trúc cao cấp hơn như pipeline, superscalar và out-of-order execution trong các CPU hiện đại.

## Câu hỏi 6: Giải thích chi tiết từng module trong block diagram CPU Multi-Cycle

**Hỏi:** Giải thích lại cho tôi từng module một trong block diagram này, những chức năng mà nó có?

**Trả lời:** Dưới đây là giải thích chi tiết từng module trong block diagram của CPU Multi-Cycle:

### 1. Program Counter (PC)
- **Chức năng**: Lưu trữ địa chỉ lệnh hiện tại trong CPU
- **Đặc điểm**: Cập nhật một lần cho mỗi lệnh hoàn chỉnh (không phải mỗi chu kỳ)
- **Kết nối**: 
  - Đầu ra: Gửi địa chỉ hiện tại đến MUX5 và MUX2
  - Đầu vào: Nhận địa chỉ tiếp theo từ MUX1
- **Hoạt động**: Khi nhận tín hiệu pc_write, nó cập nhật giá trị từ MUX1 (có thể là PC+4, địa chỉ nhảy, hoặc địa chỉ ngắt)

### 2. Instruction Register (IR)
- **Chức năng**: Lưu trữ mã lệnh hiện tại đang được thực thi
- **Đặc điểm**: Cập nhật trong giai đoạn Fetch
- **Kết nối**:
  - Đầu vào: Nhận lệnh từ MDR
  - Đầu ra: Gửi lệnh đến ID, RF, IG, BRANCH và JUMP
- **Hoạt động**: Giữ lệnh ổn định trong khi CPU thực hiện các giai đoạn khác nhau

### 3. Memory Address Register (MAR)
- **Chức năng**: Lưu trữ địa chỉ bộ nhớ cần truy cập
- **Đặc điểm**: Được sử dụng cho cả truy cập lệnh và dữ liệu
- **Kết nối**:
  - Đầu vào: Nhận địa chỉ từ MUX5
  - Đầu ra: Gửi địa chỉ đến Memory
- **Hoạt động**: Đệm địa chỉ để đảm bảo tín hiệu ổn định khi truy cập bộ nhớ

### 4. Memory Data Register (MDR)
- **Chức năng**: Đệm dữ liệu đọc/ghi từ/đến bộ nhớ
- **Đặc điểm**: Được sử dụng cho cả lệnh và dữ liệu
- **Kết nối**:
  - Đầu vào: Nhận dữ liệu từ Memory
  - Đầu ra: Gửi lệnh đến IR hoặc dữ liệu đến MUX4
- **Hoạt động**: Đệm dữ liệu để đảm bảo tín hiệu ổn định và đồng bộ

### 5. Register A và Register B
- **Chức năng**: Lưu trữ tạm thời dữ liệu từ Register File
- **Đặc điểm**: Cập nhật trong giai đoạn Decode
- **Kết nối**:
  - Đầu vào: Nhận dữ liệu từ Register File
  - Đầu ra: A gửi giá trị đến MUX2 và BC; B gửi giá trị đến MUX3 và BC
- **Hoạt động**: Giữ dữ liệu từ thanh ghi ổn định trong các giai đoạn tiếp theo

### 6. ALU Output Register (ALUOut)
- **Chức năng**: Lưu trữ kết quả từ ALU
- **Đặc điểm**: Cập nhật trong giai đoạn Execute
- **Kết nối**:
  - Đầu vào: Nhận kết quả từ ALU
  - Đầu ra: Gửi kết quả đến MUX1, MUX4 và MUX5
- **Hoạt động**: Giữ kết quả ALU ổn định cho các giai đoạn Memory và Writeback

### 7. Register File (RF)
- **Chức năng**: Lưu trữ các thanh ghi của CPU
- **Đặc điểm**: Có 32 thanh ghi x 32 bit (trong RISC-V)
- **Kết nối**:
  - Đầu vào: Nhận địa chỉ thanh ghi từ IR, dữ liệu ghi từ MUX4
  - Đầu ra: Gửi dữ liệu thanh ghi đến A và B
- **Hoạt động**: Đọc không đồng bộ, ghi đồng bộ theo xung clock

### 8. ALU (Arithmetic Logic Unit)
- **Chức năng**: Thực hiện các phép toán số học và logic
- **Đặc điểm**: Hoạt động trong giai đoạn Execute
- **Kết nối**:
  - Đầu vào: Nhận toán hạng từ MUX2 và MUX3, mã điều khiển từ ALUC
  - Đầu ra: Gửi kết quả đến ALUOut và flags đến FLAGS
- **Hoạt động**: Thực hiện phép toán dựa trên mã điều khiển ALU

### 9. ALU Control (ALUC)
- **Chức năng**: Xác định phép toán ALU cụ thể
- **Đặc điểm**: Tạo mã điều khiển 4-bit cho ALU
- **Kết nối**:
  - Đầu vào: Nhận tín hiệu điều khiển từ Control Unit FSM
  - Đầu ra: Gửi mã điều khiển đến ALU
- **Hoạt động**: Giải mã tín hiệu điều khiển để xác định phép toán ALU cụ thể

### 10. Immediate Generator (IG)
- **Chức năng**: Tạo giá trị immediate từ lệnh
- **Đặc điểm**: Mở rộng dấu cho các giá trị immediate
- **Kết nối**:
  - Đầu vào: Nhận lệnh từ IR
  - Đầu ra: Gửi giá trị immediate đến MUX3
- **Hoạt động**: Trích xuất và mở rộng dấu cho giá trị immediate dựa trên định dạng lệnh

### 11. Memory (MEM)
- **Chức năng**: Lưu trữ cả lệnh và dữ liệu
- **Đặc điểm**: Bộ nhớ kết hợp (unified memory)
- **Kết nối**:
  - Đầu vào: Nhận địa chỉ từ MAR
  - Đầu ra: Gửi dữ liệu/lệnh đến MDR
- **Hoạt động**: Đọc không đồng bộ, ghi đồng bộ theo xung clock

### 12. Branch Comparator (BC)
- **Chức năng**: So sánh giá trị từ thanh ghi để quyết định rẽ nhánh
- **Đặc điểm**: Thực hiện các phép so sánh khác nhau (bằng, khác, nhỏ hơn, lớn hơn)
- **Kết nối**:
  - Đầu vào: Nhận giá trị từ A và B
  - Đầu ra: Gửi kết quả so sánh đến BRANCH
- **Hoạt động**: So sánh giá trị dựa trên loại lệnh branch

### 13. Multiplexers (MUX1-MUX5)
- **Chức năng**: Chọn đường đi dữ liệu trong datapath
- **Đặc điểm**: Hoạt động dựa trên tín hiệu điều khiển từ Control Unit
- **Các MUX chính**:
  - MUX1 (PC Source): Chọn nguồn cập nhật PC (PC+4, branch, jump)
  - MUX2 (ALU Input A): Chọn toán hạng A cho ALU (A, PC)
  - MUX3 (ALU Input B): Chọn toán hạng B cho ALU (B, immediate)
  - MUX4 (Register Write Data): Chọn dữ liệu ghi vào Register File (ALUOut, MDR)
  - MUX5 (Memory Address): Chọn địa chỉ truy cập bộ nhớ (PC, ALUOut)

### 14. Control Unit FSM
- **Chức năng**: Điều khiển toàn bộ CPU dựa trên máy trạng thái
- **Các trạng thái chính**:
  - **IF (Instruction Fetch)**: Lấy lệnh từ bộ nhớ vào IR
  - **ID (Instruction Decode)**: Giải mã lệnh và đọc thanh ghi
  - **EX (Execute)**: Thực hiện phép toán ALU
  - **MEM (Memory Access)**: Truy cập bộ nhớ cho lệnh load/store
  - **WB (Write Back)**: Ghi kết quả vào thanh ghi
  - **NEXT**: Xác định PC tiếp theo
- **Hoạt động**: Tạo tất cả các tín hiệu điều khiển dựa trên trạng thái hiện tại và loại lệnh

### 15. Branch/Jump Logic
- **Chức năng**: Xử lý các lệnh rẽ nhánh và nhảy
- **Thành phần**:
  - **BRANCH**: Phát hiện và xử lý lệnh rẽ nhánh có điều kiện
  - **JUMP**: Phát hiện và xử lý lệnh nhảy không điều kiện
  - **FLAGS**: Lưu trữ các cờ từ ALU (zero, negative, overflow)
- **Hoạt động**: Kết hợp opcode, flags và kết quả so sánh để quyết định có nhảy hay không

### 16. Future Extensions
- **Chức năng**: Các module dự kiến thêm vào trong tương lai
- **Thành phần**:
  - **Forwarding Unit (FWD)**: Giải quyết data hazard trong pipeline
  - **Hazard Detection Unit (HDU)**: Phát hiện và xử lý hazard
  - **Interrupt Handler (INT)**: Xử lý ngắt và ngoại lệ
- **Kết nối**: Được hiển thị bằng đường nét đứt để chỉ ra rằng chúng là phần mở rộng tương lai

## Câu hỏi 7: Các module cần viết code trong CPU Multi-Cycle

**Hỏi:** Vậy khi vào code chúng ta sẽ viết code cho những module nào?

**Trả lời:** Khi triển khai CPU multi-cycle bằng Verilog, chúng ta sẽ cần viết code cho tất cả các module chính trong sơ đồ khối. Dưới đây là danh sách các module cần triển khai và cách tiếp cận:

### Các module cần viết code:

1. **Program Counter (PC)**
   - Module riêng biệt với tín hiệu clock, reset, pc_write và pc_next
   - Cập nhật giá trị PC theo điều kiện

2. **Instruction Register (IR)**
   - Module lưu trữ lệnh hiện tại
   - Có thể bao gồm logic để trích xuất các trường của lệnh (opcode, rs1, rs2, rd, funct3, funct7)

3. **Memory Address Register (MAR)**
   - Module đệm địa chỉ bộ nhớ
   - Cập nhật đồng bộ theo clock khi có tín hiệu mar_write

4. **Memory Data Register (MDR)**
   - Module đệm dữ liệu bộ nhớ
   - Cập nhật đồng bộ theo clock khi có tín hiệu mdr_write

5. **Register A và Register B**
   - Hai module thanh ghi tạm thời đơn giản
   - Cập nhật đồng bộ theo clock khi có tín hiệu a_write/b_write

6. **ALU Output Register**
   - Module lưu kết quả ALU
   - Cập nhật đồng bộ theo clock khi có tín hiệu alu_out_write

7. **Register File**
   - Module phức tạp chứa 32 thanh ghi
   - Hỗ trợ đọc không đồng bộ và ghi đồng bộ
   - Đảm bảo thanh ghi x0 luôn bằng 0

8. **ALU (Arithmetic Logic Unit)**
   - Module thực hiện các phép toán số học và logic
   - Tạo ra các cờ (zero, negative, overflow)
   - Hỗ trợ tất cả các phép toán cần thiết (ADD, SUB, AND, OR, XOR, v.v.)

9. **ALU Control**
   - Module tạo tín hiệu điều khiển ALU
   - Dựa vào ALUOp, funct3 và funct7 để quyết định phép toán

10. **Immediate Generator**
    - Module trích xuất và mở rộng dấu cho giá trị immediate
    - Hỗ trợ các định dạng immediate khác nhau (I, S, B, U, J)

11. **Memory**
    - Module bộ nhớ kết hợp cho cả lệnh và dữ liệu
    - Hỗ trợ đọc không đồng bộ và ghi đồng bộ
    - Có thể nạp từ file để khởi tạo

12. **Branch Comparator**
    - Module so sánh giá trị từ thanh ghi
    - Hỗ trợ các phép so sánh khác nhau (bằng, khác, nhỏ hơn, lớn hơn)

13. **Multiplexers**
    - Các module MUX 2-to-1 và 4-to-1
    - Chọn đường đi dữ liệu dựa trên tín hiệu điều khiển

14. **Control Unit FSM**
    - Module phức tạp nhất, triển khai máy trạng thái
    - Tạo tất cả các tín hiệu điều khiển dựa trên trạng thái và opcode
    - Quản lý chuyển đổi trạng thái

15. **Branch/Jump Logic**
    - Module xử lý các lệnh rẽ nhánh và nhảy
    - Kết hợp opcode, flags và kết quả so sánh

### Cách tiếp cận triển khai:

1. **Bắt đầu với các module đơn giản**:
   - Triển khai các thanh ghi (PC, IR, MAR, MDR, A, B, ALUOut)
   - Triển khai các MUX
   - Kiểm thử từng module riêng lẻ

2. **Tiếp tục với các module phức tạp hơn**:
   - Triển khai Register File
   - Triển khai ALU và ALU Control
   - Triển khai Immediate Generator
   - Triển khai Memory
   - Kiểm thử từng module

3. **Triển khai Control Unit và Branch Logic**:
   - Triển khai máy trạng thái FSM
   - Triển khai Branch Comparator và Branch/Jump Logic
   - Kiểm thử các thành phần này

4. **Kết nối tất cả các module**:
   - Tạo module top-level kết nối tất cả các thành phần
   - Đảm bảo tất cả các kết nối được thực hiện chính xác
   - Kiểm thử toàn bộ CPU

5. **Kiểm thử và gỡ lỗi**:
   - Chạy các chương trình đơn giản
   - Kiểm tra từng giai đoạn của chu kỳ lệnh
   - Gỡ lỗi và tối ưu hóa

### Ví dụ cấu trúc file:

```
cpu_multi_cycle/
├── rtl/
│   ├── program_counter.v
│   ├── instruction_register.v
│   ├── memory_address_register.v
│   ├── memory_data_register.v
│   ├── register_a.v
│   ├── register_b.v
│   ├── alu_output_register.v
│   ├── register_file.v
│   ├── alu.v
│   ├── alu_control.v
│   ├── immediate_generator.v
│   ├── memory.v
│   ├── branch_comparator.v
│   ├── mux_2to1.v
│   ├── mux_4to1.v
│   ├── control_unit_fsm.v
│   ├── branch_jump_logic.v
│   └── cpu_top.v
├── tb/
│   ├── program_counter_tb.v
│   ├── register_file_tb.v
│   ├── alu_tb.v
│   ├── memory_tb.v
│   ├── control_unit_fsm_tb.v
│   └── cpu_tb.v
├── programs/
│   ├── test_program.hex
│   └── test_program.asm
└── sim/
    └── wave.do
```

Lưu ý rằng các module "Future Extensions" (Forwarding Unit, Hazard Detection Unit, Interrupt Handler) không cần triển khai trong bản CPU multi-cycle cơ bản, vì chúng chủ yếu dành cho kiến trúc pipeline.

## Câu hỏi 8: Testbench cho các module CPU Multi-Cycle

**Hỏi:** Vậy với những module chính đó thì tôi có thể viết số testbench tương ứng với mỗi module chính, vì tôi muốn verify đúng toàn bộ chức năng của từng module?

**Trả lời:** Đúng vậy! Việc viết testbench cho từng module riêng biệt là cách tiếp cận rất tốt để đảm bảo chức năng của mỗi thành phần trước khi tích hợp chúng lại. Dưới đây là danh sách các testbench cần viết và các trường hợp kiểm thử quan trọng cho mỗi module:

### 1. Program Counter (PC) Testbench
- **Kiểm tra reset**: PC phải reset về 0x00000000
- **Kiểm tra cập nhật**: PC cập nhật khi pc_write=1 và clock edge
- **Kiểm tra giữ nguyên**: PC không thay đổi khi pc_write=0
- **Kiểm tra nhiều giá trị**: Cập nhật PC với nhiều giá trị khác nhau

### 2. Instruction Register (IR) Testbench
- **Kiểm tra reset**: IR phải reset về 0
- **Kiểm tra cập nhật**: IR cập nhật khi ir_write=1
- **Kiểm tra giữ nguyên**: IR không thay đổi khi ir_write=0
- **Kiểm tra trích xuất trường**: Kiểm tra các trường opcode, rd, rs1, rs2, funct3, funct7

### 3. Memory Address Register (MAR) Testbench
- **Kiểm tra reset**: MAR phải reset về 0
- **Kiểm tra cập nhật**: MAR cập nhật khi mar_write=1
- **Kiểm tra giữ nguyên**: MAR không thay đổi khi mar_write=0

### 4. Memory Data Register (MDR) Testbench
- **Kiểm tra reset**: MDR phải reset về 0
- **Kiểm tra cập nhật**: MDR cập nhật khi mdr_write=1
- **Kiểm tra giữ nguyên**: MDR không thay đổi khi mdr_write=0

### 5. Register A và Register B Testbench
- **Kiểm tra reset**: Thanh ghi phải reset về 0
- **Kiểm tra cập nhật**: Thanh ghi cập nhật khi reg_write=1
- **Kiểm tra giữ nguyên**: Thanh ghi không thay đổi khi reg_write=0

### 6. ALU Output Register Testbench
- **Kiểm tra reset**: ALUOut phải reset về 0
- **Kiểm tra cập nhật**: ALUOut cập nhật khi alu_out_write=1
- **Kiểm tra giữ nguyên**: ALUOut không thay đổi khi alu_out_write=0

### 7. Register File Testbench
- **Kiểm tra reset**: Tất cả thanh ghi phải reset về 0
- **Kiểm tra đọc/ghi**: Ghi giá trị và đọc lại để xác nhận
- **Kiểm tra thanh ghi x0**: Thanh ghi x0 luôn bằng 0, ngay cả sau khi ghi
- **Kiểm tra đọc đồng thời**: Đọc từ hai thanh ghi khác nhau
- **Kiểm tra xung đột đọc/ghi**: Đọc và ghi cùng một thanh ghi

### 8. ALU Testbench
- **Kiểm tra các phép toán**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- **Kiểm tra các cờ**: zero, negative, overflow
- **Kiểm tra trường hợp biên**: Số âm lớn nhất, số dương lớn nhất, 0, tràn số
- **Kiểm tra tất cả các mã điều khiển**: Đảm bảo mỗi mã tạo ra phép toán đúng

### 9. ALU Control Testbench
- **Kiểm tra các tổ hợp ALUOp/funct3/funct7**: Đảm bảo tạo ra mã điều khiển ALU đúng
- **Kiểm tra từng loại lệnh**: R-type, I-type, load/store, branch

### 10. Immediate Generator Testbench
- **Kiểm tra các định dạng immediate**: I-type, S-type, B-type, U-type, J-type
- **Kiểm tra mở rộng dấu**: Đảm bảo giá trị âm được mở rộng đúng
- **Kiểm tra các trường hợp biên**: Giá trị lớn nhất, nhỏ nhất, 0

### 11. Memory Testbench
- **Kiểm tra đọc/ghi**: Ghi giá trị và đọc lại để xác nhận
- **Kiểm tra các kích thước truy cập**: byte, half-word, word
- **Kiểm tra byte ordering**: Đảm bảo byte ordering đúng
- **Kiểm tra nhiều địa chỉ**: Truy cập nhiều vị trí bộ nhớ khác nhau

### 12. Branch Comparator Testbench
- **Kiểm tra các phép so sánh**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Kiểm tra các trường hợp biên**: Bằng nhau, khác nhau, số âm vs dương

### 13. Multiplexers Testbench
- **Kiểm tra chọn đúng đầu vào**: Kiểm tra mỗi giá trị select
- **Kiểm tra với nhiều giá trị đầu vào**: Đảm bảo đầu ra khớp với đầu vào được chọn

### 14. Control Unit FSM Testbench
- **Kiểm tra chuyển trạng thái**: Đảm bảo FSM chuyển đúng trạng thái
- **Kiểm tra tín hiệu điều khiển**: Kiểm tra tín hiệu điều khiển cho mỗi loại lệnh
- **Kiểm tra từng loại lệnh**: R-type, I-type, load, store, branch, jump
- **Kiểm tra tuần tự các giai đoạn**: IF → ID → EX → MEM → WB → NEXT

### 15. Branch/Jump Logic Testbench
- **Kiểm tra phát hiện branch**: Đảm bảo phát hiện đúng các lệnh branch
- **Kiểm tra phát hiện jump**: Đảm bảo phát hiện đúng các lệnh jump
- **Kiểm tra điều kiện nhảy**: Kiểm tra các điều kiện nhảy khác nhau

### 16. CPU Top-Level Testbench
- **Kiểm tra từng lệnh**: Thực thi từng lệnh và kiểm tra kết quả
- **Kiểm tra chương trình đơn giản**: Chạy chương trình đơn giản và kiểm tra kết quả
- **Kiểm tra trạng thái CPU**: Theo dõi PC, IR, thanh ghi, bộ nhớ qua các chu kỳ

### Chiến lược kiểm thử tổng thể:

1. **Kiểm thử từng module riêng lẻ**: Đảm bảo mỗi module hoạt động đúng
2. **Kiểm thử tích hợp từng cặp module**: Đảm bảo các module làm việc cùng nhau
3. **Kiểm thử từng giai đoạn**: Kiểm tra IF, ID, EX, MEM, WB riêng biệt
4. **Kiểm thử chu kỳ lệnh đầy đủ**: Kiểm tra toàn bộ chu kỳ lệnh
5. **Kiểm thử chương trình thực tế**: Chạy các chương trình thực tế

Bằng cách viết testbench chi tiết cho từng module, bạn có thể đảm bảo rằng mỗi thành phần hoạt động chính xác trước khi tích hợp chúng lại với nhau, giúp giảm thiểu thời gian gỡ lỗi và tăng độ tin cậy của thiết kế.
