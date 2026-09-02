package riscv_pkg;
    typedef enum logic [3:0] {
        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
    } alu_op_t;

    typedef enum logic [6:0] { 
        R_type      =   7'b0110011,
        IM_type     =   7'b0010011,
        IL_type     =   7'b0000011,
        S_type      =   7'b0100011,
        B_type      =   7'b1100011,
        LUI_type    =   7'b0110111,
        AUIPC_type  =   7'b0010111,
        JAL_type    =   7'b1101111,
        CSR_type    =   7'b1110011
    } opcode_t;

    typedef enum logic [2:0] {
        IMM_I, IMM_S, IMM_B, IMM_U, IMM_J, IMM_NONE
    } imm_type_t;

    typedef enum logic [1:0] {
        ALU, MEM, PC4, CSR
    } reg_sel_t;

    typedef struct packed {
        logic   [31:0]  pc;
        logic   [31:0]  instruction;
    } pipe_if_id_t;

    typedef struct packed {
        logic   [31:0]  rs1_data;
        logic   [31:0]  rs2_data;
        logic   [31:0]  imm_data;
        alu_op_t        alu_op;
        logic           alu_a_sel;
        logic           imm_select;
        logic   [4:0]   rd_addr;
        logic           reg_write;
        logic           mem_read;
        logic           mem_write;
        reg_sel_t       reg_sel;
        logic           csr_write;
        logic   [2:0]   funct3;
        logic   [31:0]  pc;
    } pipe_id_ex_t;

    typedef struct packed {
        logic   [31:0]  alu_result;
        logic   [31:0]  rs2_data;       // for stores
        logic   [4:0]   rd_addr;
        logic           reg_write;
        logic           mem_read;
        logic           mem_write;
        reg_sel_t       reg_sel;
        logic   [2:0]   funct3;
        logic   [31:0]  pc_plus_4;      // for JAL return address
    } pipe_ex_mem_t;

    typedef struct packed {
        logic   [31:0]  dmem_data;       // from load
        logic   [31:0]  alu_result;         // from ALU (pass-through for non-loads)
        logic   [4:0]   rd_addr;
        logic           reg_write;
        reg_sel_t       reg_sel;
        logic   [31:0]  pc_plus_4;       // for JAL return address
    } pipe_mem_wb_t;
endpackage