module dmem #(
    parameter MEM_DEPTH = 4096
)(
    input   logic           clk,
    input   logic [31:0]    addr,        
    input   logic [31:0]    write_data,  
    input   logic           mem_read,    
    input   logic           mem_write,   
    input   logic [2:0]     funct3,      
    output  logic [31:0]    read_data
);
    //unaligned access implicitly supported by this byte-array model; 
    //real hardware may not guarantee this
    logic [7:0] mem [0:MEM_DEPTH-1];

    //Write Path
    always_ff @(posedge clk) begin : Write_seq
        if (mem_write) begin
            case (funct3)
                3'b000  : 
                    mem[addr]   <=  write_data[7:0];

                3'b001  : begin
                    mem[addr]   <=  write_data[7:0];
                    mem[addr+1] <=  write_data[15:8];
                end

                3'b010 : begin 
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end

                default : begin 
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end
            endcase
        end
    end

    //Read Path
    always_comb begin : Read_seq
        if (mem_read) begin
            case (funct3)
                3'b000  : read_data = {{24{mem[addr][7]}}, mem[addr]};
                3'b001  : read_data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
                3'b010  : read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                3'b100  : read_data = {24'b0, mem[addr]};
                3'b101  : read_data = {16'b0, mem[addr+1], mem[addr]};
                default : read_data = 32'd0;
            endcase
        end
        else
            read_data = 32'd0;
    end

endmodule