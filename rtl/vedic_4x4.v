// ============================================================================
// Module Name:  vedic_4x4
// Project:      16-bit Vedic Multiplier
// Architecture: Urdhva Tiryagbhyam (Vertical and Crosswise)
// Description:  4x4 Vedic multiplier constructed hierarchically from four
//               2x2 Vedic multipliers (vedic_2x2) and intermediate adders.
//
// Operand Partitioning:
//   Multiplicand A = {A1, A0} where A1 = a[3:2], A0 = a[1:0]
//   Multiplier   B = {B1, B0} where B1 = b[3:2], B0 = b[1:0]
//
// Mathematical Derivation (Urdhva Tiryagbhyam):
//   Product = (A1 * 2^2 + A0) * (B1 * 2^2 + B0)
//           = (A0 * B0) + (A1 * B0 + A0 * B1) * 2^2 + (A1 * B1) * 2^4
//           =   P0      +      (P1 + P2)     * 2^2 +      P3     * 2^4
//
// Where:
//   P0 = A0 * B0 (4-bit partial product, weight 2^0)
//   P1 = A1 * B0 (4-bit partial product, weight 2^2)
//   P2 = A0 * B1 (4-bit partial product, weight 2^2)
//   P3 = A1 * B1 (4-bit partial product, weight 2^4)
//
// Bit Alignment & Addition Tree:
//   - product[1:0] = P0[1:0]
//   - P0[3:2] carries into the sum of P1 and P2:
//       sum_cross = P1 + P2                (4-bit + 4-bit = 5-bit, max 9+9 = 18)
//       sum_mid   = sum_cross + P0[3:2]    (5-bit + 2-bit = 6-bit, max 18+2 = 20)
//       product[3:2] = sum_mid[1:0]
//   - Carry-over from sum_mid (bits [5:2], 4-bit) carries into P3:
//       sum_high  = P3 + sum_mid[5:2]      (4-bit + 4-bit = 5-bit, max 9+5 = 14)
//       product[7:4] = sum_high[3:0]
//
// Note: No behavioral multiplication operator (*) is used.
// ============================================================================

`timescale 1ns / 1ps

module vedic_4x4 (
    input  wire [3:0] a,        // 4-bit unsigned multiplicand
    input  wire [3:0] b,        // 4-bit unsigned multiplier
    output wire [7:0] product   // 8-bit unsigned product
);

    // -------------------------------------------------------------------------
    // Operand Partitioning into 2-bit nibbles
    // -------------------------------------------------------------------------
    wire [1:0] a0 = a[1:0];     // Lower 2 bits of A
    wire [1:0] a1 = a[3:2];     // Upper 2 bits of A
    wire [1:0] b0 = b[1:0];     // Lower 2 bits of B
    wire [1:0] b1 = b[3:2];     // Upper 2 bits of B

    // -------------------------------------------------------------------------
    // Instantiate four 2x2 Vedic Multipliers
    // -------------------------------------------------------------------------
    wire [3:0] p0;              // P0 = A0 * B0 (weight 2^0)
    wire [3:0] p1;              // P1 = A1 * B0 (weight 2^2)
    wire [3:0] p2;              // P2 = A0 * B1 (weight 2^2)
    wire [3:0] p3;              // P3 = A1 * B1 (weight 2^4)

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

    // -------------------------------------------------------------------------
    // Partial Product Addition Stages
    // -------------------------------------------------------------------------
    // Stage 1: Add the two crosswise partial products P1 and P2.
    // 4-bit + 4-bit produces a 5-bit result (max: 9 + 9 = 18 -> fits in 5 bits).
    wire [4:0] sum_cross = p1 + p2;

    // Stage 2: Add sum_cross to the upper 2 bits of P0.
    // 5-bit + 2-bit produces a 6-bit result (max: 18 + 2 = 20 -> fits in 6 bits).
    wire [5:0] sum_mid = sum_cross + {3'b000, p0[3:2]};

    // Stage 3: Add upper 4 bits of sum_mid (carry-out to weight 2^4) to P3.
    // 4-bit + 4-bit produces a 5-bit result (max: 9 + 5 = 14 -> fits in 4 bits,
    // bit 4 is always 0 because max product 15*15 = 225 = 8'b1110_0001).
    wire [4:0] sum_high = p3 + {1'b0, sum_mid[5:2]};

    // -------------------------------------------------------------------------
    // Final 8-bit Product Assembly
    // -------------------------------------------------------------------------
    assign product = {sum_high[3:0], sum_mid[1:0], p0[1:0]};

endmodule
