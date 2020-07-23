`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/14 13:24:47
// Design Name: 
// Module Name: data_addr_check
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


module data_addr_check(
	input			memreq,
	input			wr,
	input [31:0]	addr,
	input [1:0]		size,
	input 			addr_err_if,
	input [31:0]	badvaddr_if,
	
	output logic [31:0]	badvaddr,
	output logic [1:0]	addr_err,
	output logic		m_req
    );
    
    logic addr_err_mem;
    
    always_comb begin
    	if (memreq == 1'b1 && (size == 2'b01 && addr[0] != 1'b0 || size == 2'b10 && addr[1:0] != 2'b00)) begin
    		addr_err_mem = 1'b1;
    	end else begin
    		addr_err_mem = 1'b0;
    	end
    end
    
    always_comb begin
    	if (addr_err_if) begin
    		badvaddr = badvaddr_if;
    		addr_err = 2'b01;
    		m_req = 1'b0;
    	end else if (addr_err_mem) begin
    		badvaddr = addr;
    		addr_err = {1'b1, wr};
    		m_req = 1'b0;
    	end else begin
    		badvaddr = 32'b0;
    		addr_err = 2'b00;
    		m_req = memreq;
    	end
    end
        
endmodule
