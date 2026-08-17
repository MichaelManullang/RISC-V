module branch_comparator (
    input   logic [31:0]    alu_result,
    input   logic [2:0]     funct3,
    output  logic           branch_taken
);

    wire raw_cond;
    assign raw_cond     = (funct3[2:1] == 2'b00) ? (alu_result == 32'd0) : (alu_result[0]);
    assign branch_taken = (funct3[0]) ? (~raw_cond) : (raw_cond);

endmodule