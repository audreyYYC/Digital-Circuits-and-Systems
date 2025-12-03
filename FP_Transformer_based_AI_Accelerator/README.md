# Transformer-Based AI Accelerator
**Hardware accelerator for simplified transformer attention mechanism with custom activation functions and external memory interface**

## System Overview
Specialized AI accelerator implementing simplified transformer attention computation with custom "Tom & Jerry" activation functions (RAT, CAT, SLT). Features external memory interface for weight and input storage, output-stationary dataflow optimization, and pipelined matrix multiplication units. Processes variable-length token sequences (4-32 tokens) through Q/K/V projection, attention score computation, and weighted value aggregation.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 1,526,588.098 μm²
- **Clock Period**: 4.6ns
- **Pipeline Depth**: 2-3 stages for critical operations
- **Max Latency**: <10,000 cycles per pattern
- **Supported Sequence Lengths**: 4, 8, 16, 32 tokens

### Verification Status
- **RTL Simulation**: Passed  
- **Synthesis**: Timing MET, latch-free  
- **Gate-Level Simulation**: Passed (no timing violations)

### Performance Formula
`(3 × Latency_mem + Latency_exe) × Area^1.5`

## Implementation Features
- **14-State FSM**: Complex state machine coordinating dataflow and memory access
- **Pipelined Multiplication**: Multi-stage pipelines with operand decomposition (6-bit chunks)
- **Custom Activation Functions**: RAT (row threshold), CAT (column threshold), SLT (token selection)
- **External Memory Interface**: Handshake protocol with virtual ROM (48 total memory accesses)
- **Resource Sharing**: Q/V register reuse reduces area by ~42,000 μm²
- **Selective Computation**: SLT integrated into attention score calculation—only compute last row

## Technical Specifications
### Transformer Architecture

**Computation Flow**:
```
i_token (L×8) → RAT → i_token' → [Q/K/V Projections] → Q × K^T → CAT + SLT → scores × V → o_token (1×8)
```

**Matrix Dimensions**:
- **Input**: L×8 where L ∈ {4, 8, 16, 32}
- **Weights**: WQ, WK, WV each 8×8 (column-major storage)
- **Output**: 1×8 final token vector

### Custom Activation Functions

| Function | Operation | Purpose |
|----------|-----------|---------|
| **RAT** | Row-wise threshold: keep values ≥ row_average | Input sparsification |
| **CAT** | Column-wise threshold: keep values ≥ column_average | Attention filtering |
| **SLT** | Select last token: return final row only | Output selection |

**RAT Implementation**:
- Compute row average: `row_avg = (sum of row elements) / 8`
- Apply threshold: `output = (element ≥ row_avg) ? element : 0`

### Memory Configuration

**Virtual ROM Data Packing** (32-bit words contain 8×4-bit values):

| Bit Range | [31:28] | [27:24] | [23:20] | [19:16] | [15:12] | [11:8] | [7:4] | [3:0] |
|-----------|---------|---------|---------|---------|---------|--------|-------|-------|
| **Element** | d7 | d6 | d5 | d4 | d3 | d2 | d1 | d0 |

**Memory Layout**:

| Address Range | Content | Format |
|---------------|---------|--------|
| 0 - (L-1) | Input tokens `i_token` | Row-major |
| L - (L+7) | Weight matrix WQ | Column-major |
| (L+8) - (L+15) | Weight matrix WK | Column-major |
| (L+16) - (L+23) | Weight matrix WV | Column-major |

**Memory Protocol**: Assert `m_read` + `m_addr` (6-bit) → receive `m_data` (32-bit packed)

### FSM State Overview

| State Group | Function | Key Operations |
|-------------|----------|----------------|
| **IDLE, WAIT_M_READY** | Initialization | Decode `i_length`, wait for V-ROM ready |
| **READ_INPUT_RAT** | Input processing | Load tokens with RAT activation (pipelined) |
| **MM_Q1, MM_Q2** | Q projection | Column-by-column WQ fetch, 4-row parallel multiply |
| **MM_K1/K2/K3** | K projection | Same as Q with 3-stage pipeline |
| **MM_V1/V2** | V projection | Reuse Q registers for V storage |
| **MM_T1, MM_T2** | Attention scores | Q×K^T with CAT+SLT (only last row computed) |
| **MM_S1** | Output computation | scores×V with multi-stage accumulation |
| **OUT** | Output streaming | 8-cycle output of final token |

## Design Methodology

### Pipelined Matrix Multiplication

**Three-Tier Operand Decomposition**:

| Operation | Operand Size | Decomposition | Pipeline Stages |
|-----------|--------------|---------------|-----------------|
| Input × Weight | 4-bit × 4-bit | None (direct multiply) | 1 cycle |
| Q × K^T | 11-bit × 11-bit | Split to 2×6-bit | 2 cycles |
| scores × V | 24-bit × 12-bit | Split to 4×6-bit + 2×6-bit | 3 cycles |

**Q×K^T Pipeline Example**:
- **Stage 1**: Split 11-bit elements into two 6-bit parts, compute 4 partial products per element pair
- **Stage 2**: Accumulate partial products, apply CAT threshold, store only last row (SLT integration)

### Memory Access Optimization

**Column-by-Column Weight Fetch**: Instead of loading full 8×8 weight matrix (64 elements), fetch one column at a time (8 elements). Reduces on-chip weight storage from 192 to 24 elements (87.5% reduction).

**Overlapped Read-Compute**: During RAT processing, read row N+1 while processing row N, halving input phase latency.

**Selective Attention Computation**: Rather than computing full L×L attention matrix, directly compute only last row during Q×K^T. Eliminates storage of L²-L intermediate values.

### Resource Sharing

**Q/V Register Reuse**: After attention score computation completes, repurpose Q matrix registers (64 elements) for V matrix storage. Saves ~42,000 μm² area.

**Pointer Consolidation**: Single `ptr` register tracks progress across multiple FSM states (MM_Q2, MM_K2, MM_V2, MM_S1).

### Critical Path Management

**4.6ns timing achieved through**:
- 6×6-bit multipliers (instead of 24×12)
- Multi-stage accumulation trees
- Register-balanced pipeline stages
- Achieved 15% timing slack at synthesis

## Design Challenges

### System Complexity
14-state FSM with concurrent memory access, pipeline control, and activation functions. Initial debugging overwhelming with ~2000 lines of SystemVerilog.

**Solution**: Modular verification—validated each FSM state independently before integration. Extensive waveform debugging to trace data through pipelines.

### Multiplication Critical Path
Direct 11×11-bit multiplication exceeded 4.6ns budget. Initial synthesis failed timing by 40%.

**Solution**: Operand decomposition into 6-bit chunks distributed across 2-3 pipeline stages. Reduced critical path to 6×6 multiplier + accumulator chain.

### Memory Bandwidth vs. Area
V-ROM provides only 8 elements per cycle. For L=32, need 32 cycles just for input loading.

**Solution**: 
- Pipelined read-compute overlap for RAT
- Column-by-column weight access matches computational dataflow
- Integrated SLT to avoid storing full attention matrix

### Area Optimization
Initial design: >2M μm² with full intermediate matrix storage.

**Solution**:
- Q/V register sharing: -42K μm²
- Column-wise weight fetch: -87.5% weight storage
- Selective computation: eliminated L²-L score storage
- **Final area**: 1,526,588 μm² (24% reduction)

## Performance Analysis

**Typical Latency (L=32)**:
- Input RAT: ~32 cycles (pipelined)
- Q/K/V Projections: ~480 cycles (column-by-column)
- Attention + Output: ~450 cycles (3-stage pipeline)
- **Total**: ~1000 cycles @ 4.6ns = 4.6μs

**Memory Efficiency**: 
- Memory reads: 48 words (4.8% of execution time)
- Computation: 95.2% of execution time

*Production-ready transformer attention accelerator demonstrating external memory interfacing, custom activation functions, and pipeline optimization for AI inference*