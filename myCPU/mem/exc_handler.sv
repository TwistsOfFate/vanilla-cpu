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
`include "cpu_defs.svh"


module exc_handler(
	//INPUT
	input m_is_instr,
	input [31:0] cp0_epc,
	input [31:0] cp0_status,
	input [31:0] cp0_cause,
	input m_in_delay_slot,
	input [31:0] m_pc,
    input [31:0] m_pcminus4,
	input [31:0] m_badvaddr,
	
	input [1:0] m_addr_err,
	input m_reserved_instr,
	input m_intovf,
	input m_break,
	input m_syscall,
	input m_eret,
    input m_mtc0,
    input m_tlbw,
    input m_tlbr,
    input m_tlbp,
    input tlb_exc_t m_tlb_exc,
	
	//OUTPUT
	output logic is_valid_exc,
    output logic exc_cp0_wen,
    output cp0_op_t cp0_op,
    output exc_info_t exc_info
    );

    logic [31:0] m_epc_wdata;
    logic m_cause_bd_wdata;
    logic [4:0] m_cause_exccode_wdata;

    assign exc_cp0_wen = is_valid_exc || m_eret;

    assign exc_info.epc = m_epc_wdata;
    assign exc_info.cause_bd = m_cause_bd_wdata;
    assign exc_info.cause_exccode = m_cause_exccode_wdata;
    assign exc_info.badvaddr = m_badvaddr;

    always_comb begin
    	if (!m_is_instr) begin
    		is_valid_exc = 1'b0;
    		m_cause_exccode_wdata = 5'b0;
            cp0_op = NONE;
    	end else if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'b0) && cp0_status[0] && !cp0_status[1]) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_INT;
            cp0_op = EXC;
    	end else if (m_addr_err == 2'b01) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADEL;
            cp0_op = BADVA;
        // end else if (m_addr_err == 2'b01) begin
        //     is_valid_exc = 1'b1;
        //     m_cause_exccode_wdata = `EXCCODE_ADEL;
        //     cp0_op = BADVA;
    	end else if (m_reserved_instr == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_RI;
            cp0_op = EXC;
    	end else if (m_intovf == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_OV;
            cp0_op = EXC;
    	end else if (m_break == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_BP;
            cp0_op = EXC;
    	end else if (m_syscall == 1'b1) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_SYS;
            cp0_op = EXC;
    	end else if (m_addr_err == 2'b10) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADEL;
            cp0_op = BADVA;
    	end else if (m_addr_err == 2'b11) begin
    		is_valid_exc = 1'b1;
    		m_cause_exccode_wdata = `EXCCODE_ADES;
            cp0_op = BADVA;
        end else if (m_eret) begin
            is_valid_exc = 1'b0;
            m_cause_exccode_wdata = 5'b0;
            cp0_op = ERET;
        end else if (m_mtc0) begin
            is_valid_exc = 1'b0;
            m_cause_exccode_wdata = 5'b0;
            cp0_op = MTC0;
        end else if (m_tlbw) begin
            is_valid_exc = 1'b0;
            m_cause_exccode_wdata = 5'b0;
            cp0_op = TLBW;
        end else if (m_tlbr) begin
            is_valid_exc = 1'b0;
            m_cause_exccode_wdata = 5'b0;
            cp0_op = TLBR;
        end else if (m_tlbp) begin
            is_valid_exc = 1'b0;
            m_cause_exccode_wdata = 5'b0;
            cp0_op = TLBP;
    	end else begin
    		is_valid_exc = 1'b0;
    		m_cause_exccode_wdata = 5'b0;
            cp0_op = NONE;
    	end
    end
    
    always_comb begin
    	if (cp0_status[1]) begin
    		m_epc_wdata = cp0_epc;
    		m_cause_bd_wdata = cp0_cause[31];
    	end else if (m_in_delay_slot == 1'b1) begin
    		m_epc_wdata = m_pcminus4;
    		m_cause_bd_wdata = 1'b1;
    	end else begin
    		m_epc_wdata = m_pc;
    		m_cause_bd_wdata = 1'b0;
    	end
    end
    
endmodule
