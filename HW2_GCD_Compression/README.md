# GCD Compression
**FSM-based sequential compressor with lookup table optimization for real-time GCD computation**

## System Overview
Data compression circuit that processes 8 input numbers into 3 compressed values, then computes their Greatest Common Divisor (GCD). Implements streaming input with zero-latency processing and optimized lookup-based GCD calculation.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 6,087.312 μm²
- **Clock Period**: 7ns (met timing constraints)
- **Latency**: 0 cycles (compression completes during input phase)
- **Throughput**: 4-cycle output (3 compressed numbers + GCD)

### Verification Status
- **RTL Simulation**: Passed  
- **Synthesis**: Timing MET, latch-free  
- **Gate-Level Simulation**: Passed  

## Implementation Features
- **4-State FSM**: IDLE → RECEIVE → GCD → OUTPUT
- **Zero-Latency Compression**: Parallel accumulation during input phase
- **Lookup Table GCD**: Pre-computed case statement for single-cycle GCD calculation
- **Guaranteed Even Results**: Parity-aware accumulation ensures GCD ≥ 2

## Technical Specifications
### FSM State Transitions
**IDLE**: Reset registers, wait for `in_valid`  
**RECEIVE**: Stream 8 × 4-bit inputs, compress into 3 × 5-bit values (A, B, C)  
**GCD**: Single-cycle lookup table search for GCD(A, B, C)  
**OUTPUT**: Sequential output over 4 cycles (A → B → C → GCD)

### Input Interface
- **in_data** (4 bits): Streaming input, 8 consecutive cycles
- **in_valid** (1 bit): Data valid indicator
- **Constraint**: Values range 1-15

### Output Interface
- **out_data** (5 bits): Sequential output over 4 cycles
  - Cycles 1-3: Compressed values A, B, C
  - Cycle 4: GCD of {A, B, C}
- **out_valid** (1 bit): Output valid indicator
- **Constraint**: 4 consecutive cycles, GCD ≥ 2

## Design Methodology
**Parity-Based Compression**: Accumulates even numbers with even numbers and odd numbers with odd numbers using temporary registers (x, y). This ensures all three compressed outputs are even, guaranteeing GCD ≥ 2 without additional validation logic.

**Streaming Computation**: Compression logic operates concurrently with input phase using a 7-step counter, eliminating idle cycles between input completion and output readiness. Maximum 7 inputs needed to compute all three compressed values.

**Lookup Table Optimization**: Replaced iterative Euclidean algorithm with exhaustive case statement. Since compressed values are 5-bit even numbers, the solution space is small enough to enumerate directly, achieving single-cycle GCD computation versus multi-cycle iterative approach.

**Register Reuse**: After outputting original value A in GCD state, register A is immediately repurposed to store the computed GCD value, reducing register count without extending critical path.

*Optimized sequential compressor demonstrating FSM design and algorithmic trade-offs between area and latency*