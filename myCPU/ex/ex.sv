`include"cpu_defs.svh"
module ex(
	input				clk,
	input 				rst,

	input [31:0]		e_for_rsdata,
	input [31:0]		e_for_rtdata,

	input	dp_htoe 	htoe,
	input	dp_dtoe 	dtoe,
	input	ctrl_reg 	esig,

	input 				e_guess_taken,

	// output logic [31:0] e_bpc,
	output 				bfrome,

	output	dp_etom 	etom,
	output	dp_etoh 	etoh
	
	);

//IMMEXTEND
	wire [31:0]			e_imm_out;
//ALU
	wire [31:0] 	    e_alu_srcb;
	wire [31:0]			e_alu_out;
	wire 				e_alu_intovf;
//SHIFTER
	wire [31:0]			e_sft_srca;
	wire [4:0]			e_sft_srcb;
	wire [31:0]			e_sft_out;
	wire [31:0]			e_bta_out;

	wire [31:0]			mul_hi;
	wire [31:0]			mul_lo;
	wire [31:0]			div_hi;
	wire [31:0]			div_lo;

	// assign e_bpc = dtoe.pc + 32'd8;

//BRANCH COMPARE
	logic [7:0] ebranch;
	branch_rel ecompare;

	assign ecompare.equal = e_for_rsdata == e_for_rtdata;
	assign ecompare.e0 = e_for_rsdata == 32'd0;
	assign ecompare.g0 = ~e_for_rsdata[31] & ~ecompare.e0;

	assign ebranch[0] = (esig.branch == 3'b000) &&  ecompare.equal  && esig.isbranch ;
	assign ebranch[1] = (esig.branch == 3'b001) && !ecompare.equal  && esig.isbranch ;
	assign ebranch[2] = (esig.branch == 3'b010) &&  (ecompare.g0 | ecompare.e0) && esig.isbranch ;
	assign ebranch[3] = (esig.branch == 3'b011) &&  ecompare.g0  && esig.isbranch ;
	assign ebranch[4] = (esig.branch == 3'b100) &&  !ecompare.g0 && esig.isbranch ;
	assign ebranch[5] = (esig.branch == 3'b101) && (!ecompare.g0 && !ecompare.e0) && esig.isbranch ;
	assign ebranch[6] = (esig.branch == 3'b110) && (ecompare.g0 | ecompare.e0) && esig.isbranch ;
	assign ebranch[7] = (esig.branch == 3'b111) && (!ecompare.g0 && !ecompare.e0) && esig.isbranch ;

	assign bfrome = ~(|ebranch) & e_guess_taken ;

//IMMEXTEND
	mux2 immextend(
		.a		({{16'b0}, dtoe.imm}),
		.b		({{16{dtoe.imm[15]}}, dtoe.imm}),
		.sel	(esig.imm_sign),
		.out	(e_imm_out)
	);
//ALU_SRCB_MUX2
	mux2 alu_srcb_mux2(
		.a		(e_imm_out),
		.b		(e_for_rtdata),
		.sel	(esig.alu_srcb_sel_rt),
		.out	(e_alu_srcb)
	);
//ALU
	alu my_alu(
		.func	(esig.alu_func),
		.srca	(e_for_rsdata),
		.srcb	(e_alu_srcb),
		.zero	(),
		.sign	(),
		.out	(e_alu_out),
		.intovf	(e_alu_intovf)
	);
//SFT_SRCA_MUX2
	mux2 #(32) sft_srca_mux2(
		.a		(e_for_rtdata),
		.b		(e_imm_out),
		.sel	(esig.sft_srca_sel_imm),
		.out	(e_sft_srca)
	);
//SFT_SRCB_MUX2
	mux2 #(5) sft_srcb_mux2(
		.a		(dtoe.sa),
		.b		(e_for_rsdata[4:0]),
		.sel	(esig.sft_srcb_sel_rs),
		.out	(e_sft_srcb)
	);
//SHIFTER
	shifter my_shifter(
		.srca	(e_sft_srca),
		.srcb	(e_sft_srcb),
		.func	(esig.sft_func),
		.out	(e_sft_out)
	);
//BTA_GENERATOR
	bta_generator my_bta_generator(
		.offset	(dtoe.imm),
		.pc		(dtoe.pc),
		.out	(e_bta_out)
	);
//MULTIPLIER
	// multiplier my_multiplier(
	// 	.sign	(esig.mul_sign),
	// 	.srca	(e_for_rsdata),
	// 	.srcb	(e_for_rtdata),
	// 	.hi		(mul_hi),
	// 	.lo		(mul_lo)
	// );
	multiplier_ip my_multiplier(
		.clk(clk),
		.rst(rst),
		.in_valid(esig.mul_en),
		.sign(esig.mul_sign),
		.srca(e_for_rsdata),
		.srcb(e_for_rtdata),
		.out_valid(etoh.mul_ready),
		.hi(mul_hi),
		.lo(mul_lo)
	);
//DIVIDER
//Use divider_comb to speed up simulation
//	divider_comb my_divider(
//		.sign(e_div_sign),
//		.srca(e_for_rsdata),
//		.srcb(e_for_rtdata),
//		.out_valid(e_div_ready),
//		.hi(e_div_hi),
//		.lo(e_div_lo)
//	);
	divider_ip my_divider(
		.clk(clk),
		.rst(rst),
		.in_valid(esig.div_en),
		.sign(esig.div_sign),
		.srca(e_for_rsdata),
		.srcb(e_for_rtdata),
		.out_valid(etoh.div_ready),
		.hi(div_hi),
		.lo(div_lo)
	);
//INT_OVERFLOW
	and e_intovf_and(
		etom.intovf,
		esig.intovf_en,
		e_alu_intovf
	);
//E_OUT_MUX2
	mux8 e_out_mux4(
		.a		(e_alu_out),
		.b		(e_sft_out),
		.c		(dtoe.hi),
		.d		(dtoe.lo),
		.e		(mul_lo),
		.f		(),
		.g		(),
		.h		(),
		.sel	(esig.out_sel),
		.out	(etom.ex_out)
	);
//REGDST_MUX4
	mux4 #(5) regdst_mux4(
    	.a		(dtoe.rt),
    	.b		(dtoe.rd),
    	.c		(5'd31),
    	.d		(),
    	.sel	(esig.regdst),
    	.out	(etom.reg_waddr)
    );
//HI LO MUX4	
	mux4 hi_mux4(
    	.a(mul_hi),
    	.b(div_hi),
    	.c(e_for_rsdata),
    	.d(),
    	.sel(esig.hi_sel),
    	.out(etom.hi_wdata)
    );
    
   	mux4 lo_mux4(
    	.a(mul_lo),
    	.b(div_lo),
    	.c(e_for_rsdata),
    	.d(),
    	.sel(esig.lo_sel),
    	.out(etom.lo_wdata)
    );
	
	assign etom.in_delay_slot = dtoe.in_delay_slot ;
	assign etom.rt = dtoe.rt ;
	assign etom.rsdata = e_for_rsdata ;
	assign etom.rtdata = e_for_rtdata ;
	assign etom.pc = dtoe.pc ;
	assign etom.rd = dtoe.rd ;
	assign etom.addr_err_if = dtoe.addr_err_if ;
	assign etom.is_instr	= dtoe.is_instr ;

	assign etoh.reg_waddr = etom.reg_waddr ;
	assign etoh.regwrite  = esig.regwrite ;
	assign etoh.memtoreg  = esig.memtoreg ;
	assign etoh.out_sel   = esig.out_sel  ;
	assign etoh.cp0_sel   = esig.cp0_sel ;
	assign etoh.cp0_wen   = esig.cp0_wen ;
	assign etoh.hi_wen    = esig.hi_wen  ;
	assign etoh.lo_wen    = esig.lo_wen  ;
	assign etoh.div_en    = esig.div_en  ;
	assign etoh.mul_en    = esig.mul_en  ;
	assign etoh.rs		  = dtoe.rs		 ;
	assign etoh.rt		  = dtoe.rt		 ;
	assign etoh.rd		  = dtoe.rd		 ;
	assign etoh.link 	  = esig.link    ;
	
endmodule
