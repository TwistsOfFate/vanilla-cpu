module rdata_latch(
	input clk,
	input rst,
	input stall,
	input flush,
	input data_ok,
	input [31:0] in,
	output [31:0] out
);

	logic [31:0] tmp;
	
	flop #(32)	tmp_ff		(clk, rst | flush, stall & ~data_ok, in, tmp);
	
	assign out = data_ok ? in : tmp;
		
endmodule