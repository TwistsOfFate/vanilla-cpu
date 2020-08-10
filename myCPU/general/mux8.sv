`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 18:28:16
// Design Name: 
// Module Name: mux8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux8 #(
	parameter WIDTH = 32
)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [WIDTH-1:0] d,
	input [WIDTH-1:0] e,
	input [WIDTH-1:0] f,
	input [WIDTH-1:0] g,
	input [WIDTH-1:0] h,
	input [2:0]	sel,
	output [WIDTH-1:0] out
    );

logic [31:0] tmp;

always_comb
	unique case (sel)
		3'b000:		tmp = a;
		3'b001:		tmp = b;
		3'b010:		tmp = c;
		3'b011:		tmp = d;
		3'b100:		tmp = e;
		3'b101:		tmp = f;
		3'b110:		tmp = g;
		3'b111:		tmp = h;
	endcase
    
assign out = tmp;
    
endmodule