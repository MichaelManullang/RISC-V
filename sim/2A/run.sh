#!/bin/bash
# Stage 2A: R+I-type ALU single-cycle core — compile, simulate, view waves

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
    rtl/Control_Unit.sv \
    rtl/Top.sv \
    sim/TB_Top.sv

echo "=== Running simulation ==="
cd rtl
vvp ../sim/2A/simv
cd ..
mv rtl/waveform.vcd sim/2A/waveform.vcd

echo ""
echo "=== Opening GTKWave ==="
gtkwave sim/2A/waveform.vcd sim/2A/gtkwave.gtkw 2>/dev/null || gtkwave sim/2A/waveform.vcd &