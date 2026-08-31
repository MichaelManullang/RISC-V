import riscv_pkg::*;

module Top (
    input   clk,
    input   rst
);

    logic   [31:0]  pc;
    logic   [31:0]  branch_target;
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
    logic   [31:0]  alu_out;
    alu_op_t        alu_op;
    logic           alu_a_sel;
    logic           mem_read;
    logic           mem_write;
    reg_sel_t       reg_sel;
    logic   [31:0]  dmem_out;
    logic           branch_taken;
    logic           branch;
    logic           jump;

    assign  branch_target   = pc + imm_data;

    program_counter pc_inst(
        .clk(clk),
        .rst(rst),
        .take_branch((branch_taken && branch) || jump),
        .branch_target(branch_target),
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
        .alu_a_sel(alu_a_sel),
        .branch(branch),
        .jump(jump),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_sel(reg_sel)
    );

    imm_generator imm_gen_inst(
        .instruction(instruction),
        .imm(imm_data)
    );

    always_comb begin
        case (reg_sel)
            ALU     : rd_data   = alu_out;
            MEM     : rd_data   = dmem_out;
            PC4     : rd_data   = pc+4;
            default : rd_data   = alu_out;
        endcase
    end

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

    alu alu_inst(
        .alu_op(alu_op),
        .operand_a(alu_a_sel ? pc : rs1_data),
        .operand_b(imm_select ? imm_data : rs2_data),
        .result(alu_out)
    );

    dmem dmem_inst(
        .clk(clk),
        .addr(alu_out),
        .write_data(rs2_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(instruction[14:12]),
        .read_data(dmem_out)
    );

    branch_comparator branch_comp_inst(
        .alu_result(alu_out),
        .funct3(instruction[14:12]),
        .branch_taken(branch_taken)
    );

endmodule