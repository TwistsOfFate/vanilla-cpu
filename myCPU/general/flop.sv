`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 17:42:17
// Design Name: 
// Module Name: flop
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


module flop #(
	parameter WIDTH=32
)(
	input clk,
	input rst,
	input stall,
	input [WIDTH-1:0] in,
	output [WIDTH-1:0] out
    );
    
    integer i;
    logic [WIDTH-1:0] tmp;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		for (i = 0; i < WIDTH; i = i + 1) begin
    			tmp[i] <= 1'b0;
    		end
    	end else if (stall) begin
    		tmp <= tmp;
    	end else begin
    		tmp <= in;
    	end
    end
    
    assign out = tmp;
    
endmodule
