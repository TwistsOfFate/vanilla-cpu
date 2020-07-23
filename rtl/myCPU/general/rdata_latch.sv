module rdata_latch(
	input clk,
	input rst,
	input stall,
	input flush,
	input data_ok,
	input [31:0] in,
	output [31:0] out
);
	
//	wire stall_late, flush_late;
	logic [31:0] tmp;
	
//	flop #(1) 	stall_ff 	(clk, rst, 1'b0, stall, stall_late);
//	flop #(1) 	flush_ff 	(clk, rst, 1'b0, flush, flush_late);
	flop #(32)	tmp_ff		(clk, rst | flush, stall & ~data_ok, in, tmp);
	
	assign out = data_ok ? in : tmp;
		
endmodule