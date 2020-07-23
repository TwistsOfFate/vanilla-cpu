`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/16 17:13:35
// Design Name: 
// Module Name: pc_flop
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


module pc_flop #(
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
    		tmp <= 32'hBFC0_0000;
    	end else if (stall) begin
    		tmp <= tmp;
    	end else begin
    		tmp <= in;
    	end
    end
    
    assign out = tmp;
    
endmodule
