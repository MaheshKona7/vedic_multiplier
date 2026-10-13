// ============================================================================
// Module Name:  vedic_16x16
// Project:      16-bit Vedic Multiplier
// Architecture: Urdhva Tiryagbhyam (Vertical and Crosswise)
// Description:  Top-level 16x16 Vedic multiplier constructed hierarchically
//               from four 8x8 Vedic multipliers (vedic_8x8) and intermediate adders.
//
// Operand Partitioning:
//   Multiplicand A = {A1, A0} where A1 = a[15:8], A0 = a[7:0]
//   Multiplier   B = {B1, B0} where B1 = b[15:8], B0 = b[7:0]
//
// Mathematical Derivation (Urdhva Tiryagbhyam):
//   Product = (A1 * 2^8 + A0) * (B1 * 2^8 + B0)
//           = (A0 * B0) + (A1 * B0 + A0 * B1) * 2^8 + (A1 * B1) * 2^16
//           =   P0      +      (P1 + P2)     * 2^8 +      P3     * 2^16
//
// Where:
//   P0 = A0 * B0 (16-bit partial product, weight 2^0)
//   P1 = A1 * B0 (16-bit partial product, weight 2^8)
//   P2 = A0 * B1 (16-bit partial product, weight 2^8)
//   P3 = A1 * B1 (16-bit partial product, weight 2^16)
//
// Bit Alignment & Addition Tree:
//   - product[7:0] = P0[7:0]
//   - P0[15:8] carries into the sum of P1 and P2:
//       sum_cross = P1 + P2                (16-bit + 16-bit = 17-bit, max 65025+65025 = 130050)
//       sum_mid   = sum_cross + P0[15:8]   (17-bit + 8-bit  = 18-bit, max 130050+254  = 130304)
//       product[15:8] = sum_mid[7:0]
//   - Carry-over from sum_mid (bits [17:8], 10-bit) carries into P3:
//       sum_high  = P3 + sum_mid[17:8]     (16-bit + 10-bit = 17-bit, max 65025+509   = 65534)
//       product[31:16] = sum_high[15:0]
//
// Hierarchy:
//   vedic_16x16
//       └── vedic_8x8
//               └── vedic_4x4
//                       └── vedic_2x2
//
// Note: No behavioral multiplication operator (*) is used.
// ============================================================================

`timescale 1ns / 1ps

module vedic_16x16 (
    input  wire [15:0] a,       // 16-bit unsigned multiplicand
    input  wire [15:0] b,       // 16-bit unsigned multiplier
    output wire [31:0] product  // 32-bit unsigned product
);

    // -------------------------------------------------------------------------
    // Operand Partitioning into 8-bit bytes
    // -------------------------------------------------------------------------
    wire [7:0] a0 = a[7:0];     // Lower byte of A
    wire [7:0] a1 = a[15:8];    // Upper byte of A
    wire [7:0] b0 = b[7:0];     // Lower byte of B
    wire [7:0] b1 = b[15:8];    // Upper byte of B

    // -------------------------------------------------------------------------
    // Instantiate four 8x8 Vedic Multipliers
    // -------------------------------------------------------------------------
    wire [15:0] p0;             // P0 = A0 * B0 (weight 2^0)
    wire [15:0] p1;             // P1 = A1 * B0 (weight 2^8)
    wire [15:0] p2;             // P2 = A0 * B1 (weight 2^8)
    wire [15:0] p3;             // P3 = A1 * B1 (weight 2^16)

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

    // -------------------------------------------------------------------------
    // Partial Product Addition Stages
    // -------------------------------------------------------------------------
    // Stage 1: Add crosswise partial products P1 and P2.
    // 16-bit + 16-bit produces a 17-bit result (max: 65025 + 65025 = 130050 -> fits in 17 bits).
    wire [16:0] sum_cross = p1 + p2;

    // Stage 2: Add sum_cross to the upper 8 bits of P0.
    // 17-bit + 8-bit produces an 18-bit result (max: 130050 + 254 = 130304 -> fits in 18 bits).
    wire [17:0] sum_mid = sum_cross + {9'b000000000, p0[15:8]};

    // Stage 3: Add upper 10 bits of sum_mid (carry-out to weight 2^16) to P3.
    // 16-bit + 10-bit produces a 17-bit result (max: 65025 + 509 = 65534 -> fits in 16 bits,
    // bit 16 is always 0 because max product 65535*65535 = 4294836225 = 32'hFFFE0001).
    wire [16:0] sum_high = p3 + {6'b000000, sum_mid[17:8]};

    // -------------------------------------------------------------------------
    // Final 32-bit Product Assembly
    // -------------------------------------------------------------------------
    assign product = {sum_high[15:0], sum_mid[7:0], p0[7:0]};

endmodule
