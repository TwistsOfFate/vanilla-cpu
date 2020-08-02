`include"cpu_defs.svh"
module mypipeline(
    input  logic         clk          ,
    input  logic         resetn       ,
    input  logic  [ 5:0] ext_int	  , 

    //inst sram-like 
    output logic         inst_req_1   ,
    output logic         inst_req_2   ,
    output logic         inst_wr      ,
    output logic  [ 1:0] inst_size    ,
    output logic  [31:0] inst_addr_1  ,
    output logic  [31:0] inst_addr_2  ,
    output logic  [31:0] inst_wdata   ,
    
    input  logic  [31:0] inst_rdata_1 ,
    input  logic  [31:0] inst_rdata_2 ,
    input  logic         inst_addr_ok ,
    input  logic         inst_data_ok ,
    input  logic         second_data_ok,
    
    
    //data sram-like 
    output logic         data_req     ,
    output logic         data_wr      ,
    output logic  [ 1:0] data_size    ,
    output logic  [31:0] data_addr    ,
    output logic  [31:0] data_wdata   ,
    
    input  logic  [31:0] data_rdata   ,
    input  logic         data_addr_ok ,
    input  logic         data_data_ok ,
    
    //debug signals
    output logic [31:0]  debug_wb_pc	,
	output logic [ 3:0]  debug_wb_rf_wen,
	output logic [ 4:0]  debug_wb_rf_wnum,
	output logic [31:0]  debug_wb_rf_wdata,

    output logic         icached,
    output logic         dcached
    ); 
    
logic [31:0] f_instr_alpha, f_inst_addr_tmp, f_instr_beta;
logic [31:0] m_pc, m_pc_tmp;
logic [31:0] m_data_rdata;
    
instr_inf    dinstrinf_alpha ;
stage_val_1  flush_alpha, stall_alpha ;
stage_val_1  flush_ext_alpha, stall_ext_alpha ;
ctrl_reg     dstage_alpha,estage_alpha,mstage_alpha,wstage_alpha ;
branch_rel   dcompare_alpha;

instr_inf    dinstrinf_beta ;
stage_val_1  flush_beta, stall_beta ;
stage_val_1  flush_ext_beta, stall_ext_beta ;
ctrl_reg     dstage_beta,estage_beta,mstage_beta,wstage_beta ;
branch_rel   dcompare_beta;

logic instr_alpha_wen, instr_beta_wen ;

busy_ok      idmem ;

logic		 m_stall_late;
logic		 m_flush_late;
logic		 m_data_req;
logic [ 1:0] imem_state, dmem_state;
logic [31:0] f_inst_addr;
logic [31:0] m_data_addr;
logic [ 3:0] m_data_wen;
logic [31:0] f_inst_addr_alpha, f_inst_addr_beta;
logic        f_inst_req_alpha, f_inst_req_beta;

logic [31:0]  debug_wb_pc_alpha;
logic [ 3:0]  debug_wb_rf_wen_alpha;
logic [ 4:0]  debug_wb_rf_wnum_alpha;
logic [31:0]  debug_wb_rf_wdata_alpha;

logic [31:0]  debug_wb_pc_beta;
logic [ 3:0]  debug_wb_rf_wen_beta;
logic [ 4:0]  debug_wb_rf_wnum_beta;
logic [31:0]  debug_wb_rf_wdata_beta;


assign idmem.inst_data_ok = inst_data_ok ;
assign idmem.data_data_ok = data_data_ok ;

assign instr_alpha_wen = inst_data_ok;
assign instr_beta_wen = second_data_ok & inst_data_ok;

//--------------------------------------------------------------------------
assign {stall_ext_alpha.f, stall_ext_alpha.d, stall_ext_alpha.e, stall_ext_alpha.m, stall_ext_alpha.w, flush_ext_alpha.f, flush_ext_alpha.d, flush_ext_alpha.e, flush_ext_alpha.m, flush_ext_alpha.w} = 10'b0;
assign {stall_ext_beta.f, stall_ext_beta.d, stall_ext_beta.e, stall_ext_beta.m, stall_ext_beta.w, flush_ext_beta.f, flush_ext_beta.d, flush_ext_beta.e, flush_ext_beta.m, flush_ext_beta.w} = 10'b0;
//--------------------------------------------------------------------------

controller ctrl_alpha(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    
    .dinstr             (dinstrinf_alpha)         ,
    
    .flush              (flush_alpha)             ,
    .stall              (stall_alpha)             ,
    
    .dcompare           (dcompare_alpha)          ,
    
    .dstage             (dstage_alpha)            ,
    .estage             (estage_alpha)            ,
    .mstage             (mstage_alpha)            ,
    .wstage             (wstage_alpha)            
);

controller ctrl_beta(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    
    .dinstr             (dinstrinf_beta)         ,
    
    .flush              (flush_beta)             ,
    .stall              (stall_beta)             ,
    
    .dcompare           (dcompare_beta)          ,
    
    .dstage             (dstage_beta)            ,
    .estage             (estage_beta)            ,
    .mstage             (mstage_beta)            ,
    .wstage             (wstage_beta)            
);

    
datapath dp(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    .ext_int            (ext_int)           ,

    .f_instr_alpha      (f_instr_alpha)     ,
    .f_instr_beta       (f_instr_beta)      ,

    .inst_data_ok       (inst_data_ok)      ,
    .inst_addr_ok       (inst_addr_ok)      ,


    .dsig_alpha        (dstage_alpha)       ,
    .esig_alpha        (estage_alpha)       ,
    .msig_alpha        (mstage_alpha)       ,
    .wsig_alpha        (wstage_alpha)       ,

    .dsig_beta         (dstage_beta)       ,
    .esig_beta         (estage_beta)       ,
    .msig_beta         (mstage_beta)       ,
    .wsig_beta         (wstage_beta)       ,

    .stall_ext_alpha   (stall_ext_alpha)    ,
    .flush_ext_alpha   (flush_ext_alpha)    ,

    .stall_ext_beta    (stall_ext_beta)    ,
    .flush_ext_beta    (flush_ext_beta)    ,

    .idmem             (idmem)              ,
    .second_data_ok    (second_data_ok)     ,
 
    .dinstrinf_alpha   (dinstrinf_alpha)    ,
    .dinstrinf_beta    (dinstrinf_beta)     ,

    .inst_req_alpha    (f_inst_req_alpha)   ,
    .inst_req_beta     (f_inst_req_beta)    ,
    .inst_addr_alpha   (f_inst_addr_alpha)  ,
    .inst_addr_beta    (f_inst_addr_beta)   ,

    .m_pc_alpha        (m_pc)               ,
    
    

    .flush_alpha       (flush_alpha)       ,
    .stall_alpha       (stall_alpha)       ,
    .flush_beta        (flush_beta)        ,
    .stall_beta        (stall_beta)        ,

    .dbranchcmp_alpha  (dcompare_alpha)    ,

   
    //dmem sram interface
	.m_data_req			(m_data_req)		,
    .m_data_wr			(data_wr)			,
    .m_data_size		(data_size)			,
    .m_data_addr		(m_data_addr)		,
    .m_data_wdata		(data_wdata)		,
    .m_data_rdata		(m_data_rdata)		,
    
	//debug
    .debug_wb_pc_alpha        (debug_wb_pc_alpha)       ,
    .debug_wb_rf_wen_alpha    (debug_wb_rf_wen_alpha)   ,
    .debug_wb_rf_wnum_alpha   (debug_wb_rf_wnum_alpha)  ,
    .debug_wb_rf_wdata_alpha  (debug_wb_rf_wdata_alpha) ,

    .debug_wb_pc_beta         (debug_wb_pc_beta)       ,
    .debug_wb_rf_wen_beta     (debug_wb_rf_wen_beta)   ,
    .debug_wb_rf_wnum_beta    (debug_wb_rf_wnum_beta)  ,
    .debug_wb_rf_wdata_beta   (debug_wb_rf_wdata_beta)  
 
); 

regfifo my_regfifo(
    .clk(clk),
    .reset(~resetn),
    .w_stall(stall_alpha.w || stall_beta.w),

    .debug_wb_pc_alpha        (debug_wb_pc_alpha)       ,
    .debug_wb_rf_wen_alpha    (debug_wb_rf_wen_alpha)   ,
    .debug_wb_rf_wnum_alpha   (debug_wb_rf_wnum_alpha)  ,
    .debug_wb_rf_wdata_alpha  (debug_wb_rf_wdata_alpha) ,

    .debug_wb_pc_beta         (debug_wb_pc_beta)       ,
    .debug_wb_rf_wen_beta     (debug_wb_rf_wen_beta)   ,
    .debug_wb_rf_wnum_beta    (debug_wb_rf_wnum_beta)  ,
    .debug_wb_rf_wdata_beta   (debug_wb_rf_wdata_beta) ,

    .output_debug_wb_pc       (debug_wb_pc),
    .output_debug_wb_rf_wen   (debug_wb_rf_wen),
    .output_debug_wb_rf_wnum  (debug_wb_rf_wnum),
    .output_debug_wb_rf_wdata (debug_wb_rf_wdata)
) ;

assign icached = 1'b1;

mmu immu_alpha(f_inst_addr_alpha, inst_addr_1);
mmu immu_beta(f_inst_addr_beta, inst_addr_2);
mmu dmmu(m_data_addr, data_addr, dcached);

assign inst_wr = 1'b0;
assign inst_size = 2'b10;
assign inst_wdata = 32'b0;

assign f_instr_alpha = inst_rdata_1;
assign f_instr_beta = inst_rdata_2;

assign inst_req_2 = f_inst_req_beta ;

rdata_latch m_rdata_latch(
	.clk(clk),
	.rst(~resetn),
	.stall(stall_alpha.m),
	.flush(flush_alpha.m),
	.data_ok(data_data_ok),
	.in(data_rdata),
	.out(m_data_rdata)
);

// SRAM-Like Interface FSM

logic [31:0] d_instr_count, e_instr_count, m_instr_count;

always_ff @(posedge clk) begin
    if(~resetn) begin
         d_instr_count <= 32'b0;
    end else if (!stall_alpha.d && !flush_alpha.d) begin
         d_instr_count <= d_instr_count + 32'b1;
    end
end

flop de_instr_count (clk, ~resetn | flush_alpha.e, stall_alpha.e, d_instr_count, e_instr_count);
flop em_instr_count (clk, ~resetn | flush_alpha.m, stall_alpha.m, e_instr_count, m_instr_count);

sram_like_handshake imem_handshake(
    .clk(clk),
    .rst(~resetn),
    .unique_id(f_inst_addr_alpha),
    .need_req(f_inst_req_alpha),
    .busy(idmem.imem_busy),

    .addr_ok(inst_addr_ok),
    .data_ok(inst_data_ok),
    .req(inst_req_1)
    );

sram_like_handshake dmem_handshake(
    .clk(clk),
    .rst(~resetn),
    .unique_id(m_instr_count),
    .need_req(m_data_req),
    .busy(idmem.dmem_busy),

    .addr_ok(data_addr_ok),
    .data_ok(data_data_ok),
    .req(data_req)
    );

endmodule