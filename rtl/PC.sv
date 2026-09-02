module program_counter(
    input   logic           clk,
    input   logic           rst,

    input   logic           stall_pc,

    input   logic           take_branch,
    input   logic [31:0]    branch_target,
    
    output  logic [31:0]    pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc  <= 32'h0000_0000;
        else if (stall_pc)
            pc  <= pc;
        else if (take_branch)
            pc  <= branch_target;
        else
            pc  <= pc + 32'd4;
    end
endmodule