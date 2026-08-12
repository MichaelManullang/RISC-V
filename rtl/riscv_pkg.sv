package riscv_pkg;
    typedef enum logic [3:0] {
        ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
    } alu_op_t;

    typedef enum logic [6:0] { 
        R_type  =   7'b0110011,
        IM_type =   7'b0010011,
        IL_type =   7'b0000011,
        S_type  =   7'b0100011
    } opcode_t;

    typedef enum logic [2:0] {
        IMM_I, IMM_S, IMM_B, IMM_U, IMM_J, IMM_NONE
    } imm_type_t;
endpackage