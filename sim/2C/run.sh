#!/bin/bash
# Stage 2C — compile, simulate, view waves
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Compiling Stage 2C RTL ==="
iverilog -g2012 \
    -o sim/2C/simv \
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
    sim/2C/TB_Top_2C.sv

echo "=== Running simulation ==="
cd rtl
vvp ../sim/2C/simv
cd ..

echo ""
echo "=== Opening GTKWave ==="
gtkwave sim/2C/waveform*.vcd 2>/dev/null &
