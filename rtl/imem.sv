module imem #(
    parameter MEM_DEPTH = 1024,           
    parameter string MEM_FILE = "program_2b.hex"
)(
    input  logic [31:0] addr,             
    output logic [31:0] rdata             
);

    logic [31:0] mem [0:MEM_DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    // byte address -> word index: drop the lower 2 bits
    assign rdata = mem[addr[31:2]];

endmodule