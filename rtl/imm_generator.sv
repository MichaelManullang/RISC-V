import riscv_pkg::*;

module imm_generator (
    input   logic [31:0]    instruction,
    output  logic [31:0]    imm
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    imm_type_t imm_type;

    always_comb begin
        case (opcode)
            7'b0010011,                     // I-type ALU
            7'b0000011,                     // loads
            7'b1100111 : imm_type = IMM_I;  // JALR
            7'b0100011 : imm_type = IMM_S;  // stores
            7'b1100011 : imm_type = IMM_B;  // branches
            7'b0110111,                     // LUI
            7'b0010111 : imm_type = IMM_U;  // AUIPC
            7'b1101111 : imm_type = IMM_J;  // JAL
            default    : imm_type = IMM_NONE; // R-type, no immediate
        endcase
    end

    always_comb begin
        case (imm_type)
            IMM_I   : imm = {{20{instruction[31]}}, instruction[31:20]};

            IMM_S   : imm = {{20{instruction[31]}}, instruction[31:25],
                              instruction[11:7]};

            IMM_B   : imm = {{19{instruction[31]}}, instruction[31],
                              instruction[7], instruction[30:25],
                              instruction[11:8], 1'b0};

            IMM_U   : imm = {instruction[31:12], 12'b0};

            IMM_J   : imm = {{11{instruction[31]}}, instruction[31],
                              instruction[19:12], instruction[20],
                              instruction[30:21], 1'b0};

            default : imm = 32'd0;   // R-type: no immediate, doesn't matter
        endcase
    end

endmodule