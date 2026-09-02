`timescale 1ns/1ps

module TB_Top_4A();
    logic clk, rst;
    logic [7:0] cycle;

    Top_pipeline dut (.clk(clk), .rst(rst));
    defparam dut.imem_inst.MEM_FILE = "hex/program_4a.hex";

    initial begin clk = 0; forever #10 clk = ~clk; end
    initial begin rst = 1; #25 rst = 0; end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) cycle <= 0; else cycle <= cycle + 1;
    end

    always @(posedge clk) begin
        if (cycle == 25) begin  // wait for pipeline to fully drain
            $display("cycle=%0d", cycle);
            $display("x1 = %0d (expect 10)", dut.regfile_inst.regs[1]);
            $display("x2 = %0d (expect 20)", dut.regfile_inst.regs[2]);
            $display("x3 = %0d (expect 30)", dut.regfile_inst.regs[3]);

            if (dut.regfile_inst.regs[1] === 32'd10 &&
                dut.regfile_inst.regs[2] === 32'd20 &&
                dut.regfile_inst.regs[3] === 32'd30)
                $display("\n=== PASS ===");
            else
                $display("\n=== FAIL ===");
            $finish;
        end
    end

    initial begin
        $dumpfile("waveform_4a.vcd");
        $dumpvars(0, TB_Top_4A);
    end
endmodule