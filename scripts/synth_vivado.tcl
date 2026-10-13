# ==============================================================================
# Script:  synth_vivado.tcl
# Project: 16-bit Vedic Multiplier Synthesis Automation
# Usage:   vivado -mode batch -source scripts/synth_vivado.tcl
# ==============================================================================

set TARGET_PART "xc7a35tcpg236-1"
set OUTPUT_DIR  "synth_reports"

file mkdir $OUTPUT_DIR

puts "=========================================================================="
puts "  STARTING BATCH SYNTHESIS: 16-BIT VEDIC MULTIPLIER"
puts "  Target FPGA: $TARGET_PART"
puts "=========================================================================="

# 1. Read RTL sources for Vedic Multiplier
read_verilog rtl/vedic_2x2.v
read_verilog rtl/vedic_4x4.v
read_verilog rtl/vedic_8x8.v
read_verilog rtl/vedic_16x16.v

# 2. Run synthesis targeting top module
synth_design -top vedic_16x16 -part $TARGET_PART

# 3. Generate detailed hardware reports
report_utilization -file "$OUTPUT_DIR/vedic_16x16_utilization.rpt"
report_timing_summary -file "$OUTPUT_DIR/vedic_16x16_timing.rpt"
report_power -file "$OUTPUT_DIR/vedic_16x16_power.rpt"

puts "=========================================================================="
puts "  SYNTHESIS COMPLETED: Vedic Multiplier reports saved in $OUTPUT_DIR"
puts "=========================================================================="
