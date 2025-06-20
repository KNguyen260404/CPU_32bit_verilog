`timescale 1ns / 1ps

module Register_tb;
    // Tham số
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    // Các tín hiệu đầu vào
    reg clk;
    reg reset;
    reg reg_write;
    reg [31:0] data_in;

    // Tín hiệu đầu ra
    wire [31:0] data_out;

    // Tạo xung nhịp
    always #(CLK_PERIOD/2) clk = ~clk;

    // Khởi tạo đối tượng cần kiểm tra
    Register uut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Tạo file VCD để xem dạng sóng
    initial begin
        $dumpfile("register_waveform.vcd");
        $dumpvars(0, Register_tb);
    end

    // Biến đếm test case và kết quả mong đợi
    integer test_case;
    reg [31:0] expected_data;

    // Hàm hiển thị kết quả kiểm tra
    task display_test_result;
        input [8*30:1] test_name;
        begin
            $display("Test Case %0d: %s", test_case, test_name);
            $display("  data_in = %h, reg_write = %b", data_in, reg_write);
            $display("  Expected: data_out = %h", expected_data);
            $display("  Actual:   data_out = %h", data_out);
            
            if (data_out !== expected_data) begin
                $display("  TEST FAILED!");
            end else begin
                $display("  Test passed.");
            end
            $display("--------------------------------------");
        end
    endtask

    // Quy trình kiểm tra chính
    initial begin
        // Khởi tạo các tín hiệu đầu vào
        clk = 0;
        reset = 1;
        reg_write = 0;
        data_in = 0;
        test_case = 0;
        expected_data = 0;

        // Đợi reset hoàn tất
        #(CLK_PERIOD*2);
        reset = 0;
        #CLK_PERIOD;

        // Test 1: Ghi dữ liệu khi reg_write=1
        test_case = test_case + 1;
        data_in = 32'h12345678;
        reg_write = 1;
        expected_data = 32'h12345678;
        #CLK_PERIOD;
        display_test_result("Ghi dữ liệu khi reg_write=1");

        // Test 2: Giữ giá trị khi reg_write=0
        test_case = test_case + 1;
        data_in = 32'h87654321;
        reg_write = 0;
        expected_data = 32'h12345678; // Giữ giá trị cũ
        #CLK_PERIOD;
        display_test_result("Giữ giá trị khi reg_write=0");

        // Test 3: Ghi dữ liệu mới khi reg_write=1
        test_case = test_case + 1;
        data_in = 32'hABCDEF01;
        reg_write = 1;
        expected_data = 32'hABCDEF01;
        #CLK_PERIOD;
        display_test_result("Ghi dữ liệu mới khi reg_write=1");

        // Test 4: Reset thanh ghi
        test_case = test_case + 1;
        reset = 1;
        expected_data = 32'h00000000;
        #CLK_PERIOD;
        display_test_result("Reset thanh ghi");
        reset = 0;

        // Test 5: Ghi dữ liệu sau khi reset
        test_case = test_case + 1;
        data_in = 32'h55555555;
        reg_write = 1;
        expected_data = 32'h55555555;
        #CLK_PERIOD;
        display_test_result("Ghi dữ liệu sau khi reset");

        // Test 6: Kiểm tra với giá trị nhỏ
        test_case = test_case + 1;
        data_in = 32'h00000001;
        reg_write = 1;
        expected_data = 32'h00000001;
        #CLK_PERIOD;
        display_test_result("Kiểm tra với giá trị nhỏ");

        // Test 7: Kiểm tra với giá trị lớn nhất
        test_case = test_case + 1;
        data_in = 32'hFFFFFFFF;
        reg_write = 1;
        expected_data = 32'hFFFFFFFF;
        #CLK_PERIOD;
        display_test_result("Kiểm tra với giá trị lớn nhất");

        // Test 8: Kiểm tra với giá trị 0
        test_case = test_case + 1;
        data_in = 32'h00000000;
        reg_write = 1;
        expected_data = 32'h00000000;
        #CLK_PERIOD;
        display_test_result("Kiểm tra với giá trị 0");

        // Kết thúc mô phỏng
        $display("Tất cả các test đã hoàn thành!");
        #(CLK_PERIOD*2);
        $finish;
    end

endmodule
