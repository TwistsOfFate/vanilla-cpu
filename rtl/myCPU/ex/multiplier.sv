`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 12:42:10
// Design Name: 
// Module Name: multiplier
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


module multiplier(
	input sign,
	input [31:0] srca,
	input [31:0] srcb,
	output [31:0] hi,
	output [31:0] lo
	);

	logic [63:0] tmp;
	
	always_comb begin
		case (sign)
			1'b0:		tmp = srca * srcb;
			1'b1:		tmp = signed'(srca) * signed'(srcb);
			default:	tmp = srca * srcb;
		endcase
	end
	
	assign hi = tmp[63:32];
	assign lo = tmp[31:0];
    
endmodule
