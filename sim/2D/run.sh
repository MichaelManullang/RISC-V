#!/bin/bash
# Stage 2D — compile, simulate, view waves
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Compiling Stage 2D RTL ==="
iverilog -g2012 \
    -o sim/2D/simv \
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
    sim/2D/TB_Top_2D.sv

echo "=== Running simulation ==="
cd rtl
vvp ../sim/2D/simv
cd ..

echo ""
echo "=== Opening GTKWave ==="
gtkwave sim/2D/waveform*.vcd 2>/dev/null &
