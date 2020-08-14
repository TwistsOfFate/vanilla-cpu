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

    //TLB signals
    input  tlb_exc_t      f_tlb_exc_if      ,
    input  tlb_exc_t      m_tlb_exc_mem     ,
    input  tlb_t          m_read_tlb        ,
    output tlb_t          m_write_tlb       ,
    output tlb_req_t      tlb_req           ,
    input logic           m_tlb_ok          ,

    //CACHE signals
    output cache_req_t    icache_req,
    output cache_req_t    dcache_req,
    output logic [31:0]   m_taglo,
    input logic           m_icache_ok,
    input logic           m_dcache_ok,

    //debug signals
    output logic [31:0]  debug_wb_pc	,
	output logic [ 3:0]  debug_wb_rf_wen,
	output logic [ 4:0]  debug_wb_rf_wnum,
    output logic [31:0]  debug_wb_rf_wdata,

    //cache signals
    output logic         icached      ,
    output logic         dcached
    );

//Cache Requests
logic icache_req_logic, dcache_req_logic, m_cache_busy, m_icache_busy, m_dcache_busy;
cache_req_t  m_icache_req, m_dcache_req;

tlb_exc_t f_tlb_exc, m_tlb_exc;
logic f_inst_req, d_rtzero;
logic [31:0] f_instr_alpha, f_inst_addr_tmp;
logic [31:0] m_pc, m_pc_tmp;
logic [31:0] m_data_rdata;

instr_inf dinstrinf_alpha ;
//--------------------------------------------------------------------------
stage_val_1 flush_alpha, stall_alpha ;

logic		 m_stall_late	   ;
logic		 m_flush_late	   ;

busy_ok      idmem ;
logic        m_tlb_busy, tlb_req_logic, w_tlbw;
tlb_req_t    m_tlb_req;
tlb_t        read_tlb;
ctrl_reg     dstage_alpha,estage_alpha,mstage_alpha,wstage_alpha ;
branch_rel   dcompare_alpha, ecompare_alpha;

logic		 m_data_req;

logic [1:0] imem_state, dmem_state;

assign idmem.inst_data_ok = inst_data_ok ;
assign idmem.data_data_ok = data_data_ok ;

logic [31:0]	f_inst_addr;
logic [31:0]	m_data_addr;


controller ctrl(
    .clk                (clk)               ,
    .resetn             (resetn)            ,

    .dinstr             (dinstrinf_alpha)   ,
    .d_rtzero           (d_rtzero)          ,

    .flush              (flush_alpha)       ,
    .stall              (stall_alpha)       ,

    .dstage             (dstage_alpha)
);

datapath dp(
    .clk                (clk)               ,
    .resetn             (resetn)            ,
    .ext_int            (ext_int)           ,

    .f_instr_alpha      (f_inst_req && f_tlb_exc_if == NO_EXC ? f_instr_alpha : 32'b0),

    .dsig_alpha        (dstage_alpha)       ,

    .idmem             (idmem)              ,
    .dinstrinf_alpha   (dinstrinf_alpha)    ,
    .d_rtzero           (d_rtzero)          ,
    .w_tlbw             (w_tlbw)            ,

    .f_inst_req        (f_inst_req)         ,
    .f_pc_alpha        (f_inst_addr)        ,
    .m_pc_alpha        (m_pc)               ,

    .flush_alpha       (flush_alpha)        ,
    .stall_alpha       (stall_alpha)        ,

    //dmem sram interface
	.m_data_req			(m_data_req)		,
    .m_data_wr			(data_wr)			,
    .m_data_size		(data_size)			,
    .m_data_addr		(m_data_addr)		,
    .m_data_wdata		(data_wdata)		,
    .m_data_rdata		(m_data_rdata)		,

    //TLB interface
    .f_tlb_exc_if       (f_tlb_exc)         ,
    .m_tlb_exc_mem      (m_tlb_exc)         ,
    .m_read_tlb         (read_tlb)          ,
    .m_write_tlb        (m_write_tlb)       ,
    .m_tlb_req          (m_tlb_req)         ,
    .m_tlb_busy         (m_tlb_busy)        ,

    .m_icache_req       (m_icache_req)      ,
    .m_dcache_req       (m_dcache_req)      ,
    .m_cache_busy       (m_cache_busy)      ,
    .m_taglo            (m_taglo)           ,

	//debug
    .debug_wb_pc        (debug_wb_pc)       ,
    .debug_wb_rf_wen    (debug_wb_rf_wen)   ,
    .debug_wb_rf_wnum   (debug_wb_rf_wnum)  ,
    .debug_wb_rf_wdata  (debug_wb_rf_wdata)

);

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

exc_latch f_tlb_exc_latch(
    .clk(clk),
    .rst(~resetn),
    .stall(stall_alpha.f),
    .flush(1'b0),
    .data_ok(inst_data_ok),
    .in(f_tlb_exc_if),
    .out(f_tlb_exc)
);

exc_latch m_tlb_exc_latch(
    .clk(clk),
    .rst(~resetn),
    .stall(stall_alpha.m),
    .flush(flush_alpha.m),
    .data_ok(data_data_ok),
    .in(m_tlb_exc_mem),
    .out(m_tlb_exc)
);

tlb_latch m_tlb_latch(
    .clk(clk),
    .rst(~resetn),
    .stall(stall_alpha.m),
    .flush(flush_alpha.m),
    .data_ok(tlb_ok),
    .in(m_read_tlb),
    .out(read_tlb)
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
    .force_req(w_tlbw),
    .unique_id(f_inst_addr),
    .need_req(f_inst_req),
    .busy(idmem.imem_busy),

    .addr_ok(inst_addr_ok),
    .data_ok(inst_data_ok),
    .req(inst_req)
    );

sram_like_handshake dmem_handshake(
    .clk(clk),
    .rst(~resetn),
    .force_req(1'b0),
    .unique_id(m_instr_count),
    .need_req(m_data_req),
    .busy(idmem.dmem_busy),

    .addr_ok(data_addr_ok),
    .data_ok(data_data_ok),
    .req(data_req)
    );

sram_like_handshake tlb_handshake(
    .clk(clk),
    .rst(~resetn),
    .force_req(1'b0),
    .unique_id(m_instr_count),
    .need_req(m_tlb_req != NO_REQ),
    .busy(m_tlb_busy),

    .addr_ok(m_tlb_ok),
    .data_ok(m_tlb_ok),
    .req(tlb_req_logic)
    );

sram_like_handshake icache_handshake(
    .clk(clk),
    .rst(~resetn),
    .force_req(1'b0),
    .unique_id(m_instr_count),
    .need_req(m_icache_req != NO_CACHE),
    .busy(m_icache_busy),

    .addr_ok(m_icache_ok),
    .data_ok(m_icache_ok),
    .req(icache_req_logic)
    );

sram_like_handshake dcache_handshake(
    .clk(clk),
    .rst(~resetn),
    .force_req(1'b0),
    .unique_id(m_instr_count),
    .need_req(m_dcache_req != NO_CACHE),
    .busy(m_dcache_busy),

    .addr_ok(m_dcache_ok),
    .data_ok(m_dcache_ok),
    .req(dcache_req_logic)
    );

assign tlb_req = tlb_req_logic ? m_tlb_req : NO_REQ;
assign icache_req = icache_req_logic ? m_icache_req : NO_CACHE;
assign dcache_req = dcache_req_logic ? m_dcache_req : NO_CACHE;

assign m_cache_busy = m_icache_busy | m_dcache_busy;

endmodule
