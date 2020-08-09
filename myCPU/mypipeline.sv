`include"cpu_defs.svh"
module mypipeline(
    input  logic         clk          ,
    input  logic         resetn       ,
    input  logic  [ 5:0] ext_int	  , 

    //inst sram-like 
    output logic         inst_req     ,
    output logic         inst_wr      ,
    output logic  [ 1:0] inst_size    ,
    output logic  [31:0] inst_addr    ,
    output logic  [31:0] inst_wdata   ,
    
    input  logic  [31:0] inst_rdata   ,
    input  logic         inst_addr_ok ,
    input  logic         inst_data_ok ,
    
    
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
    
    //cache signals
    output logic         icached      ,
    output logic         dcached
    ); 
    
logic [31:0] f_instr_alpha, f_inst_addr_tmp;
logic [31:0] m_pc, m_pc_tmp;
logic [31:0] m_data_rdata;
    
instr_inf dinstrinf_alpha ;
//--------------------------------------------------------------------------
stage_val_1 flush_alpha, stall_alpha ;

logic		 m_stall_late	   ;
logic		 m_flush_late	   ;

stage_val_1  flush_ext_alpha, stall_ext_alpha ;
busy_ok      idmem ;
ctrl_reg     dstage_alpha,estage_alpha,mstage_alpha,wstage_alpha ;
branch_rel   dcompare_alpha, ecompare_alpha;
// logic bfrome_alpha;

logic		 m_data_req;

logic [1:0] imem_state, dmem_state;

assign idmem.inst_data_ok = inst_data_ok ;
assign idmem.data_data_ok = data_data_ok ;

logic [31:0]	f_inst_addr;
logic [31:0]	m_data_addr;

logic [3:0]     m_data_wen;


//--------------------------------------------------------------------------

assign {stall_ext_alpha.f, stall_ext_alpha.d, stall_ext_alpha.e, stall_ext_alpha.m, stall_ext_alpha.w, flush_ext_alpha.f, flush_ext_alpha.d, flush_ext_alpha.e, flush_ext_alpha.m, flush_ext_alpha.w} = 10'b0;

//--------------------------------------------------------------------------

controller ctrl(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    
    .dinstr             (dinstrinf_alpha)         ,
    
    .flush              (flush_alpha)             ,
    .stall              (stall_alpha)             ,
    
    .dcompare           (dcompare_alpha)          ,
    // .ecompare           (ecompare_alpha)          ,

    // .bfrome             (bfrome_alpha)            ,
    
    .dstage             (dstage_alpha)            ,
    .estage             (estage_alpha)            ,
    .mstage             (mstage_alpha)            ,
    .wstage             (wstage_alpha)            
);
    
datapath dp(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    .ext_int            (ext_int)           ,

    .f_instr_alpha      (f_instr_alpha)     ,

    // .bfrome            (bfrome_alpha)       ,
    
    .dsig_alpha        (dstage_alpha)       ,
    .esig_alpha        (estage_alpha)       ,
    .msig_alpha        (mstage_alpha)       ,
    .wsig_alpha        (wstage_alpha)       ,

    .stall_ext_alpha   (stall_ext_alpha)    ,
    .flush_ext_alpha   (flush_ext_alpha)    ,

    .idmem             (idmem)              ,
    .dinstrinf_alpha   (dinstrinf_alpha)    ,

    .f_pc_alpha        (f_inst_addr)        ,
    .m_pc_alpha        (m_pc)               ,

    .flush_alpha       (flush_alpha)        ,
    .stall_alpha       (stall_alpha)        ,

    .dbranchcmp_alpha  (dcompare_alpha)     ,
    // .ebranchcmp_alpha  (ecompare_alpha)     ,

   
    //dmem sram interface
	.m_data_req			(m_data_req)		,
    .m_data_wr			(data_wr)			,
    .m_data_size		(data_size)			,
    .m_data_addr		(m_data_addr)		,
    .m_data_wdata		(data_wdata)		,
    .m_data_rdata		(m_data_rdata)		,
    
	//debug
    .debug_wb_pc        (debug_wb_pc)       ,
    .debug_wb_rf_wen    (debug_wb_rf_wen)   ,
    .debug_wb_rf_wnum   (debug_wb_rf_wnum)  ,
    .debug_wb_rf_wdata  (debug_wb_rf_wdata)                  
 
); 

// mmu immu(f_inst_addr, inst_addr, icached);
// mmu dmmu(m_data_addr, data_addr, dcached);
assign inst_addr = f_inst_addr;
assign data_addr = m_data_addr;

assign inst_wr = 1'b0;
assign inst_size = 2'b10;
assign inst_wdata = 32'b0;

// rdata latches

rdata_latch f_rdata_latch(
	.clk(clk),
	.rst(~resetn),
	.stall(stall_alpha.f),
	.flush(1'b0),
	.data_ok(inst_data_ok),
	.in(inst_rdata),
	.out(f_instr_alpha)
);

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
    .unique_id(f_inst_addr),
    .need_req(1'b1),
    .busy(idmem.imem_busy),

    .addr_ok(inst_addr_ok),
    .data_ok(inst_data_ok),
    .req(inst_req)
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