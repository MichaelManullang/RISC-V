// Minimal CSR register file for RV32I compliance testing
// Supports: mstatus, mie, mtvec, mepc, mcause, mtval, mip, mscratch, medeleg, mideleg
// Other CSR addresses read 0 and ignore writes
module csr_regs (
    input   logic           clk,
    input   logic           rst,

    // CSR access
    input   logic           csr_write,
    input   logic [11:0]    csr_addr,
    input   logic [31:0]    csr_wdata,
    output  logic [31:0]    csr_rdata
);

    // CSR storage — only the ones we need
    logic [31:0] mstatus;
    logic [31:0] mtvec;
    logic [31:0] mepc;
    logic [31:0] mcause;
    logic [31:0] mtval;
    logic [31:0] mscratch;

    // Write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            mstatus   <= 32'h0;
            mtvec     <= 32'h0;
            mepc      <= 32'h0;
            mcause    <= 32'h0;
            mtval     <= 32'h0;
            mscratch  <= 32'h0;
        end
        else if (csr_write) begin
            case (csr_addr)
                // Read/write CSRs
                12'h300: mstatus   <= csr_wdata;
                12'h305: mtvec     <= csr_wdata;
                12'h340: mscratch  <= csr_wdata;
                12'h341: mepc      <= csr_wdata;
                12'h342: mcause    <= csr_wdata;
                12'h343: mtval     <= csr_wdata;
                // Write-ignored (reads 0)
                12'h304, 12'h344, 12'h302, 12'h303: ; // mie, mip, medeleg, mideleg — ignore writes
                default: ;
            endcase
        end
    end

    // Read logic (combinational)
    always_comb begin
        case (csr_addr)
            12'h300: csr_rdata = mstatus;
            12'h304: csr_rdata = 32'h0;   // mie
            12'h305: csr_rdata = mtvec;
            12'h340: csr_rdata = mscratch;
            12'h341: csr_rdata = mepc;
            12'h342: csr_rdata = mcause;
            12'h343: csr_rdata = mtval;
            12'h344: csr_rdata = 32'h0;   // mip
            12'h302: csr_rdata = 32'h0;   // medeleg
            12'h303: csr_rdata = 32'h0;   // mideleg
            default: csr_rdata = 32'h0;
        endcase
    end

endmodule