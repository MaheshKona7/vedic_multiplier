// ============================================================================
// Module Name:  conventional_multiplier
// Project:      16-bit Vedic Multiplier
// Architecture: Behavioral / Standard RTL Multiplier
// Description:  Reference 16x16 unsigned multiplier using the standard Verilog
//               multiplication operator (*).
//
// Purpose:
//   This module serves as an architectural baseline for comparison against
//   the 16x16 hierarchical Vedic Multiplier under identical synthesis
//   constraints and FPGA target device in AMD Vivado.
//
// Synthesis Behavior:
//   FPGA synthesis tools (like Vivado) may map this operator directly to
//   dedicated DSP slices (e.g., DSP48E1/DSP48E2) or infer LUT-based logic
//   depending on synthesis settings and tool directives.
// ============================================================================

`timescale 1ns / 1ps

module conventional_multiplier (
    input  wire [15:0] a,       // 16-bit unsigned multiplicand
    input  wire [15:0] b,       // 16-bit unsigned multiplier
    output wire [31:0] product  // 32-bit unsigned product
);

    // Behavioral multiplication operator
    assign product = a * b;

endmodule
