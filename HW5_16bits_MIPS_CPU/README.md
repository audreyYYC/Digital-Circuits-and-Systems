# Simple CPU with Fixed-Point Arithmetic
**4-stage pipelined RISC processor supporting integer and neural network activation operations**

## System Overview
Pipelined CPU implementing custom instruction set with R-type and I-type instructions. Supports basic arithmetic (add, multiply), bit shifting, and neural network activation functions (ReLU, Leaky ReLU) using 16-bit signed fixed-point representation (Q0.15 format). Features aggressive multiplication optimization through operand decomposition across pipeline stages.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 82,122.16 μm²
- **Clock Period**: 2.6ns (aggressive timing optimization)
- **Pipeline Depth**: 4 stages
- **Latency**: 4-10 cycles per instruction
- **Register File**: 6 × 16-bit registers

### Verification Status
- **RTL Simulation**: Passed  
- **Synthesis**: Timing MET, latch-free  
- **Gate-Level Simulation**: Passed (no timing violations)

## Implementation Features
- **4-Stage Pipeline**: IF/ID → EXE1 → EXE2 → WB
- **Distributed Multiplication**: 16×16 decomposed into sixteen 4×4 operations
- **Fixed-Point Arithmetic**: Q0.15 format (1 sign bit + 15 fractional bits)
- **Neural Network Support**: Hardware ReLU and Leaky ReLU activation functions
- **Continuous Output**: Streaming register file values every cycle

## Technical Specifications
### Instruction Set Architecture

**R-Type Format**: `opcode(6) | rs(5) | rt(5) | rd(5) | shamt(5) | funct(6)`

| Instruction | Opcode | Funct  | Operation | Description |
|-------------|--------|--------|-----------|-------------|
| **ADD**     | 000000 | 100000 | `rd = rs + rt` | Signed addition |
| **MULT**    | 000000 | 011000 | `rd = (rs × rt) >>> 15` | Fixed-point multiplication with normalization |
| **SLL**     | 000000 | 000000 | `rd = rt << shamt` | Logical left shift |
| **SRL**     | 000000 | 000010 | `rd = rt >> shamt` | Logical right shift |
| **ReLU**    | 000000 | 110001 | `rd = max(0, rt)` | Rectified Linear Unit activation |
| **Leaky ReLU** | 000000 | 110010 | `rd = (rt ≥ 0) ? rt : (rs × rt) >>> 15` | Leaky ReLU with programmable negative slope |

**I-Type Format**: `opcode(6) | rs(5) | rt(5) | immediate(16)`

| Instruction | Opcode | Operation | Description |
|-------------|--------|-----------|-------------|
| **ADDI**    | 001000 | `rt = rs + immediate` | Add immediate (sign-extended) |

**Invalid Opcode Handling**: Any opcode not listed above triggers `instruction_fail = 1` and preserves current register values.

### Register File Architecture

| Address (5-bit) | Output Signal | Initial Value |
|-----------------|---------------|---------------|
| `10001` | `out_0[15:0]` | 0x0000 |
| `10010` | `out_1[15:0]` | 0x0000 |
| `01000` | `out_2[15:0]` | 0x0000 |
| `10111` | `out_3[15:0]` | 0x0000 |
| `11111` | `out_4[15:0]` | 0x0000 |
| `10000` | `out_5[15:0]` | 0x0000 |

### Data Format
- **Fixed-Point Q0.15**: 1 sign bit + 15 fractional bits
- **Multiplication Result**: Upper 15 bits retained after sign (arithmetic right shift 15)
- **Value Range**: [-1.0, +0.999969482421875] in decimal representation

### Pipeline Stages

| Stage | Name | Operations | Cycle |
|-------|------|------------|-------|
| **Stage 1** | IF/ID | Instruction fetch, decode, register read, opcode validation | 1 |
| **Stage 2** | EXE1 | ADD, shifts, ReLU execution; Multiplication: compute sixteen 4×4 sub-products | 2 |
| **Stage 3** | EXE2 | Pass-through; Multiplication: aggregate and shift sub-products into 7 partial sums | 3 |
| **Stage 4** | WB | Write-back; Multiplication: final accumulation and >>>15 normalization | 4 |

**Stage 1 - Instruction Fetch & Decode**:
- Decode 32-bit instruction into opcode, rs, rt, rd, shamt, immediate
- Fetch register values directly from output signals (`out_0`-`out_5`)
- Classify operation type and detect invalid opcodes
- Set `instruction_fail` flag for unsupported opcodes

**Stage 2 - Execute 1 (EXE1)**:
- Execute ADD, bit shifts, ReLU operations
- **Multiplication Step 1**: Decompose operands into 4-bit chunks
  - Compute sixteen 4×4 sub-products (`out_m[0:15]`)
- Pass operation type and intermediate results to next stage

**Stage 3 - Execute 2 (EXE2)**:
- Pass-through for non-multiplication operations
- **Multiplication Step 2**: Aggregate sub-products by shift alignment
  - Combine and shift sub-products into partial sums (`wb_0`-`wb_6`)

**Stage 4 - Write Back (WB)**:
- **Multiplication Step 3**: Final accumulation and arithmetic right shift (>>>15)
- Update destination register in register file
- Output all 6 register values every cycle

## Design Methodology
**Multiplication Decomposition**: Critical path bottleneck from 16×16 multiplication eliminated through operand decomposition. Each 16-bit operand split into four 4-bit chunks, generating sixteen 4×4 multiplications (8-bit products). These sub-products distributed across three pipeline stages:

| Pipeline Stage | Multiplication Work | Description |
|----------------|---------------------|-------------|
| EXE1 (Stage 2) | Compute 4×4 products | Generate sixteen 8-bit sub-products from operand chunks |
| EXE2 (Stage 3) | Group & shift | Align sub-products by bit position, combine into 7 partial sums |
| WB (Stage 4) | Final accumulation | Sum partial results and normalize via >>>15 |

This approach reduced cycle time from 10ns to 2.6ns (74% improvement).

**Register File Organization**: Direct mapping from instruction bit fields to register file addresses enables single-cycle register access in decode stage. All six registers continuously output via `out_0`-`out_5` signals, eliminating need for read port arbitration or multiplexing delays.

**Fixed-Point Arithmetic**: Q0.15 format represents fractional values in range [-1, 1) with 15-bit precision. After multiplication, only upper 15 bits (plus sign) retained via arithmetic right shift by 15, maintaining fixed-point alignment. Leaky ReLU leverages same multiplication hardware for negative slope computation.

**Instruction Validation**: Invalid opcodes detected in decode stage by comparing against supported instruction table. `instruction_fail` flag propagates through pipeline, causing write-back stage to preserve existing register values rather than updating with erroneous results.

**Pipeline Hazard Avoidance**: Test patterns guarantee no read-after-write (RAW) dependencies within 4-instruction windows, eliminating need for forwarding logic or stall mechanisms. This simplifies control logic significantly while maintaining correctness.

## Design Challenges
Primary challenge involved critical path dominated by 16×16 multiplication. Initial single-cycle multiplication design couldn't meet timing even at 10ns cycle period. Solution required algorithmic restructuring: decomposing multiplication into smaller operations distributable across pipeline stages.

The decomposition strategy splits each 16-bit signed operand into four 4-bit chunks. With two operands, this generates 4×4=16 partial products. However, these products require careful alignment and sign extension handling:
- Products from high-order chunks need left-shifting before accumulation
- Sign bit handling requires proper extension of partial products
- Three-stage accumulation (compute → group → sum) balances work across pipeline

Additional complexity from Leaky ReLU operation requiring conditional multiplication in EXE1. Implemented `shift` flag to indicate when stages 2-3 should perform multiplication accumulation versus passing through pre-computed results from other operations.

## Performance Optimization Results

| Metric | Initial Design | Optimized Design | Improvement |
|--------|---------------|------------------|-------------|
| **Cycle Time** | 10.0ns | 2.6ns | 74% reduction |
| **Critical Path** | 16×16 multiplier | 4×4 multiplier + adder | Distributed across stages |
| **Area** | - | 82,122.16 μm² | Balanced area/timing trade-off |
| **Performance Score** | Area × Cycles × 10² | Area × Cycles × 2.6² | ~84% improvement |

*High-performance pipelined CPU demonstrating instruction set design, fixed-point arithmetic, and critical path optimization through algorithmic decomposition*