module regfile (
    input  logic        clk,
    input  logic        rst,

    // Read port 1 (rs1)
    input  logic [4:0]  rs1_addr,
    output logic [31:0] rs1_data,

    // Read port 2 (rs2)
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs2_data,

    // Write port (rd)
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    input  logic        reg_write
);
endmodule