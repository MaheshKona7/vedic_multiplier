`timescale 1ns / 1ps

module conventional_multiplier_tb;

    reg  [15:0] a;
    reg  [15:0] b;
    wire [31:0] product;

    integer total_tests;
    integer pass_count;
    integer fail_count;
    integer i;

    conventional_multiplier u_dut (
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
        $dumpfile("simulation/conventional_multiplier.vcd");
        $dumpvars(0, conventional_multiplier_tb);

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;
        a           = 16'd0;
        b           = 16'd0;

        $display("================================================================================");
        $display("   STARTING FUNCTIONAL VERIFICATION: CONVENTIONAL MULTIPLIER");
        $display("================================================================================");

        check_product(16'd0, 16'd0);
        check_product(16'd1, 16'd1);
        check_product(16'd15, 16'd10);
        check_product(16'd25, 16'd20);
        check_product(16'd65535, 16'd65535);

        for (i = 1; i <= 20; i = i + 1) begin
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
        $finish;
    end

endmodule
