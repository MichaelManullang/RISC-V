`timescale 1ns/1ps
import riscv_pkg::*;

module TB_Top_2C();

    // ── Expected register values ──
    logic [31:0] exp_reg [0:31];

    initial begin
        // setup values
        exp_reg[1]  = 32'h00000005;   // x1  = 5
        exp_reg[2]  = 32'h00000005;   // x2  = 5
        exp_reg[3]  = 32'h00000003;   // x3  = 3
        exp_reg[4]  = 32'hFFFFFFFF;   // x4  = -1

        // branch results: 1 = branch taken (skip the "set 0"), 0 = not taken
        exp_reg[10] = 32'h00000001;   // BEQ  x1,x2 (equal)      -> taken
        exp_reg[11] = 32'h00000000;   // BEQ  x1,x3 (not equal)  -> not taken
        exp_reg[12] = 32'h00000001;   // BNE  x1,x3 (not equal)  -> taken
        exp_reg[13] = 32'h00000000;   // BNE  x1,x2 (equal)      -> not taken
        exp_reg[14] = 32'h00000001;   // BLT  x4,x3 (-1<3)       -> taken
        exp_reg[15] = 32'h00000000;   // BLT  x3,x4 (3<-1)       -> not taken
        exp_reg[16] = 32'h00000001;   // BGE  x3,x4 (3>=-1)      -> taken
        exp_reg[17] = 32'h00000000;   // BGE  x4,x3 (-1>=3)      -> not taken
        exp_reg[18] = 32'h00000001;   // BLTU x3,x4 (3<MAXU)     -> taken
        exp_reg[19] = 32'h00000000;   // BLTU x4,x3 (MAXU<3)     -> not taken
        exp_reg[20] = 32'h00000001;   // BGEU x4,x3 (MAXU>=3)    -> taken
        exp_reg[21] = 32'h00000000;   // BGEU x3,x4 (3>=MAXU)    -> not taken
    end

    // ── Signals ──
    logic clk;
    logic rst;
    logic [7:0] cycle_count;

    // ── DUT ──
    Top dut (
        .clk(clk),
        .rst(rst)
    );

    defparam dut.imem_inst.MEM_FILE = "program_2c.hex";

    // ── Clock & reset ──
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        #25 rst = 0;
    end

    // ── Cycle counter ──
    always_ff @(posedge clk or posedge rst) begin
        if (rst) cycle_count <= 0;
        else     cycle_count <= cycle_count + 1;
    end

    // ── Checks (run once after program finishes) ──
    logic [31:0] pass_count;
    logic [31:0] fail_count;
    logic        done;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pass_count <= 0;
            fail_count <= 0;
            done       <= 0;
        end
        else if (!done && cycle_count == 60) begin
            done <= 1;
            // check only the registers we care about
            for (int i = 1; i < 32; i++) begin
                if (i >= 5 && i <= 9) continue;   // unused
                if (i >= 22 && i <= 31) continue; // unused
                if (exp_reg[i] === 32'hxxxxxxxx) continue;

                $display("x%-2d  expected=0x%08h  got=0x%08h  %s",
                         i, exp_reg[i], dut.regfile_inst.regs[i],
                         (dut.regfile_inst.regs[i] === exp_reg[i]) ? "PASS" : "FAIL");

                if (dut.regfile_inst.regs[i] === exp_reg[i])
                    pass_count = pass_count + 1;
                else
                    fail_count = fail_count + 1;
            end
        end
        else if (done) begin
            $display("\n=== RESULTS: %0d correct, %0d wrong ===", pass_count, fail_count);
            $finish;
        end
    end

    // ── Waveform dump ──
    initial begin
        $dumpfile("waveform_2c.vcd");
        $dumpvars(0, TB_Top_2C);
    end

endmodule