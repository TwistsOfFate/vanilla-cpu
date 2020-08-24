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
`include "iCache.vh"
`include "dCache.vh"

module cp0_regfile #(
	parameter INDEX_WIDTH = 5,
	parameter PABITS = 32,
	parameter RANDOM_MAX = 2 ** INDEX_WIDTH - 1,
	parameter TLB_SIZE = 2 ** INDEX_WIDTH,
	parameter C1_IS = `ICACHE_S == 5 ? 7 : `ICACHE_S - 6, // ICACHE_S should be between 5 and 12
	parameter C1_IL = `ICACHE_B - 1, // ICACHE_B should be between 2 and 7
	parameter C1_IA = `ICACHE_E - 1, // should be between 2 and 8
	parameter C1_DS = `DCACHE_S == 5 ? 7 : `DCACHE_S - 6, // DCACHE_S should be between 5 and 12
	parameter C1_DL = `DCACHE_B - 1, // DCACHE_B should be between 2 and 7
	parameter C1_DA = `DCACHE_E - 1 // should be between 2 and 8
)(
	input 				clk,
	input 				rst,
	input [5:0] 		ext_int,
	input 				m_stall,
	
	input 				ren,
	input 				wen,
	input cp0_op_t 		wtype,
	input exc_info_t	exc_info,
	input tlb_t			read_tlb,

	input [4:0] 		waddr,
	input [2:0]			wsel,
	input [31:0] 		wdata,
	input [4:0] 		raddr,
	input [2:0]			rsel,

	output logic 		ready,
	output logic [31:0] rdata,

	output logic [31:0] epc,
	output logic [31:0] status,
	output logic [31:0] cause,

	output tlb_t		write_tlb
    );
    
    logic [255:0][31:0] regs, regs_new;
    logic [7:0] windex, rindex;
    logic cnt;
    logic [2:0] wen_cnt, ren_cnt;
    logic w_done, r_done;
    logic [5:0] tlb_size_m1;

    assign windex = {wsel, waddr};
    assign rindex = {rsel, raddr};
    assign tlb_size_m1 = TLB_SIZE - 1;

    always_ff @(posedge clk)
    	cnt <= rst ? 1'b0 : ~cnt;

    always_comb begin
    	regs_new = regs;
    	unique case (wtype)
    		OP_NONE: ;
    		OP_MTC0:
    		begin
    			unique case (windex)
    				`CP0_INDEX: regs_new[windex][INDEX_WIDTH-1:0] = wdata[INDEX_WIDTH-1:0];
    				`CP0_RANDOM: ;
    				`CP0_ENTRYLO0: regs_new[windex][29-(36-PABITS):0] = wdata[29-(36-PABITS):0];
    				`CP0_ENTRYLO1: regs_new[windex][29-(36-PABITS):0] = wdata[29-(36-PABITS):0];
    				`CP0_CONTEXT: regs_new[windex][31:23] = wdata[31:23];
    				`CP0_PAGEMASK: ;
    				`CP0_WIRED: regs_new[windex][INDEX_WIDTH-1:0] = wdata[INDEX_WIDTH-1:0];
    				`CP0_BADVADDR: ;
    				`CP0_COUNT: regs_new[windex] = wdata;
    				`CP0_ENTRYHI: regs_new[windex] = {wdata[31:13], regs[windex][12:8], wdata[7:0]};
    				`CP0_COMPARE: regs_new[windex] = wdata;
    				`CP0_STATUS: regs_new[windex] = {regs[windex][31:16], wdata[15:8], regs[windex][7:2], wdata[1:0]};
    				`CP0_CAUSE: regs_new[windex][9:8] = wdata[9:8];
    				`CP0_EPC: regs_new[windex] = wdata;
    				`CP0_PRID: ;
    				`CP0_CONFIG: regs_new[windex][2:0] = wdata[2:0];
    				`CP0_CONFIG1: ;
    				`CP0_TAGLO: regs_new[windex] = wdata;
    				default: ; // Do nothing for reserved registers
    			endcase
    		end
    		OP_EXC:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    		end
    		OP_BADVA:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    			regs_new[`CP0_BADVADDR] = exc_info.badvaddr;
    		end
    		OP_ERET:
    		begin
    			regs_new[`CP0_STATUS][1] = 1'b0;
    		end
    		OP_TLB_EXC:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    			regs_new[`CP0_BADVADDR] = exc_info.badvaddr;
    			regs_new[`CP0_ENTRYHI][31:13] = exc_info.badvaddr[31:13];
    		end
    		OP_TLBW: ;
    		OP_TLBR:
    		begin
    			regs_new[`CP0_ENTRYHI] = read_tlb.entryhi;
    			regs_new[`CP0_PAGEMASK] = read_tlb.pagemask;
    			regs_new[`CP0_ENTRYLO0] = read_tlb.entrylo0;
    			regs_new[`CP0_ENTRYLO1] = read_tlb.entrylo1;
    		end
    		OP_TLBP:
    		begin
    			regs_new[`CP0_INDEX] = read_tlb.index;
    		end
    		OP_WAIT:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    		end
    	endcase
    end

    always_ff @(posedge clk) begin
    	if (rst) begin
    		regs <= '0;
    		regs[`CP0_RANDOM] <= RANDOM_MAX;
    		regs[`CP0_STATUS] <= {9'b0, 1'b1, 22'b0};
    		regs[`CP0_PRID] <= {8'b0, 8'b0, 8'h42, 8'h20};
    		regs[`CP0_CONFIG] <= {1'b1, 21'b0, 3'b1, 4'b0, 3'd3};
    		regs[`CP0_CONFIG1] <= {1'b0, tlb_size_m1[5:0], C1_IS[2:0], C1_IL[2:0], C1_IA[2:0], C1_DS[2:0], C1_DL[2:0], C1_DA[2:0], 7'b0};
    	end
    	else begin

    		// Update written registers
    		if (wen)
    			regs <= regs_new;

    		// Update Random register
    		if (wen && wtype == OP_MTC0 && windex == `CP0_WIRED)
    			regs[`CP0_RANDOM] <= RANDOM_MAX;
    		else
    			regs[`CP0_RANDOM] <= regs[`CP0_RANDOM] < RANDOM_MAX ? regs[`CP0_RANDOM] + 32'd1 : regs[`CP0_WIRED];

    		// Update Count register
    		if (wen && wtype == OP_MTC0 && windex == `CP0_COUNT)
    			;
    		else
    			regs[`CP0_COUNT] <= regs[`CP0_COUNT] + {31'b0, cnt};

    		// Updata Cause register (external interrupt)
    		regs[`CP0_CAUSE][15:10] <= ext_int | regs[`CP0_CAUSE][15:10];

    	end
    end

    always_ff @(posedge clk) begin
    	if (!m_stall) begin	// Never read the new value
			epc <= regs[`CP0_EPC];
			status <= regs[`CP0_STATUS];
			cause <= regs[`CP0_CAUSE];
		end
	end

	always_ff @(posedge clk) begin
		rdata <= regs[rindex];
		write_tlb.index <= regs[`CP0_INDEX];
		write_tlb.random <= regs[`CP0_RANDOM];
		write_tlb.entryhi <= regs[`CP0_ENTRYHI];
		write_tlb.pagemask <= regs[`CP0_PAGEMASK];
		write_tlb.entrylo0 <= regs[`CP0_ENTRYLO0];
		write_tlb.entrylo1 <= regs[`CP0_ENTRYLO1];
	end

	always_ff @(posedge clk)
		if (rst) wen_cnt <= '0;
		else begin
			unique case (wen_cnt)
				3'd0: wen_cnt <= wen;
				3'd1: wen_cnt <= 3'd2;
				3'd2: wen_cnt <= 3'd0;
			endcase
		end

	assign w_done = wen_cnt == 3'd2;

	always_ff @(posedge clk)
		if (rst) ren_cnt <= '0;
		else begin
			unique case (ren_cnt)
				3'd0: ren_cnt <= ren;
				3'd1: ren_cnt <= 3'd0;
			endcase
		end

	assign r_done = ren_cnt == 3'd1;

	assign ready = wen && w_done || ren && r_done || !wen && !ren;
    
endmodule
