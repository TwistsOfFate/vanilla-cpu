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
    input tlb_req_t m_tlb_req,
    input tlb_exc_t tlb_exc_if,
    input tlb_exc_t tlb_exc_mem,
	
	//OUTPUT
	output logic is_valid_exc,
    output logic [31:0] exc_addr,
    output cp0_op_t cp0_op,
    output exc_info_t exc_info
    );

    assign exc_info.badvaddr = tlb_exc_if != NO_EXC ? m_pc : m_badvaddr;

    always_comb begin
    	if (!m_is_instr) begin
    		is_valid_exc = 1'b0;
    		exc_info.cause_exccode = 5'b0;
            cp0_op = OP_NONE;
            exc_addr = 32'hBFC00380;
    	end else if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'b0) && cp0_status[0] && !cp0_status[1]) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_INT;
            cp0_op = OP_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_addr_err == 2'b01) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_ADEL;
            cp0_op = OP_BADVA;
            exc_addr = 32'hBFC00380;
        end else if (tlb_exc_if == REFILL_L) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBL;
            cp0_op = OP_TLB_EXC;
            exc_addr = cp0_status[1] ? 32'hBFC00380 : 32'hBFC00200;
        end else if (tlb_exc_if == INVALID_L) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBL;
            cp0_op = OP_TLB_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_reserved_instr == 1'b1) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_RI;
            cp0_op = OP_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_intovf == 1'b1) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_OV;
            cp0_op = OP_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_break == 1'b1) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_BP;
            cp0_op = OP_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_syscall == 1'b1) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_SYS;
            cp0_op = OP_EXC;
            exc_addr = 32'hBFC00380;
    	end else if (m_addr_err == 2'b10) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_ADEL;
            cp0_op = OP_BADVA;
            exc_addr = 32'hBFC00380;
    	end else if (m_addr_err == 2'b11) begin
    		is_valid_exc = 1'b1;
    		exc_info.cause_exccode = `EXCCODE_ADES;
            cp0_op = OP_BADVA;
            exc_addr = 32'hBFC00380;
        end else if (tlb_exc_mem == REFILL_L) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBL;
            cp0_op = OP_TLB_EXC;
            exc_addr = cp0_status[1] ? 32'hBFC00380 : 32'hBFC00200;
        end else if (tlb_exc_mem == REFILL_S) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBS;
            cp0_op = OP_TLB_EXC;
            exc_addr = cp0_status[1] ? 32'hBFC00380 : 32'hBFC00200;
        end else if (tlb_exc_mem == INVALID_L) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBL;
            cp0_op = OP_TLB_EXC;
            exc_addr = 32'hBFC00380;
        end else if (tlb_exc_mem == INVALID_S) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_TLBS;
            cp0_op = OP_TLB_EXC;
            exc_addr = 32'hBFC00380;
        end else if (tlb_exc_mem == MODIFIED) begin
            is_valid_exc = 1'b1;
            exc_info.cause_exccode = `EXCCODE_MOD;
            cp0_op = OP_TLB_EXC;
            exc_addr = 32'hBFC00380;
        end else if (m_eret) begin
            is_valid_exc = 1'b0;
            exc_info.cause_exccode = 5'b0;
            cp0_op = OP_ERET;
            exc_addr = 32'hBFC00380;
        end else if (m_mtc0) begin
            is_valid_exc = 1'b0;
            exc_info.cause_exccode = 5'b0;
            cp0_op = OP_MTC0;
            exc_addr = 32'hBFC00380;
        end else if (m_tlb_req == TLBWI || m_tlb_req == TLBWR) begin
            is_valid_exc = 1'b0;
            exc_info.cause_exccode = 5'b0;
            cp0_op = OP_TLBW;
            exc_addr = 32'hBFC00380;
        end else if (m_tlb_req == TLBR) begin
            is_valid_exc = 1'b0;
            exc_info.cause_exccode = 5'b0;
            cp0_op = OP_TLBR;
            exc_addr = 32'hBFC00380;
        end else if (m_tlb_req == TLBP) begin
            is_valid_exc = 1'b0;
            exc_info.cause_exccode = 5'b0;
            cp0_op = OP_TLBP;
            exc_addr = 32'hBFC00380;
    	end else begin
    		is_valid_exc = 1'b0;
    		exc_info.cause_exccode = 5'b0;
            cp0_op = OP_NONE;
            exc_addr = 32'hBFC00380;
    	end
    end
    
    always_comb begin
    	if (cp0_status[1]) begin
    		exc_info.epc = cp0_epc;
    		exc_info.cause_bd = cp0_cause[31];
    	end else if (m_in_delay_slot == 1'b1) begin
    		exc_info.epc = m_pcminus4;
    		exc_info.cause_bd = 1'b1;
    	end else begin
    		exc_info.epc = m_pc;
    		exc_info.cause_bd = 1'b0;
    	end
    end

    
endmodule
