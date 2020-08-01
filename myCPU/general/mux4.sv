module mux4 #(
	parameter WIDTH = 32
)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [WIDTH-1:0] d,
	input [1:0]	sel,
	output [WIDTH-1:0] out
    );
    
    assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);
    
endmodule
