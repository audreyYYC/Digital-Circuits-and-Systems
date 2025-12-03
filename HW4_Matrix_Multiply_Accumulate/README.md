# MAC Array for Matrix Multiplication and Convolution
**Dual-mode AI accelerator with resource sharing for matrix operations and 2D convolution**

## System Overview
Unified hardware accelerator supporting both 8×8 matrix multiplication and 8×8 convolution with 3×3 kernels. Implements streaming input/output interface with user-controlled data fetch order, enabling flexible dataflow management and efficient resource utilization through operation-specific state machines.

## Verified Performance Results
### Timing & Area (Synthesis Results)
- **Total Cell Area**: 41,520.13 μm²
- **Clock Period**: 10.0ns (user-configurable)
- **Max Latency**: <1000 cycles per operation
- **Throughput**: Row-based streaming output (8 elements per output cycle)

### Verification Status
- **RTL Simulation**: Passed  
- **Synthesis**: Timing MET, latch-free  
- **Gate-Level Simulation**: Passed (no timing violations)

## Implementation Features
- **Dual-Mode Operation**: Supports matrix multiplication (mode 0) and convolution (mode 1)
- **Streaming I/O Interface**: User-controlled row/column fetch with 8-element parallel access
- **Row-Based Computation**: Processes and outputs one complete row before moving to next
- **Sliding Window Buffer**: Efficient 3-row window management for convolution with automatic zero padding
- **Resource Sharing**: Single MAC array reused for both operation types

## Technical Specifications
### Operation Modes
**Matrix Multiplication (mode 0)**:
- Input: 8×8 activation × 8×8 weight
- Output: 8×8 result matrix
- Method: Row-column dot product

**Convolution (mode 1)**:
- Input: 8×8 activation (zero-padded to 10×10) × 3×3 kernel
- Output: 8×8 feature map
- Method: Sliding window with automatic boundary zero-padding

### Interface Protocol
**Input Control** (`out_act_idx`, `out_wgt_idx`):
- User specifies row/column to fetch via 4-bit index
- Bit [3]: 0=row, 1=column
- Bits [2:0]: Row/column number (0-7)
- System returns 8 elements via `in_act`/`in_wgt` in next cycle

**Output Protocol** (`out_idx`, `out_data`):
- User specifies output row/column position
- Outputs 8 × 12-bit results simultaneously
- `out_finish` asserted when entire 8×8 matrix complete

### Data Widths
- **Input Elements**: 4-bit unsigned integers
- **Output Elements**: 12-bit unsigned integers
- **Parallel I/O**: 8 elements per cycle

## Design Methodology
**6-State FSM Architecture**:
- **IDLE**: Reset state, captures operation mode
- **PROCESS_ROW** (matrix mult): Computes one output row via 8 dot products
- **WINDOW** (convolution): Initializes 3×3 kernel and middle activation row
- **ACT_1** (convolution): Loads first window (zero-padded top row + activation rows)
- **ACT_2** (convolution): Shifts window upward, loads new bottom row
- **OUTPUT_ROW**: Streams completed row to output interface

**Row-Based Streaming Strategy**: Processes output matrix row-by-row, outputting each row immediately after computation. This approach eliminates need for full 8×8 output buffer, reducing register usage from 64×12 bits to 8×12 bits while maintaining throughput.

**Convolution Window Management**: Maintains 3-row sliding window buffer for convolution operations. Separate states (WINDOW, ACT_1, ACT_2) handle initialization, first row (top zero-padding), middle rows (shifting), and last row (bottom zero-padding) distinctly, simplifying control logic and avoiding conditional complexity.

**User-Controlled Data Fetch**: Delegates input sequencing to user via `out_act_idx`/`out_wgt_idx` outputs, allowing flexible access patterns. For matrix multiplication, fetches activation rows and weight columns on-demand. For convolution, weight kernel provided in fixed raster-scan order.

**Critical Path Considerations**: Dot product computation (8 multiplications + 7 additions) forms critical path in both modes. Design maintains 10ns cycle time with adequate timing margin, though pipeline optimization was considered but not implemented due to time constraints.

## Design Challenges
Primary challenge involved managing distinct dataflow patterns for two operation types within unified hardware. Initial attempts to merge convolution and matrix multiplication logic within shared states caused timing violations and functional errors. Solution required separate state machines with operation-specific sequencing.

Encountered correctness issue where matrix multiplication generated incorrect results for last row's final element. Root cause: OUTPUT_ROW state incorrectly attempted to pre-compute first element of non-existent next row. Fix: added boundary condition to skip pre-computation on final row.

Window buffer management for convolution required careful register allocation and zero-padding logic. Separating window initialization, loading, and shifting into distinct states (WINDOW, ACT_1, ACT_2) significantly improved design clarity and eliminated edge-case bugs.

*Dual-mode accelerator demonstrating hardware resource sharing and streaming computation for neural network inference primitives*