<div align="center">

# Direct Memory Access Controller Using Verilog HDL

**An FSM-based DMA controller for autonomous memory-to-memory data transfer**

Verilog HDL • Cadence Genus • Cadence Innovus

</div>

## Introduction

Moving data between memory locations is a common operation in digital systems. When a CPU performs every read and write itself, it spends time transferring data instead of executing other instructions. **Direct Memory Access (DMA)** allows a dedicated hardware controller to manage these transfers after an initial configuration by the CPU.

This project implements a DMA controller using Verilog HDL. The CPU provides a source address, destination address, and transfer length. The controller then copies the data between locations in its internal memory and generates an interrupt when the operation is complete. The design is organized into a configuration register bank, a transfer controller, and a top-level module.

## Objective

- Implement autonomous transfer of 32-bit words between memory locations.
- Use a finite state machine to control transfer sequencing.
- Provide a register interface for CPU configuration and status monitoring.
- Verify data transfer and completion signaling through simulation.
- Study the synthesized circuit and physical layout using Cadence tools.

## Project Theory and Working

### 1. System Architecture

![DMA system architecture](docs/block_diagram.png)

The CPU communicates with the **register bank**, which stores the transfer settings. These settings are passed to the **DMA controller**, which performs the copy within a **256 × 32-bit internal memory array**. The controller reports its operating state through `busy` and `done`, and notifies the CPU through `interrupt`.

### 2. CPU Interface and Configuration Registers

The CPU selects a register using `cpu_addr` and writes its value through `cpu_wdata` while `cpu_write` is asserted. Register values and transfer status can be read through `cpu_rdata`.

| Address | Register | Purpose |
|---|---|---|
| `0x0` | Source address | Starting word index of the data to be copied |
| `0x1` | Destination address | Starting word index where data will be stored |
| `0x2` | Transfer length | Number of 32-bit words to transfer |
| `0x3` | Start control | Writing `1` requests a transfer |
| `0x4` | Status | Bit 0 indicates `busy`; bit 1 indicates `done` |

The `dma_registers` module stores the configuration values. A single-cycle write to the start register produces the start command for the controller.

### 3. FSM-Based Transfer Controller

The `dma_controller` module uses three states:

| State | Operation |
|---|---|
| **IDLE** | Waits for a start request with a nonzero transfer length. Captures the source, destination, and length, and asserts `busy`. |
| **TRANSFER** | Copies one word per clock, increments both addresses, and decrements the remaining word count. |
| **COMPLETE** | Clears `busy`, asserts `done` and `interrupt` for one clock cycle, and returns to IDLE. |

During the transfer, the central operation is:

```verilog
memory[dst] <= memory[src];
src        <= src + 1;
dst        <= dst + 1;
count      <= count - 1;
```

When the remaining count is one, the controller copies the final word and moves to the completion state. A zero-length request does not start a transfer.

### 4. Top-Level Integration

The `dma_top` module connects `dma_registers` and `dma_controller`. It exposes the CPU interface and interrupt output, while the configuration and status signals connect the two submodules internally.

### 5. Example: Eight-Word Transfer

1. The source region is initialized with eight data words.
2. The CPU writes source address **0**, destination address **20**, and length **8**.
3. A start command activates the controller.
4. The controller copies memory locations **0–7** to **20–27**, one word per clock.
5. After the final copy, the interrupt indicates completion.
6. The testbench compares the destination words with the source data.

This implementation demonstrates DMA operation using an internal memory array; the addresses refer to words within that memory.

## Results

### Simulation Waveform

![DMA simulation waveform in Cadence SimVision](docs/waveform_simvision.png)

The waveform shows reset, CPU configuration, transfer activity, and interrupt assertion. During the transfer, `busy` remains active. At completion, `busy` clears and the completion signals assert.

![Detailed DMA transfer waveform](docs/waveform_transfer.png)

The detailed plot shows the eight-word example and the relationship between the configuration writes, `busy`, `done`, and `interrupt`. The lab testbench reports **DMA TEST PASSED** after checking the copied data.

### Synthesized Circuit

![DMA top-level schematic](docs/rtl_schematic_top.png)

The Cadence Genus schematic shows the register-bank and controller instances connected at the top level. The configuration signals drive the transfer controller, while status signals return to the register interface.

<details>
<summary>View the controller and register-bank schematics</summary>

![DMA controller schematic](docs/rtl_schematic_controller.png)

![DMA register-bank schematic](docs/rtl_schematic_registers.png)

</details>

### Physical Layout

![DMA physical layout in Cadence Innovus](docs/layout_innovus.png)

The physical-layout result shows the placement of the design's cells and their routed interconnections. It illustrates the progression from the Verilog description through synthesis to physical implementation.

## Tools and Technologies

| Tool / Language | Use |
|---|---|
| Verilog HDL | Register interface, FSM, and top-level design |
| Cadence Xcelium / SimVision | Functional simulation and waveform analysis |
| Cadence Genus | Logic synthesis and schematic inspection |
| Cadence Innovus | Physical implementation and layout analysis |

## Conclusion

The project demonstrates how a register-controlled DMA engine performs a programmed memory copy without continuous CPU involvement. Its modular design combines configuration registers, FSM-based sequencing, and interrupt generation. Simulation verifies the transfer behavior, while synthesis and layout results illustrate the hardware implementation flow.


