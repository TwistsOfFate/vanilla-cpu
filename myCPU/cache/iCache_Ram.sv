`include "iCache.vh"

/* byte */

module iCache_Ram #(
	parameter DATA_WIDTH   = 32,
			  OFFSET_SIZE  = 2 ** (`ICACHE_B - 2)
)(
	input  logic clk,
	input  logic [`ICACHE_S - 1 : 0]   addr,
	input  logic [DATA_WIDTH - 1 : 0]  din,
	output logic [DATA_WIDTH - 1 : 0]  wdata,
	input  logic wen
);

	logic [OFFSET_SIZE * 32 - 1 : 0] RAM[2 ** `ICACHE_S - 1 : 0];

	assign wdata = RAM[addr];

    always_ff @(posedge clk)
        if (wen) RAM[addr] <= din;
	
endmodule