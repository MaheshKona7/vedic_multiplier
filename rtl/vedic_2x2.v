// ============================================================================
// Module Name:  vedic_2x2
// Project:      16-bit Vedic Multiplier
// Architecture: Urdhva Tiryagbhyam (Vertical and Crosswise)
// Description:  Fundamental 2x2 Vedic multiplier building block.
//               Computes the product of two 2-bit unsigned numbers (a and b)
//               to produce a 4-bit product using basic logic gates and half adders.
//
//               Multiplication Steps (Urdhva Tiryagbhyam):
//               Step 1 (Vertical):   product[0] = a[0] & b[0]
//               Step 2 (Crosswise):  sum1       = (a[1] & b[0]) + (a[0] & b[1])
//                                    product[1] = sum1
//                                    carry1     = carry from sum1
//               Step 3 (Vertical):   sum2       = (a[1] & b[1]) + carry1
//                                    product[2] = sum2
//                                    product[3] = carry2
//
// Note: No behavioral multiplication operator (*) is used.
// ============================================================================

`timescale 1ns / 1ps

module vedic_2x2 (
    input  wire [1:0] a,        // 2-bit unsigned multiplicand
    input  wire [1:0] b,        // 2-bit unsigned multiplier
    output wire [3:0] product   // 4-bit unsigned product
);

    // -------------------------------------------------------------------------
    // Step 1: Vertical multiplication of LSBs
    // -------------------------------------------------------------------------
    // Bit 0 is formed directly by the AND operation between a[0] and b[0].
    assign product[0] = a[0] & b[0];

    // -------------------------------------------------------------------------
    // Step 2: Crosswise multiplication and first addition
    // -------------------------------------------------------------------------
    // Partial product terms:
    wire pp10 = a[1] & b[0];    // Cross-term 1
    wire pp01 = a[0] & b[1];    // Cross-term 2

    // Half Adder 1 adds pp10 and pp01:
    // Sum bit gives product[1], Carry bit is forwarded to Step 3.
    wire ha1_sum   = pp10 ^ pp01;
    wire ha1_carry = pp10 & pp01;

    assign product[1] = ha1_sum;

    // -------------------------------------------------------------------------
    // Step 3: Vertical multiplication of MSBs and addition with carry
    // -------------------------------------------------------------------------
    // Partial product term:
    wire pp11 = a[1] & b[1];    // Vertical term for MSBs

    // Half Adder 2 adds pp11 and the carry from Step 2:
    // Sum bit gives product[2], Carry bit gives product[3] (MSB).
    wire ha2_sum   = pp11 ^ ha1_carry;
    wire ha2_carry = pp11 & ha1_carry;

    assign product[2] = ha2_sum;
    assign product[3] = ha2_carry;

endmodule
