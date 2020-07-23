`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 14:34:46
// Design Name: 
// Module Name: bta_generator
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


module bta_generator(
	input [31:0] pc,
	input [15:0] offset,
	output [31:0] out
    );
    
    assign out = {{14{offset[15]}}, offset, 2'b0} + pc + 32'd4;
    
endmodule
