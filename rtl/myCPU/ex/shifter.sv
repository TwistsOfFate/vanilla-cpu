`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 12:41:47
// Design Name: 
// Module Name: shifter
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


module shifter(
	input [31:0] srca,
	input [4:0] srcb,
	input [1:0] func,
	output [31:0] out
	);
	
	logic [31:0] tmp;
	
	always_comb begin
		case (func)
			2'b00:		tmp = {srca[15:0], 16'b0};
			2'b01:		tmp = srca << srcb;
			2'b10:		tmp = $signed(srca) >>> srcb;
			2'b11:		tmp = srca >> srcb;
			default:	tmp = {32{1'b1}};
		endcase
	end
	
	assign out = tmp;
	
endmodule
