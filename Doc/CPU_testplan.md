# CPU Test Plan

## 1. Mục tiêu kiểm thử

Mục tiêu của test plan này là kiểm tra toàn diện chức năng của CPU multi-cycle, bao gồm:
- Kiểm tra các trạng thái FSM của Control Unit
- Kiểm tra thực thi các loại lệnh khác nhau
- Kiểm tra datapath và luồng dữ liệu
- Kiểm tra xử lý rẽ nhánh và nhảy
- Kiểm tra truy cập bộ nhớ

## 2. Phương pháp kiểm thử

### 2.1 Kiểm thử đơn vị (Unit Testing)
- Kiểm tra từng module riêng biệt (đã thực hiện)
- Kiểm tra các tín hiệu vào/ra của từng module

### 2.2 Kiểm thử tích hợp (Integration Testing)
- Kiểm tra kết nối giữa các module
- Kiểm tra luồng dữ liệu qua datapath

### 2.3 Kiểm thử hệ thống (System Testing)
- Kiểm tra CPU hoàn chỉnh với các chương trình mẫu
- Kiểm tra hiệu năng và tài nguyên

## 3. Các testcase

### 3.1 Testcase 1: Kiểm tra chu kỳ lệnh cơ bản
- **Mục tiêu**: Kiểm tra các trạng thái FSM và chu kỳ lệnh cơ bản
- **Đầu vào**: Lệnh NOP (addi x0, x0, 0)
- **Kết quả mong đợi**: 
  - CPU đi qua các trạng thái IF, ID, EX, WB
  - PC tăng 4 sau mỗi lệnh
  - Không có thay đổi trong thanh ghi

### 3.2 Testcase 2: Kiểm tra lệnh số học và logic
- **Mục tiêu**: Kiểm tra các lệnh R-type và I-type
- **Đầu vào**: Chuỗi lệnh số học (add, sub, and, or, xor, addi, andi, ori)
- **Kết quả mong đợi**: 
  - Các phép toán được thực hiện chính xác
  - Kết quả được ghi vào thanh ghi đúng
  - ALU flags được thiết lập chính xác

### 3.3 Testcase 3: Kiểm tra truy cập bộ nhớ
- **Mục tiêu**: Kiểm tra lệnh load và store
- **Đầu vào**: Chuỗi lệnh lw, sw
- **Kết quả mong đợi**: 
  - Dữ liệu được đọc/ghi từ/vào bộ nhớ chính xác
  - Địa chỉ được tính toán đúng
  - Dữ liệu được chuyển qua MDR đúng cách

### 3.4 Testcase 4: Kiểm tra rẽ nhánh có điều kiện
- **Mục tiêu**: Kiểm tra các lệnh branch
- **Đầu vào**: Chuỗi lệnh beq, bne, blt, bge, bltu, bgeu
- **Kết quả mong đợi**: 
  - Branch comparator hoạt động chính xác
  - PC được cập nhật đúng khi điều kiện đúng
  - PC+4 được sử dụng khi điều kiện sai

### 3.5 Testcase 5: Kiểm tra lệnh nhảy
- **Mục tiêu**: Kiểm tra lệnh jal và jalr
- **Đầu vào**: Chuỗi lệnh jal, jalr
- **Kết quả mong đợi**: 
  - PC được cập nhật đến địa chỉ đích
  - Địa chỉ trở về (PC+4) được lưu vào thanh ghi đích
  - Nhảy không điều kiện luôn được thực hiện

### 3.6 Testcase 6: Kiểm tra chương trình hoàn chỉnh
- **Mục tiêu**: Kiểm tra CPU với chương trình thực tế
- **Đầu vào**: Chương trình tính tổng các số từ 1 đến 10
- **Kết quả mong đợi**: 
  - Kết quả cuối cùng là 55 trong thanh ghi x5
  - Chương trình thực thi đúng số chu kỳ
  - Các lệnh được thực hiện theo đúng thứ tự

## 4. Môi trường kiểm thử

### 4.1 Công cụ
- Icarus Verilog cho mô phỏng
- GTKWave cho phân tích waveform
- VCD file cho ghi lại tín hiệu

### 4.2 Thiết lập
- Tạo các chương trình kiểm thử trong bộ nhớ
- Ghi lại tất cả các tín hiệu quan trọng
- Theo dõi trạng thái CPU, PC, và nội dung thanh ghi

## 5. Quy trình kiểm thử

1. Biên dịch và mô phỏng với từng testcase
2. Ghi lại kết quả và so sánh với kết quả mong đợi
3. Phân tích waveform để xác định các vấn đề
4. Sửa lỗi và kiểm thử lại

## 6. Tiêu chí đánh giá

CPU được coi là hoạt động chính xác khi:
- Tất cả các testcase đều thành công
- Không có lỗi hoặc cảnh báo nghiêm trọng
- Các lệnh được thực thi trong số chu kỳ dự kiến
- Kết quả cuối cùng khớp với kết quả mong đợi 