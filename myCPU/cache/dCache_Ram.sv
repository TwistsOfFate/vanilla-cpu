`include "dCache.vh"

module dCache_Ram #(
    parameter DATA_WIDTH   = 32,
              OFFSET_SIZE  = 2 ** (`CACHE_B - 2)
)(
    input  logic                         clk, reset,
    input  logic [`CACHE_S - 1 : 0]      addr,
    input  logic [1 : 0]                 bit_pos,
    input  logic [`CACHE_B - 3 : 0]      offset,
    input  logic [1 : 0]                 size,
    input  logic [DATA_WIDTH - 1 : 0]    din,
    output logic [DATA_WIDTH - 1 : 0]    wdata,
    input  logic                         wen,
    input  logic                         data_ok
);
    logic [DATA_WIDTH - 1 : 0] RAM[2 ** `CACHE_S - 1 : 0];

    assign wdata = RAM[addr];

    always_ff @(posedge clk)
        if (reset)
            for (int i = 0; i < 2 ** `CACHE_S; i = i + 1) RAM[i] <= '0;
        else if (wen)
        //  case (wen)
        //  1'b1: 
            case (size)
                2'b00: RAM[addr][offset * 32 + bit_pos * 8 +: 8] <= din[offset * 32 + bit_pos * 8 +: 8];
                2'b01: RAM[addr][offset * 32 + bit_pos * 8 +: 16] <= din[offset * 32 + bit_pos * 8 +: 8];
                2'b10: RAM[addr][offset * 32 +: 32] <= din[offset * 32 +: 32];
                default : RAM[addr] <= din;
            endcase
            
        /*  default: case (size)
                2'b00: RAM[addr[31 : 2]][addr[1 : 0] +: 8] <= din[addr[1 : 0] +: 8];
                2'b01: RAM[addr[31 : 2]][addr[1 : 0] +: 16] <= din[addr[1 : 0] +: 16];
                default : RAM[addr[31 : 2]] <= din;
                endcase
        endcase */

endmodule