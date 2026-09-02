`timescale 1ns/1ps
module TB_Top_4B();
    logic clk, rst;
    logic [7:0] cycle;
    Top_pipeline dut(.clk(clk), .rst(rst));
    defparam dut.imem_inst.MEM_FILE = "hex/program_4b.hex";
    initial begin clk=0; forever #10 clk=~clk; end
    initial begin rst=1; #25 rst=0; end
    always_ff @(posedge clk or posedge rst) begin
        if(rst) cycle<=0; else cycle<=cycle+1;
    end

    // Trace stall/flush activity
    always @(negedge clk) begin
        if(cycle>=1 && cycle<=15) begin
            $display("c=%0d pc=%0h stall_pc=%0d stall_if=%0d flush_ex=%0d x1=%0d x2=%0d x3=%0d",
                cycle, dut.pc, dut.stall_pc, dut.stall_if_id, dut.flush_id_ex,
                dut.regfile_inst.regs[1], dut.regfile_inst.regs[2], dut.regfile_inst.regs[3]);
        end
    end

    always @(posedge clk) begin
        if(cycle==20) begin
            $display("\nx10=%0d (expect 5)", dut.regfile_inst.regs[10]);
            $display("x1 =%0d (expect value from DMEM[5])", dut.regfile_inst.regs[1]);
            $display("x2 =%0d (expect x1+3)", dut.regfile_inst.regs[2]);
            $display("x3 =%0d (expect 42)", dut.regfile_inst.regs[3]);
            if(dut.regfile_inst.regs[10] === 32'd5 &&
               dut.regfile_inst.regs[3]  === 32'd42)
                $display("\n=== HAZARD TEST OK (x10=5, x3=42) ===");
            else
                $display("\n=== FAIL ===");
            $finish;
        end
    end
endmodule
