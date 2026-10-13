// ============================================================================
// Module Name:  vedic_16x16_tb
// Project:      16-bit Vedic Multiplier
// Architecture: Functional Verification Testbench (Self-Checking)
// Description:  Comprehensive testbench for functional verification of the
//               16x16 Vedic Multiplier (vedic_16x16).
//
// Verification Scope:
//   - Corner Cases: 0x0, 1x1, Max Value (65535 x 65535)
//   - Prompt Cases: 15x10, 25x20
//   - Multiplication by Zero: 0 x N, N x 0, 0 x 65535, 65535 x 0
//   - Multiplication by One: 1 x N, N x 1, 1 x 65535, 65535 x 1
//   - Powers of Two: 2x4, 16x32, 256x256, 1024x32, 32768x2
//   - Alternating Bit Patterns: 0xAAAA x 0x5555
//   - 50 Pseudo-Random Input Vectors covering the 16-bit domain
//
// Features:
//   - Automated reference model computation (a * b)
//   - Individual test PASS / FAIL console logging
//   - Cumulative test tally summary
//   - VCD waveform generation for GTKWave analysis
// ============================================================================

`timescale 1ns / 1ps

module vedic_16x16_tb;

    // -------------------------------------------------------------------------
    // Testbench Signals
    // -------------------------------------------------------------------------
    reg  [15:0] a;                  // Multiplicand stimulus
    reg  [15:0] b;                  // Multiplier stimulus
    wire [31:0] product;            // Multiplier output from DUT

    // Verification statistics counters
    integer total_tests;
    integer pass_count;
    integer fail_count;
    integer i;

    // -------------------------------------------------------------------------
    // Device Under Test (DUT) Instantiation
    // -------------------------------------------------------------------------
    vedic_16x16 u_dut (
        .a(a),
        .b(b),
        .product(product)
    );

    // -------------------------------------------------------------------------
    // Self-Checking Verification Task
    // -------------------------------------------------------------------------
    task check_product;
        input [15:0] test_a;
        input [15:0] test_b;
        reg   [31:0] expected;
        begin
            a = test_a;
            b = test_b;
            #10; // Wait for combinational propagation delay

            // Compute expected reference product using golden model
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

    // -------------------------------------------------------------------------
    // Stimulus Generation
    // -------------------------------------------------------------------------
    initial begin
        // Initialize waveform dumping for GTKWave
        $dumpfile("simulation/vedic_16x16.vcd");
        $dumpvars(0, vedic_16x16_tb);

        // Initialize counters and signals
        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;
        a           = 16'd0;
        b           = 16'd0;

        $display("================================================================================");
        $display("   STARTING FUNCTIONAL VERIFICATION: 16-BIT VEDIC MULTIPLIER (vedic_16x16)");
        $display("================================================================================");

        // ---------------------------------------------------------------------
        // 1. Mandatory Corner Cases & Specified Test Vectors
        // ---------------------------------------------------------------------
        $display("\n--- [Section 1] Corner Cases & Specified Test Vectors ---");
        check_product(16'd0, 16'd0);            // 0 x 0
        check_product(16'd1, 16'd1);            // 1 x 1
        check_product(16'd15, 16'd10);          // 15 x 10
        check_product(16'd25, 16'd20);          // 25 x 20
        check_product(16'd65535, 16'd65535);    // Maximum unsigned value: 65535 x 65535

        // ---------------------------------------------------------------------
        // 2. Multiplication by Zero
        // ---------------------------------------------------------------------
        $display("\n--- [Section 2] Multiplication by Zero Tests ---");
        check_product(16'd0, 16'd100);
        check_product(16'd250, 16'd0);
        check_product(16'd0, 16'd65535);
        check_product(16'd65535, 16'd0);

        // ---------------------------------------------------------------------
        // 3. Multiplication by One
        // ---------------------------------------------------------------------
        $display("\n--- [Section 3] Multiplication by One Tests ---");
        check_product(16'd1, 16'd45);
        check_product(16'd1234, 16'd1);
        check_product(16'd1, 16'd65535);
        check_product(16'd65535, 16'd1);

        // ---------------------------------------------------------------------
        // 4. Powers of Two (Testing Individual Bit Shifts)
        // ---------------------------------------------------------------------
        $display("\n--- [Section 4] Powers of Two Tests ---");
        check_product(16'd2, 16'd4);            // 2 x 4
        check_product(16'd16, 16'd32);          // 16 x 32
        check_product(16'd256, 16'd256);        // 256 x 256
        check_product(16'd1024, 16'd32);        // 1024 x 32
        check_product(16'd32768, 16'd2);        // 32768 x 2
        check_product(16'd128, 16'd512);        // 128 x 512

        // ---------------------------------------------------------------------
        // 5. Special Boundary and Bit Pattern Tests
        // ---------------------------------------------------------------------
        $display("\n--- [Section 5] Bit-Pattern and Partition Boundary Tests ---");
        check_product(16'h00FF, 16'h00FF);      // 255 x 255 (Lower byte max)
        check_product(16'hFF00, 16'h00FF);      // Upper byte x lower byte
        check_product(16'hAAAA, 16'h5555);      // Alternating bits 1010... x 0101...
        check_product(16'h5555, 16'h5555);      // Alternating bits
        check_product(16'hFFFF, 16'h0001);      // 65535 x 1

        // ---------------------------------------------------------------------
        // 6. Random Stimulus Vectors (50 Cases)
        // ---------------------------------------------------------------------
        $display("\n--- [Section 6] Random Stimulus Vectors (50 tests) ---");
        for (i = 1; i <= 50; i = i + 1) begin
            // $random returns 32-bit signed integer; mask to 16 bits unsigned
            check_product($random & 16'hFFFF, $random & 16'hFFFF);
        end

        // ---------------------------------------------------------------------
        // Final Summary Report
        // ---------------------------------------------------------------------
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
