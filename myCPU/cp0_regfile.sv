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
	parameter C1_IS = `ICACHE_E == 32 ? 7 : $clog2(`ICACHE_E) - 6,	// ICACHE_E should be between 32 to 4096
	parameter C1_IL = `ICACHE_B - 1,	// ICACHE_B should be between 2 to 7
	parameter C1_IA = `ISET_NUM - 1,	// ISET_NUM should be between 2 to 8
	parameter C1_DS = `DCACHE_E == 32 ? 7 : $clog2(`DCACHE_E) - 6,	// DCACHE_E should be between 32 to 4096
	parameter C1_DL = `DCACHE_B - 1,	// DCACHE_B should be between 2 to 7
	parameter C1_DA = `DSET_NUM - 1	// DSET_NUM should be between 2 to 8
)(
	input 				clk,
	input 				rst,
	input [5:0] 		ext_int,
	
	input 				ren,
	input 				wen,
	input cp0_op_t 		wtype,
	input exc_info_t	exc_info,

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

	// TLB outputs
	output logic [31:0] index,
	output logic [31:0] random,
	output logic [31:0] entryhi
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
    		NONE: ;
    		MTC0:
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
    		EXC:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    		end
    		BADVA:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    			regs_new[`CP0_BADVADDR] = exc_info.badvaddr;
    		end
    		ERET:
    		begin
    			regs_new[`CP0_STATUS][1] = 1'b0;
    		end
    		TLB:
    		begin
    			regs_new[`CP0_EPC] = exc_info.epc;
    			regs_new[`CP0_CAUSE][31] = exc_info.cause_bd;
    			regs_new[`CP0_STATUS][1] = 1'b1;
    			regs_new[`CP0_CAUSE][6:2] = exc_info.cause_exccode;
    			regs_new[`CP0_BADVADDR] = exc_info.badvaddr;
    			regs_new[`CP0_ENTRYHI][31:13] = exc_info.badvaddr[31:13];
    		end
    	endcase
    end

    always_ff @(posedge clk) begin
    	if (rst) begin
    		regs <= '0;
    		regs[`CP0_RANDOM] <= RANDOM_MAX;
    		regs[`CP0_STATUS] <= {9'b0, 1'b1, 22'b0};
    		regs[`CP0_PRID] <= {8'b0, 8'b1, 8'h80, 8'b0};
    		regs[`CP0_CONFIG] <= {1'b1, 21'b0, 3'b1, 4'b0, 3'd3};
    		regs[`CP0_CONFIG1] <= {1'b0, tlb_size_m1[5:0], C1_IS[2:0], C1_IL[2:0], C1_IA[2:0], C1_DS[2:0], C1_DL[2:0], C1_DA[2:0], 7'b0};
    	end
    	else if (wen) begin

    		// Update written registers
    		regs <= regs_new;

    		// Update Random register
    		if (wen && wtype == MTC0 && windex == `CP0_WIRED)
    			regs[`CP0_RANDOM] <= RANDOM_MAX;
    		else
    			regs[`CP0_RANDOM] <= regs[`CP0_RANDOM] < RANDOM_MAX ? regs[`CP0_RANDOM] + 32'd1 : regs[`CP0_WIRED];

    		// Update Count register
    		if (wen && wtype == MTC0 && windex == `CP0_COUNT)
    			;
    		else
    			regs[`CP0_COUNT] <= regs[`CP0_COUNT] + {31'b0, cnt};

    		// Updata Cause register (external interrupt)
    		regs[`CP0_CAUSE][15:10] <= ext_int | regs[`CP0_CAUSE][15:10];

    	end
    end

    always_ff @(posedge clk) begin
    	if (!wen) begin						// Never read the new value
			epc <= regs[`CP0_EPC];
			status <= regs[`CP0_STATUS];
			cause <= regs[`CP0_CAUSE];
			rdata <= regs[rindex];
			index <= regs[`CP0_INDEX];
			random <= regs[`CP0_RANDOM];
			entryhi <= regs[`CP0_ENTRYHI];
		end
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
    
    // integer i;
    
    // always_ff @(posedge clk) begin
    // 	if (rst) begin
    // 		cnt <= 1'b0;
    // 		regs[`CP0_STATUS] <= {9'b0, 1'b1, 22'b0};
    // 		for (i = 0; i < 32; i = i + 1) begin
    // 		    if (i != `CP0_STATUS) regs[i] <= 32'b0;
    // 		end
    // 	end else begin
    // 		regs[`CP0_CAUSE][15:10] <= ext_int;
	   //  	if (is_valid_exc && !m_stall) begin
	   //  		regs[`CP0_EPC] <= epc_wdata;
	   //  		regs[`CP0_CAUSE][31] <= cause_bd_wdata;
	   //  		regs[`CP0_STATUS][1] <= 1'b1;
	   //  		regs[`CP0_CAUSE][6:2] <= cause_exccode_wdata;
	   //  		if (wen && waddr == `CP0_BADVADDR) begin
	   //  			regs[`CP0_BADVADDR] <= wdata;
	   //  		end
	   //  	end else if (wen && !is_valid_exc || is_valid_exc && !m_stall) begin
	   //  		case (waddr)
	   //  			`CP0_CAUSE:		regs[waddr][9:8] <= wdata[9:8];
	   //  			`CP0_EPC:		regs[waddr] <= wdata;
	   //  			`CP0_STATUS:	regs[waddr] <= {regs[waddr][31:16], wdata[15:8], regs[waddr][7:2], wdata[1:0]};
	   //  			`CP0_COUNT:		begin regs[waddr] <= wdata; cnt <= 0; end
	   //  		endcase
	   //  	end else begin
	   //  		cnt <= ~cnt;
	   //  		regs[`CP0_COUNT] <= regs[`CP0_COUNT] + {31'b0, cnt};
	   //  	end
	   //  end
    // end
    
    // assign epc = regs[`CP0_EPC];
    // assign status = regs[`CP0_STATUS];
    // assign cause = regs[`CP0_CAUSE];
    // assign rdata = regs[raddr];
    
endmodule
