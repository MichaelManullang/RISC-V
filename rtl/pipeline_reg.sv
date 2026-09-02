module pipe_reg #(
    parameter WIDTH = 32
)(
    input   logic               clk,
    input   logic               rst,

    input   logic               flush,
    input   logic               stall,

    input   logic [WIDTH-1:0]   din,
    output  logic [WIDTH-1:0]   dout
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            dout    <= 0;
        else if (flush)
            dout    <= 0;
        else if (!stall)
            dout    <= din;
    end

endmodule