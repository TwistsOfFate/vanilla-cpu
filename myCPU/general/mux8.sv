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
	case (sel)
		'b000:		tmp = a;
		'b001:		tmp = b;
		'b010:		tmp = c;
		'b011:		tmp = d;
		'b100:		tmp = e;
		'b101:		tmp = f;
		'b110:		tmp = g;
		'b111:		tmp = h;
	endcase
    
assign out = tmp;
    
endmodule