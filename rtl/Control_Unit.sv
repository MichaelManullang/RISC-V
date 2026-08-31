import riscv_pkg::*;

module control_unit(
    input   logic [31:0]    instruction,

    output  logic           imm_select,

    output  alu_op_t        alu_op,
    output  logic           alu_a_sel, //Operand a selector
    output  logic           branch,
    output  logic           jump,

    output  logic           reg_write,
    output  logic [4:0]     rs1_addr,
    output  logic [4:0]     rs2_addr,
    output  logic [4:0]     rd_addr,

    output  logic           mem_read,
    output  logic           mem_write,
    output  reg_sel_t       reg_sel
);

    logic [6:0] opcode;
    logic [2:0] funct3;

    assign opcode       = instruction[6:0];
    assign rd_addr      = instruction[11:7];
    assign funct3       = instruction[14:12];
    assign rs1_addr     = (opcode == LUI_type || opcode == AUIPC_type || opcode == JAL_type) ? 5'd0 : instruction[19:15];
    assign rs2_addr     = (opcode == R_type || opcode == S_type || opcode == B_type) ? instruction[24:20] : 5'd0;
    // logic [6:0] funct7  = (opcode == R_type) ? instruction[31:25] : 7'd0; //WILL BE USED LATER ON

    assign branch       = (opcode == B_type);
    assign jump         = (opcode == JAL_type);

    always_comb begin : decode
        case (opcode)
            R_type  : begin
                imm_select  = 0;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 0;

                case (funct3)
                    3'b000  : alu_op    = alu_op_t'(instruction[30] ? SUB : ADD);
                    3'b001  : alu_op    = SLL;
                    3'b010  : alu_op    = SLT;
                    3'b011  : alu_op    = SLTU;
                    3'b100  : alu_op    = XOR;
                    3'b101  : alu_op    = alu_op_t'(instruction[30] ? SRA : SRL);
                    3'b110  : alu_op    = OR;
                    3'b111  : alu_op    = AND;
                endcase
            end

            IM_type : begin
                imm_select  = 1;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 0;

                case (funct3)
                    3'b000  : alu_op    = ADD;
                    3'b001  : alu_op    = SLL;
                    3'b010  : alu_op    = SLT;
                    3'b011  : alu_op    = SLTU;
                    3'b100  : alu_op    = XOR;
                    3'b101  : alu_op    = alu_op_t'(instruction[30] ? SRA : SRL);
                    3'b110  : alu_op    = OR;
                    3'b111  : alu_op    = AND;
                endcase
            end

            IL_type : begin
                imm_select  = 1;
                reg_write   = 1;
                mem_read    = 1;
                mem_write   = 0;
                reg_sel     = MEM;
                alu_a_sel   = 0;
                alu_op      = ADD;
            end

            S_type  : begin
                imm_select  = 1;
                reg_write   = 0;
                mem_read    = 0;
                mem_write   = 1;
                reg_sel     = ALU;
                alu_a_sel   = 0;
                alu_op      = ADD;
            end

            B_type  : begin
                imm_select  = 0;
                reg_write   = 0;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 0;
                case (funct3)
                    3'b000  : alu_op    = SUB;
                    3'b001  : alu_op    = SUB;
                    3'b100  : alu_op    = SLT;
                    3'b101  : alu_op    = SLT;
                    3'b110  : alu_op    = SLTU;
                    3'b111  : alu_op    = SLTU;
                    default : alu_op    = SUB;
                endcase
            end

            LUI_type    : begin
                imm_select  = 1;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 0;
                alu_op      = ADD;
            end

            AUIPC_type  : begin
                imm_select  = 1;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 1;
                alu_op      = ADD;
            end

            JAL_type    : begin
                imm_select  = 0;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = PC4;
                alu_a_sel   = 0;
                alu_op      = ADD;
            end

            default: begin
                imm_select  = 0;
                reg_write   = 1;
                mem_read    = 0;
                mem_write   = 0;
                reg_sel     = ALU;
                alu_a_sel   = 0;
                alu_op      = ADD;   
            end
        endcase
    end

endmodule