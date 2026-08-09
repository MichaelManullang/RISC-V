# RISC-V Core From-Scratch Roadmap (Simulation-First)

A staged build plan for designing an RV32I core from scratch, verifying entirely in simulation before any FPGA involvement, and eventually integrating it with the existing AXI4-Lite UART IP as a small SoC.

---

## Stage 0 — Setup & Tooling
- [x] Install Icarus Verilog (already in use) and Verilator — **Icarus ✅ (v13.0), Verilator ❌ (needs autoconf + sudo)**
- [x] Install GTKWave for waveform inspection — **✅ (v3.3.126)**
- [x] Build/install `riscv-gnu-toolchain` (RV32I target) for compiling test programs to ELF/hex — **✅ (SiFive 10.2.0-2020.12.8, at RISC/toolchain)**
- [x] Build/install Spike (`riscv-isa-sim`) as a golden reference model — **✅ (v1.1.1-dev, in RISC/toolchain)**
- [x] Clone `riscv-arch-test` (official compliance test suite) — **✅ (RISC/riscv-arch-test)**
- [x] Decide on RTL language/style conventions (module naming, reset polarity, coding style) to keep consistent across the project — **✅ (see docs/coding-style.md)**
- [x] Set up a Git repo with a clear directory structure (`rtl/`, `tb/`, `sim/`, `sw/`, `docs/`) — **✅ (Git init done, directories created)**

---

## Stage 1 — ISA Study & Architecture Planning
- [ ] Read the RISC-V Unprivileged ISA spec (RV32I base integer instruction set)
- [ ] Define instruction categories to support first: R-type, I-type, S-type, B-type, U-type, J-type
- [ ] Decide register file structure (32 x 32-bit, x0 hardwired to zero)
- [ ] Sketch a block diagram: single-cycle datapath (PC, instruction memory, register file, ALU, data memory, control unit)
- [ ] Write an instruction decode table (opcode/funct3/funct7 → control signals) before writing RTL

---

## Stage 2 — Single-Cycle RV32I Core
- [ ] Implement Program Counter + next-PC logic (PC+4, branch/jump targets)
- [ ] Implement instruction memory interface (simulation-only ROM/RAM model)
- [ ] Implement register file (2 read ports, 1 write port, x0 = 0)
- [ ] Implement ALU (add/sub/logic/shift/compare) and ALU control decode
- [ ] Implement immediate generator for all instruction formats
- [ ] Implement data memory interface (load/store, byte/half/word, sign/zero extend)
- [ ] Implement control unit (opcode → control signal decode)
- [ ] Wire up full datapath
- [ ] Write self-checking testbenches per instruction class (arithmetic, branches, loads/stores, jumps) in Icarus Verilog
- [ ] Run hand-written assembly test programs and check register/memory state against expected results

---

## Stage 3 — Compliance Verification
- [ ] Cross-compile `riscv-arch-test` RV32I test programs with `riscv-gnu-toolchain`
- [ ] Build a test harness to load ELF/hex into your simulated instruction memory
- [ ] Compare your core's output signatures against the reference signatures from the compliance suite
- [ ] Debug and fix mismatches until all RV32I compliance tests pass
- [ ] (Optional) Set up lockstep/co-simulation against Spike for instruction-by-instruction comparison

---

## Stage 4 — Pipelined Core (5-Stage: IF/ID/EX/MEM/WB)
- [ ] Convert single-cycle datapath into 5 pipeline stages with pipeline registers
- [ ] Implement hazard detection unit (data hazards, load-use hazard)
- [ ] Implement forwarding/bypass logic (EX/MEM and MEM/WB to EX)
- [ ] Implement branch/jump handling (flush on misprediction, or simple always-not-taken + flush)
- [ ] Re-run all Stage 2/3 testbenches and compliance tests against the pipelined version
- [ ] Add pipeline-specific testbenches: back-to-back dependent instructions, load-use stalls, branch flush correctness
- [ ] Move to Verilator for full-core simulation speed; add waveform dumps for pipeline debug

---

## Stage 5 — AXI4-Lite Bus Integration (SoC Step)
- [ ] Design an AXI4-Lite master interface for the core's memory access stage
- [ ] Define a simple memory map: instruction memory, data memory, and peripheral region
- [ ] Integrate existing AXIL_Handler/Regmap UART IP as a memory-mapped peripheral
- [ ] Write software test programs that poll/control the UART peripheral (e.g., echo test) and run them on the core in simulation
- [ ] Testbench: core boots, writes to UART TXFIFO, verifies transmitted bytes; receives via RXFIFO, verifies core reads correct data

---

## Stage 6 — Stretch Features (pick based on time/portfolio goals)
- [ ] Interrupt controller, tied into UART RX/TX status flags
- [ ] M-extension (multiply/divide unit)
- [ ] Simple 2-way set-associative instruction cache
- [ ] C-extension (compressed instructions)
- [ ] Formal verification (SymbiYosys) on hazard unit / FSMs

---

## Stage 7 — Documentation & Portfolio Packaging
- [ ] Write architecture documentation (block diagrams, pipeline diagram, memory map)
- [ ] Document verification methodology and compliance test results
- [ ] Write a README with build/run instructions for simulation
- [ ] Prepare a short writeup or slide deck summarizing design decisions and challenges (similar to the AXI4-Lite UART deck)

---

## Stage 8 — FPGA Bring-Up (later, once hardware is available)
- [ ] Adapt memory interfaces to target FPGA's BRAM/external RAM
- [ ] Timing closure and constraints
- [ ] Clock domain crossing for UART pins
- [ ] On-hardware validation against the same test programs used in simulation