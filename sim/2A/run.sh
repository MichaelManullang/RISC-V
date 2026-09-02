#!/bin/bash
# Stage 2A — compile, simulate, view waves
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Compiling Stage 2A RTL ==="
iverilog -g2012 \
    -o sim/2A/simv \
    rtl/riscv_pkg.sv \
    rtl/PC.sv \
    rtl/imem.sv \
    rtl/regfile.sv \
    rtl/alu.sv \
    rtl/imm_generator.sv \
    rtl/dmem.sv \
    rtl/branch_comp.sv \
    rtl/csr_regs.sv \
    rtl/Control_Unit.sv \
    rtl/Top.sv \
    sim/2A/TB_Top_2A.sv

echo "=== Running simulation ==="
cd rtl
vvp ../sim/2A/simv
cd ..

echo ""
echo "=== Opening GTKWave ==="
gtkwave sim/2A/waveform*.vcd 2>/dev/null &
