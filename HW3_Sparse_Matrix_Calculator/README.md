# Sparse Matrix-Vector Multiplication (SpMV)
**Hardware-accelerated sparse matrix calculator with pipelined multiply-accumulate architecture**

## System Overview
Specialized circuit for computing sparse matrix-vector multiplication (32×32 matrix × 32×1 vector). Exploits sparsity by processing only nonzero elements, eliminating redundant operations on zero values. Designed for neural network inference applications where weight pruning creates sparse weight matrices.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 122,055.6 μm²
- **Clock Period**: 8.0ns (met timing constraints)
- **Max Latency**: <5000 cycles per pattern
- **Output Format**: Variable-length sparse output (nonzero elements only)

### Verification Status
- **RTL Simulation**: Passed  
- **Synthesis**: Timing MET, latch-free  
- **Gate-Level Simulation**: Passed  

## Implementation Features
- **2-State FSM**: IDLE → PROCESS (unified computation/output state)
- **Pipelined MAC**: Separate multiplication and accumulation stages to reduce critical path
- **Zero-Skipping**: Conditional computation only when both matrix element and vector element are nonzero
- **Dynamic Sparsity Tracking**: Real-time counter for nonzero output elements

## Technical Specifications
### Matrix-Vector Operation
**Equation**: `O[i] = Σ(M[i][j] × V[j])` for j = 0 to 31

**Input Format**:
- **Vector**: Sparse format with row indices (ascending order)
- **Matrix**: Sparse format with (row, col) indices (raster-scan order)
- **Element Width**: 8-bit unsigned integers

**Output Format**:
- **Sparse Output**: Only nonzero results with row indices
- **Element Width**: 21-bit unsigned integers (accommodates accumulated products)
- **Completion Signal**: `out_finish` asserted on final output cycle

### FSM State Transitions
**IDLE**: Reset internal registers (invector[32][8], outvector[32][21], count[6])  
**PROCESS**: Unified state for:
- Input vector storage (during `in_valid`)
- Matrix processing with MAC operations (during `weight_valid`)
- Sequential nonzero output scanning (after `weight_valid` deasserts)

## Design Methodology
**Critical Path Reduction**: Separated 8×8 multiplication and 21-bit accumulation into different clock cycles using a flag register. Multiplier computes `product = invector[in_col] × in_data` in one cycle, then accumulator adds `product` to `outvector[in_row]` in the next cycle.

**Sparse Output Scanning**: Implemented for-loop based sequential scanner that iterates through all 32 output indices per cycle to locate next nonzero element. After outputting each element, sets that position to zero to prevent duplicate outputs while maintaining row ordering.

**Nonzero Tracking**: Maintained 6-bit counter incremented whenever a previously-zero output position receives its first nonzero product. This count determines when all outputs have been emitted, avoiding unnecessary scanning cycles.

**Register Organization**: Stored entire input vector (32×8 bits) and output accumulator (32×21 bits) in register arrays for parallel random access during matrix multiplication phase. Trade-off: higher area for lower latency versus sequential memory with area savings.

## Algorithm Highlights
- **Conditional MAC**: Zero-checking both operands before multiplication prevents wasted computation
- **In-Place Accumulation**: Direct accumulation into output vector eliminates intermediate buffer
- **Sequential Output**: Linear scan from index 0→31 guarantees ordered sparse output
- **Area vs. Latency Trade-off**: Full register storage enables single-cycle MAC operations but consumes significant area

## Design Challenges
Balancing area optimization against latency requirements proved difficult. Initial attempts at memory reduction through sequential storage increased critical path unacceptably. The final approach prioritized meeting timing constraints while accepting higher area cost.

*Sparse computation engine demonstrating datapath pipelining and sparsity exploitation for neural network acceleration*