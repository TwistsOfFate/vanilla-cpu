`include"cpu_defs.svh"
module datapath(

    input  logic          clk               ,
    input  logic          resetn            ,
    input  logic [5:0]	  ext_int           ,
    
    // the instr fetched
    input  logic [31:0]   f_instr_alpha     ,

    // input logic           bfrome            ,
    
    // signals of the corresponding instr
    input  ctrl_reg       dsig_alpha        ,
    // input  ctrl_reg       esig_alpha        ,
    // input  ctrl_reg       msig_alpha        ,
    // input  ctrl_reg       wsig_alpha        ,

    // input  stage_val_1    stall_ext_alpha   ,
    // input  stage_val_1    flush_ext_alpha   ,
    
    input  busy_ok        idmem             ,
    
    // give the controller the inf of instr 
    output instr_inf      dinstrinf_alpha    ,
      
    // the next pc 
    output logic [31:0]   f_pc_alpha        ,
    output logic [31:0]	  m_pc_alpha        ,
    
    // whether choose to flush 
    output stage_val_1    flush_alpha       ,
    output stage_val_1    stall_alpha       ,
        
    //compare num
    // output branch_rel     dbranchcmp_alpha  ,
    // output branch_rel     ebranchcmp_alpha  ,
    
    //dmem sram-like interface
	output logic       	  m_data_req        ,
    output logic   		  m_data_wr         ,
    output logic [ 1:0]   m_data_size       ,
    output logic [31:0]   m_data_addr       ,
    output logic [31:0]   m_data_wdata      ,
    input  logic [31:0]   m_data_rdata      ,
    
	//debug signals
    output logic [31:0]   debug_wb_pc       ,
    output logic [ 3:0]   debug_wb_rf_wen   ,
    output logic [ 4:0]   debug_wb_rf_wnum  ,
    output logic [31:0]   debug_wb_rf_wdata 

    
    );


dp_ftod dp_ftod_f_alpha, dp_ftod_d_alpha ;
dp_dtoe dp_dtoe_d_alpha, dp_dtoe_e_alpha ;
dp_etom dp_etom_e_alpha, dp_etom_m_alpha ;
dp_mtow dp_mtow_m_alpha, dp_mtow_w_alpha ; 
dp_dtoh dp_dtoh_d_alpha;
dp_etoh dp_etoh_e_alpha;
dp_mtoh dp_mtoh_m_alpha;
dp_wtoh dp_wtoh_w_alpha;
dp_htod dp_htod_d_alpha;
dp_htoe dp_htoe_e_alpha;

ctrl_reg esig_alpha, msig_alpha, wsig_alpha;

logic d_guess_taken, e_guess_taken;

logic [31:0] delayslot_addr, e_bpc ;
logic bfrome;

logic [31:0] d_for_hi_alpha, d_for_lo_alpha;
logic [31:0] d_for_rsdata_alpha, d_for_rtdata_alpha;
logic [31:0] e_for_rsdata_alpha, e_for_rtdata_alpha;

logic [31:0] w_reg_wdata_alpha ;
logic [31:0] f_nextpc_alpha ;

//-----------------------------EX to WB stages output wires---------------------------

wire [31:0]		epc_wdata;
wire			cause_bd_wdata;
wire [4:0]		cause_exccode_wdata;

wire [31:0]		cp0_epc;
// wire [31:0]		cp0_status;
// wire [31:0]		cp0_cause;
wire [31:0]		cp0_rdata;

wire			m_exc_cp0_wen;
wire [4:0]		m_exc_cp0_waddr;
wire [31:0]		m_exc_cp0_wdata;

wire			cp0_wsel;
wire			cp0_wen;
wire [4:0]		cp0_waddr;
wire [31:0]		cp0_wdata;

//-----------------------------debug signals-----------------------------------
assign debug_wb_pc 		= dp_mtow_w_alpha.pc ;
assign debug_wb_rf_wen 	= {4{wsig_alpha.regwrite & ~stall_alpha.w}};
assign debug_wb_rf_wnum = dp_mtow_w_alpha.reg_waddr ;
assign debug_wb_rf_wdata = w_reg_wdata_alpha;


//---------------------------hazardmodule---------------------------------------
hazard hz(

    .d_alpha(dp_dtoh_d_alpha),
    .e_alpha(dp_etoh_e_alpha),
    .m_alpha(dp_mtoh_m_alpha),
    .w_alpha(dp_wtoh_w_alpha),

    .bfrome(bfrome),

    .to_d_alpha(dp_htod_d_alpha),
    .to_e_alpha(dp_htoe_e_alpha),

    .d_guess_taken(d_guess_taken),

    .stall          (stall_alpha),
    .flush          (flush_alpha),
    // .stall_ext      (stall_ext_alpha),
    // .flush_ext      (flush_ext_alpha),
    
    .idmem          (idmem)

    
);
logic [31:0] d_hi,d_lo, d_rsdata, d_rtdata ;

regfile rf(
    .clk           (clk)         ,
    .reset         (~resetn)      ,
    // .w_stall	   (stall_alpha.w)	  ,
    .regwrite_en   (wsig_alpha.regwrite & ~stall_alpha.w)   ,
    .regwrite_addr (dp_mtow_w_alpha.reg_waddr)   ,
    .regwrite_data (w_reg_wdata_alpha) ,
    .rs_addr       (dp_dtoe_d_alpha.rs)        ,
    .rt_addr       (dp_dtoe_d_alpha.rt)        ,
    .rs_data       (d_rsdata)    ,
    .rt_data       (d_rtdata)
);



HI_regfile my_hi(
	.clk			(clk),
	.reset			(~resetn),
	.HI_wen			(wsig_alpha.hi_wen),
	.HI_wdata		(dp_mtow_w_alpha.hi_wdata),
	.HI_rdata		(d_hi)
);

LO_regfile my_lo(
	.clk			(clk),
	.reset			(~resetn),
	.LO_wen			(wsig_alpha.lo_wen),
	.LO_wdata		(dp_mtow_w_alpha.lo_wdata),
	.LO_rdata		(d_lo)
);



mux3 #(32) d_forwardrsmux(
    .mux3_valA   (d_rsdata)     ,
    .mux3_valB   (w_reg_wdata_alpha) ,
    .mux3_valC   (dp_etom_m_alpha.ex_out)     ,
    .mux3_sel    (dp_htod_d_alpha.forwarda)   ,
    .mux3_result (d_for_rsdata_alpha) 
) ;

mux3 #(32) d_forwardrtmux(
    .mux3_valA   (d_rtdata)     ,
    .mux3_valB   (w_reg_wdata_alpha) ,
    .mux3_valC   (dp_etom_m_alpha.ex_out)     ,
    .mux3_sel    (dp_htod_d_alpha.forwardb)   ,
    .mux3_result (d_for_rtdata_alpha) 
) ;

mux3 #(32) d_forwardhimux(
    .mux3_valA   (d_hi)           ,
    .mux3_valB   (dp_mtow_w_alpha.hi_wdata)     , 
    .mux3_valC   (dp_mtow_m_alpha.hi_wdata)     ,
    .mux3_sel    (dp_htod_d_alpha.hi_forward)   ,
    .mux3_result (d_for_hi_alpha) 
) ;

mux3 #(32) d_forwardlomux(
    .mux3_valA   (d_lo)           ,
    .mux3_valB   (dp_mtow_w_alpha.lo_wdata)     , 
    .mux3_valC   (dp_mtow_m_alpha.lo_wdata)     ,
    .mux3_sel    (dp_htod_d_alpha.lo_forward)   ,
    .mux3_result (d_for_lo_alpha)       
) ;

mux4 #(32) e_forward_rs_mux4(
    .a      (dp_dtoe_e_alpha.rsdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_mtow_m_alpha.ex_out),
    .d      (),
    .sel    (dp_htoe_e_alpha.forwarda),
    .out    (e_for_rsdata_alpha)
);

mux4 #(32) e_forward_rt_mux4(
    .a      (dp_dtoe_e_alpha.rtdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_mtow_m_alpha.ex_out),
    .d      (),
    .sel    (dp_htoe_e_alpha.forwardb),
    .out    (e_for_rtdata_alpha)
);

decode my_decode(
    .d_for_rsdata(d_for_rsdata_alpha),
    .d_for_rtdata(d_for_rtdata_alpha),
    .d_for_hi(d_for_hi_alpha),
    .d_for_lo(d_for_lo_alpha),

    .f_nowpc(dp_ftod_f_alpha.pc),
    .f_pcplus4(dp_ftod_f_alpha.pcplus4),
    .cp0_epc(cp0_epc),
    // .e_bpc(e_bpc),
    .is_valid_exc(dp_mtoh_m_alpha.is_valid_exc),

    .dsig(dsig_alpha),
    .d_guess_taken(d_guess_taken),
    .bfrome(bfrome),
    .eret(msig_alpha.eret),

    .ftod(dp_ftod_d_alpha),

    .f_nextpc(f_nextpc_alpha),

    // .dbranchcmp(dbranchcmp_alpha),
    .f_indelayslot(dp_ftod_f_alpha.in_delay_slot),

    .dtoe(dp_dtoe_d_alpha),
    .dinstrinf(dinstrinf_alpha),

    .dtoh(dp_dtoh_d_alpha)
) ;

flop #(1) de_guess_taken(clk, ~resetn | flush_alpha.e, stall_alpha.e, d_guess_taken, e_guess_taken);

pc_flop #(32) pcreg(
    .clk       (clk)       ,
    .rst       (~resetn)   ,
    .stall     (stall_alpha.f)   ,
    .in        (f_nextpc_alpha)  ,
    .out       (dp_ftod_f_alpha.pc)
) ;

assign f_pc_alpha = dp_ftod_f_alpha.pc ;
assign m_pc_alpha = dp_etom_m_alpha.pc ;
assign dp_ftod_f_alpha.pcplus4 = dp_ftod_f_alpha.pc + 32'd4;
assign dp_ftod_f_alpha.is_instr = 1'b1;
assign dp_ftod_f_alpha.addr_err_if = (f_pc_alpha[1:0] != 2'b00) ;
assign dp_ftod_f_alpha.instr = f_instr_alpha ;

ex my_ex(
// input
	.clk(clk),
    .rst(~resetn),

    .e_for_rsdata(e_for_rsdata_alpha),
    .e_for_rtdata(e_for_rtdata_alpha),

    .esig(esig_alpha),

    .htoe(dp_htoe_e_alpha),
    .dtoe(dp_dtoe_e_alpha),

    .e_guess_taken(e_guess_taken),

// output
    // .e_bpc(e_bpc),
    // .ebranchcmp(ebranchcmp_alpha),
    .bfrome(bfrome),
    .etom(dp_etom_e_alpha),
    .etoh(dp_etoh_e_alpha)

	);

mem my_mem(
    .clk(clk),
    .rst(~resetn),
    .ext_int(ext_int),

    .m_stall(stall_alpha.m),
    .msig(msig_alpha),
    .etom(dp_etom_m_alpha),
    .mtow(dp_mtow_m_alpha),
    .mtoh(dp_mtoh_m_alpha),

    .cp0_epc(cp0_epc),

    .data_rdata(m_data_rdata),

    .read_tlb(),
    .write_tlb(),

	
	//SRAM INTERFACE
	.m_data_req(m_data_req),
    .m_data_wr(m_data_wr),
    .m_data_size(m_data_size),
    .m_data_addr(m_data_addr),
    .m_data_wdata(m_data_wdata)
    );

wb my_wb(
    .mtow(dp_mtow_w_alpha),
    .wsig(wsig_alpha),
    // .cp0_rdata(cp0_rdata),

    .wtoh(dp_wtoh_w_alpha),
    .w_reg_wdata(w_reg_wdata_alpha)

    );


//CPO INPUT MUXES AND HAZARD HANDLING
// or cp0_src_or(
// 	cp0_wen,
// 	m_exc_cp0_wen,
// 	wsig_alpha.cp0_wen
// );

// assign cp0_wsel = wsig_alpha.cp0_wen ? 1'b1 : 1'b0;

// mux2 #(5) cp0_waddr_mux2(
// 	.a(m_exc_cp0_waddr),
// 	.b(dp_mtow_w_alpha.rd),
// 	.sel(cp0_wsel),
// 	.out(cp0_waddr)
// );

// mux2 #(32) cp0_wdata_mux2(
// 	.a(m_exc_cp0_wdata),
// 	.b(dp_mtow_w_alpha.rtdata),
// 	.sel(cp0_wsel),
// 	.out(cp0_wdata)
// );


// //CP0 REGISTERS
// cp0_regfile my_cp0(
// 	.clk				(clk),
// 	.rst				(~resetn),
// 	.m_stall			(stall_alpha.m),
	
// 	.ext_int			(ext_int),
// 	.is_valid_exc		(dp_mtoh_m_alpha.is_valid_exc),
// 	.epc_wdata			(epc_wdata),
// 	.cause_bd_wdata		(cause_bd_wdata),
// 	.cause_exccode_wdata(cause_exccode_wdata),
	
// 	.wen				(cp0_wen),
// 	.waddr				(cp0_waddr),
// 	.wdata				(cp0_wdata),
// 	.raddr				(dp_mtow_w_alpha.rd),
	
// 	.epc				(cp0_epc),
// 	.status				(cp0_status),
// 	.cause				(cp0_cause),
// 	.rdata				(cp0_rdata)
// );





// transfer the data 

flop_ftod ftod(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.d),
    .stall		(stall_alpha.d),
    .in			(dp_ftod_f_alpha) ,
    .out 		(dp_ftod_d_alpha)  
) ;

flop_dtoe dtoe(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.e),
    .stall		(stall_alpha.e),
    .in			(dp_dtoe_d_alpha) ,
    .out 		(dp_dtoe_e_alpha)  
) ;

flop_etom etom(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.m),
    .stall		(stall_alpha.m),
    .in			(dp_etom_e_alpha) ,
    .out 		(dp_etom_m_alpha)  
) ;

flop_mtow mtow(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.w),
    .stall		(stall_alpha.w),
    .in			(dp_mtow_m_alpha) ,
    .out 		(dp_mtow_w_alpha)  
) ;

flop_ctrl desig(
    .clk(clk) ,
    .rst(~resetn | flush_alpha.e) ,
    .stall(stall_alpha.e) ,
    .in(dsig_alpha) ,
    .out(esig_alpha) 
);

flop_ctrl emsig(
    .clk(clk) ,
    .rst(~resetn | flush_alpha.m) ,
    .stall(stall_alpha.m) ,
    .in(esig_alpha) ,
    .out(msig_alpha) 
);

flop_ctrl mwsig(
    .clk(clk) ,
    .rst(~resetn | flush_alpha.w) ,
    .stall(stall_alpha.w) ,
    .in(msig_alpha) ,
    .out(wsig_alpha) 
);



endmodule
