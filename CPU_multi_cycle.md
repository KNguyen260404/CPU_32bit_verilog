# Kiến trúc CPU Multi-Cycle

Tài liệu này mô tả thiết kế chi tiết của một CPU multi-cycle, bao gồm các module chính, sơ đồ trạng thái FSM, và các cơ chế xử lý branch/jump.

## Sơ đồ khối CPU Multi-Cycle

```mermaid
graph TD
    subgraph "CPU Multi-Cycle Architecture"
        PC["Program Counter<br/>- Updates once per instruction"]
        IR["Instruction Register<br/>- Holds current instruction"]
        MDR["Memory Data Register<br/>- Buffers memory data"]
        MAR["Memory Address Register<br/>- Holds memory address"]
        A["Register A<br/>- Temporary register"]
        B["Register B<br/>- Temporary register"]
        ALUOut["ALU Output Register<br/>- Holds ALU result"]
        RF["Register File<br/>- CPU registers"]
        ALU["ALU<br/>- Arithmetic/Logic Unit"]
        IG["Immediate Generator<br/>- Creates immediate values"]
        MEM["Memory<br/>- Combined Instr/Data Memory"]
        ALUC["ALU Control<br/>- Controls ALU operation"]
        MUX1["MUX - PC Source"]
        MUX2["MUX - ALU Input A"]
        MUX3["MUX - ALU Input B"]
        MUX4["MUX - Register Write Data"]
        MUX5["MUX - Memory Address"]
        BC["Branch Comparator<br/>- Evaluates branch conditions"]
    end
    
    subgraph "Control Unit FSM"
        IF["IF (Instruction Fetch)<br/>- MAR ← PC<br/>- MDR ← MEM[MAR]<br/>- IR ← MDR<br/>- PC ← PC + 4"]
        ID["ID (Instruction Decode)<br/>- Decode instruction<br/>- A ← RF[rs1]<br/>- B ← RF[rs2]<br/>- Generate immediate"]
        EX["EX (Execute)<br/>- ALUOut ← ALU(A, B/Imm)<br/>- Set flags<br/>- Calculate branch address"]
        MEM["MEM (Memory Access)<br/>- For load/store:<br/>- MAR ← ALUOut<br/>- MDR ← MEM[MAR] / MEM[MAR] ← B"]
        WB["WB (Write Back)<br/>- For R/I-type: RF[rd] ← ALUOut<br/>- For load: RF[rd] ← MDR"]
        NEXT["Next Instruction<br/>- For branch/jump:<br/>- PC ← ALUOut if condition"]
        
        IF -->|"Next state"| ID
        ID -->|"Next state"| EX
        EX -->|"Next state"| MEM
        MEM -->|"Next state"| WB
        WB -->|"Next state"| NEXT
        NEXT -->|"Next instruction"| IF
    end
    
    subgraph "Branch/Jump Logic"
        BRANCH["Branch Detection<br/>- beq, bne, blt, bge"]
        JUMP["Jump Detection<br/>- jal, jalr"]
        FLAGS["ALU Flags<br/>- Zero, Negative, Overflow"]
        
        BRANCH -->|"branch condition"| MUX1
        JUMP -->|"jump signal"| MUX1
        FLAGS -->|"condition flags"| BRANCH
    end
    
    subgraph "Future Extensions"
        FWD["Forwarding Unit<br/>(For Pipeline)"]
        HDU["Hazard Detection Unit<br/>(For Pipeline)"]
        INT["Interrupt Handler<br/>- Exception processing<br/>- External interrupts"]
        
        FWD -.->|"Forward paths"| MUX2
        FWD -.->|"Forward paths"| MUX3
        HDU -.->|"Stall signals"| PC
        HDU -.->|"Stall signals"| IR
        INT -.->|"Interrupt vector"| MUX1
        INT -.->|"Save PC"| PC
    end
    
    PC -->|"PC value"| MUX5
    PC -->|"PC value"| MUX2
    MUX1 -->|"next PC"| PC
    
    MEM -->|"data/instruction"| MDR
    MAR -->|"address"| MEM
    MUX5 -->|"address"| MAR
    
    MDR -->|"instruction"| IR
    MDR -->|"data"| MUX4
    
    IR -->|"instruction"| ID
    IR -->|"rs1/rs2/rd addr"| RF
    IR -->|"instruction"| IG
    IR -->|"opcode"| BRANCH
    IR -->|"opcode"| JUMP
    
    RF -->|"rs1_data"| A
    RF -->|"rs2_data"| B
    MUX4 -->|"write_data"| RF
    
    A -->|"value"| MUX2
    B -->|"value"| MUX3
    B -->|"value"| BC
    A -->|"value"| BC
    
    MUX2 -->|"operand_a"| ALU
    MUX3 -->|"operand_b"| ALU
    
    ALUC -->|"alu_control"| ALU
    ALU -->|"result"| ALUOut
    ALU -->|"flags"| FLAGS
    
    ALUOut -->|"result"| MUX1
    ALUOut -->|"result"| MUX4
    ALUOut -->|"address"| MUX5
    
    IG -->|"immediate"| MUX3
    BC -->|"comparison result"| BRANCH
```

## Sơ đồ trạng thái FSM chi tiết

```mermaid
stateDiagram-v2
    [*] --> IF
    IF --> ID: Fetch complete
    ID --> EX: Decode complete
    
    state EX {
        [*] --> R_Type: R-Type instruction
        [*] --> I_Type: I-Type instruction
        [*] --> Load_Store: Load/Store instruction
        [*] --> Branch: Branch instruction
        [*] --> Jump: Jump instruction
        
        R_Type --> [*]: ALU operation complete
        I_Type --> [*]: ALU operation complete
        Load_Store --> [*]: Address calculation complete
        Branch --> [*]: Branch address calculated
        Jump --> [*]: Jump address calculated
    }
    
    EX --> MEM: Execute complete
    
    state MEM {
        [*] --> No_Mem: R/I-Type (no memory access)
        [*] --> Load: Load instruction
        [*] --> Store: Store instruction
        [*] --> Branch_Eval: Branch evaluation
        
        No_Mem --> [*]: Skip memory
        Load --> [*]: Memory read complete
        Store --> [*]: Memory write complete
        Branch_Eval --> [*]: Branch condition evaluated
    }
    
    MEM --> WB: Memory access complete
    
    state WB {
        [*] --> Reg_Write: R/I/Load instruction
        [*] --> No_Write: Store/Branch with no writeback
        
        Reg_Write --> [*]: Register updated
        No_Write --> [*]: No register update
    }
    
    WB --> NEXT: Writeback complete
    
    state NEXT {
        [*] --> PC_Inc: No branch/jump
        [*] --> PC_Branch: Branch taken
        [*] --> PC_Jump: Jump instruction
        
        PC_Inc --> [*]: PC = PC + 4
        PC_Branch --> [*]: PC = Branch target
        PC_Jump --> [*]: PC = Jump target
    }
    
    NEXT --> IF: PC updated
    
    note right of IF: "MAR ← PC\nMDR ← MEM[MAR]\nIR ← MDR"
    note right of ID: "A ← RF[rs1]\nB ← RF[rs2]\nGenerate immediate"
    note right of EX: "ALUOut ← ALU(A, B/Imm)\nSet flags"
    note right of MEM: "MAR ← ALUOut\nMDR ← MEM[MAR] or\nMEM[MAR] ← B"
    note right of WB: "RF[rd] ← ALUOut or\nRF[rd] ← MDR"
    note right of NEXT: "Update PC based on\ninstruction type and\nbranch condition"
```

## Các thành phần chính

### 1. Sơ đồ trạng thái FSM chi tiết

Máy trạng thái hữu hạn (FSM) của CPU multi-cycle bao gồm các trạng thái sau:

- **IF (Instruction Fetch)**: 
  - Đặt MAR = PC
  - Đọc bộ nhớ: MDR = MEM[MAR]
  - Lưu lệnh vào IR: IR = MDR
  - Tăng PC: PC = PC + 4 (tạm thời, có thể thay đổi ở trạng thái NEXT)

- **ID (Instruction Decode)**:
  - Giải mã lệnh từ IR
  - Đọc thanh ghi nguồn: A = RF[rs1], B = RF[rs2]
  - Tạo giá trị immediate từ lệnh
  - Tạo tín hiệu điều khiển cho các trạng thái tiếp theo

- **EX (Execute)**:
  - Thực hiện phép toán ALU: ALUOut = ALU(A, B/Imm)
  - Thiết lập các cờ (zero, negative, overflow)
  - Tính toán địa chỉ đích cho lệnh branch/jump

- **MEM (Memory Access)**:
  - Cho lệnh load/store: MAR = ALUOut
  - Lệnh load: MDR = MEM[MAR]
  - Lệnh store: MEM[MAR] = B
  - Đánh giá điều kiện rẽ nhánh

- **WB (Write Back)**:
  - Lệnh R/I-type: RF[rd] = ALUOut
  - Lệnh load: RF[rd] = MDR

- **NEXT (Next Instruction)**:
  - Cập nhật PC dựa trên loại lệnh và điều kiện rẽ nhánh
  - PC = PC (đã tăng ở IF) nếu không nhảy
  - PC = Branch target nếu điều kiện rẽ nhánh đúng
  - PC = Jump target cho lệnh jump

### 2. Xử lý Branch/Jump chi tiết

Cơ chế xử lý Branch/Jump bao gồm:

- **Branch Detection**:
  - Phát hiện các lệnh rẽ nhánh (beq, bne, blt, bge, bltu, bgeu)
  - Sử dụng opcode và funct3 để xác định loại lệnh branch
  - Kết hợp với ALU flags để đánh giá điều kiện

- **Jump Detection**:
  - Phát hiện các lệnh nhảy (jal, jalr)
  - Tạo tín hiệu điều khiển cho việc cập nhật PC
  - Lưu địa chỉ trở về (PC+4) vào thanh ghi đích (rd) nếu cần

- **ALU Flags**:
  - Zero: Kết quả ALU bằng 0
  - Negative: Kết quả ALU là số âm
  - Overflow: Phép toán ALU gây tràn số

- **Branch Comparator**:
  - So sánh giá trị từ thanh ghi rs1 và rs2
  - Tạo kết quả so sánh (bằng, khác, nhỏ hơn, lớn hơn)
  - Kết hợp với loại lệnh branch để quyết định có nhảy hay không

### 3. Chuẩn bị cho mở rộng tương lai

Kiến trúc này có thể mở rộng trong tương lai với:

- **Forwarding Unit**:
  - Phát hiện data hazard trong pipeline
  - Chuyển dữ liệu trực tiếp từ các giai đoạn sau về giai đoạn EX
  - Giảm thiểu stall và tăng hiệu suất

- **Hazard Detection Unit**:
  - Phát hiện các hazard không thể giải quyết bằng forwarding
  - Tạo tín hiệu stall khi cần thiết
  - Xử lý load-use hazard và control hazard

- **Interrupt Handler**:
  - Xử lý ngắt và ngoại lệ
  - Lưu trạng thái CPU khi có ngắt
  - Nhảy đến vector ngắt và trở về sau khi xử lý

## Ưu điểm của kiến trúc Multi-Cycle

1. **Tối ưu tài nguyên phần cứng**:
   - Sử dụng lại ALU và các thành phần khác cho nhiều giai đoạn
   - Giảm diện tích chip và chi phí

2. **Linh hoạt trong thiết kế**:
   - Các lệnh khác nhau có thể sử dụng số chu kỳ khác nhau
   - Lệnh đơn giản hoàn thành nhanh hơn

3. **Dễ dàng mở rộng**:
   - Có thể thêm lệnh mới mà không cần thay đổi lớn về phần cứng
   - Nền tảng tốt để phát triển lên kiến trúc pipeline

4. **Điều khiển đơn giản hơn**:
   - Mỗi chu kỳ chỉ thực hiện một phần của lệnh
   - Giảm độ phức tạp của đường dẫn dữ liệu

## Nhược điểm

1. **Hiệu suất thấp hơn**:
   - Mỗi lệnh cần nhiều chu kỳ để hoàn thành
   - Thời gian thực thi trung bình cao hơn so với pipeline

2. **Độ phức tạp của FSM**:
   - Máy trạng thái phức tạp hơn so với CPU single-cycle
   - Cần xử lý nhiều trường hợp đặc biệt

## Kết luận

Kiến trúc CPU multi-cycle cung cấp sự cân bằng tốt giữa hiệu suất và chi phí phần cứng. Nó là một bước tiến so với kiến trúc single-cycle và là nền tảng để phát triển lên kiến trúc pipeline phức tạp hơn. Với các thành phần đã được thiết kế, CPU multi-cycle này có thể thực thi đầy đủ bộ lệnh RISC và dễ dàng mở rộng với các tính năng nâng cao trong tương lai. 