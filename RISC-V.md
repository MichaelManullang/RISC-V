# RISC-V Core From-Scratch Roadmap (Simulation-First)

A staged build plan for designing an RV32I core from scratch, verifying entirely in simulation before any FPGA involvement, and eventually integrating it with the existing AXI4-Lite UART IP as a small SoC.

---

## Current Project Structure

```
myproject/RISC/
├── GIT/RISC-V/                    # Git repo (github.com/MichaelManullang/RISC-V)
│   ├── rtl/
│   │   ├── riscv_pkg.sv           # Shared types (alu_op_t, opcode_t, reg_sel_t)
│   │   ├── PC.sv                  # Program counter (PC+4 / branch / jump)
│   │   ├── imem.sv                # Instruction memory (hex-loaded ROM)
│   │   ├── regfile.sv             # Register file (32×32, 2R/1W, x0=0)
│   │   ├── alu.sv                 # ALU (10 ops: ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND)
│   │   ├── imm_generator.sv       # Immediate generator (I/S/B/U/J formats)
│   │   ├── dmem.sv                # Data memory (LB/LBU/LH/LHU/LW/SB/SH/SW)
│   │   ├── branch_comp.sv         # Branch comparator (BEQ/BNE/BLT/BGE/BLTU/BGEU)
│   │   ├── Control_Unit.sv        # Main decoder (all opcodes including CSR)
│   │   ├── csr_regs.sv            # CSR register file (mstatus, mtvec, mepc, ...)
│   │   ├── Top.sv                 # Top-level datapath
│   │   └── program_*.hex          # Test programs (2A–2E)
│   ├── sim/
│   │   ├── 2A/  (R+I ALU)         # run.sh, TB, 23/23 ✅
│   │   ├── 2B/  (Loads & Stores)  # run.sh, TB, 34/34 ✅
│   │   ├── 2C/  (Branches)        # run.sh, TB, 16/16 ✅
│   │   ├── 2D/  (LUI/AUIPC/JAL)   # run.sh, TB,  5/5  ✅
│   │   └── 2E/  (Full Integration) # run.sh, TB, === PASS ===
│   ├── sw/riscv-arch-test-dut/    # Compliance test DUT config (WIP)
│   └── docs/coding-style.md       # RTL coding conventions
├── toolchain/                      # riscv64-unknown-elf-gcc + spike (3.5G)
├── spike-src/                      # Spike source + build (3.6G)
└── riscv-arch-test/               # Official compliance suite (690M)
```

---

## Stage 0 — Setup & Tooling
- [x] Install Icarus Verilog (already in use) and Verilator — **Icarus ✅ (v13.0), Verilator ✅ (v5.032)**
- [x] Install GTKWave for waveform inspection — **✅ (v3.3.126)**
- [x] Build/install `riscv-gnu-toolchain` (RV32I target) for compiling test programs to ELF/hex — **✅ (SiFive 10.2.0-2020.12.8, at RISC/toolchain)**
- [x] Build/install Spike (`riscv-isa-sim`) as a golden reference model — **✅ (v1.1.1-dev, in RISC/toolchain)**
- [x] Clone `riscv-arch-test` (official compliance test suite) — **✅ (RISC/riscv-arch-test)**
- [x] Decide on RTL language/style conventions (module naming, reset polarity, coding style) to keep consistent across the project — **✅ (see docs/coding-style.md)**
- [x] Set up a Git repo with a clear directory structure (`rtl/`, `tb/`, `sim/`, `sw/`, `docs/`) — **✅ (Git init done, directories created)**

---

## Stage 1 — ISA Study & Architecture Planning
- [x] Read the RISC-V Unprivileged ISA spec (RV32I base integer instruction set)
- [x] Define instruction categories to support first: R-type, I-type, S-type, B-type, U-type, J-type — **✅ all completed (R/I/S/B/U/J)**
- [x] Decide register file structure (32 x 32-bit, x0 hardwired to zero)
- [x] Sketch a block diagram: single-cycle datapath (PC, instruction memory, register file, ALU, data memory, control unit)
- [x] Write an instruction decode table (opcode/funct3/funct7 → control signals) before writing RTL

---

## Stage 2 — Single-Cycle RV32I Core (built incrementally, R+I-type first)

### Stage 2A — R-type + I-type ALU ops only
Scope: Implement ADD/SUB/AND/OR/XOR/SLL/SRL/SRA/SLT/SLTU + their I-type immediate forms.
No loads/stores, no branches/jumps — PC is just PC+4 every cycle, no data memory yet.
- [x] Implement Program Counter (PC+4 only, no mux yet) — **✅ PC.sv**
- [x] Implement instruction memory interface — **✅ imem.sv**
- [x] Implement register file (2 read ports, 1 write port, x0 = 0) — **✅ regfile.sv**
- [x] Implement ALU (add/sub/logic/shift/compare) — **✅ alu.sv (all 10 ops)**
- [x] Implement immediate generator (I-type only for this milestone) — **✅ imm_generator.sv (covers all formats ahead of time)**
- [x] Implement control unit (R+I-type decode) — **✅ Control_Unit.sv**
- [x] Wire up full R+I-type datapath — **✅ Top.sv**
- [x] Write self-checking testbenches (arithmetic, immediate ops) in Icarus Verilog — **✅ TB_Top.sv, 23/23 pass**
- [x] Run hand-written assembly test programs and check register state against expected results — **✅ program.hex, all ops verified**
- [x] Set up shared package (e.g. `riscv_pkg.sv`) for shared types like `alu_op_t` across modules — **✅ riscv_pkg.sv**

### Stage 2B — Loads & Stores
- [x] Implement data memory interface (load/store, byte/half/word, sign/zero extend) — **✅ dmem.sv**
- [x] Extend immediate generator with S-type — **✅ already covered (imm_generator.sv has all formats)**
- [x] Extend control unit decode table with load/store opcodes — **✅ IL_type + S_type added**
- [x] Testbenches: memory read/write round-trips — **✅ TB_Top_2B.sv, 34/34 pass**

### Stage 2C — Branches
- [x] Extend PC logic with branch mux (PC+4 vs branch target) — **✅ PC.sv (take_branch + branch_target)**
- [x] Extend immediate generator with B-type — **✅ already covered (imm_generator.sv)**
- [x] Extend control unit decode table with branch opcodes — **✅ B_type + branch_comparator.sv**
- [x] Testbenches: loops, conditional branch correctness — **✅ TB_Top_2C.sv, 16/16 pass**

### Stage 2D — LUI / AUIPC / JAL (remaining base ISA)
- [x] Extend immediate generator with U-type and J-type — **✅ already covered (imm_generator.sv)**
- [x] Extend control unit decode table with LUI/AUIPC/JAL — **✅ LUI_type, AUIPC_type, JAL_type + alu_a_sel + reg_sel**
- [x] Testbenches: function-call-style control flow — **✅ TB_Top_2D.sv, 5/5 pass**

### Stage 2E — Full Stage 2 wrap-up
- [x] Re-run all testbenches across the complete R+I+S+B+U+J instruction set together — **✅ TB_Top_2E.sv, === PASS ===**
- [x] Confirm full single-cycle datapath (as drafted in the Stage 1 block diagram, extended with data memory + branch mux) matches implementation — **✅ complete**

### Stage 2F — Minimal CSR Support (added for future compliance testing)
- [x] Implement CSR register file (mstatus, mtvec, mepc, mcause, mtval, mscratch) — **✅ csr_regs.sv**
- [x] Add SYSTEM opcode decode (CSRRW/CSRRS/CSRRC) to control unit — **✅ CSR_type in Control_Unit.sv**
- [x] Wire CSR read data into register writeback mux — **✅ Top.sv (reg_sel = CSR)**
- [x] Add CSR opcode to riscv_pkg — **✅ CSR_type + CSR in reg_sel_t**

---

## Stage 3 — Compliance Verification (DEFERRED — blocked by tooling/complexity)

> **Why deferred:** The `riscv-arch-test` framework requires CSR support (✅ done),
> large DMEM (≥64KB vs current 4KB), and the `act` build tool with full dependency
> chain. Core is verified via 78/78 hand-written directed tests covering all RV32I
> instruction classes (2A–2E). CSRs are implemented and ready for compliance.
> **Plan:** Return to compliance after pipeline is working.

- [ ] Cross-compile `riscv-arch-test` RV32I test programs with `riscv-gnu-toolchain`
- [ ] Build a test harness to load ELF/hex into your simulated instruction memory
- [ ] Compare your core's output signatures against the reference signatures from the compliance suite
- [ ] Debug and fix mismatches until all RV32I compliance tests pass
- [ ] (Optional) Set up lockstep/co-simulation against Spike for instruction-by-instruction comparison

---

## Stage 4 — Pipelined Core (5-Stage: IF/ID/EX/MEM/WB)

### Stage 4A — Pipeline Registers + Datapath Split
- [ ] Create pipeline register modules (IF/ID, ID/EX, EX/MEM, MEM/WB)
- [ ] Split single-cycle datapath: each stage gets its own pipeline register
- [ ] Forward all control signals through the pipeline
- [ ] PC update logic: handle branch/jump target reaching IF stage
- [ ] Testbench: single NOP stream — verify pipeline flows correctly

### Stage 4B — Hazard Detection
- [ ] Implement load-use hazard detection (stall IF + ID, bubble EX)
- [ ] Handle RAW hazards between back-to-back dependent instructions
- [ ] Testbench: dependent instruction pairs, verify stalls inserted

### Stage 4C — Forwarding / Bypass
- [ ] EX/MEM → EX forwarding (ALU result feeds next instruction's ALU input)
- [ ] MEM/WB → EX forwarding (memory/previous result bypass)
- [ ] Testbench: RAW hazard sequences without stalls — verify forwarding

### Stage 4D — Branch / Jump Handling
- [ ] Always-not-taken branch prediction
- [ ] Flush IF/ID on taken branch (nullify 2 instructions)
- [ ] Resolve branch in EX stage
- [ ] Testbench: branch flush correctness

### Stage 4E — Full Pipeline Integration
- [ ] Re-run all Stage 2A–2E test programs on pipelined core
- [ ] Run pipeline-specific stress tests (dense dependencies, loops)
- [ ] Move to Verilator for faster simulation
- [ ] Dump waveforms for pipeline debug (GTKWave)

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