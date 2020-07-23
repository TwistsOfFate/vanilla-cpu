`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/14 09:01:47
// Design Name: 
// Module Name: exc_handler
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


module exc_handler(
	//INPUT
	input m_is_instr,
	input [31:0] cp0_epc,
	input [31:0] cp0_status,
	input [31:0] cp0_cause,
	input m_in_delay_slot,
	input [31:0] m_pc,
	input [31:0] m_badvaddr,
	
	input [1:0] m_addr_err,
	input m_reserved_instr,
	input m_intovf,
	input m_break,
	input m_syscall,
	input m_eret,
	
	//OUTPUT
	output logic is_valid_exc,
	output logic [31:0] m_epc_wdata,
	output logic m_cause_bd_wdata,
	output logic [4:0] m_cause_exccode_wdata,
	
	output logic m_cp0_wen,
	output logic [4:0] m_cp0_waddr,
	output logic [31:0] m_cp0_wdata
    );
    
    always_comb begin
    	if (!m_is_instr) begin
    		is_valid_exc = 1'b0;
    		m_cause_exccode_wdata = 5'b0;
    	end else if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'b0) && cp0_status[0] && !cp0_status[1]) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_INT;
    	end else if (m_addr_err == 2'b01) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADEL;
    	end else if (m_reserved_instr == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_RI;
    	end else if (m_intovf == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_OV;
    	end else if (m_break == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_BP;
    	end else if (m_syscall == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_SYS;
    	end else if (m_addr_err == 2'b10) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADEL;
    	end else if (m_addr_err == 2'b11) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADES;
    	end else begin
    		is_valid_exc = 1'b0;
    		m_cause_exccode_wdata = 5'b0;
    	end
    end
    
    always_comb begin
    	if (cp0_status[1]) begin
    		m_epc_wdata = cp0_epc;
    		m_cause_bd_wdata = cp0_cause[31];
    	end else if (m_in_delay_slot == 1'b1) begin
    		m_epc_wdata = m_pc - 32'd4;
    		m_cause_bd_wdata = 1'b1;
    	end else begin
    		m_epc_wdata = m_pc;
    		m_cause_bd_wdata = 1'b0;
    	end
    end
    
    always_comb begin
    	if (m_addr_err != 2'b00) begin
    		m_cp0_wen = 1'b1;
    		m_cp0_waddr = `CP0_BADVADDR;
    		m_cp0_wdata = m_badvaddr;
    	end else if (m_eret == 1'b1) begin
    		m_cp0_wen = 1'b1;
    		m_cp0_waddr = `CP0_STATUS;
    		m_cp0_wdata = {cp0_status[31:2], 1'b0, cp0_status[0]};
    	end else begin
    		m_cp0_wen = 1'b0;
    		m_cp0_waddr = 32'b0;
    		m_cp0_wdata = 32'b0;
    	end
    end
    
endmodule
