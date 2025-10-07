# 🧠 Bảng Tổng Hợp Từ Viết Tắt & Định Nghĩa - Kiến Trúc CPU RISC-V Pipeline

| **Từ viết tắt / Thông số** | **Định nghĩa / Giải thích** |
|-----------------------------|------------------------------|
| **IF** | *Instruction Fetch* – Giai đoạn nạp lệnh từ bộ nhớ chương trình (Instruction Memory). |
| **ID** | *Instruction Decode* – Giai đoạn giải mã lệnh và đọc thanh ghi nguồn. |
| **EX** | *Execute* – Giai đoạn thực thi phép toán ALU hoặc tính toán địa chỉ bộ nhớ. |
| **MEM** | *Memory Access* – Giai đoạn truy cập bộ nhớ dữ liệu (load/store). |
| **WB** | *Write Back* – Giai đoạn ghi kết quả trở lại thanh ghi đích (Register File). |
| **PC** | *Program Counter* – Thanh ghi đếm chương trình, giữ địa chỉ của lệnh hiện tại. |
| **NPC Generator** | Khối tính địa chỉ lệnh kế tiếp (Next Program Counter), phục vụ nhảy, rẽ nhánh, v.v. |
| **Instr** | *Instruction* – Mã lệnh RISC-V 32-bit được đọc từ Instruction Memory. |
| **RegFile** | *Register File* – Tập hợp 32 thanh ghi x0–x31 trong RISC-V. |
| **RD1, RD2** | Dữ liệu đọc từ hai thanh ghi nguồn (Register Data 1, Register Data 2). |
| **A1, A2, A3** | Địa chỉ các thanh ghi nguồn 1, nguồn 2, và thanh ghi đích. |
| **ImmD** | *Immediate Data* – Hằng số tức thời được giải mã từ lệnh. |
| **ALU** | *Arithmetic Logic Unit* – Khối thực hiện các phép toán số học & logic (ADD, SUB, AND, OR,...). |
| **ALUCtrlE** | Tín hiệu điều khiển ALU ở giai đoạn Execute. |
| **RegWriteE / M / W** | Cờ cho phép ghi thanh ghi ở stage EX, MEM hoặc WB. |
| **MemWriteM** | Cờ ghi dữ liệu vào bộ nhớ (store). |
| **MemToRegM / W** | Chọn nguồn dữ liệu ghi về thanh ghi (từ bộ nhớ hay từ ALU). |
| **BranchE / BrTypeE** | Loại rẽ nhánh đang được thực hiện (BEQ, BNE, BLT, v.v.). |
| **ForwardA / ForwardB** | Cơ chế *data forwarding* để tránh *data hazard* trong pipeline. |
| **FlushF / D / E / M / W** | Tín hiệu làm sạch (flush) các stage khi có *branch misprediction* hoặc *reset*. |
| **StallF / D / E / M / W** | Tín hiệu dừng (stall) để xử lý *data hazard* hoặc *cache miss*. |
| **Hazard Unit** | Khối phát hiện và xử lý hazard (dừng hoặc chuyển tiếp dữ liệu). |
| **Branch Decision Unit** | Quyết định việc rẽ nhánh dựa trên điều kiện (so sánh thanh ghi). |
| **Data Memory** | Bộ nhớ dữ liệu – đọc/ghi dữ liệu trong các lệnh load/store. |
| **Data Ext** | Khối mở rộng dữ liệu (byte/halfword/word) khi load từ memory. |
| **Ctrl Unit / Control Unit** | Giải mã opcode và tạo các tín hiệu điều khiển cho toàn pipeline. |
| **Op, Fun3, Fun7** | Các trường mã trong lệnh RISC-V xác định loại phép toán. |
| **RegReadE** | Cờ xác định có đọc thanh ghi ở stage EX không. |
| **PCF / PCD / PCE / PCM / PCW** | Giá trị PC tại các stage IF, ID, EX, MEM, WB tương ứng. |
| **ALUSrcE** | Tín hiệu chọn toán hạng thứ 2 của ALU (từ thanh ghi hoặc Immediate). |
| **LoadNpcE** | Cờ cho phép cập nhật PC theo nhánh (jump hoặc branch). |
| **JaL / JaLr / BrE / BtT** | Tín hiệu điều khiển nhảy hoặc rẽ nhánh trong kiến trúc RISC-V. |
| **ImmTypeD** | Loại immediate (I-type, S-type, B-type, U-type, J-type). |
| **RegOut2D, RegOut2E, RegOutM, RegOutW** | Dữ liệu từ các pipeline register nối giữa các stage. |
| **DCache / ICache** | Data Cache / Instruction Cache – nếu có bộ nhớ đệm. |
| **Flush / Stall Logic** | Logic đảm bảo pipeline đồng bộ khi có thay đổi điều khiển hoặc phụ thuộc dữ liệu. |
| **ResultW** | Dữ liệu cuối cùng được ghi trở lại Register File ở stage WB. |
| **RdD / RdE / RdM / RdW** | Thanh ghi đích tại từng stage pipeline. |
| **CPU_RST** | Tín hiệu Reset toàn bộ pipeline. |
| **CPU_Debug_InitRAM** | Giao diện nạp dữ liệu vào RAM khi debug. |
| **CPU_Debug_DataRAM** | Giao diện truy cập RAM trong chế độ Debug. |
