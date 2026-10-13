# AMD Vivado Synthesis Guide and Results Log

This document provides a complete step-by-step workflow for synthesizing the **16-bit Vedic Multiplier** (`vedic_16x16`) in **AMD Vivado Design Suite** (e.g., Vivado ML / 2020.x–2024.x).

> [!NOTE]
> In accordance with rigorous VLSI engineering practices, this document contains **no fabricated or simulated synthesis numbers**. All metric fields are marked as **TBD** for you to populate after executing synthesis on your specific target FPGA device (e.g., Xilinx Artix-7 `xc7a35tcpg236-1` / Basys-3, or Kintex-7).

---

## 1. Step-by-Step Vivado GUI Synthesis Workflow

### Step 1: Create a New Vivado RTL Project
1. Launch **Vivado**.
2. Click **Create Project** $\rightarrow$ Click **Next**.
3. **Project Name:** `vedic_multiplier_vivado`
   - **Project Location:** Select a local directory (e.g., `C:/projects/vedic_multiplier/vivado_project`).
4. Select **RTL Project** and leave *"Do not specify sources at this time"* unchecked $\rightarrow$ Click **Next**.

### Step 2: Add RTL Source Files
1. In the **Add Sources** dialog:
   - Click **Add Files** and select all Verilog RTL files from `rtl/`:
     - `rtl/vedic_2x2.v`
     - `rtl/vedic_4x4.v`
     - `rtl/vedic_8x8.v`
     - `rtl/vedic_16x16.v`
2. Ensure **Target language** is set to **Verilog** and **Simulator language** is set to **Mixed**.
3. Click **Next**.

### Step 3: Select Target FPGA Part / Board
1. Select your target device:
   - *Example Entry FPGA:* **Artix-7** $\rightarrow$ Part: `xc7a35tcpg236-1` (Basys 3 board) or `xc7a100tcsg324-1` (Nexys A7).
2. Click **Next** $\rightarrow$ Click **Finish**.

### Step 4: Set Top Module
1. In the Vivado **Sources** pane (`Hierarchy` tab):
2. Expand Design Sources.
3. Right-click on `vedic_16x16` and select **Set as Top**.

### Step 5: Run RTL Elaboration & Inspect Schematic
1. In the Flow Navigator (left pane), expand **RTL Analysis** $\rightarrow$ Click **Open Elaborated Design**.
2. Click **Schematic** to view the elaborated gate/block diagram.
3. Verify that Vivado displays four `vedic_8x8` instances connected to the intermediate addition buses.

### Step 6: Run Synthesis
1. In the Flow Navigator, under **Synthesis**, click **Run Synthesis**.
2. Choose your preferred number of CPU jobs $\rightarrow$ Click **OK**.
3. Wait for synthesis to complete.
4. When the *Synthesis Completed* dialog appears, select **Open Synthesized Design** $\rightarrow$ Click **OK**.

---

## 2. Extracting Hardware Metrics in Vivado

### A. Resource Utilization (LUTs, FFs, I/O)
1. In the Synthesized Design toolbar, click **Report Utilization** (or go to `Reports` $\rightarrow$ `Report Utilization`).
2. Click **OK**.
3. The Utilization tab at the bottom will display:
   - **Slice LUTs** (Lookup Tables)
   - **LUT as Logic**
   - **Bonded IOB** (Input/Output Buffers)
   - **DSP48 Slices** (Should be **0** for pure LUT-based Vedic Multiplier)

### B. Timing & Critical Path Delay
1. Since the multiplier is purely combinational, to measure path delay:
   - Run: `report_timing -delay_type max -nworst 1 -path_type full -name max_delay` in the Vivado Tcl Console.
2. Note the **Data Path Delay** (in nanoseconds) from input `a`/`b` to output `product`.
3. Estimated maximum throughput / combinatorial frequency:
   $$F_{\text{est}} \approx \frac{1}{\text{Data Path Delay}}$$

### C. Estimated Power Analysis
1. In Flow Navigator under Synthesized Design, click **Report Power** (`Reports` $\rightarrow$ `Report Power`).
2. Click **OK**.
3. Read:
   - **Total On-Chip Power (W or mW)**
   - **Dynamic Power (mW)**
   - **Device Static Power (mW)**

---

## 3. Vivado Synthesis Results Log (Template to Fill In)

*Target Device:* `Xilinx Artix-7 (xc7a35tcpg236-1)` *(or enter your specific FPGA part)*  
*Vivado Version:* `AMD Vivado 20xx.x`  
*Synthesis Strategy:* `Vivado Synthesis Defaults`  

### Table 1: Area & Hardware Resource Utilization

| Resource | Available on Device | Used by `vedic_16x16` | Utilization (%) |
| :--- | :--- | :--- | :--- |
| **LUTs (Look-Up Tables)** | *TBD (e.g., 20800)* | **TBD** | **TBD %** |
| **Slice Registers (FFs)** | *TBD (e.g., 41600)* | **TBD (0 for pure combinational)** | **TBD %** |
| **DSP48 Slices** | *TBD (e.g., 90)* | **TBD (Expected: 0)** | **TBD %** |
| **Bonded IOBs** | *TBD (e.g., 106)* | **TBD (64: 32 in, 32 out)** | **TBD %** |

---

### Table 2: Timing & Performance Metrics

| Metric | Target Constraint | Measured Vivado Value |
| :--- | :--- | :--- |
| **Worst Data Path Delay ($T_{pd}$)** | N/A (Combinational) | **TBD ns** |
| **Estimated Max Combinational Rate ($1/T_{pd}$)** | N/A | **TBD MHz** |
| **Worst Negative Slack (WNS)** *(if clocked)* | N/A | **TBD** |

---

### Table 3: Estimated Power Consumption

| Power Category | Estimated Value |
| :--- | :--- |
| **Total On-Chip Power** | **TBD mW** |
| **Dynamic Power** | **TBD mW** |
| **Static / Quiescent Power** | **TBD mW** |
| **Junction Temperature** | **TBD °C** |

---

## 4. Automated Synthesis via Vivado TCL Script

For quick headless synthesis without clicking through the GUI, use the provided TCL script `scripts/synth_vivado.tcl`:

```cmd
vivado -mode batch -source scripts/synth_vivado.tcl
```

This will automatically generate:
- `vivado_synth_vedic_utilization.rpt`
- `vivado_synth_vedic_timing.rpt`
- `vivado_synth_vedic_power.rpt`
