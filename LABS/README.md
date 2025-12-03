# Digital Circuit and System Labs

In-class lab exercises completed within 1-hour demo windows. All labs follow standard RTL → Synthesis → Gate-level simulation flow.

## Lab Overview

| Lab | Topic | Module | Key Focus |
|-----|-------|--------|-----------|
| Lab01 | Combinational Circuit | `Comb.sv` | Bitwise operations, max/min, Gray code conversion |
| Lab02 | Counter | `Counter.sv` | Sequential logic, counter design with hold state |
| Lab03 | Blackjack | `Seq.sv` | FSM basics, card game logic (hit until >16, bust at >21) |
| Lab04 | Synchronous FIFO | `Fifo.sv` | FIFO buffer implementation |
| Lab05 | Branch Predictor | `FSM.sv` | 2-bit branch predictor FSM for RISC-V |
| Lab06 | Pattern Writing | `PATTERN.sv` | Testbench development, fault detection |
| Lab07 | FPGA FIR Filter | Vivado | Low-pass FIR filter on FPGA hardware |
| Lab08 | AXI Interface | `INF.sv` | AXI protocol, handshake mechanisms |
| Lab09 | Pipelined FIR | `FIR.sv` | Pipeline architecture, FIR filter optimization |
| Lab10 | Clock Domain Crossing | `CDC.sv` | Asynchronous clock handling, handshake synchronizer |

## Common Requirements

All labs (except Lab06 and Lab07) must meet:
- **No synthesis errors**
- **Timing slack ≥ 0** (MET)
- **No latches synthesized**
- **No gate-level timing violations**
- **All outputs properly reset**

Grading: 100% for Demo 1, 70% for Demo 2 (late submission)

## Lab Highlights

### Lab01: Combinational Circuit
- Bitwise operations (XNOR, OR, AND, XOR) on 4 inputs
- Max/min selection and summation
- Binary to Gray code conversion

### Lab02-03: Sequential Basics
- **Lab02**: Counter incrementing from 0 to `in_num` over cycles
- **Lab03**: Blackjack game logic with hit/stand decisions based on hand value

### Lab04-05: Advanced Sequential
- **Lab04**: FIFO with read/write control and full/empty flags
- **Lab05**: FSM-based 2-bit branch predictor (strongly taken ↔ strongly not taken)

### Lab06: Testbench Development
- Write `PATTERN.sv` to detect 7 faulty designs
- No RTL design required—pure verification focus

### Lab07: FPGA Implementation
- Deploy FIR filter on actual FPGA hardware using Vivado
- Bridge between simulation and physical implementation

### Lab08: AXI Protocol
- Master-slave communication using AXI4-Lite
- Read/write transactions with handshaking (ARVALID/ARREADY, RVALID/RREADY, etc.)
- Simplified version (no burst length control)

### Lab09: Pipelined Design
- Implement FIR filter with pipeline stages for higher throughput
- Balance between latency and area efficiency

### Lab10: CDC Design
- Handle data transfer between asynchronous clock domains
- Use handshake synchronizer to prevent metastability

## Project Structure (Standard Labs)
```
LabXX/
├── 00_TESTBED/
│   ├── TESTBED.sv    # Top-level testbench
│   └── PATTERN.sv    # Test patterns
├── 01_RTL/
│   ├── 01_run        # Run RTL simulation
│   ├── 09_clean_up   # Clean simulation files
│   └── [Module].sv   # Your design
├── 02_SYN/
│   ├── 01_run_dc     # Run synthesis
│   └── 09_clean_up   # Clean synthesis files
└── 03_GATE/
    ├── 01_run        # Run gate-level simulation
    └── 09_clean_up   # Clean simulation files
```

## Workflow

1. **Extract lab**: `tar -xvf ~dcsTA01/LabXX.tar`
2. **RTL simulation**: `cd LabXX/01_RTL && ./01_run && nWave &`
3. **Synthesis**: `cd ../02_SYN && ./01_run_dc` (check for errors, timing, latches)
4. **Gate-level sim**: `cd ../03_GATE && ./01_run && nWave &`
5. **Upload**: Rename module to `[Module]_dcsxxx.sv` and submit to E3

## Notes

- Labs emphasize clean coding practices: separate combinational/sequential blocks, avoid multiple drivers
- FSM labs (03, 05, 08) require careful state transition design
- Pipeline lab (09) introduces performance-area tradeoffs
- CDC lab (10) addresses real-world multi-clock domain challenges