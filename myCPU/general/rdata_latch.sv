module rdata_latch #(
	parameter WIDTH = 32
)(
	input clk,
	input rst,
	input stall,
	input flush,
	input data_ok,
	input [WIDTH-1:0] in,
	output [WIDTH-1:0] out
);
	
	logic [WIDTH-1:0] tmp;

	flop #(WIDTH)	tmp_ff		(clk, rst | flush, stall & ~data_ok, in, tmp);
	
	assign out = data_ok ? in : tmp;
		
endmodule