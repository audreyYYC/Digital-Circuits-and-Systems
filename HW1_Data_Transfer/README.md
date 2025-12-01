# Simple Data Transfer
**Combinational routing network with congestion detection and priority-based arbitration**

## System Overview
Multi-point data routing circuit implementing destination-based switching with hardware congestion detection. Routes data from 4 input ports to 5 output ports with acknowledgment signaling for transmission status feedback.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 5,132.635 μm²
- **Performance Rank**: #1 / 150 students (BEST CODE)
- **Timing**: Met 6ns constraint
- **Technology**: Standard cell library

### Verification Status
- **RTL Simulation**: All test patterns passed
- **Synthesis**: Latch-free implementation with timing closure (MET)
- **Gate-Level Simulation**: Post-synthesis verification confirmed
- **Implementation**: Pure combinational logic design

## Technical Specifications
### Inputs (4 × 20-bit commands)
- **in_valid** (1 bit): Data transfer request indicator
- **destination** (3 bits): Target output address (0-4)
- **data** (16 bits): Payload for transmission

### Outputs (5 × 18-bit status + 4 × 1-bit acks)
- **condition** (2 bits): Transfer status
  - `00`: No incoming data
  - `01`: Single source, successful transfer
  - `10`: Congestion detected (≥2 sources)
- **data** (16 bits): Routed payload from selected input
- **ack_n[0:3]**: Per-input acknowledgment (1=success, 0=fail/no-transfer)

## Design Methodology
**Output-Centric Routing**: Each output independently selects from inputs based on destination matching, rather than inputs pushing to outputs. This approach reduces critical path and hardware complexity.

**Destination Decoding Optimization**: Exploited unique bit patterns in 3-bit destination field. For example, out_n4 is uniquely identified by MSB=1, eliminating need to check lower bits.

**Separated Congestion Logic**: Congestion detection implemented in independent MUX rather than nested within data path, reducing area overhead from complex condition nesting.

*High-efficiency combinational router demonstrating area optimization techniques for multi-port arbitration systems*