#!/bin/bash
# Stage 2B: Loads & Stores — compile, simulate, view waves

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Compiling Stage 2B RTL ==="
iverilog -g2012 \
    -o sim/2B/simv \
    rtl/riscv_pkg.sv \
    rtl/PC.sv \
    rtl/imem.sv \
    rtl/regfile.sv \
    rtl/alu.sv \
    rtl/imm_generator.sv \
    rtl/dmem.sv \
    rtl/Control_Unit.sv \
    rtl/Top.sv \
    sim/2B/TB_Top_2B.sv

echo "=== Running simulation ==="
cd rtl
vvp ../sim/2B/simv
cd ..
mv rtl/waveform_2b.vcd sim/2B/waveform_2b.vcd 2>/dev/null || true

echo ""
echo "=== Opening GTKWave ==="
gtkwave sim/2B/waveform_2b.vcd sim/2B/gtkwave.gtkw 2>/dev/null || gtkwave sim/2B/waveform_2b.vcd &