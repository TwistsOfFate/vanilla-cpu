`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/13 21:00:17
// Design Name: 
// Module Name: cp0_regfile
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

`include "cpu_defs.svh"

module cp0_regfile(
	input clk,
	input rst,
	input m_stall,
	
	input [5:0] 	ext_int,
	input 			is_valid_exc,
	input [31:0] 	epc_wdata,
	input 			cause_bd_wdata,
	input [4:0] 	cause_exccode_wdata,
	
	input 			wen,
	input [4:0] 	waddr,
	input [31:0] 	wdata,
	input [4:0] 	raddr,
	
	output [31:0]	epc,
	output [31:0] 	status,
	output [31:0] 	cause,
	output [31:0] 	rdata
    );
    
    logic [31:0] regs[31:0];
    logic cnt;
    integer i;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		cnt <= 1'b0;
    		regs[`CP0_STATUS] <= {9'b0, 1'b1, 22'b0};
    		for (i = 0; i < 32; i = i + 1) begin
    		    if (i != `CP0_STATUS) regs[i] <= 32'b0;
    		end
    	end else begin
    		regs[`CP0_CAUSE][15:10] <= ext_int;
	    	if (is_valid_exc && !m_stall) begin
	    		regs[`CP0_EPC] <= epc_wdata;
	    		regs[`CP0_CAUSE][31] <= cause_bd_wdata;
	    		regs[`CP0_STATUS][1] <= 1'b1;
	    		regs[`CP0_CAUSE][6:2] <= cause_exccode_wdata;
	    		if (wen && waddr == `CP0_BADVADDR) begin
	    			regs[`CP0_BADVADDR] <= wdata;
	    		end
	    	end else if (wen && !is_valid_exc || is_valid_exc && !m_stall) begin
	    		case (waddr)
	    			`CP0_CAUSE:		regs[waddr][9:8] <= wdata[9:8];
	    			`CP0_EPC:		regs[waddr] <= wdata;
	    			`CP0_STATUS:	regs[waddr] <= {regs[waddr][31:16], wdata[15:8], regs[waddr][7:2], wdata[1:0]};
	    			`CP0_COUNT:		begin regs[waddr] <= wdata; cnt <= 0; end
	    		endcase
	    	end else begin
	    		cnt <= ~cnt;
	    		regs[`CP0_COUNT] <= regs[`CP0_COUNT] + {31'b0, cnt};
	    	end
	    end
    end
    
    assign epc = regs[`CP0_EPC];
    assign status = regs[`CP0_STATUS];
    assign cause = regs[`CP0_CAUSE];
    assign rdata = regs[raddr];
    
endmodule
