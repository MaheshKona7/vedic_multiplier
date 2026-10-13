// ============================================================================
// Module Name:  vedic_8x8
// Project:      16-bit Vedic Multiplier
// Architecture: Urdhva Tiryagbhyam (Vertical and Crosswise)
// Description:  8x8 Vedic multiplier constructed hierarchically from four
//               4x4 Vedic multipliers (vedic_4x4) and intermediate adders.
//
// Operand Partitioning:
//   Multiplicand A = {A1, A0} where A1 = a[7:4], A0 = a[3:0]
//   Multiplier   B = {B1, B0} where B1 = b[7:4], B0 = b[3:0]
//
// Mathematical Derivation (Urdhva Tiryagbhyam):
//   Product = (A1 * 2^4 + A0) * (B1 * 2^4 + B0)
//           = (A0 * B0) + (A1 * B0 + A0 * B1) * 2^4 + (A1 * B1) * 2^8
//           =   P0      +      (P1 + P2)     * 2^4 +      P3     * 2^8
//
// Where:
//   P0 = A0 * B0 (8-bit partial product, weight 2^0)
//   P1 = A1 * B0 (8-bit partial product, weight 2^4)
//   P2 = A0 * B1 (8-bit partial product, weight 2^4)
//   P3 = A1 * B1 (8-bit partial product, weight 2^8)
//
// Bit Alignment & Addition Tree:
//   - product[3:0] = P0[3:0]
//   - P0[7:4] carries into the sum of P1 and P2:
//       sum_cross = P1 + P2                (8-bit + 8-bit = 9-bit, max 225+225 = 450)
//       sum_mid   = sum_cross + P0[7:4]    (9-bit + 4-bit = 10-bit, max 450+14 = 464)
//       product[7:4] = sum_mid[3:0]
//   - Carry-over from sum_mid (bits [9:4], 6-bit) carries into P3:
//       sum_high  = P3 + sum_mid[9:4]      (8-bit + 6-bit = 9-bit, max 225+29 = 254)
//       product[15:8] = sum_high[7:0]
//
// Note: No behavioral multiplication operator (*) is used.
// ============================================================================

`timescale 1ns / 1ps

module vedic_8x8 (
    input  wire [7:0]  a,       // 8-bit unsigned multiplicand
    input  wire [7:0]  b,       // 8-bit unsigned multiplier
    output wire [15:0] product  // 16-bit unsigned product
);

    // -------------------------------------------------------------------------
    // Operand Partitioning into 4-bit nibbles
    // -------------------------------------------------------------------------
    wire [3:0] a0 = a[3:0];     // Lower 4 bits of A
    wire [3:0] a1 = a[7:4];     // Upper 4 bits of A
    wire [3:0] b0 = b[3:0];     // Lower 4 bits of B
    wire [3:0] b1 = b[7:4];     // Upper 4 bits of B

    // -------------------------------------------------------------------------
    // Instantiate four 4x4 Vedic Multipliers
    // -------------------------------------------------------------------------
    wire [7:0] p0;              // P0 = A0 * B0 (weight 2^0)
    wire [7:0] p1;              // P1 = A1 * B0 (weight 2^4)
    wire [7:0] p2;              // P2 = A0 * B1 (weight 2^4)
    wire [7:0] p3;              // P3 = A1 * B1 (weight 2^8)

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

    // -------------------------------------------------------------------------
    // Partial Product Addition Stages
    // -------------------------------------------------------------------------
    // Stage 1: Add the two crosswise partial products P1 and P2.
    // 8-bit + 8-bit produces a 9-bit result (max: 225 + 225 = 450 -> fits in 9 bits).
    wire [8:0] sum_cross = p1 + p2;

    // Stage 2: Add sum_cross to the upper 4 bits of P0.
    // 9-bit + 4-bit produces a 10-bit result (max: 450 + 14 = 464 -> fits in 10 bits).
    wire [9:0] sum_mid = sum_cross + {5'b00000, p0[7:4]};

    // Stage 3: Add upper 6 bits of sum_mid (carry-out to weight 2^8) to P3.
    // 8-bit + 6-bit produces a 9-bit result (max: 225 + 29 = 254 -> fits in 8 bits,
    // bit 8 is always 0 because max product 255*255 = 65025 = 16'hFE01).
    wire [8:0] sum_high = p3 + {2'b00, sum_mid[9:4]};

    // -------------------------------------------------------------------------
    // Final 16-bit Product Assembly
    // -------------------------------------------------------------------------
    assign product = {sum_high[7:0], sum_mid[3:0], p0[3:0]};

endmodule
