# Design and Functional Verification of a 16-bit Vedic Multiplier Using Verilog HDL

[![Verilog HDL](https://img.shields.io/badge/Language-Verilog--2001-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Simulator](https://img.shields.io/badge/Simulation-Icarus%20Verilog%20%7C%20GTKWave-brightgreen.svg)](http://iverilog.icarus.com/)
[![Synthesis](https://img.shields.io/badge/Synthesis-AMD%20Vivado-red.svg)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Verification](https://img.shields.io/badge/Verification-100%25%20Passed-success.svg)]()
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A complete, synthesizable, and beginner-friendly digital VLSI project implementing an unsigned **16-bit Vedic Multiplier** using the **Urdhva Tiryagbhyam** (Vertical and Crosswise) algorithm. The design is structured hierarchically from $2 \times 2$ up to $16 \times 16$, completely avoiding behavioral black-box multiplication operators (`*`) in the RTL datapath.

---

## Table of Contents
1. [Project Overview & Objective](#1-project-overview--objective)
2. [What is Vedic Multiplication?](#2-what-is-vedic-multiplication)
3. [Urdhva Tiryagbhyam Sutra](#3-urdhva-tiryagbhyam-sutra)
4. [Hierarchical RTL Architecture](#4-hierarchical-rtl-architecture)
   - [2x2 Vedic Multiplier](#41-2x2-vedic-multiplier-vedic_2x2)
   - [4x4 Vedic Multiplier](#42-4x4-vedic-multiplier-vedic_4x4)
   - [8x8 Vedic Multiplier](#43-8x8-vedic-multiplier-vedic_8x8)
   - [16x16 Vedic Multiplier](#44-16x16-vedic-multiplier-vedic_16x16)
5. [Repository Structure](#5-repository-structure)
6. [Tools & Technologies](#6-tools--technologies)
7. [Simulation & Functional Verification](#7-simulation--functional-verification)
   - [Icarus Verilog Execution](#71-running-with-icarus-verilog)
   - [Sample Verification Output](#72-sample-simulation-output)
   - [Waveform Analysis with GTKWave](#73-gtkwave-waveform-analysis)
8. [AMD Vivado Synthesis Workflow](#8-amd-vivado-synthesis-workflow)
9. [Synthesis Results & FPGA Metrics](#9-synthesis-results--fpga-metrics)
10. [Architectural Comparison (Vedic vs. Conventional)](#10-architectural-comparison-vedic-vs-conventional)
11. [Future Improvements](#11-future-improvements)
12. [Interview Preparation](#12-interview-preparation)
13. [Resume Description](#13-resume-description)

---

## 1. Project Overview & Objective

High-speed multiplication is a performance-critical bottleneck in modern Digital Signal Processing (DSP), Computer Graphics, Arithmetic Logic Units (ALUs), and Deep Learning hardware accelerators. Traditional array multipliers suffer from long carry propagation paths that limit maximum operating frequency.

### Key Objectives:
- Implement a **16-bit unsigned Vedic Multiplier** producing a **32-bit product**.
- Build an authentic hardware datapath using the ancient mathematical principle of **Urdhva Tiryagbhyam**.
- **No behavioral shortcuts:** The multiplier does NOT use `assign product = a * b;`.
- Construct a strict modular hierarchy:
  $$\text{vedic\_2x2} \longrightarrow \text{vedic\_4x4} \longrightarrow \text{vedic\_8x8} \longrightarrow \text{vedic\_16x16}$$
- Ensure all intermediate addition bit widths prevent overflow or truncation.
- Develop a comprehensive, self-checking testbench with directed corner cases and pseudo-random stimuli.
- Provide synthesis workflows for **AMD Vivado** and functional verification via **Icarus Verilog + GTKWave**.

---

## 2. What is Vedic Multiplication?

Vedic mathematics is a system of mental mathematics consisting of 16 sutras (aphorisms) formulated from ancient Indian texts. In digital hardware design, these sutras map naturally to concurrent arithmetic structures. Instead of waiting for full bit-by-bit serial carries, the algorithm calculates partial products and intermediate sums simultaneously in parallel.

---

## 3. Urdhva Tiryagbhyam Sutra

**Urdhva Tiryagbhyam** translates literally to **"Vertical and Crosswise"**.

In binary arithmetic:
- **Vertical multiplication:** Multiplying bit pairs aligned in the same column (realized using simple logic AND gates).
- **Crosswise multiplication:** Multiplying cross-aligned bit pairs and adding their results concurrently along with carries generated from preceding lower-order steps.

Because all partial products are generated concurrently, the multiplication latency is primarily governed by the adder tree rather than sequential carry accumulation.

---

## 4. Hierarchical RTL Architecture

The multiplier follows a modular hierarchy where every $(2N \times 2N)$ multiplier is composed of **four $(N \times N)$ multipliers** plus intermediate adder stages.

```
vedic_16x16 (Inputs: A[15:0], B[15:0] -> Product[31:0])
    ├── vedic_8x8 u0 (A[7:0],   B[7:0])   --> P0[15:0] (Weight 2^0)
    ├── vedic_8x8 u1 (A[15:8],  B[7:0])   --> P1[15:0] (Weight 2^8)
    ├── vedic_8x8 u2 (A[7:0],   B[15:8])  --> P2[15:0] (Weight 2^8)
    ├── vedic_8x8 u3 (A[15:8],  B[15:8])  --> P3[15:0] (Weight 2^16)
    └── 3 Adder Stages (17-bit, 18-bit, 17-bit)
```

```
Hierarchical Tree:
vedic_16x16
    └── vedic_8x8
            └── vedic_4x4
                    └── vedic_2x2 (Gate-level: 4 ANDs + 2 Half Adders)
```

### 4.1. 2×2 Vedic Multiplier (`vedic_2x2`)
Given inputs $a[1:0]$ and $b[1:0]$, the 4-bit output $p[3:0]$ is calculated as:
1. $p[0] = a[0] \ \& \ b[0]$ (Vertical)
2. $p[1] = (a[1] \ \& \ b[0]) \oplus (a[0] \ \& \ b[1])$ (Crosswise sum via Half Adder 1)
3. Carry from Half Adder 1 is added to $(a[1] \ \& \ b[1])$ via Half Adder 2, yielding $p[2]$ (Sum) and $p[3]$ (Carry).

### 4.2. 4×4 Vedic Multiplier (`vedic_4x4`)
- Operands are split into 2-bit nibbles: $a = \{a_1, a_0\}$, $b = \{b_1, b_0\}$.
- Four `vedic_2x2` instances generate partial products $P_0, P_1, P_2, P_3$ (each 4 bits).
- **Addition tree:**
  - $\text{sum\_cross} = P_1 + P_2$ (5 bits, max 18)
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[3:2]$ (6 bits, max 20)
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[5:2]$ (5 bits, max 14)
  - Product = $\{\text{sum\_high}[3:0], \text{sum\_mid}[1:0], P_0[1:0]\}$.

### 4.3. 8×8 Vedic Multiplier (`vedic_8x8`)
- Operands are split into 4-bit nibbles: $a = \{a_1, a_0\}$, $b = \{b_1, b_0\}$.
- Four `vedic_4x4` instances generate partial products $P_0, P_1, P_2, P_3$ (each 8 bits).
- Addition tree produces a 16-bit product without truncation:
  - $\text{sum\_cross} = P_1 + P_2$ (9 bits)
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[7:4]$ (10 bits)
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[9:4]$ (9 bits)
  - Product = $\{\text{sum\_high}[7:0], \text{sum\_mid}[3:0], P_0[3:0]\}$.

### 4.4. 16×16 Vedic Multiplier (`vedic_16x16`)
- Operands are split into 8-bit bytes: $a = \{a_1, a_0\}$, $b = \{b_1, b_0\}$.
- Four `vedic_8x8` instances generate partial products $P_0, P_1, P_2, P_3$ (each 16 bits).
- Addition tree produces the full 32-bit product:
  - $\text{sum\_cross} = P_1 + P_2$ (17 bits)
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[15:8]$ (18 bits)
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[17:8]$ (17 bits)
  - Product = $\{\text{sum\_high}[15:0], \text{sum\_mid}[7:0], P_0[7:0]\}$.

---

## 5. Repository Structure

```
vedic_multiplier/
├── .gitignore
├── README.md
│
├── rtl/
│   ├── vedic_2x2.v                  # 2x2 fundamental Vedic building block
│   ├── vedic_4x4.v                  # 4x4 hierarchical Vedic multiplier
│   ├── vedic_8x8.v                  # 8x8 hierarchical Vedic multiplier
│   ├── vedic_16x16.v                # 16x16 top-level Vedic multiplier
│   └── conventional_multiplier.v    # 16-bit reference multiplier (assign product = a * b)
│
├── tb/
│   ├── vedic_16x16_tb.v             # Self-checking testbench for 16x16 Vedic Multiplier
│   └── conventional_multiplier_tb.v # Self-checking testbench for reference multiplier
│
├── simulation/
│   ├── README.md                    # Detailed simulation instructions
│   ├── run_sim.bat                  # One-click Windows compilation & simulation script
│   └── open_waveform.bat            # One-click script to open GTKWave with VCD
│
├── docs/
│   ├── architecture.md              # Detailed mathematical equations & adder bit sizing
│   ├── vivado_results.md            # Vivado synthesis guide and result logging templates
│   ├── comparison.md                # Vedic vs Conventional FPGA hardware trade-off analysis
│   └── interview_questions.md       # 22 comprehensive interview questions & answers
│
└── scripts/
    └── synth_vivado.tcl             # Automated batch synthesis script for AMD Vivado
```

---

## 6. Tools & Technologies

- **Hardware Description Language:** Verilog HDL (IEEE 1364-2001 standard)
- **Simulation Tool:** [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` v12.0+)
- **Waveform Viewer:** [GTKWave](http://gtkwave.sourceforge.net/) v3.3+
- **Synthesis Tool:** AMD Xilinx Vivado ML (Target: Artix-7 `xc7a35tcpg236-1` or equivalent)
- **Operating System:** Microsoft Windows 10/11 (PowerShell & Command Prompt)

---

## 7. Simulation & Functional Verification

### 7.1. Running with Icarus Verilog

Open PowerShell or Command Prompt inside the project root (`C:\projects\vedic_multiplier`):

```cmd
# 1. Compile RTL hierarchy and testbench
iverilog -o simulation/vedic_16x16_tb.vvp -I rtl rtl/vedic_2x2.v rtl/vedic_4x4.v rtl/vedic_8x8.v rtl/vedic_16x16.v tb/vedic_16x16_tb.v

# 2. Run simulation using vvp runtime engine
vvp simulation/vedic_16x16_tb.vvp
```

Alternatively, run the automated batch script:
```cmd
simulation\run_sim.bat
```

### 7.2. Sample Simulation Output

```text
================================================================================
   STARTING FUNCTIONAL VERIFICATION: 16-BIT VEDIC MULTIPLIER (vedic_16x16)
================================================================================

--- [Section 1] Corner Cases & Specified Test Vectors ---
A = 0, B = 0, Expected = 0, DUT = 0, PASS
A = 1, B = 1, Expected = 1, DUT = 1, PASS
A = 15, B = 10, Expected = 150, DUT = 150, PASS
A = 25, B = 20, Expected = 500, DUT = 500, PASS
A = 65535, B = 65535, Expected = 4294836225, DUT = 4294836225, PASS

--- [Section 2] Multiplication by Zero Tests ---
A = 0, B = 100, Expected = 0, DUT = 0, PASS
A = 250, B = 0, Expected = 0, DUT = 0, PASS
A = 0, B = 65535, Expected = 0, DUT = 0, PASS
A = 65535, B = 0, Expected = 0, DUT = 0, PASS

--- [Section 3] Multiplication by One Tests ---
A = 1, B = 45, Expected = 45, DUT = 45, PASS
A = 1234, B = 1, Expected = 1234, DUT = 1234, PASS
A = 1, B = 65535, Expected = 65535, DUT = 65535, PASS
A = 65535, B = 1, Expected = 65535, DUT = 65535, PASS

--- [Section 4] Powers of Two Tests ---
A = 2, B = 4, Expected = 8, DUT = 8, PASS
A = 16, B = 32, Expected = 512, DUT = 512, PASS
A = 256, B = 256, Expected = 65536, DUT = 65536, PASS
A = 1024, B = 32, Expected = 32768, DUT = 32768, PASS
A = 32768, B = 2, Expected = 65536, DUT = 65536, PASS
A = 128, B = 512, Expected = 65536, DUT = 65536, PASS

--- [Section 5] Bit-Pattern and Partition Boundary Tests ---
A = 255, B = 255, Expected = 65025, DUT = 65025, PASS
A = 65280, B = 255, Expected = 16646400, DUT = 16646400, PASS
A = 43690, B = 21845, Expected = 954408050, DUT = 954408050, PASS
A = 21845, B = 21845, Expected = 477204025, DUT = 477204025, PASS
A = 65535, B = 1, Expected = 65535, DUT = 65535, PASS

--- [Section 6] Random Stimulus Vectors (50 tests) ---
A = 13604, B = 24193, Expected = 329121572, DUT = 329121572, PASS
...
================================================================================
                         VERIFICATION SUMMARY
================================================================================
TOTAL TESTS: 74
PASSED:      74
FAILED:      0
================================================================================
>>> ALL TESTS PASSED SUCCESSFULLY! <<<
```

### 7.3. GTKWave Waveform Analysis

To view the generated waveforms:
```cmd
gtkwave simulation/vedic_16x16.vcd
```
Or run `simulation\open_waveform.bat`.

**Signals to inspect:**
- `vedic_16x16_tb/a[15:0]` — Multiplicand
- `vedic_16x16_tb/b[15:0]` — Multiplier
- `vedic_16x16_tb/product[31:0]` — 32-bit Product Output
- Internal sub-products: `u_dut/p0`, `u_dut/p1`, `u_dut/p2`, `u_dut/p3`

---

## 8. AMD Vivado Synthesis Workflow

To synthesize the design using AMD Vivado:

1. **Create an RTL Project** in Vivado targeting your FPGA (e.g., Artix-7 `xc7a35tcpg236-1`).
2. **Add RTL Source Files:** Add `vedic_2x2.v`, `vedic_4x4.v`, `vedic_8x8.v`, and `vedic_16x16.v`.
3. **Set Top Module:** Right-click `vedic_16x16` $\rightarrow$ **Set as Top**.
4. **Run Synthesis:** Click **Run Synthesis** in the Flow Navigator.
5. **Open Synthesized Design:**
   - View the schematic (**RTL Analysis** $\rightarrow$ **Schematic**).
   - Check resource utilization (**Reports** $\rightarrow$ **Report Utilization**).
   - Check timing path delay (**Reports** $\rightarrow$ **Report Timing Summary**).
   - Check power dissipation (**Reports** $\rightarrow$ **Report Power**).

For automated batch synthesis, run:
```cmd
vivado -mode batch -source scripts/synth_vivado.tcl
```

---

## 9. Synthesis Results & FPGA Metrics

> [!NOTE]
> Values below represent a template to be populated after running synthesis on your specific physical FPGA hardware. In strict compliance with engineering ethics, no synthetic or fabricated figures are included.

*Target FPGA:* AMD Artix-7 (`xc7a35tcpg236-1`)

| Metric | Vedic Multiplier (`vedic_16x16`) | Conventional Multiplier (`conventional_multiplier`) |
| :--- | :--- | :--- |
| **LUT Utilization** | *TBD (Measured in Vivado)* | *TBD (Measured in Vivado)* |
| **Dedicated DSP Slices** | **0** | *TBD (Typically 1 DSP48)* |
| **Data Path Delay ($T_{pd}$)** | *TBD ns* | *TBD ns* |
| **Max Frequency ($F_{\text{est}}$)** | *TBD MHz* | *TBD MHz* |
| **Estimated Power** | *TBD mW* | *TBD mW* |

See [docs/vivado_results.md](docs/vivado_results.md) for full instructions on reading these metrics.

---

## 10. Architectural Comparison (Vedic vs. Conventional)

Modern FPGAs contain dedicated, hardened silicon arithmetic tiles called **DSP48 slices**.
- When using `assign product = a * b;`, Vivado automatically maps the multiplication to a DSP48 block, which achieves high clock frequencies with **0 LUT consumption**.
- The hierarchical Vedic Multiplier is constructed explicitly from modular gates and adders, causing the synthesis tool to map it into **soft logic (Slice LUTs)**.
- **Why build a Vedic Multiplier?**
  1. **ASIC Implementation:** In Application-Specific Integrated Circuits (standard cell ASIC libraries), hardened DSP blocks do not exist by default. The concurrent partial product generation of Vedic math offers lower carry propagation delay than classical Ripple Carry Multipliers.
  2. **DSP-Constrained FPGA Designs:** When all DSP48 blocks are fully occupied by filters, FFTs, or AI algorithms, the Vedic architecture provides a modular, easily pipelinable soft-logic alternative.

Detailed trade-off analysis is available in [docs/comparison.md](docs/comparison.md).

---

## 11. Future Improvements

1. **Pipelining:** Insert pipeline registers between the $4 \times 4$, $8 \times 8$, and $16 \times 16$ stages to break long combinational paths and achieve higher clock frequencies.
2. **Carry-Save Addition (CSA):** Implement Carry-Save Adders (CSA) to sum partial products without intermediate carry propagation delays until the final stage.
3. **Signed Arithmetic Support:** Adapt the architecture using 2's complement or Baugh-Wooley algorithms to support signed integer multiplication.

---

## 12. Interview Preparation

Comprehensive technical interview questions and beginner-friendly answers are documented in:
📄 **[docs/interview_questions.md](docs/interview_questions.md)**

Covers:
- Urdhva Tiryagbhyam mathematical derivation
- Port sizing and arithmetic overflow prevention
- Simulation vs. Synthesis fundamentals
- Self-checking testbench methodology
- FPGA architecture (LUTs, DSP48, CARRY chains, Critical path delay)

---

## 13. Resume Description

### Project Title
**Design and Functional Verification of a 16-bit Vedic Multiplier Using Verilog HDL**

### 2-Line Resume Description
Designed and functionally verified a modular 16-bit unsigned Vedic Multiplier in Verilog HDL utilizing the Urdhva Tiryagbhyam sutra without behavioral operators. Implemented a 4-level hierarchy ($2 \times 2$ to $16 \times 16$) and validated correctness via a self-checking testbench with 100% test pass rate in Icarus Verilog and GTKWave.

### Tools & Technologies
- **Languages:** Verilog HDL (IEEE 1364-2001)
- **EDA & Simulation Tools:** Icarus Verilog, GTKWave, AMD Vivado Design Suite
- **Methodologies:** RTL Design, Hierarchical Modeling, Functional Verification, Self-Checking Testbenches

### 3 Strong Resume Bullet Points
- **Designed a synthesizable 16-bit unsigned Vedic Multiplier in Verilog HDL** implementing the Urdhva Tiryagbhyam algorithm across a 4-level hierarchy ($2 \times 2 \rightarrow 4 \times 4 \rightarrow 8 \times 8 \rightarrow 16 \times 16$) with zero behavioral multiplication operators.
- **Developed a comprehensive self-checking testbench** with 70+ test vectors covering corner cases ($0 \times 0$, $65535 \times 65535$), powers of two, and pseudo-random inputs, achieving a 100% pass rate in Icarus Verilog and analyzing timing waveforms in GTKWave.
- **Prepared synthesis workflows for AMD Vivado (Artix-7)** and engineered a reference conventional multiplier baseline to evaluate trade-offs between soft LUT logic and hardened DSP48 slice inference.
