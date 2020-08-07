`include "dCache.vh"

module dCache_Ram #(
    parameter DATA_WIDTH   = 32,
              OFFSET_SIZE  = 2 ** (`DCACHE_B - 2)
)(
    input  logic                         clk, 
    input  logic [`DCACHE_S - 1 : 0]     addr,
    input  logic [1 : 0]                 bit_pos,
    input  logic [`DCACHE_B - 3 : 0]     offset,
    input  logic [1 : 0]                 size,
    input  logic [DATA_WIDTH - 1 : 0]    din,
    output logic [DATA_WIDTH - 1 : 0]    wdata,
    input  logic                         wen
);
    logic [DATA_WIDTH - 1 : 0] RAM[2 ** `DCACHE_S - 1 : 0];

    assign wdata = RAM[addr];

    always_ff @(posedge clk)
        if (wen)
            case (size)
                3'b00: RAM[addr][offset * 32 + bit_pos * 8 +: 8] <= din[offset * 32 + bit_pos * 8 +: 8];
                3'b01: RAM[addr][offset * 32 + bit_pos * 8 +: 16] <= din[offset * 32 + bit_pos * 8 +: 16];
                3'b10: RAM[addr][offset * 32 +: 32] <= din[offset * 32 +: 32];
                3'b11 : RAM[addr][offset * 32 + bit_pos * 8 +: 24] <= din[offset * 32 + bit_pos * 8 +: 24];
                default : RAM[addr] <= din;
            endcase

endmodule