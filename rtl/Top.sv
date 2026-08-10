import riscv_pkg::*;

module Top (
    input   clk,
    input   rst
);

    logic   [31:0]  pc;
    logic   [31:0]  instruction;
    logic           imm_select;
    logic   [4:0]   rs1_addr;
    logic   [31:0]  rs1_data;
    logic   [4:0]   rs2_addr;
    logic   [31:0]  rs2_data;
    logic           reg_write;
    logic   [4:0]   rd_addr;
    logic   [31:0]  rd_data;
    logic   [31:0]  imm_data;
    alu_op_t        alu_op;

    program_counter pc_inst(
        .clk(clk),
        .rst(rst),
        .pc(pc)
    );

    imem imem_inst (
        .addr(pc),
        .rdata(instruction)
    );

    control_unit cu_inst(
        .instruction(instruction),
        .imm_select(imm_select),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr)
    );

    imm_generator imm_gen_inst(
        .instruction(instruction),
        .imm(imm_data)
    );

    regfile regfile_inst(
        .clk(clk),
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .reg_write(reg_write)
    );

    ALU alu_inst(
        .alu_op(alu_op),
        .operand_a(rs1_data),
        .operand_b(imm_select ? imm_data : rs2_data),
        .result(rd_data)
    );

endmodule