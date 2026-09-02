import riscv_pkg::*;

module Top_pipeline(
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
    logic           csr_write;
    logic   [31:0]  csr_rdata;
    logic   [2:0]   funct3;
    logic   [31:0]  pc_plus_4;          // pc+4 for JAL writeback
    logic   [31:0]  wb_rd_data;          // final writeback data (mux output)

    // PIPELINE Hazard Handler Signal
    logic   stall_pc,
            stall_if_id, 
            flush_id_ex;

    // IF / ID
    pipe_if_id_t    if_id_next, //Upcoming IF/ID data
                    pipe_if_id; //Stored IF/ID
    assign  if_id_next  = {pc,instruction};

    // ID / EX
    pipe_id_ex_t    id_ex_next, //Upcoming ID/EX data
                    pipe_id_ex; //Stored ID/EX
    assign  id_ex_next  = { rs1_data,
                            rs2_data,
                            imm_data,
                            alu_op,
                            alu_a_sel,
                            imm_select,
                            rd_addr,
                            reg_write,
                            mem_read,
                            mem_write,
                            reg_sel,
                            csr_write,
                            funct3,
                            pc};

    // EX / MEM
    pipe_ex_mem_t   ex_mem_next, //Upcoming EX/MEM
                    pipe_ex_mem; //Stored EX/MEM
    assign  ex_mem_next = { alu_out,
                            pipe_id_ex.rs2_data,   
                            pipe_id_ex.rd_addr,
                            pipe_id_ex.reg_write,
                            pipe_id_ex.mem_read,
                            pipe_id_ex.mem_write,
                            pipe_id_ex.reg_sel,
                            pipe_id_ex.funct3,
                            pipe_id_ex.pc + 32'd4};    

    // MEM / WB
    pipe_mem_wb_t   mem_wb_next, //Upcoming MEM/WB
                    pipe_mem_wb; //Stored MEM/WB
    assign  mem_wb_next = { dmem_out,
                            pipe_ex_mem.alu_result,
                            pipe_ex_mem.rd_addr,
                            pipe_ex_mem.reg_write,
                            pipe_ex_mem.reg_sel,
                            pipe_ex_mem.pc_plus_4};

    assign  branch_target   = pc + imm_data;

    program_counter pc_inst(
        .clk(clk),
        .rst(rst),
        .stall_pc(stall_pc),
        .take_branch((branch_taken && branch) || jump),
        .branch_target(branch_target),
        .pc(pc)
    );

    imem imem_inst (
        .addr(pc),
        .rdata(instruction)
    );

    control_unit cu_inst(
        .instruction(pipe_if_id.instruction),
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
        .reg_sel(reg_sel),
        .csr_write(csr_write)
    );

    hazard_handler hazard_handler_inst(
       .id_rs1_addr(pipe_if_id.instruction[19:15]),
       .id_rs2_addr(pipe_if_id.instruction[24:20]),
       .ex_rd_addr(pipe_id_ex.rd_addr),
       .ex_mem_read(pipe_id_ex.mem_read),
       .stall_pc(stall_pc),
       .stall_if_id(stall_if_id),
       .flush_id_ex(flush_id_ex)
   );

    imm_generator imm_gen_inst(
        .instruction(pipe_if_id.instruction),
        .imm(imm_data)
    );

    always_comb begin
        case (pipe_mem_wb.reg_sel)
            ALU     : wb_rd_data = pipe_mem_wb.alu_result;
            MEM     : wb_rd_data = pipe_mem_wb.dmem_data;
            PC4     : wb_rd_data = pipe_mem_wb.pc_plus_4;
            CSR     : wb_rd_data = csr_rdata;
            default : wb_rd_data = pipe_mem_wb.alu_result;
        endcase
    end

    regfile regfile_inst(
        .clk(clk),
        .rs1_addr(pipe_if_id.instruction[19:15]),     // ID stage reads
        .rs1_data(rs1_data),
        .rs2_addr(pipe_if_id.instruction[24:20]),
        .rs2_data(rs2_data),
        .rd_addr(pipe_mem_wb.rd_addr),                 // WB stage writes
        .rd_data(wb_rd_data),                          // from WB mux
        .reg_write(pipe_mem_wb.reg_write)               // from WB stage
    );

    alu alu_inst(
        .alu_op(pipe_id_ex.alu_op),
        .operand_a(pipe_id_ex.alu_a_sel ? pipe_id_ex.pc : pipe_id_ex.rs1_data),
        .operand_b(pipe_id_ex.imm_select ? pipe_id_ex.imm_data : pipe_id_ex.rs2_data),
        .result(alu_out)
    );

    dmem dmem_inst(
        .clk(clk),
        .addr(pipe_ex_mem.alu_result),
        .write_data(pipe_ex_mem.rs2_data),
        .mem_read(pipe_ex_mem.mem_read),
        .mem_write(pipe_ex_mem.mem_write),
        .funct3(pipe_ex_mem.funct3),
        .read_data(dmem_out)
    );

    branch_comparator branch_comp_inst(
        .alu_result(alu_out),
        .funct3(funct3),
        .branch_taken(branch_taken)
    );

    pipe_reg #(.WIDTH($bits(pipe_if_id_t))) if_id_reg (
        .clk(clk),
        .rst(rst),
        .flush(0),
        .stall(stall_if_id),
        .din(if_id_next),
        .dout(pipe_if_id)
    );

    pipe_reg #(.WIDTH($bits(pipe_id_ex_t))) id_ex_reg (
        .clk(clk),
        .rst(rst),
        .flush(flush_id_ex),
        .stall(0),
        .din(id_ex_next),
        .dout(pipe_id_ex)
    );

    pipe_reg #(.WIDTH($bits(pipe_ex_mem_t))) ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .flush(0),
        .stall(0),
        .din(ex_mem_next),
        .dout(pipe_ex_mem)
    );

    pipe_reg #(.WIDTH($bits(pipe_mem_wb_t))) mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .flush(0),
        .stall(0),
        .din(mem_wb_next),
        .dout(pipe_mem_wb)
    );

    csr_regs csr_inst(
        .clk(clk),
        .rst(rst),
        .csr_write(csr_write),
        .csr_addr(instruction[31:20]),
        .csr_wdata(rs1_data),
        .csr_rdata(csr_rdata)
    );

endmodule