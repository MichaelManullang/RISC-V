module hazard_handler (
    // Current instruction in ID stage
    input  logic [4:0]  id_rs1_addr,        // rs1 field from instruction
    input  logic [4:0]  id_rs2_addr,        // rs2 field from instruction

    // Instruction in EX stage (one cycle ahead)
    input  logic [4:0]  ex_rd_addr,         // destination register of EX instruction
    input  logic        ex_mem_read,        // is EX instruction a load?

    // Control outputs
    output logic        stall_pc,           // freeze PC (don't fetch new instruction)
    output logic        stall_if_id,        // freeze IF/ID pipe register
    output logic        flush_id_ex         // clear ID/EX (insert bubble in EX)
);

    // Load-use hazard conditions:
    // 1. Instruction in EX is a load (LW/LH/LB/LHU/LBU)
    // 2. Load destination register matches rs1 or rs2 of instruction in ID
    // 3. Destination is not x0 (writing to x0 has no effect)
    // 4. rs1/rs2 is not x0 (reading x0 always returns 0, no hazard)

    logic load_use_rs1, load_use_rs2;

    assign load_use_rs1 = ex_mem_read && (ex_rd_addr == id_rs1_addr) && (id_rs1_addr != 5'd0) && (ex_rd_addr != 5'd0);
    assign load_use_rs2 = ex_mem_read && (ex_rd_addr == id_rs2_addr) && (id_rs2_addr != 5'd0) && (ex_rd_addr != 5'd0);

    assign stall_pc     = load_use_rs1 || load_use_rs2;
    assign stall_if_id  = load_use_rs1 || load_use_rs2;
    assign flush_id_ex  = load_use_rs1 || load_use_rs2;

endmodule