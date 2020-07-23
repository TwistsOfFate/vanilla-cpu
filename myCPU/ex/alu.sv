`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 12:17:35
// Design Name: 
// Module Name: alu
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


module alu(
	input [2:0] func,
	input [31:0] srca,
	input [31:0] srcb,
	output zero,
	output sign,
	output [31:0] out,
	output intovf
);

wire [32:0] a, b;
logic [32:0] tmp;

assign a = {srca[31], srca};
assign b = {srcb[31], srcb};

always_comb begin
	case (func)
		3'b000:		tmp = a + b;
		3'b001:		tmp = a - b;
		3'b010:		tmp = ($signed(srca) < $signed(srcb) ? 32'b1 : 32'b0);
		3'b011:		tmp = (srca < srcb ? 32'b1 : 32'b0);
		3'b100:		tmp = a & b;
		3'b101:		tmp = ~(a | b);
		3'b110:		tmp = a | b;
		3'b111:		tmp = a ^ b;
		default:	tmp = a + b;
	endcase
end

assign out = tmp[31:0];
assign zero = (out == 32'b0);
assign sign = out[31];
assign intovf = (tmp[32] != tmp[31]);

endmodule
