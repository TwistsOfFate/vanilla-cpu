`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 18:28:16
// Design Name: 
// Module Name: mux4
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


module mux4 #(
	parameter WIDTH = 32
)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [WIDTH-1:0] d,
	input [1:0]	sel,
	output logic [WIDTH-1:0] out
    );
    
    always_comb
    	unique case (sel)
    		2'b00:	out = a;
    		2'b01:	out = b;
    		2'b10:	out = c;
    		2'b11:  out = d;
    	endcase
    // assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);
    
endmodule
