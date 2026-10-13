`timescale 1ns / 1ps

module vedic_4x4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] product
);

    wire [1:0] a0 = a[1:0];
    wire [1:0] a1 = a[3:2];
    wire [1:0] b0 = b[1:0];
    wire [1:0] b1 = b[3:2];

    wire [3:0] p0;
    wire [3:0] p1;
    wire [3:0] p2;
    wire [3:0] p3;

    vedic_2x2 u_vedic_2x2_0 (
        .a(a0),
        .b(b0),
        .product(p0)
    );

    vedic_2x2 u_vedic_2x2_1 (
        .a(a1),
        .b(b0),
        .product(p1)
    );

    vedic_2x2 u_vedic_2x2_2 (
        .a(a0),
        .b(b1),
        .product(p2)
    );

    vedic_2x2 u_vedic_2x2_3 (
        .a(a1),
        .b(b1),
        .product(p3)
    );

    wire [4:0] sum_cross = p1 + p2;
    wire [5:0] sum_mid   = sum_cross + {3'b000, p0[3:2]};
    wire [4:0] sum_high  = p3 + {1'b0, sum_mid[5:2]};

    assign product = {sum_high[3:0], sum_mid[1:0], p0[1:0]};

endmodule
