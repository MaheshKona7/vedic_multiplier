`timescale 1ns / 1ps

module vedic_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [31:0] product
);

    wire [7:0] a0 = a[7:0];
    wire [7:0] a1 = a[15:8];
    wire [7:0] b0 = b[7:0];
    wire [7:0] b1 = b[15:8];

    wire [15:0] p0;
    wire [15:0] p1;
    wire [15:0] p2;
    wire [15:0] p3;

    vedic_8x8 u_vedic_8x8_0 (
        .a(a0),
        .b(b0),
        .product(p0)
    );

    vedic_8x8 u_vedic_8x8_1 (
        .a(a1),
        .b(b0),
        .product(p1)
    );

    vedic_8x8 u_vedic_8x8_2 (
        .a(a0),
        .b(b1),
        .product(p2)
    );

    vedic_8x8 u_vedic_8x8_3 (
        .a(a1),
        .b(b1),
        .product(p3)
    );

    wire [16:0] sum_cross = p1 + p2;
    wire [17:0] sum_mid   = sum_cross + {9'b000000000, p0[15:8]};
    wire [16:0] sum_high  = p3 + {6'b000000, sum_mid[17:8]};

    assign product = {sum_high[15:0], sum_mid[7:0], p0[7:0]};

endmodule
