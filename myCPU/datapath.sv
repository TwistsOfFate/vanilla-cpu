`include"cpu_defs.svh"
module datapath(

    input  logic          clk               ,
    input  logic          resetn            ,
    input  logic [5:0]	  ext_int           ,
    
    // the instr fetched
    input  logic [31:0]   f_instr_alpha     ,
    input  logic [31:0]   f_instr_beta      ,
    // input  logic          instr_alpha_wen   ,
    // input  logic          instr_beta_wen    ,
    
    // signals of the corresponding instr
    input  ctrl_reg       dsig_alpha        ,
    input  ctrl_reg       esig_alpha        ,
    input  ctrl_reg       msig_alpha        ,
    input  ctrl_reg       wsig_alpha        ,

    input  ctrl_reg       dsig_beta         ,
    input  ctrl_reg       esig_beta         ,
    input  ctrl_reg       msig_beta         ,
    input  ctrl_reg       wsig_beta         ,

    input  stage_val_1    stall_ext_alpha   ,
    input  stage_val_1    flush_ext_alpha   ,
    input  stage_val_1    stall_ext_beta    ,
    input  stage_val_1    flush_ext_beta    ,
    
    input  busy_ok        idmem             ,
    input  logic          second_data_ok    ,
    input  logic          inst_data_ok      ,
    input  logic          inst_addr_ok      ,

    // give the controller the inf of instr 
    output instr_inf      dinstrinf_alpha   ,
    output instr_inf      dinstrinf_beta    ,
      
    // the next pc 
    output logic          inst_req_alpha    ,
    output logic          inst_req_beta     ,
    output logic [31:0]   inst_addr_alpha   ,
    output logic [31:0]   inst_addr_beta    ,

    output logic [31:0]   m_pc_alpha        ,
    // output logic [31:0]   m_pc_beta         , // not need
    
    // whether choose to flush 
    output stage_val_1    flush_alpha       ,
    output stage_val_1    stall_alpha       ,
    output stage_val_1    flush_beta        ,
    output stage_val_1    stall_beta        ,
        
    //compare num
    output branch_rel     dbranchcmp_alpha  , // not need beta
    
    //dmem sram-like interface
	output logic       	  m_data_req        ,
    output logic   		  m_data_wr         ,
    output logic [ 1:0]   m_data_size       ,
    output logic [31:0]   m_data_addr       ,
    output logic [31:0]   m_data_wdata      ,
    input  logic [31:0]   m_data_rdata      ,
    
	//debug signals
    output logic [31:0]   debug_wb_pc_alpha       ,
    output logic [ 3:0]   debug_wb_rf_wen_alpha   ,
    output logic [ 4:0]   debug_wb_rf_wnum_alpha  ,
    output logic [31:0]   debug_wb_rf_wdata_alpha ,

    output logic [31:0]   debug_wb_pc_beta        ,
    output logic [ 3:0]   debug_wb_rf_wen_beta    ,
    output logic [ 4:0]   debug_wb_rf_wnum_beta   ,
    output logic [31:0]   debug_wb_rf_wdata_beta  

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

dp_ftod dp_ftod_f_beta, dp_ftod_d_beta ;
dp_dtoe dp_dtoe_d_beta, dp_dtoe_e_beta ;
dp_etom dp_etom_e_beta, dp_etom_m_beta ;
dp_mtow dp_mtow_m_beta, dp_mtow_w_beta ; 
dp_dtoh dp_dtoh_d_beta;
dp_etoh dp_etoh_e_beta;
dp_mtoh dp_mtoh_m_beta;
dp_wtoh dp_wtoh_w_beta;
dp_htod dp_htod_d_beta;
dp_htoe dp_htoe_e_beta;

logic fifo_busy, fifo_wait;
logic fifo_inst_req, d_inst_req, pre_inst_req_alpha, pre_inst_req_beta;
logic [31:0] fifo_inst_addr, d_inst_addr, pre_inst_addr_alpha, pre_inst_addr_beta;

logic [31:0] delayslot_addr ; // just alpha need

logic [31:0] d_for_hi_alpha, d_for_lo_alpha;
logic [31:0] d_for_rsdata_alpha, d_for_rtdata_alpha ;

logic [31:0] d_for_hi_beta, d_for_lo_beta;
logic [31:0] d_for_rsdata_beta, d_for_rtdata_beta;

logic [31:0] e_for_rsdata_alpha, e_for_rtdata_alpha ;
logic [31:0] e_for_rsdata_beta, e_for_rtdata_beta;

logic [31:0] w_reg_wdata_alpha ;
logic [31:0] f_nextpc_alpha ;
logic [31:0] w_reg_wdata_beta ;
logic [31:0] f_nextpc_beta ;

logic [31:0] d_hi,d_lo, d_rsdata_alpha, d_rtdata_alpha,d_rsdata_beta, d_rtdata_beta ;

//-----------------------------EX to WB stages output wires---------------------------

logic [31:0]	epc_wdata_alpha;
logic			cause_bd_wdata_alpha;
logic [4:0]		cause_exccode_wdata_alpha;

logic [31:0]		epc_wdata_beta;
logic			cause_bd_wdata_beta;
logic [4:0]		cause_exccode_wdata_beta;

logic [31:0]		epc_wdata;
logic			cause_bd_wdata;
logic [4:0]		cause_exccode_wdata;
logic            is_valid_exc;

logic [31:0]		cp0_epc;
logic [31:0]		cp0_status;
logic [31:0]		cp0_cause;
logic [31:0]		cp0_rdata;

logic			m_exc_cp0_wen_alpha;
logic [4:0]		m_exc_cp0_waddr_alpha;
logic [31:0]	m_exc_cp0_wdata_alpha;

logic			m_exc_cp0_wen_beta;
logic [4:0]		m_exc_cp0_waddr_beta;
logic [31:0]	m_exc_cp0_wdata_beta;

logic [ 1:0]	cp0_wsel;
logic			cp0_wen;
logic [4:0]		cp0_waddr;
logic [31:0]    cp0_wdata;

logic [1:0] issue_method ;

logic   need_req_alpha, need_req_beta ;
logic f_next_req_alpha, f_next_req_beta ;
logic beta_success;
logic fifo_isempty ;
logic second_data_ok_long ;

//-----------------------------debug signals-----------------------------------
assign debug_wb_pc_alpha 		= dp_mtow_w_alpha.pc ;
assign debug_wb_rf_wen_alpha 	= {4{wsig_alpha.regwrite & ~stall_alpha.w}};
assign debug_wb_rf_wnum_alpha = dp_mtow_w_alpha.reg_waddr ;
assign debug_wb_rf_wdata_alpha = w_reg_wdata_alpha;

assign debug_wb_pc_beta 		= dp_mtow_w_beta.pc ;
assign debug_wb_rf_wen_beta 	= {4{wsig_beta.regwrite & ~stall_beta.w}};
assign debug_wb_rf_wnum_beta = dp_mtow_w_beta.reg_waddr ;
assign debug_wb_rf_wdata_beta = w_reg_wdata_beta;

//----------------------------- Select next PC ---------------------------------------

assign inst_req_alpha = 1'b1;
assign inst_req_beta = 1'b1;

//------------------------------------------fetch--------------------------------------

fetch my_fetch(
    .clk               (clk),
    .rst               (~resetn),
    .f_stall           (stall_alpha.f | stall_beta.f),
    .d_stall           (stall_alpha.d | stall_beta.d),
    .d_flush_alpha     (flush_alpha.d),
    .d_flush_beta      (flush_beta.d),
    .inst_data_ok      (inst_data_ok),
    .second_data_ok    (second_data_ok),
    .jb_req            (d_inst_req),
    .jb_addr           (d_inst_addr),
    .inst_rdata_1      (f_instr_alpha),
    .inst_rdata_2      (f_instr_beta),

    .inst_addr_1       (inst_addr_alpha),
    .inst_addr_2       (inst_addr_beta),

    .out_addr_alpha    (dp_ftod_d_alpha.pc),
    .out_addr_beta     (dp_ftod_d_beta.pc),
    .out_instr_alpha   (dp_ftod_d_alpha.instr),
    .out_instr_beta    (dp_ftod_d_beta.instr),
    .out_addr_err_alpha(dp_ftod_d_alpha.addr_err_if),
    .out_addr_err_beta (dp_ftod_d_beta.addr_err_if),
    .out_inds_alpha    (dp_ftod_d_alpha.in_delay_slot),
    .out_inds_beta     (dp_ftod_d_beta.in_delay_slot),
    .issue_method      (issue_method)
);


//---------------------------hazardmodule---------------------------------------
hazard hz(
    .clk(clk),
    .reset(~resetn),

    .d_alpha(dp_dtoh_d_alpha),
    .e_alpha(dp_etoh_e_alpha),
    .m_alpha(dp_mtoh_m_alpha),
    .w_alpha(dp_wtoh_w_alpha),

    .d_beta (dp_dtoh_d_beta),
    .e_beta (dp_etoh_e_beta),
    .m_beta (dp_mtoh_m_beta),
    .w_beta (dp_wtoh_w_beta),

    .to_d_alpha(dp_htod_d_alpha),
    .to_e_alpha(dp_htoe_e_alpha),

    .to_d_beta (dp_htod_d_beta),
    .to_e_beta (dp_htoe_e_beta),

    .stall_ext_alpha(stall_ext_alpha),
    .flush_ext_alpha(flush_ext_alpha),

    .stall_ext_beta(stall_ext_beta),
    .flush_ext_beta(flush_ext_beta),

    .stall_alpha(stall_alpha),
    .flush_alpha(flush_alpha),

    .stall_beta(stall_beta),
    .flush_beta(flush_beta),
        
    .imem_busy(idmem.imem_busy),
    .dmem_busy(idmem.dmem_busy),
    .issue_method(issue_method),

    .fifo_wait      (fifo_wait)

);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
regfile rf(
    .clk           (clk)         ,
    .reset         (~resetn)      ,
    .w_stall	   (stall_alpha.w || stall_beta.w)   ,

    .regwrite_en_alpha   (wsig_alpha.regwrite)   ,
    .regwrite_addr_alpha (dp_mtow_w_alpha.reg_waddr) ,
    .regwrite_data_alpha (w_reg_wdata_alpha) ,

    .regwrite_en_beta   (wsig_beta.regwrite)   ,
    .regwrite_addr_beta (dp_mtow_w_beta.reg_waddr)   ,
    .regwrite_data_beta (w_reg_wdata_beta) ,

    .rs_addr_alpha       (dp_dtoe_d_alpha.rs)        ,
    .rt_addr_alpha       (dp_dtoe_d_alpha.rt)        ,
    .rs_data_alpha       (d_rsdata_alpha)            ,
    .rt_data_alpha       (d_rtdata_alpha)            ,
    
    .rs_addr_beta        (dp_dtoe_d_beta.rs)         ,
    .rt_addr_beta        (dp_dtoe_d_beta.rt)         ,
    .rs_data_beta        (d_rsdata_beta)             ,
    .rt_data_beta        (d_rtdata_beta)
);

HI_regfile my_hi(
	.clk			(clk),
	.reset			(~resetn),
	.HI_wen_alpha	(wsig_alpha.hi_wen),
	.HI_wdata_alpha	(dp_mtow_w_alpha.hi_wdata),
    .HI_wen_beta	(wsig_beta.hi_wen),
	.HI_wdata_beta	(dp_mtow_w_beta.hi_wdata),

	.HI_rdata       (d_hi)

);

LO_regfile my_lo(
	.clk			(clk),
	.reset			(~resetn),
	.LO_wen_alpha	(wsig_alpha.lo_wen),
	.LO_wdata_alpha	(dp_mtow_w_alpha.lo_wdata),
    .LO_wen_beta	(wsig_beta.lo_wen),
	.LO_wdata_beta	(dp_mtow_w_beta.lo_wdata),

	.LO_rdata		(d_lo)
);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

//这边应该也是�?4个地方进行转�?

mux5 #(32) d_forwardrsmux_alpha(
    .a   (d_rsdata_alpha)          ,
    .b   (w_reg_wdata_alpha)       ,
    .c   (dp_etom_m_alpha.ex_out)  ,
    .d   (w_reg_wdata_beta)        ,
    .e   (dp_etom_m_beta.ex_out)   ,
    .sel (dp_htod_d_alpha.forwarda),
    .out (d_for_rsdata_alpha) 
) ;

mux5 #(32) d_forwardrtmux_alpha(
    .a   (d_rtdata_alpha)          ,
    .b   (w_reg_wdata_alpha)       ,
    .c   (dp_etom_m_alpha.ex_out)  ,
    .d   (w_reg_wdata_beta)        ,
    .e   (dp_etom_m_beta.ex_out)   ,
    .sel (dp_htod_d_alpha.forwardb),
    .out (d_for_rtdata_alpha) 
) ;


mux5 #(32) d_forwardrsmux_beta(
    .a   (d_rsdata_beta)          ,
    .b   (w_reg_wdata_alpha)       ,
    .c   (dp_etom_m_alpha.ex_out)  ,
    .d   (w_reg_wdata_beta)        ,
    .e   (dp_etom_m_beta.ex_out)   ,
    .sel (dp_htod_d_beta.forwarda),
    .out (d_for_rsdata_beta) 
) ;

mux5 #(32) d_forwardrtmux_beta(
    .a   (d_rtdata_beta)          ,
    .b   (w_reg_wdata_alpha)      ,
    .c   (dp_etom_m_alpha.ex_out) ,
    .d   (w_reg_wdata_beta)       ,
    .e   (dp_etom_m_beta.ex_out)  ,
    .sel (dp_htod_d_beta.forwardb),
    .out (d_for_rtdata_beta) 
) ;


mux5 #(32) d_forwardhimux(
    .a   (d_hi)                      ,
    .b   (dp_mtow_w_alpha.hi_wdata)  ,
    .c   (dp_mtow_m_alpha.hi_wdata)  ,
    .d   (dp_mtow_w_beta.hi_wdata)   ,
    .e   (dp_mtow_m_beta.hi_wdata)   ,
    .sel (dp_htod_d_alpha.hi_forward),
    .out (d_for_hi_alpha) 
) ;

mux5 #(32) d_forwardlomux(
    .a   (d_lo)                      ,
    .b   (dp_mtow_w_alpha.lo_wdata)  , 
    .c   (dp_mtow_m_alpha.lo_wdata)  ,
    .d   (dp_mtow_w_beta.lo_wdata)   ,
    .e   (dp_mtow_m_beta.lo_wdata)   ,
    .sel (dp_htod_d_alpha.lo_forward),
    .out (d_for_lo_alpha) 
) ;


mux5 #(32) e_forward_rs_alpha(
    .a      (dp_dtoe_e_alpha.rsdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_etom_m_alpha.ex_out) ,
    .d      (w_reg_wdata_beta)       ,
    .e      (dp_etom_m_beta.ex_out)  ,
    .sel    (dp_htoe_e_alpha.forwarda),
    .out    (e_for_rsdata_alpha)
);

mux5 #(32) e_forward_rt_alpha(
    .a      (dp_dtoe_e_alpha.rtdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_etom_m_alpha.ex_out) ,
    .d      (w_reg_wdata_beta)       ,
    .e      (dp_etom_m_beta.ex_out)  ,
    .sel    (dp_htoe_e_alpha.forwardb),
    .out    (e_for_rtdata_alpha)
);

mux5 #(32) e_forward_rs_beta(
    .a      (dp_dtoe_e_beta.rsdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_etom_m_alpha.ex_out) ,
    .d      (w_reg_wdata_beta)       ,
    .e      (dp_etom_m_beta.ex_out)  ,
    .sel    (dp_htoe_e_beta.forwarda),
    .out    (e_for_rsdata_beta)
);

mux5 #(32) e_forward_rt_beta(
    .a      (dp_dtoe_e_beta.rtdata),
    .b      (w_reg_wdata_alpha),
    .c      (dp_etom_m_alpha.ex_out) ,
    .d      (w_reg_wdata_beta)       ,
    .e      (dp_etom_m_beta.ex_out)  ,
    .sel    (dp_htoe_e_beta.forwardb),
    .out    (e_for_rtdata_beta)
);



//decode这边的整个�?�辑改一下，主要在于下一个pc如何去取
decode_alpha my_decode_alpha(
    .clk(clk),
    .rst(~resetn),

    .d_stall      (stall_alpha.d),
    .d_flush      (flush_alpha.d),

    .d_for_rsdata (d_for_rsdata_alpha),
    .d_for_rtdata (d_for_rtdata_alpha),
    .d_for_hi     (d_for_hi_alpha),
    .d_for_lo     (d_for_lo_alpha),

    .cp0_epc      (cp0_epc),
    .is_valid_exc (is_valid_exc),

    .dsig         (dsig_alpha),
    .eret         (msig_alpha.eret || msig_beta.eret),

    .ftod         (dp_ftod_d_alpha),
    .issue_method (issue_method),

    .d_inst_req   (d_inst_req),
    .d_inst_addr  (d_inst_addr),

    .dbranchcmp   (dbranchcmp_alpha),

    .dtoe         (dp_dtoe_d_alpha),
    .dinstrinf    (dinstrinf_alpha),

    .dtoh         (dp_dtoh_d_alpha)

) ;

decode_beta my_decode_beta(
    .d_for_rsdata(d_for_rsdata_beta),
    .d_for_rtdata(d_for_rtdata_beta),
    .d_for_hi(d_for_hi_alpha),
    .d_for_lo(d_for_lo_alpha),
    .f_stall(stall_alpha.f),

    .cp0_epc(cp0_epc),
    .is_valid_exc(is_valid_exc),

    .dsig(dsig_beta),
    // .alpha_is_jb(dsig.)

    .eret(msig_alpha.eret || msig_beta.eret),
    // .pc_next_alpha(f_nextpc_alpha),

    .ftod(dp_ftod_d_beta),
    .issue_method (issue_method),


    // .f_nextpc(f_nextpc_beta),
    .next_req(f_next_req_beta),

    .dbranchcmp(),

    .dtoe(dp_dtoe_d_beta),
    .dinstrinf(dinstrinf_beta),

    .dtoh(dp_dtoh_d_beta)
) ;

assign m_pc_alpha = dp_etom_m_alpha.pc ;
assign dp_ftod_f_alpha.is_instr = 1'b1;

//assign m_pc_beta = dp_etom_m_beta.pc ;
assign dp_ftod_f_beta.is_instr = 1'b1;

//ex里面的转发�?�辑改一下，�?4个地方进行转�?
ex my_ex_alpha(
	.clk(clk),
    .rst(~resetn),

    .e_for_rsdata(e_for_rsdata_alpha),
    .e_for_rtdata(e_for_rtdata_alpha),

    
    .htoe(dp_htoe_e_alpha),
    .dtoe(dp_dtoe_e_alpha),
    .esig(esig_alpha),

	
    .etom(dp_etom_e_alpha),
    .etoh(dp_etoh_e_alpha)

);

ex my_ex_beta(
	.clk(clk),
    .rst(~resetn),

    .e_for_rsdata(e_for_rsdata_beta),
    .e_for_rtdata(e_for_rtdata_beta),

    .htoe(dp_htoe_e_beta),
    .dtoe(dp_dtoe_e_beta),
    .esig(esig_beta),

    .etom(dp_etom_e_beta),
    .etoh(dp_etoh_e_beta)

);

mem my_mem_alpha(
    .clk(clk),
    .msig(msig_alpha),
    .etom(dp_etom_m_alpha),
    .mtow(dp_mtow_m_alpha),
    .mtoh(dp_mtoh_m_alpha),

    .data_rdata(m_data_rdata),


	//MEM STAGE INPUT
	.cp0_epc(cp0_epc),
	.cp0_status(cp0_status),
	.cp0_cause(cp0_cause),
	
	//EXCEPTION HANDLER OUTPUT
	.m_epc_wdata(epc_wdata_alpha),
	.m_cause_bd_wdata(cause_bd_wdata_alpha),
	.m_cause_exccode_wdata(cause_exccode_wdata_alpha),
	.exc_cp0_wen(m_exc_cp0_wen_alpha),
	.m_cp0_waddr(m_exc_cp0_waddr_alpha),
	.m_cp0_wdata(m_exc_cp0_wdata_alpha),
	
	//SRAM INTERFACE
	.m_data_req(m_data_req),
    .m_data_wr(m_data_wr),
    .m_data_size(m_data_size),
    .m_data_addr(m_data_addr),
    .m_data_wdata(m_data_wdata)
    );


mem my_mem_beta(
    .clk(clk),
    .msig(msig_beta),
    .etom(dp_etom_m_beta),
    .mtow(dp_mtow_m_beta),
    .mtoh(dp_mtoh_m_beta),

    .data_rdata(m_data_rdata),


	//MEM STAGE INPUT
	.cp0_epc(cp0_epc),
	.cp0_status(cp0_status),
	.cp0_cause(cp0_cause),
	
	//EXCEPTION HANDLER OUTPUT
	.m_epc_wdata(epc_wdata_beta),
	.m_cause_bd_wdata(cause_bd_wdata_beta),
	.m_cause_exccode_wdata(cause_exccode_wdata_beta),
	.exc_cp0_wen(m_exc_cp0_wen_beta),
	.m_cp0_waddr(m_exc_cp0_waddr_beta),
	.m_cp0_wdata(m_exc_cp0_wdata_beta),
	
	//SRAM INTERFACE
	.m_data_req(),
    .m_data_wr(),
    .m_data_size(),
    .m_data_addr(),
    .m_data_wdata()
    );






wb my_wb_alpha(
    .mtow(dp_mtow_w_alpha),
    .wsig(wsig_alpha),
    .cp0_rdata(cp0_rdata),

    .wtoh(dp_wtoh_w_alpha),
    .w_reg_wdata(w_reg_wdata_alpha)

    );

wb my_wb_beta(
    .mtow(dp_mtow_w_beta),
    .wsig(wsig_beta),
    .cp0_rdata(cp0_rdata),

    .wtoh(dp_wtoh_w_beta),
    .w_reg_wdata(w_reg_wdata_beta)

    );

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

assign cp0_wen = wsig_alpha.cp0_wen || m_exc_cp0_wen_alpha || m_exc_cp0_wen_beta ;

always_comb 
begin
    if(wsig_alpha.cp0_wen)
        cp0_wsel = 2'b10 ;
    else if(m_exc_cp0_wen_alpha)
        cp0_wsel = 2'b01 ;
    else
        cp0_wsel = 2'b00 ;
end

mux3 #(5) cp0_waddr_mux3(
	.mux3_valA(m_exc_cp0_waddr_beta),
	.mux3_valB(m_exc_cp0_waddr_alpha),
    .mux3_valC(dp_mtow_w_alpha.rd),
	.mux3_sel(cp0_wsel),
	.mux3_result(cp0_waddr)
);

mux3 #(32) cp0_wdata_mux3(
	.mux3_valA(m_exc_cp0_wdata_beta),
	.mux3_valB(m_exc_cp0_wdata_alpha),
    .mux3_valC(dp_mtow_w_alpha.rtdata),
	.mux3_sel(cp0_wsel),
	.mux3_result(cp0_wdata)
);

always_comb 
begin
    if(dp_mtoh_m_alpha.is_valid_exc)
    begin
        is_valid_exc = dp_mtoh_m_alpha.is_valid_exc ;
        epc_wdata    = epc_wdata_alpha ;
        cause_bd_wdata = cause_bd_wdata_alpha ;
        cause_exccode_wdata = cause_exccode_wdata_alpha ;
    end
    else if(dp_mtoh_m_beta.is_valid_exc)
    begin
        is_valid_exc = dp_mtoh_m_beta.is_valid_exc ;
        epc_wdata    = epc_wdata_beta ;
        cause_bd_wdata = cause_bd_wdata_beta ;
        cause_exccode_wdata = cause_exccode_wdata_beta ;
    end
    else 
    begin
        is_valid_exc = 1'b0 ;
        epc_wdata    = 32'b0 ;
        cause_bd_wdata = 1'b0 ;
        cause_exccode_wdata = 5'b0 ;
    end


end

//CP0 REGISTERS
cp0_regfile my_cp0(
	.clk				(clk),
	.rst				(~resetn),
	.m_stall			(stall_alpha.m),
	
	.ext_int			(ext_int),
    
	.is_valid_exc		(is_valid_exc),
	.epc_wdata			(epc_wdata),
	.cause_bd_wdata		(cause_bd_wdata),
	.cause_exccode_wdata(cause_exccode_wdata),
	
	.wen				(cp0_wen),
	.waddr				(cp0_waddr),
	.wdata				(cp0_wdata),
	.raddr				(dp_mtow_w_alpha.rd),//beta not write in wb stage
	
	.epc				(cp0_epc),
	.status				(cp0_status),
	.cause				(cp0_cause),
	.rdata				(cp0_rdata)
);

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


// transfer the data 



flop #(1) ftod_alpha(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.d),
    .stall		(stall_alpha.d),
    .in			({dp_ftod_f_alpha.is_instr}) ,
    .out 		({dp_ftod_d_alpha.is_instr})  
) ;

flop #(1) ftod_beta(
    .clk       	(clk),
    .rst     	(~resetn | flush_beta.d),
    .stall		(stall_beta.d),
    .in			({dp_ftod_f_beta.is_instr}) ,
    .out 		({dp_ftod_d_beta.is_instr})  
) ;

flop    #(199) dtoe_alpha(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.e),
    .stall		(stall_alpha.e),
    .in			(dp_dtoe_d_alpha) ,
    .out 		(dp_dtoe_e_alpha)  
) ;

flop    #(199) dtoe_beta(
    .clk       	(clk),
    .rst     	(~resetn | flush_beta.e),
    .stall		(stall_beta.e),
    .in			(dp_dtoe_d_beta) ,
    .out 		(dp_dtoe_e_beta)  
) ;

flop   #(206) etom_alpha(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.m),
    .stall		(stall_alpha.m),
    .in			(dp_etom_e_alpha) ,
    .out 		(dp_etom_m_alpha)  
) ;

flop   #(206) etom_beta(
    .clk       	(clk),
    .rst     	(~resetn | flush_beta.m),
    .stall		(stall_beta.m),
    .in			(dp_etom_e_beta) ,
    .out 		(dp_etom_m_beta)  
) ;

flop   #(235) mtow_alpha(
    .clk       	(clk),
    .rst     	(~resetn | flush_alpha.w),
    .stall		(stall_alpha.w),
    .in			(dp_mtow_m_alpha) ,
    .out 		(dp_mtow_w_alpha)  
) ;

flop   #(235) mtow_beta(
    .clk       	(clk),
    .rst     	(~resetn | flush_beta.w),
    .stall		(stall_beta.w),
    .in			(dp_mtow_m_beta) ,
    .out 		(dp_mtow_w_beta)  
) ;

endmodule
