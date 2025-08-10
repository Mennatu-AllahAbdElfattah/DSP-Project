
# Digital Signal Processing (DSP) Project – Basys3 FPGA Implementation

## Overview
This repository presents a comprehensive digital signal processing (DSP) project designed for the Basys3 FPGA development board. The project features modular Verilog code, simulation scripts, constraint files, and detailed documentation of results.

---

## Repository Structure

### `codes_and_simulation_files/`
Design and simulation resources:
- `DSP_code.v`: Verilog source code for the DSP module
- `DSP_tb.v`: Testbench for functional verification
- `Constraints_basys3.xdc`: Xilinx constraints file for Basys3 pin assignments
- `DSP.do`: ModelSim simulation script

### `project_results/`
Project documentation and results:
- `Mennatu-Allah_AbdElfattah_project1.docx`: Includes waveform captures, timing analysis, and implementation outcomes

---

## Tools & Environment
- **Xilinx Vivado**: Design entry, synthesis, implementation, and bitstream generation
- **ModelSim**: Simulation and waveform analysis

---

## Getting Started

### Simulation
1. Launch ModelSim.
2. Load `DSP_tb.v` and execute the `DSP.do` script.
3. Review the simulation waveforms to verify module functionality.

### FPGA Implementation
1. Create a new Vivado project.
2. Add `DSP_code.v` and `Constraints_basys3.xdc` to the project.
3. Run synthesis and implementation, then generate the bitstream file.
4. Program the Basys3 FPGA board with the generated bitstream.


---

## Author

**Mennatu-Allah Abd Elfattah**  
Final-year Electronics & Communications Engineering student, Helwan University  
Specialization: Digital Systems

---