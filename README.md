# Digital Circuits and Systems (DCS)
**Complete coursework for NYCU Digital Circuits and Systems (2025 Spring)**

Hardware design projects progressing from basic combinational circuits to a complete transformer-based AI accelerator. Covers RTL design, synthesis, timing optimization, FSM implementation, pipeline architecture, and memory interfaces using SystemVerilog.

## Repository Overview

This repository contains all coursework from NYCU's Digital Circuits and Systems course, demonstrating progression from fundamental digital logic to complex AI accelerator design.

### Course Projects

| Project | Topic | Area (μm²) | Cycle Time | Key Achievement |
|---------|-------|------------|------------|-----------------|
| [**HW1**](HW1_Simple_Data_Transfer/) | Data Transfer Router | 5,132 | 6.0ns | #1 ranked (best area optimization) |
| [**HW2**](HW2_GCD_Compression/) | GCD Compression | 6,087 | 7.0ns | Lookup table optimization |
| [**HW3**](HW3_Sparse_Matrix_Calculator/) | Sparse Matrix-Vector Multiply | 122,056 | 8.0ns | Zero-skipping MAC operations |
| [**HW4**](HW4_Matrix_Multiply_Accumulate/) | MAC Array (MatMul + Conv) | 41,520 | 10.0ns | Dual-mode accelerator |
| [**HW5**](HW5_16bits_MIPS_CPU/) | 16-bit Fixed-Point CPU | 82,122 | 2.6ns | 4-stage pipeline, Q0.15 arithmetic |
| [**Final**](FP_Transformer_based_AI_Accelerator/) | Transformer Attention Accelerator | 1,526,588 | 4.6ns | External memory interface, custom activations |

### Weekly Labs

[**Labs**](LABS/) - Ten 1-hour in-class exercises covering fundamental to advanced digital design topics (combinational logic, FSMs, FIFOs, pipelining, CDC, AXI protocol, FPGA implementation).

## Project Highlights

### HW1: Simple Data Transfer (5,132 μm²)
Combinational routing network with congestion detection and priority-based arbitration. Routes data from 4 input ports to 5 output ports with acknowledgment feedback.

**Key Features**: MUX-based architecture, conflict resolution, destination bit optimization  
**Achievement**: Ranked #1 among 150 students for area optimization

### HW2: GCD Compression (6,087 μm²)
Sequential compressor computing GCD of compressed values. FSM-based design with zero-latency input processing.

**Key Features**: 4-state FSM, lookup table GCD calculation, parity-based compression  
**Innovation**: Replaced iterative Euclidean algorithm with exhaustive case statement for single-cycle GCD

### HW3: Sparse Matrix-Vector Multiplication (122,056 μm²)
Hardware accelerator for sparse matrix operations with zero-skipping optimization.

**Key Features**: 2-state FSM, pipelined MAC, dynamic sparsity tracking  
**Application**: Neural network inference with pruned weight matrices

### HW4: MAC Array for Matrix Ops (41,520 μm²)
Dual-mode AI accelerator supporting both matrix multiplication (8×8) and 2D convolution (8×8 input, 3×3 kernel).

**Key Features**: 6-state FSM, sliding window buffer for convolution, row-based streaming output  
**Optimization**: Resource sharing between operation modes, user-controlled data fetch

### HW5: 16-bit MIPS CPU (82,122 μm², 2.6ns)
Pipelined RISC processor with fixed-point arithmetic and neural network activation instructions.

**Key Features**: 4-stage pipeline (IF/ID → EXE1 → EXE2 → WB), Q0.15 fixed-point format, ReLU/Leaky ReLU hardware  
**Optimization**: 16×16 multiplication decomposed into sixteen 4×4 operations across pipeline stages  
**Achievement**: 2.6ns cycle time (74% improvement from initial 10ns design)

### Final Project: Transformer Attention Accelerator (1,526,588 μm², 4.6ns)
Complete attention mechanism accelerator with external memory interface and custom activation functions.

**Key Features**: 
- 14-state FSM coordinating memory access and computation
- Custom "Tom & Jerry" activations (RAT, CAT, SLT) for attention score filtering
- Variable sequence length support (4, 8, 16, 32 tokens)
- Pipelined matrix multiplication with operand decomposition (6-bit chunks)
- Q/V register reuse saving ~42,000 μm²

**Optimizations**:
- Column-by-column weight fetch (87.5% storage reduction)
- Selective attention computation (only last row computed)
- Multi-stage pipelines with 6×6 multipliers for timing closure

## Technical Skills Demonstrated

### RTL Design
- SystemVerilog synthesis and simulation
- Combinational and sequential logic separation
- FSM design and state transition optimization
- Pipeline architecture and hazard handling
- Resource sharing and register reuse

### Performance Optimization
- Critical path analysis and reduction
- Pipelining for throughput improvement
- Operand decomposition for timing closure
- Memory access pattern optimization
- Area-latency tradeoff analysis

### Hardware Architectures
- MAC (Multiply-Accumulate) arrays
- Sparse matrix processing
- Fixed-point arithmetic units
- External memory interfaces
- Custom activation functions

### Verification & Synthesis
- RTL simulation and waveform debugging
- Design Compiler synthesis
- Timing analysis and optimization
- Gate-level simulation
- Area/power/performance analysis

## Development Environment

### Tools
- **Simulator**: Synopsys VCS
- **Waveform Viewer**: Verdi nWave
- **Synthesis**: Synopsys Design Compiler
- **Technology**: Standard cell library (UMC 0.18μm for labs)

### Design Flow
1. **RTL Design**: SystemVerilog implementation
2. **Functional Verification**: Testbench simulation
3. **Synthesis**: Timing/area optimization
4. **Gate-Level Verification**: Post-synthesis simulation
5. **Performance Analysis**: Area/timing reports

## Repository Structure
```
DIGITAL-CIRCUITS-AND-SYSTEMS/
├── HW1_Simple_Data_Transfer/
│   ├── DT.sv
│   └── README.md
├── HW2_GCD_Compression/
│   ├── GCD.sv
│   └── README.md
├── HW3_Sparse_Matrix_Calculator/
│   ├── SPMV.sv
│   └── README.md
├── HW4_Matrix_Multiply_Accumulate/
│   ├── MAC_10_0.sv
│   └── README.md
├── HW5_16bits_MIPS_CPU/
│   ├── CPU_2_6.sv
│   └── README.md
├── FP_Transformer_based_AI_Accelerator/
│   ├── TA_4_6.sv
│   └── README.md
├── LABS/
│   ├── Lab01_Comb.sv
│   ├── Lab02_Counter.sv
│   ├── Lab03_Seq.sv
│   ├── Lab04_Fifo.sv
│   ├── Lab05_FSM.sv
│   ├── Lab08_INF.sv
│   ├── Lab09_FIR.sv
│   ├── Lab10_CDC.sv
│   └── README.md
└── README.md
```

## Key Learnings

### Design Methodology
- **Start Simple**: Begin with basic functionality, then optimize
- **Pipeline Everything**: Most effective technique for timing improvement
- **Decompose Operations**: Break complex operations into manageable stages
- **Reuse Resources**: Share registers and logic blocks across states
- **Profile First**: Use synthesis reports to identify bottlenecks

### Common Patterns
- **FSM Design**: Clear state definitions with well-separated combinational/sequential logic
- **Memory Interface**: Handshake protocols with ready/valid signals
- **Pipeline Stages**: Register-balanced stages with appropriate bit-width management
- **Critical Path**: Multiply-accumulate chains typically dominate timing

### Optimization Techniques
1. **Timing**: Pipeline long paths, decompose large multipliers, balance logic depth
2. **Area**: Register sharing, selective computation, efficient encoding
3. **Power**: Clock gating, operand isolation, reduced bit-width where possible
4. **Memory**: Access pattern optimization, data reuse, reduced bandwidth

## Course Progression

**Weeks 1-4**: Combinational and sequential basics (HW1-2, Labs 1-4)  
**Weeks 5-8**: Matrix operations and FSMs (HW3-4, Labs 5-6)  
**Weeks 9-12**: Pipelining and memory interfaces (HW5, Labs 7-10)  
**Weeks 13-16**: Final project - AI accelerator with external memory

## Results Summary

### Area Optimization
- **Best**: HW1 (5,132 μm²) - Ranked #1 in class
- **Most Complex**: Final Project (1,526,588 μm²) - 14-state FSM with memory interface

### Timing Optimization  
- **Fastest**: HW5 (2.6ns) - Aggressive pipelining with operand decomposition
- **Most Challenging**: Final Project (4.6ns) - Complex datapath with multi-bit multiplications

### Design Complexity
- **Simple**: HW1-2 (pure combinational / basic FSM)
- **Medium**: HW3-4 (matrix operations, resource sharing)
- **Advanced**: HW5 (pipelined CPU with hazard handling)
- **Expert**: Final Project (full system with external memory, custom ops)

## Acknowledgments

Course: Digital Circuits and Systems (DCS-2025)  
Institution: National Yang Ming Chiao Tung University (NYCU)  
Instructor: Tian-Sheuan Chang

---

*This repository represents a complete semester of digital design coursework, progressing from basic logic gates to a production-ready AI accelerator. Each project demonstrates systematic approach to hardware design, optimization, and verification.*