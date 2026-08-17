`timescale 1ns/1ps
import riscv_pkg::*;

module TB_Top_2B();

    localparam TOTAL_INSTRS = 34;    // instructions in program_2b.hex
    localparam WAIT_CYCLES  = 36;    // +2 margin after last instruction

    // ── Expected register values after full program ──
    logic [31:0] exp_reg [0:31];

    initial begin
        // R+I ALU (from 2A)
        exp_reg[1]  = 32'h00000005;   // x1   ADDI x1, x0, 5
        exp_reg[2]  = 32'h00000003;   // x2   ADDI x2, x0, 3
        exp_reg[3]  = 32'h00000008;   // x3   ADD  x3, x1, x2
        exp_reg[4]  = 32'h00000002;   // x4   SUB  x4, x1, x2
        exp_reg[5]  = 32'hFFFFFFFF;   // x5   ADDI x5, x0, -1
        exp_reg[6]  = 32'h00000005;   // x6   AND  x6, x1, x5
        exp_reg[7]  = 32'h00000007;   // x7   OR   x7, x1, x2
        exp_reg[8]  = 32'h00000006;   // x8   XOR  x8, x1, x2
        exp_reg[9]  = 32'h00000001;   // x9   SLT  x9, x2, x1
        exp_reg[10] = 32'h00000000;   // x10  SLTU x10, x1, x2
        exp_reg[11] = 32'h00000028;   // x11  SLL  x11, x1, x2
        exp_reg[12] = 32'h00000000;   // x12  SRL  x12, x1, x2
        exp_reg[13] = 32'hFFFFFFFF;   // x13  SRA  x13, x5, x2
        exp_reg[14] = 32'h0000000A;   // x14  ADDI x14, x0, 10
        exp_reg[15] = 32'h00000001;   // x15  SLTI x15, x14, 20
        exp_reg[16] = 32'h00000000;   // x16  SLTIU x16, x14, 5
        exp_reg[17] = 32'h00000005;   // x17  XORI x17, x14, 15
        exp_reg[18] = 32'h0000000B;   // x18  ORI  x18, x14, 1
        exp_reg[19] = 32'h00000002;   // x19  ANDI x19, x14, 3
        exp_reg[20] = 32'h00000028;   // x20  SLLI x20, x14, 2
        exp_reg[21] = 32'h00000005;   // x21  SRLI x21, x14, 1
        exp_reg[22] = 32'hFFFFFFF8;   // x22  ADDI x22, x0, -8
        exp_reg[23] = 32'hFFFFFFFC;   // x23  SRAI x23, x22, 1

        // 2B: Loads & Stores
        exp_reg[24] = 32'h00000064;   // x24  ADDI x24, x0, 100 (base addr)
        exp_reg[25] = 32'hFFFFFFFB;   // x25  ADDI x25, x0, -5
        exp_reg[26] = 32'hFFFFFFFB;   // x26  LB  x26, 0(x24)  ← sign-ext byte 0xFB
        exp_reg[27] = 32'h000000FB;   // x27  LBU x27, 0(x24)  ← zero-ext byte 0xFB
        exp_reg[28] = 32'hFFFFFED4;   // x28  ADDI x28, x0, -300
        exp_reg[29] = 32'hFFFFFED4;   // x29  LH  x29, 4(x24)  ← sign-ext half 0xFED4
        exp_reg[30] = 32'h0000FED4;   // x30  LHU x30, 4(x24)  ← zero-ext half 0xFED4
        exp_reg[31] = 32'h00000028;   // x31  LW  x31, 8(x24)  ← 0x28 (from SW x11,8(x24))
    end

    // ── Signals ──
    logic       clk;
    logic       rst;
    logic [7:0] cycle_count;

    // ── DUT ──
    Top dut (
        .clk(clk),
        .rst(rst)
    );

    defparam dut.imem_inst.MEM_FILE = "program_2b.hex";

    // ── Clock & Reset ──
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        #25 rst = 1'b0;
    end

    // ── Cycle counter ──
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // ── Register checks ──
    logic [5:0]  reg_idx;
    logic [31:0] pass_count;
    logic [31:0] fail_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_idx    <= 0;
            pass_count <= 0;
            fail_count <= 0;
        end
        else if (cycle_count == WAIT_CYCLES) begin
            if (reg_idx != 32) begin
                if (reg_idx == 0) begin
                    // x0 is always 0 — skip check, just advance
                    reg_idx <= reg_idx + 1;
                end
                else begin
                    $display("x%0d  expected=0x%08h  got=0x%08h  %s",
                             reg_idx,
                             exp_reg[reg_idx],
                             dut.regfile_inst.regs[reg_idx],
                             (dut.regfile_inst.regs[reg_idx] === exp_reg[reg_idx]) ? "PASS" : "FAIL");

                    if (dut.regfile_inst.regs[reg_idx] === exp_reg[reg_idx])
                        pass_count <= pass_count + 1;
                    else
                        fail_count <= fail_count + 1;

                    reg_idx <= reg_idx + 1;
                end
            end
        end
        else if (cycle_count > WAIT_CYCLES && reg_idx == 32) begin
            // ── Memory checks ──
            $display("\n--- Memory checks ---");

            // Byte at addr 100 = x25[7:0] = 0xFB
            if (dut.dmem_inst.mem[100] === 8'hFB) begin
                pass_count <= pass_count + 1;
                $display("mem[100] (SB)  expected=0xFB  got=0x%02h  PASS", dut.dmem_inst.mem[100]);
            end else begin
                fail_count <= fail_count + 1;
                $display("mem[100] (SB)  expected=0xFB  got=0x%02h  FAIL", dut.dmem_inst.mem[100]);
            end

            // Halfword at addr 104
            if (dut.dmem_inst.mem[104] === 8'hD4 && dut.dmem_inst.mem[105] === 8'hFE) begin
                pass_count <= pass_count + 1;
                $display("mem[104:105] (SH)  expected=D4,FE  got=%02h,%02h  PASS",
                         dut.dmem_inst.mem[104], dut.dmem_inst.mem[105]);
            end else begin
                fail_count <= fail_count + 1;
                $display("mem[104:105] (SH)  expected=D4,FE  got=%02h,%02h  FAIL",
                         dut.dmem_inst.mem[104], dut.dmem_inst.mem[105]);
            end

            // Word at addr 108 = x11 = 0x00000028
            if ({dut.dmem_inst.mem[111], dut.dmem_inst.mem[110],
                 dut.dmem_inst.mem[109], dut.dmem_inst.mem[108]} === 32'h00000028) begin
                pass_count <= pass_count + 1;
                $display("mem[108:111] (SW)  expected=0x00000028  got=0x%02h%02h%02h%02h  PASS",
                         dut.dmem_inst.mem[111], dut.dmem_inst.mem[110],
                         dut.dmem_inst.mem[109], dut.dmem_inst.mem[108]);
            end else begin
                fail_count <= fail_count + 1;
                $display("mem[108:111] (SW)  expected=0x00000028  got=0x%02h%02h%02h%02h  FAIL",
                         dut.dmem_inst.mem[111], dut.dmem_inst.mem[110],
                         dut.dmem_inst.mem[109], dut.dmem_inst.mem[108]);
            end

            $display("\n=== RESULTS: %0d correct, %0d wrong (out of 34) ===",
                     pass_count, fail_count);
            $finish;
        end
    end

    // ── Waveform dump ──
    initial begin
        $dumpfile("waveform_2b.vcd");
        $dumpvars(0, TB_Top_2B);
    end

endmodule