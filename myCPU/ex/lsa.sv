module lsa(
	input [31:0] rsdata,
	input [31:0] rtdata,
	input [1:0] sa,
	output logic [31:0] out
	);

logic [2:0] sad;
logic [31:0] pout;

assign sad = {1'b0, sa} + 3'b1;
assign pout = rsdata << sad;
assign out = pout + rtdata;

endmodule