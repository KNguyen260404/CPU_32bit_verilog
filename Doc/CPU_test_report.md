# CPU Test Report

## 1. Tổng quan

Báo cáo này trình bày kết quả kiểm thử của CPU RISC-V 32-bit đã được thiết kế. Các bài kiểm thử được thực hiện theo test plan đã đề ra, bao gồm kiểm tra các loại lệnh khác nhau và các chức năng cơ bản của CPU.

## 2. Môi trường kiểm thử

- **Công cụ mô phỏng**: Icarus Verilog
- **Công cụ phân tích waveform**: GTKWave
- **Định dạng ghi tín hiệu**: VCD
- **Thời gian mô phỏng**: 1000ns cho mỗi testcase

## 3. Kết quả kiểm thử

### 3.1 Kiểm tra lệnh số học và logic

#### Testcase: CPU_test_arithmetic.v

**Mục tiêu**: Kiểm tra các lệnh số học và logic cơ bản (add, sub, and, or, xor, sll).

**Kết quả**:
- Các lệnh được thực thi theo đúng thứ tự
- CPU đi qua các trạng thái IF, ID, EX, WB cho mỗi lệnh
- Kết quả tính toán được lưu vào đúng thanh ghi

**Vấn đề phát hiện**:
- Có cảnh báo về bit width padding giữa ALU và ALU Control Unit
- Cần điều chỉnh số bit của tín hiệu alu_control để đồng nhất giữa các module

### 3.2 Kiểm tra lệnh rẽ nhánh

#### Testcase: CPU_test_branch.v

**Mục tiêu**: Kiểm tra các lệnh rẽ nhánh (beq, bne, blt, bge, bltu, bgeu) và lệnh nhảy (jal).

**Kết quả**:
- Các lệnh rẽ nhánh được thực hiện đúng khi điều kiện đúng
- PC được cập nhật đúng khi điều kiện thỏa mãn
- PC+4 được sử dụng khi điều kiện không thỏa mãn
- Lệnh jal lưu địa chỉ trở về vào thanh ghi đích

**Vấn đề phát hiện**:
- Cần tối ưu hóa chu kỳ xử lý lệnh rẽ nhánh

### 3.3 Kiểm tra truy cập bộ nhớ

#### Testcase: CPU_test_memory.v

**Mục tiêu**: Kiểm tra các lệnh load và store (lw, sw).

**Kết quả**:
- Dữ liệu được đọc/ghi từ/vào bộ nhớ chính xác
- Địa chỉ được tính toán đúng
- Dữ liệu được chuyển qua MDR đúng cách

**Vấn đề phát hiện**:
- Cần tối ưu hóa chu kỳ truy cập bộ nhớ

## 4. Phân tích waveform

Phân tích waveform cho thấy:
- Các tín hiệu điều khiển được tạo ra đúng thời điểm
- Datapath hoạt động đúng với luồng dữ liệu mong đợi
- FSM của Control Unit chuyển trạng thái đúng theo chu kỳ lệnh

## 5. Vấn đề và đề xuất cải tiến

### 5.1 Vấn đề phát hiện

1. **Bit width mismatch**: Có sự không đồng nhất về số bit giữa các module, đặc biệt là ALU và ALU Control Unit.
2. **Hiệu năng**: Một số lệnh cần nhiều chu kỳ để hoàn thành hơn cần thiết.
3. **Reset handling**: Cần cải thiện cơ chế reset để đảm bảo CPU khởi động ở trạng thái đúng.

### 5.2 Đề xuất cải tiến

1. **Đồng bộ bit width**: Chuẩn hóa số bit của các tín hiệu điều khiển giữa các module.
2. **Tối ưu FSM**: Giảm số trạng thái cần thiết cho một số loại lệnh.
3. **Pipeline**: Cân nhắc thiết kế pipeline để tăng hiệu năng.
4. **Cải thiện testbench**: Phát triển testbench tự động kiểm tra kết quả.

## 6. Kết luận

CPU RISC-V 32-bit đã được kiểm thử thành công với các loại lệnh cơ bản. Thiết kế hiện tại đáp ứng được các yêu cầu chức năng cơ bản, nhưng vẫn có thể được cải thiện về hiệu năng và tính ổn định. Các vấn đề phát hiện trong quá trình kiểm thử cần được giải quyết trong các phiên bản tiếp theo. 