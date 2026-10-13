# Architectural Specification: 16-bit Hierarchical Vedic Multiplier

## 1. Introduction

The **Vedic Multiplier** is based on ancient Indian Vedic mathematics, specifically the **Urdhva Tiryagbhyam** (Vertical and Crosswise) sutra. This algorithm enables concurrent generation of partial products and parallel addition steps, reducing carry-propagation bottlenecks compared to traditional serial array multipliers.

In this project, the multiplier is designed **hierarchically**:
```
vedic_16x16
    └── vedic_8x8
            └── vedic_4x4
                    └── vedic_2x2
```
Crucially, **no behavioral multiplication operator (`*`)** is used in the RTL datapath. The architecture relies purely on concurrent gate-level operations and structured hierarchical additions.

---

## 2. Fundamental Building Block: 2×2 Vedic Multiplier (`vedic_2x2`)

Let the two 2-bit unsigned inputs be:
- $A = [a_1, a_0]$
- $B = [b_1, b_0]$

The 4-bit product $P = [p_3, p_2, p_1, p_0]$ is computed in three concurrent steps:

```
      a1   a0
   x  b1   b0
   -----------
```

### Mathematical Steps:
1. **Vertical Multiplication (LSB):**
   $$p_0 = a_0 \cdot b_0$$
2. **Crosswise Multiplication (Middle Bits):**
   $$w_{10} = a_1 \cdot b_0$$
   $$w_{01} = a_0 \cdot b_1$$
   $$\text{Sum}_1 = w_{10} \oplus w_{01} \implies p_1 = \text{Sum}_1$$
   $$\text{Carry}_1 = w_{10} \cdot w_{01}$$
3. **Vertical Multiplication (MSBs + Carry):**
   $$w_{11} = a_1 \cdot b_1$$
   $$\text{Sum}_2 = w_{11} \oplus \text{Carry}_1 \implies p_2 = \text{Sum}_2$$
   $$\text{Carry}_2 = w_{11} \cdot \text{Carry}_1 \implies p_3 = \text{Carry}_2$$

### Gate-Level Hardware Structure:
- **AND Gates:** 4 (for generating bit products $a_0 b_0, a_1 b_0, a_0 b_1, a_1 b_1$)
- **Half Adders (HA):** 2
  - $HA_1$: Adds $(a_1 b_0)$ and $(a_0 b_1) \rightarrow$ Produces $p_1$ and $\text{Carry}_1$.
  - $HA_2$: Adds $(a_1 b_1)$ and $\text{Carry}_1 \rightarrow$ Produces $p_2$ and $p_3$.

```
               a0 ----+---------+
                      |         |
               b0 ----|--+      |
                      |  |      |
                    [AND]       |
                      |         |
                     p[0]       |
                                |
               a1 ------+       |
                        |       |
               b0 ------|--+    |
                        |  |    |
                      [AND]     |
                        |       |
               a0 ------|-------+
                        |       |
               b1 ------|--+    |
                        |  |    |
                      [AND]     |
                        |       |
                     [ HA1 ] ---+---- (Carry1)
                        |                |
                       p[1]              |
                                         |
               a1 ---------------+       |
                                 |       |
               b1 -------------+-|       |
                               | |       |
                             [AND]       |
                               |         |
                             [   HA2   ]
                              |       |
                             p[2]    p[3]
```

---

## 3. Generalized $2N \times 2N$ Hierarchical Composition

Any $2N \times 2N$ Vedic multiplier can be constructed using **four $N \times N$ Vedic multipliers** and an addition network.

Let operands $A$ and $B$ be divided into upper ($A_1, B_1$) and lower ($A_0, B_0$) halves of $N$ bits each:
$$A = A_1 \cdot 2^N + A_0$$
$$B = B_1 \cdot 2^N + B_0$$

The product is:
$$A \times B = (A_1 \cdot 2^N + A_0) \times (B_1 \cdot 2^N + B_0)$$
$$A \times B = (A_0 B_0) + (A_1 B_0 + A_0 B_1) \cdot 2^N + (A_1 B_1) \cdot 2^{2N}$$

We define four $2N$-bit partial products from four identical $N \times N$ sub-blocks:
- $P_0 = A_0 \times B_0$ (Weight $2^0$)
- $P_1 = A_1 \times B_0$ (Weight $2^N$)
- $P_2 = A_0 \times B_1$ (Weight $2^N$)
- $P_3 = A_1 \times B_1$ (Weight $2^{2N}$)

### Overlap Alignment & Addition Strategy:
```
Bit Position:     [4N-1  :  2N]     [2N-1  :  N]     [N-1  :  0]
                  ----------------------------------------------
P0 (weight 2^0):                     P0[2N-1:N]       P0[N-1:0]
P1 (weight 2^N):                     P1[2N-1:0]
P2 (weight 2^N):                     P2[2N-1:0]
P3 (weight 2^2N):  P3[2N-1:0]
                  ----------------------------------------------
Product:           Product[4N-1:2N]  Product[2N-1:N]  Product[N-1:0]
```

To prevent overflow or bit loss, addition is carried out in three stages:

1. **Stage 1 (Cross-Term Addition):**
   $$\text{sum\_cross} = P_1 + P_2$$
   - Width: $(2N + 1)$ bits.
2. **Stage 2 (Middle Addition with Carry-in from $P_0$):**
   $$\text{sum\_mid} = \text{sum\_cross} + P_0[2N-1 : N]$$
   - Width: $(2N + 2)$ bits.
   - Lowest $N$ bits form the product: $\text{Product}[2N-1 : N] = \text{sum\_mid}[N-1 : 0]$.
3. **Stage 3 (High-Term Addition):**
   $$\text{sum\_high} = P_3 + \text{sum\_mid}[\text{MSB} : N]$$
   - Highest $2N$ bits of the product: $\text{Product}[4N-1 : 2N] = \text{sum\_high}[2N-1 : 0]$.

---

## 4. Hierarchy Breakdown

### 4.1. 4×4 Vedic Multiplier (`vedic_4x4`)
- **Inputs:** $a[3:0], b[3:0]$ ($N=2$)
- **Output:** $\text{product}[7:0]$
- **Sub-blocks:** Four `vedic_2x2` instances ($P_0, P_1, P_2, P_3$, each 4 bits).
- **Adder Bit Sizing:**
  - $\text{sum\_cross} = P_1 + P_2 \rightarrow$ 5 bits (Max: $9 + 9 = 18$).
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[3:2] \rightarrow$ 6 bits (Max: $18 + 2 = 20$).
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[5:2] \rightarrow$ 5 bits (Max: $9 + 5 = 14$).
  - $\text{product} = \{\text{sum\_high}[3:0], \text{sum\_mid}[1:0], P_0[1:0]\}$.

### 4.2. 8×8 Vedic Multiplier (`vedic_8x8`)
- **Inputs:** $a[7:0], b[7:0]$ ($N=4$)
- **Output:** $\text{product}[15:0]$
- **Sub-blocks:** Four `vedic_4x4` instances ($P_0, P_1, P_2, P_3$, each 8 bits).
- **Adder Bit Sizing:**
  - $\text{sum\_cross} = P_1 + P_2 \rightarrow$ 9 bits (Max: $225 + 225 = 450$).
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[7:4] \rightarrow$ 10 bits (Max: $450 + 14 = 464$).
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[9:4] \rightarrow$ 9 bits (Max: $225 + 29 = 254$).
  - $\text{product} = \{\text{sum\_high}[7:0], \text{sum\_mid}[3:0], P_0[3:0]\}$.

### 4.3. 16×16 Vedic Multiplier (`vedic_16x16`)
- **Inputs:** $a[15:0], b[15:0]$ ($N=8$)
- **Output:** $\text{product}[31:0]$
- **Sub-blocks:** Four `vedic_8x8` instances ($P_0, P_1, P_2, P_3$, each 16 bits).
- **Adder Bit Sizing:**
  - $\text{sum\_cross} = P_1 + P_2 \rightarrow$ 17 bits (Max: $65025 + 65025 = 130050$).
  - $\text{sum\_mid} = \text{sum\_cross} + P_0[15:8] \rightarrow$ 18 bits (Max: $130050 + 254 = 130304$).
  - $\text{sum\_high} = P_3 + \text{sum\_mid}[17:8] \rightarrow$ 17 bits (Max: $65025 + 509 = 65534$).
  - $\text{product} = \{\text{sum\_high}[15:0], \text{sum\_mid}[7:0], P_0[7:0]\}$.

---

## 5. Hardware Complexity Hierarchy Summary

| Multiplier Module | Sub-blocks Used | Sub-block Count | Intermediate Adders | Output Width |
| :--- | :--- | :--- | :--- | :--- |
| `vedic_2x2` | Logic gates (AND, XOR) | 4 AND, 2 XOR | 2 Half Adders | 4 bits |
| `vedic_4x4` | `vedic_2x2` | 4 | 4-bit, 5-bit, 4-bit | 8 bits |
| `vedic_8x8` | `vedic_4x4` | 4 | 8-bit, 9-bit, 8-bit | 16 bits |
| `vedic_16x16` | `vedic_8x8` | 4 | 16-bit, 17-bit, 16-bit | 32 bits |

This regular and modular structure simplifies layout, reduces interconnect congestion, and provides a clear conceptual bridge for VLSI design interviews.
