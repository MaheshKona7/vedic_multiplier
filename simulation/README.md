# Simulation Guide: Icarus Verilog and GTKWave

This directory contains simulation artifacts, waveform dumps, and execution scripts for functional verification of the 16-bit Vedic Multiplier and the reference Conventional Multiplier.

---

## 1. Prerequisites

Ensure you have **Icarus Verilog** and **GTKWave** installed. On Windows, they are typically installed under `C:\iverilog\bin` and `C:\iverilog\gtkwave\bin`.

Verify from PowerShell or Command Prompt:
```cmd
iverilog -v
vvp -v
gtkwave --version
```

If not found, ensure `C:\iverilog\bin` and `C:\iverilog\gtkwave\bin` are added to your system `PATH`.

---

## 2. Command-Line Simulation Flow (Exact Windows Commands)

Open PowerShell or Command Prompt and navigate to the project root directory:
```cmd
cd C:\projects\vedic_multiplier
```

### Step A: 16-bit Vedic Multiplier Simulation

#### 1. Compile the RTL hierarchy and testbench:
```cmd
iverilog -o simulation/vedic_16x16_tb.vvp -I rtl rtl/vedic_2x2.v rtl/vedic_4x4.v rtl/vedic_8x8.v rtl/vedic_16x16.v tb/vedic_16x16_tb.v
```

#### 2. Run the compiled simulation binary:
```cmd
vvp simulation/vedic_16x16_tb.vvp
```

You will see self-checking output:
```text
A = 0, B = 0, Expected = 0, DUT = 0, PASS
A = 1, B = 1, Expected = 1, DUT = 1, PASS
A = 15, B = 10, Expected = 150, DUT = 150, PASS
A = 25, B = 20, Expected = 500, DUT = 500, PASS
A = 65535, B = 65535, Expected = 4294836225, DUT = 4294836225, PASS
...
================================================================================
                         VERIFICATION SUMMARY
================================================================================
TOTAL TESTS: 73
PASSED:      73
FAILED:      0
================================================================================
>>> ALL TESTS PASSED SUCCESSFULLY! <<<
```

#### 3. View waveforms in GTKWave:
```cmd
gtkwave simulation/vedic_16x16.vcd
```
*(If gtkwave is not directly in PATH, run `C:\iverilog\gtkwave\bin\gtkwave.exe simulation/vedic_16x16.vcd`)*

---

### Step B: Reference Conventional Multiplier Simulation

#### 1. Compile:
```cmd
iverilog -o simulation/conventional_multiplier_tb.vvp rtl/conventional_multiplier.v tb/conventional_multiplier_tb.v
```

#### 2. Run simulation:
```cmd
vvp simulation/conventional_multiplier_tb.vvp
```

#### 3. View waveform:
```cmd
gtkwave simulation/conventional_multiplier.vcd
```

---

## 3. Quick Run Batch Scripts

For convenience on Windows, double-click or run:
- `simulation\run_sim.bat` — Compiles and executes both simulations, outputting full pass/fail tallies.
- `simulation\open_waveform.bat` — Launches GTKWave with the generated Vedic Multiplier waveform.
