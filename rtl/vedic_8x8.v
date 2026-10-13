`timescale 1ns / 1ps

module vedic_8x8 (
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output wire [15:0] product
);

    wire [3:0] a0 = a[3:0];
    wire [3:0] a1 = a[7:4];
    wire [3:0] b0 = b[3:0];
    wire [3:0] b1 = b[7:4];

    wire [7:0] p0;
    wire [7:0] p1;
    wire [7:0] p2;
    wire [7:0] p3;

    vedic_4x4 u_vedic_4x4_0 (
        .a(a0),
        .b(b0),
        .product(p0)
    );

    vedic_4x4 u_vedic_4x4_1 (
        .a(a1),
        .b(b0),
        .product(p1)
    );

    vedic_4x4 u_vedic_4x4_2 (
        .a(a0),
        .b(b1),
        .product(p2)
    );

    vedic_4x4 u_vedic_4x4_3 (
        .a(a1),
        .b(b1),
        .product(p3)
    );

    wire [8:0] sum_cross = p1 + p2;
    wire [9:0] sum_mid   = sum_cross + {5'b00000, p0[7:4]};
    wire [8:0] sum_high  = p3 + {2'b00, sum_mid[9:4]};

    assign product = {sum_high[7:0], sum_mid[3:0], p0[3:0]};

endmodule
