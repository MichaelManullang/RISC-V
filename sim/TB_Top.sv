`timescale 1ns/1ps
import riscv_pkg::*;

module Testbench_top();

    localparam Test_Number = 24;
    logic [31:0] expected_value [0:23];

    initial begin
        expected_value[0]  = 32'h00000000; // x0  (hardwired zero — NOT checked, see note below)
        expected_value[1]  = 32'h00000005; // x1  ADDI x1, x0, 5
        expected_value[2]  = 32'h00000003; // x2  ADDI x2, x0, 3
        expected_value[3]  = 32'h00000008; // x3  ADD  x3, x1, x2
        expected_value[4]  = 32'h00000002; // x4  SUB  x4, x1, x2
        expected_value[5]  = 32'hFFFFFFFF; // x5  ADDI x5, x0, -1
        expected_value[6]  = 32'h00000005; // x6  AND  x6, x1, x5
        expected_value[7]  = 32'h00000007; // x7  OR   x7, x1, x2
        expected_value[8]  = 32'h00000006; // x8  XOR  x8, x1, x2
        expected_value[9]  = 32'h00000001; // x9  SLT  x9, x2, x1
        expected_value[10] = 32'h00000000; // x10 SLTU x10, x1, x2
        expected_value[11] = 32'h00000028; // x11 SLL  x11, x1, x2
        expected_value[12] = 32'h00000000; // x12 SRL  x12, x1, x2
        expected_value[13] = 32'hFFFFFFFF; // x13 SRA  x13, x5, x2
        expected_value[14] = 32'h0000000A; // x14 ADDI x14, x0, 10
        expected_value[15] = 32'h00000001; // x15 SLTI x15, x14, 20
        expected_value[16] = 32'h00000000; // x16 SLTIU x16, x14, 5
        expected_value[17] = 32'h00000005; // x17 XORI x17, x14, 15
        expected_value[18] = 32'h0000000B; // x18 ORI  x18, x14, 1
        expected_value[19] = 32'h00000002; // x19 ANDI x19, x14, 3
        expected_value[20] = 32'h00000028; // x20 SLLI x20, x14, 2
        expected_value[21] = 32'h00000005; // x21 SRLI x21, x14, 1
        expected_value[22] = 32'hFFFFFFF8; // x22 ADDI x22, x0, -8
        expected_value[23] = 32'hFFFFFFFC; // x23 SRAI x23, x22, 1
    end

    logic           clk;
    logic           rst;
    logic [31:0]    check_index;
    logic [31:0]    correct_counter;
    logic [31:0]    wrong_counter;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, Testbench_top);
    end

    initial begin
        rst = 0;
        #5  rst = 1;
        #25 rst = 0;
    end

    Top dut(
        .clk(clk),
        .rst(rst)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            check_index     <= 0;
            correct_counter <= 0;
            wrong_counter   <= 0;
        end
        else if (check_index != Test_Number) begin
            if (check_index != 0) begin
                $display("Expected value = 0x%08h", expected_value[check_index]);
                $display("Register value = 0x%08h", dut.regfile_inst.regs[check_index]);

                if (dut.regfile_inst.regs[check_index] !== expected_value[check_index])
                    wrong_counter   <= wrong_counter + 1;
                else
                    correct_counter <= correct_counter + 1;
            end
            check_index <= check_index + 1;
        end
        else begin
            $display("\n=== RESULTS: %0d correct, %0d wrong (out of %0d checked) ===",
                      correct_counter, wrong_counter, Test_Number - 1);
            $finish;
        end
    end

endmodule