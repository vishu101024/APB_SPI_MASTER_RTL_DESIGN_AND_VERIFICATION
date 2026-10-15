# APB_SPI_MASTER_RTL_DESIGN_AND_VERIFICATION
RTL Design and UVM-Based Verification of an APB-Controlled SPI Master IP Core using Verilog/SystemVerilog, with protocol checking, functional coverage, and simulation-based validation.


## Project Overview

This project focuses on the RTL design and functional verification of an APB-controlled Serial Peripheral Interface (SPI) Master IP Core using Verilog/SystemVerilog.

The core provides a programmable interface between an APB-based system and SPI peripheral devices. It supports configuration through control registers, serial data transmission and reception, and clock generation for synchronous communication.

##Project focus: RTL Design | SystemVerilog | Functional Verification

## Objectives

- Design a synthesizable SPI Master IP Core with an APB register interface.
- Implement SPI clock generation and slave selection.
- Support serial data transmission and reception through MOSI and MISO.
- Configure SPI clock polarity and phase.
- Develop a verification environment to validate register access and SPI transactions.
- Debug simulation issues and evaluate functional correctness.

## Architecture

The design is organized around the following functional blocks:

### 1. APB Slave Interface
- Handles APB read and write transactions.
- Provides access to SPI configuration, status, baud-rate and data registers.
- Controls register updates and data exchange with the SPI core.

### 2. Baud Rate Generator
- Generates the SPI serial clock (SCLK) from the system clock.
- Supports programmable clock division.
- Uses SPI clock polarity configuration to determine the idle clock level.

### 3. SPI Slave Select Generator
- Controls the active-low slave-select signal.
- Coordinates peripheral selection with data-transfer activity.
- Indicates when a transfer is in progress.

### 4. SPI Shifter
- Handles parallel-to-serial transmission through MOSI.
- Handles serial-to-parallel reception through MISO.
- Supports configurable bit ordering and clock timing.

## Protocol Features

- **APB interface:** Register-based configuration and data access.
- **SPI modes:** Mode 0, Mode 1, Mode 2 and Mode 3, subject to implementation and verification.
- **Clock configuration:** Programmable baud rate, clock polarity (CPOL) and clock phase (CPHA).
- **Data transfer:** Synchronous serial transmission and reception.
- **Register access:** Control, status, baud-rate and data registers.
- **Status handling:** Transfer status and transmit-buffer status.
- **Interrupt support:** Configuration and status-based interrupt functionality, if enabled and implemented.

## Design Flow

1. Analyze the protocol requirements.
2. Develop the RTL modules.
3. Integrate the functional blocks.
4. Compile and simulate the design.
5. Debug functional and timing-related issues.
6. Verify register operations and SPI transfers.
7. Review synthesizability and lint results, where available.

## Verification Plan

The following tests can be used to evaluate the design. Mark a test as passed only after obtaining simulation evidence.

| Test case | Verification objective |
|---|---|
| Reset | Check initial register and signal states |
| APB write | Verify configuration and data-register writes |
| APB read | Verify register readback |
| Baud-rate generation | Check SCLK frequency and timing |
| Slave selection | Check assertion and deassertion of SS |
| SPI Mode 0 | Validate configured clock and data timing |
| SPI Mode 1 | Validate configured clock and data timing |
| SPI Mode 2 | Validate configured clock and data timing |
| SPI Mode 3 | Validate configured clock and data timing |
| MOSI transmission | Verify transmitted data and bit ordering |
| MISO reception | Verify received data |
| Interrupt and status | Check applicable status flags and interrupt conditions |
| Reset during operation | Evaluate behavior under the supported reset scenarios |

## Verification Results

**Simulation status:** [Update with actual result]

**Test cases passed:** [Enter verified count]

**Test cases failed:** [Enter verified count]

**Functional coverage:** [Enter measured percentage, if collected]

**Assertions:** [List implemented protocol assertions, if any]

Add selected waveform screenshots or simulation logs to demonstrate verified behavior.

## Tools and Technologies

- Verilog / SystemVerilog
- [QuestaSim / ModelSim / Synopsys VCS — specify the tools actually used]
- [Synthesis and lint tools, if used]
- Git and GitHub for version control and project documentation

## Repository Structure

```text
APB-SPI-Master-RTL-Design-and-Verification/
├── rtl/
│   ├── apb_slave.sv
│   ├── baud_generator.sv
│   ├── spi_slave_select.sv
│   ├── spi_shifter.sv
│   └── spi_top.sv
├── tb/
│   └── testbench.sv
├── verification/
│   ├── sequences/
│   ├── agents/
│   ├── scoreboard/
│   └── coverage/
├── sim/
├── docs/
├── results/
├── .gitignore
└── README.md
```

*Adjust the filenames and folders to match your actual repository. Include UVM-specific directories only if you have implemented those components.*

## Key Learning Outcomes

- APB register-interface design.
- SPI clock generation and timing control.
- Serial data shifting and sampling.
- RTL integration and simulation debugging.
- Functional verification planning and result analysis.
- Version control and technical documentation.

## Author

**Vishwanatha SH**

GitHub: [Your GitHub Profile]

LinkedIn: [Your LinkedIn Profile]
