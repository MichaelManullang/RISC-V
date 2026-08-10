module regfile (
    input  logic        clk,

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

    logic [31:0] regs [31:0];
    /* ----------IMPLEMENTED LATER ON----------------------------
    Register  |  ABI Name  |  Description
    -----------------------------------------
    x0        |  zero      |  Hardwired to 0
    x1        |  ra        |  Return address
    x2        |  sp        |  Stack pointer
    x3        |  gp        |  Global pointer
    x4        |  tp        |  Thread pointer
    x5-x7     |  t0-t2     |  Temporary registers
    x8        |  s0 / fp   |  Saved register / Frame pointer
    x9        |  s1        |  Saved register
    x10-x11   |  a0-a1     |  Function arguments / return values
    x12-x17   |  a2-a7     |  Function arguments
    x18-x27   |  s2-s11    |  Saved registers
    x28-x31   |  t3-t6     |  Temporary registers
    -----------------------------------------------------------*/

    // Reads combinational
    // Further enhancement will be developed
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    // Synchronus write
    always_ff @(posedge clk) begin
        if (reg_write && rd_addr != 5'd0)
            regs[rd_addr]   <= rd_data;
    end
endmodule