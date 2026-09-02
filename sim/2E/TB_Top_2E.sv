`timescale 1ns/1ps
import riscv_pkg::*;

module TB_2E();
    logic clk, rst;
    initial begin clk=0; forever #10 clk=~clk; end
    initial begin rst=1; #25 rst=0; end

    Top dut(.clk(clk), .rst(rst));
    defparam dut.imem_inst.MEM_FILE = "hex/program_2e.hex";

    initial begin
        #(25 + 60*20 + 60);
        $display("x10 (base addr, expect 200)         = %0d", dut.regfile_inst.regs[10]);
        $display("x11 (sum*2, expect 200)              = %0d", dut.regfile_inst.regs[11]);
        $display("x12 (loop counter, expect 4)         = %0d", dut.regfile_inst.regs[12]);
        $display("x13 (loop limit, expect 4)           = %0d", dut.regfile_inst.regs[13]);
        $display("x18 (mem round-trip, expect 200)     = %0d", dut.regfile_inst.regs[18]);
        $display("x19 (LUI, expect 4096/0x1000)        = %0d", dut.regfile_inst.regs[19]);
        $display("x21 (LUI+AUIPC+ADD, expect 4192/0x1060) = %0d", dut.regfile_inst.regs[21]);

        if (dut.regfile_inst.regs[10] === 32'd200  &&
            dut.regfile_inst.regs[11] === 32'd200  &&
            dut.regfile_inst.regs[12] === 32'd4    &&
            dut.regfile_inst.regs[13] === 32'd4    &&
            dut.regfile_inst.regs[18] === 32'd200  &&
            dut.regfile_inst.regs[19] === 32'h1000 &&
            dut.regfile_inst.regs[21] === 32'h1060)
            $display("\n=== PASS ===");
        else
            $display("\n=== FAIL ===");
        $finish;
    end
endmodule