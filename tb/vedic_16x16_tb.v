`timescale 1ns / 1ps

module vedic_16x16_tb;

    reg  [15:0] a;
    reg  [15:0] b;
    wire [31:0] product;

    integer total_tests;
    integer pass_count;
    integer fail_count;
    integer i;

    vedic_16x16 u_dut (
        .a(a),
        .b(b),
        .product(product)
    );

    task check_product;
        input [15:0] test_a;
        input [15:0] test_b;
        reg   [31:0] expected;
        begin
            a = test_a;
            b = test_b;
            #10;

            expected = test_a * test_b;
            total_tests = total_tests + 1;

            if (product === expected) begin
                $display("A = %0d, B = %0d, Expected = %0d, DUT = %0d, PASS",
                         a, b, expected, product);
                pass_count = pass_count + 1;
            end else begin
                $display("A = %0d, B = %0d, Expected = %0d, DUT = %0d, FAIL",
                         a, b, expected, product);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/vedic_16x16.vcd");
        $dumpvars(0, vedic_16x16_tb);

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;
        a           = 16'd0;
        b           = 16'd0;

        $display("================================================================================");
        $display("   STARTING FUNCTIONAL VERIFICATION: 16-BIT VEDIC MULTIPLIER (vedic_16x16)");
        $display("================================================================================");

        check_product(16'd0, 16'd0);
        check_product(16'd1, 16'd1);
        check_product(16'd15, 16'd10);
        check_product(16'd25, 16'd20);
        check_product(16'd65535, 16'd65535);

        check_product(16'd0, 16'd100);
        check_product(16'd250, 16'd0);
        check_product(16'd0, 16'd65535);
        check_product(16'd65535, 16'd0);

        check_product(16'd1, 16'd45);
        check_product(16'd1234, 16'd1);
        check_product(16'd1, 16'd65535);
        check_product(16'd65535, 16'd1);

        check_product(16'd2, 16'd4);
        check_product(16'd16, 16'd32);
        check_product(16'd256, 16'd256);
        check_product(16'd1024, 16'd32);
        check_product(16'd32768, 16'd2);
        check_product(16'd128, 16'd512);

        check_product(16'h00FF, 16'h00FF);
        check_product(16'hFF00, 16'h00FF);
        check_product(16'hAAAA, 16'h5555);
        check_product(16'h5555, 16'h5555);
        check_product(16'hFFFF, 16'h0001);

        for (i = 1; i <= 50; i = i + 1) begin
            check_product($random & 16'hFFFF, $random & 16'hFFFF);
        end

        $display("\n================================================================================");
        $display("                         VERIFICATION SUMMARY");
        $display("================================================================================");
        $display("TOTAL TESTS: %0d", total_tests);
        $display("PASSED:      %0d", pass_count);
        $display("FAILED:      %0d", fail_count);
        $display("================================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> ERROR: %0d TEST(S) FAILED! <<<", fail_count);
        end
        $display("================================================================================\n");

        $finish;
    end

endmodule
