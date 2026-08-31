`timescale 1ns/1ps
import riscv_pkg::*;

module TB_Top_2D();

    // ── Expected register values ──
    logic [31:0] exp_reg [0:31];

    initial begin
        exp_reg[1]  = 32'h12345000;   // x1  LUI x1, 0x12345
        exp_reg[2]  = 32'h00001004;   // x2  AUIPC x2, 0x1  (pc=4 + 0x1000)
        exp_reg[3]  = 32'h00000010;   // x3  JAL x3, 8     (return addr = 16)
        exp_reg[4]  = 32'h00000001;   // x4  ADDI x4, 1    (set-to-0 skipped by JAL)
        exp_reg[5]  = 32'h0000002A;   // x5  ADDI x5, 42   (executed after jump)
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

    defparam dut.imem_inst.MEM_FILE = "program_2d.hex";

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

    // ── Checks ──
    logic [31:0] pass_count;
    logic [31:0] fail_count;
    logic        done;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pass_count <= 0;
            fail_count <= 0;
            done       <= 0;
        end
        else if (!done && cycle_count == 20) begin
            done <= 1;
            for (int i = 1; i <= 5; i++) begin
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
            $display("\n=== RESULTS: %0d correct, %0d wrong (out of 5) ===", pass_count, fail_count);
            $finish;
        end
    end

    // ── Waveform dump ──
    initial begin
        $dumpfile("waveform_2d.vcd");
        $dumpvars(0, TB_Top_2D);
    end

endmodule