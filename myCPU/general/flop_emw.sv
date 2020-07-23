`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 17:42:17
// Design Name: 
// Module Name: flop_emw
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

`include "../cpu_defs.svh"

module flop_emw #(
	parameter WIDTH=32
)(
	input 					clk,
	input 					rst,
	input  stall_flush_t 	sig,
	input  [WIDTH-1:0] 		d,
	
	output [WIDTH-1:0] 		e,
	output [WIDTH-1:0] 		m,
	output [WIDTH-1:0] 		w
    );
    
    flop #(WIDTH) de_flop(clk, rst | sig.e_flush, sig.e_stall, d, e);
    flop #(WIDTH) em_flop(clk, rst | sig.m_flush, sig.m_stall, e, m);
    flop #(WIDTH) mw_flop(clk, rst | sig.w_flush, sig.w_stall, m, w);
    
endmodule
