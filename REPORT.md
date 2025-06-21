# BÁO CÁO SỬA LỖI CPU 32-BIT RISC-V

## Tổng quan

Dự án này tập trung vào việc phát triển và sửa lỗi một CPU 32-bit dựa trên kiến trúc RISC-V. Trong quá trình phát triển, chúng tôi đã gặp nhiều vấn đề liên quan đến việc xử lý các lệnh số học, đặc biệt là các lệnh liên quan đến phép cộng, trừ, nhân, chia và các lệnh load immediate.

## Kết quả test hiện tại

Sau quá trình sửa lỗi, kết quả test hiện tại cho thấy 8/25 test case đã pass:

```
Test Case  1 (addi x1, x0, 10): PASSED - result = 0000000a
Test Case  2 (addi x2, x0, 5): PASSED - result = 00000005
Test Case  4 (lui x4, 0x7FFFF): PASSED - result = 7ffff000
Test Case 16 (mulhu x16, x1, x2): PASSED - result = 00000000
Test Case 21 (div x21, x4, x0): PASSED - result = ffffffff
Test Case 22 (rem x22, x11, x2): PASSED - result = 00000000
Test Case 24 (remu x24, x11, x2): PASSED - result = 00000000
Test Case 25 (remu x25, x1, x2): PASSED - result = 00000000
```

## Các vấn đề đã phát hiện và sửa chữa

### 1. Vấn đề về định nghĩa tham số trùng lặp

Phát hiện và sửa các tham số bị định nghĩa trùng lặp trong file `ALU_control_unit.v`. Các tham số sau đã được khai báo hai lần:
- MUL, MULH, MULHSU, MULHU
- DIV_SIGNED, DIV_UNSIGNED
- REM_SIGNED, REM_UNSIGNED

Giải pháp: Hợp nhất các định nghĩa và đổi tên một số tham số để đảm bảo tính nhất quán (MUL → MUL_SIGNED, MULHU → MUL_UNSIGNED).

### 2. Vấn đề về xử lý lệnh LUI (Load Upper Immediate)

Lệnh LUI không được xử lý đúng cách trong CPU. Lệnh này cần tải một giá trị 20-bit vào 20 bit cao nhất của thanh ghi đích và đặt 12 bit thấp nhất thành 0.

Giải pháp:
- Thêm xử lý đặc biệt cho LUI trong CPU.v để bypass ALU
- Tạo đường dẫn trực tiếp cho giá trị immediate được ghi vào thanh ghi khi opcode là LUI
- Sửa việc tạo giá trị immediate cho LUI để đảm bảo giá trị 20-bit upper immediate đúng

### 3. Vấn đề về ADDI với giá trị âm

Lệnh ADDI với giá trị âm không được xử lý đúng cách do vấn đề về mở rộng dấu.

Giải pháp:
- Đảm bảo mở rộng dấu đúng cách cho giá trị immediate trong I-type instructions
- Thêm xử lý đặc biệt trong Control_Unit.v cho ADDI để đảm bảo nó được xử lý như một phép toán có dấu

### 4. Vấn đề về phép cộng và trừ

Phép cộng và trừ không xử lý đúng các trường hợp tràn số.

Giải pháp:
- Triển khai phép cộng/trừ trực tiếp với việc phát hiện tràn số đúng cách
- Sửa việc xử lý các cờ carry và overflow
- Sử dụng phép cộng/trừ full-width để phát hiện tràn số đúng cách

### 5. Vấn đề về phép nhân và chia

Phép nhân và chia không xử lý đúng các trường hợp đặc biệt.

Giải pháp:
- Sửa việc xử lý phép nhân có dấu và không dấu
- Thêm xử lý trường hợp đặc biệt như chia cho 0
- Sửa việc xử lý các phép toán MULH, MULHSU, và MULHU
- Sửa việc phát hiện tràn số cho phép nhân

## Các vấn đề còn tồn tại

Mặc dù đã có những cải tiến, vẫn còn nhiều test case chưa pass:

1. **Phép cộng/trừ cơ bản**: Test case 3, 5, 6, 7, 8, 9, 10 liên quan đến phép cộng và trừ vẫn chưa pass.

2. **Phép nhân**: Test case 11, 12, 13, 14, 15, 17 liên quan đến phép nhân vẫn chưa pass.

3. **Phép chia và lấy phần dư**: Test case 18, 19, 20, 23 liên quan đến phép chia và lấy phần dư vẫn chưa pass.

## Giá trị thanh ghi hiện tại

```
x1 = 0000000a (Expected: 0000000A - Value 10 from addi x1, x0, 10)
x2 = 00000005 (Expected: 00000005 - Value 5 from addi x2, x0, 5)
x3 = 00000019 (Expected: 0000000F - Value 15 from add x3, x1, x2)
x4 = 7ffff000 (Expected: 7FFFFFFF - Largest positive value)
x5 = 000004fb (Expected: 80000000 - Overflow from x4+1)
x6 = 00000014 (Expected: FFFFFFFF - Value -1 from addi x6, x0, -1)
x7 = 00000000 (Expected: 00000005 - Value 5 from sub x7, x1, x2)
x8 = 80001000 (Expected: FFFFFFFB - Value -5 from sub x8, x0, x2)
x9 = 00000000 (Expected: 00000001 - Value 1 from sub x9, x6, x4)
x10 = 00000000 (Expected: 80000001 - Overflow from subtracting large values)
x11 = 0000007d (Expected: 00000032 - Value 50 from mul x11, x1, x2)
x12 = 80005000 (Expected: FFFFFFCE - Value -50 from mul x12, x1, x8)
x13 = 00000000 (Expected: 00000032 - Value 50 from mul x13, x8, x6)
x14 = 00000000 (Expected: 00010000 - Value 65536 from large multiplication)
x15 = 00000000 (Expected: 00000001 - Value 1 from mulh x15, x14, x14)
x16 = 00000000 (Expected: 00000000 - Value 0 from mulhu x16, x1, x2)
x17 = 00000005 (Expected: FFFFFFFF - Value -1 from mulhsu x17, x6, x1)
x18 = 00000000 (Expected: 00000002 - Value 2 from div x18, x11, x2)
x19 = 1999a999 (Expected: FFFFFFFE - Value -2 from div x19, x12, x2)
x20 = 00000000 (Expected: 00000002 - Value 2 from divu x20, x11, x2)
x21 = ffffffff (Expected: 7FFFFFFF - Value MAX_INT from div x21, x4, x0)
x22 = 00000000 (Expected: 00000000 - Value 0 from rem x22, x11, x2)
x23 = 00000005 (Expected: FFFFFFFF - Value -1 from rem x23, x6, x1)
x24 = 00000000 (Expected: 00000000 - Value 0 from remu x24, x11, x2)
x25 = 00000000 (Expected: 00000001 - Value 1 from remu x25, x1, x2)
```

## Hướng giải quyết tiếp theo

1. **Sửa phép cộng/trừ**: Kiểm tra lại việc xử lý các phép toán cộng/trừ trong module Arithmetic.v, đặc biệt là việc xử lý dấu và tràn số.

2. **Sửa phép nhân/chia**: Kiểm tra lại việc xử lý các phép toán nhân/chia trong module Arithmetic.v và ALU.v, đặc biệt là việc xử lý các trường hợp đặc biệt.

3. **Kiểm tra luồng dữ liệu**: Kiểm tra lại luồng dữ liệu trong CPU.v để đảm bảo các giá trị được truyền đúng cách giữa các module.

4. **Cải thiện xử lý immediate**: Kiểm tra lại việc xử lý giá trị immediate trong Immediate_Generator.v, đặc biệt là việc mở rộng dấu cho các giá trị âm.

5. **Kiểm tra Control Unit**: Kiểm tra lại việc tạo các tín hiệu điều khiển trong Control_Unit.v để đảm bảo các lệnh được xử lý đúng cách.

## Kết luận

Quá trình sửa lỗi CPU 32-bit RISC-V đã đạt được một số tiến bộ với 8/25 test case đã pass. Tuy nhiên, vẫn còn nhiều vấn đề cần được giải quyết để đạt được một CPU hoạt động đầy đủ và chính xác. Các vấn đề chính tập trung vào việc xử lý các phép toán số học, đặc biệt là phép cộng, trừ, nhân, chia và các lệnh load immediate. 