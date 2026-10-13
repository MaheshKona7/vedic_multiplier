`timescale 1ns / 1ps

module vedic_2x2 (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] product
);

    assign product[0] = a[0] & b[0];

    wire pp10 = a[1] & b[0];
    wire pp01 = a[0] & b[1];

    wire ha1_sum   = pp10 ^ pp01;
    wire ha1_carry = pp10 & pp01;

    assign product[1] = ha1_sum;

    wire pp11 = a[1] & b[1];

    wire ha2_sum   = pp11 ^ ha1_carry;
    wire ha2_carry = pp11 & ha1_carry;

    assign product[2] = ha2_sum;
    assign product[3] = ha2_carry;

endmodule
