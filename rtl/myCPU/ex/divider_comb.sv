`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 16:16:17
// Design Name: 
// Module Name: divider
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


module divider_comb(
	input logic sign,
	input logic [31:0] srca,
	input logic [31:0] srcb,
	output logic out_valid,
	output logic [31:0] hi,
	output logic [31:0] lo
    );
    logic[31:0] shi, slo, uhi, ulo;
    assign shi = signed'(srca) % signed'(srcb);
    assign slo = signed'(srca) / signed'(srcb);
    assign uhi = srca % srcb;
    assign ulo = srca / srcb;
    
    
    assign out_valid = 1'b1;
    assign hi = sign ? shi : uhi;
	assign lo = sign ? slo : ulo;
    
endmodule
