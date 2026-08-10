import riscv_pkg::*;

module ALU (
    input   alu_op_t        alu_op,
    input   logic [31:0]    operand_a,
    input   logic [31:0]    operand_b,
    output  logic [31:0]    result
);
    always_comb begin
        case (alu_op)
            ADD  : result = operand_a + operand_b;
            SUB  : result = operand_a - operand_b;
            SLL  : result = operand_a << operand_b[4:0];
            SLT  : result = ($signed(operand_a) < $signed(operand_b));
            SLTU : result = (operand_a < operand_b);
            XOR  : result = operand_a ^ operand_b;
            SRL  : result = operand_a >> operand_b[4:0];
            SRA  : result = $signed(operand_a) >>> operand_b[4:0];
            OR   : result = operand_a | operand_b;
            AND  : result = operand_a & operand_b;
        endcase
    end
endmodule