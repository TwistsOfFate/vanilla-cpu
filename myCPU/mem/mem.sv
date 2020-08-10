`include"cpu_defs.svh"
module mem(
	input			clk,
	input 			rst,
	input [5:0]		ext_int,

	input 			m_stall,
	input  ctrl_reg msig,
	input  dp_etom	etom,
	output dp_mtow  mtow,
	output dp_mtoh  mtoh,

	output [31:0] 	cp0_epc,
	output [31:0]	exc_addr,

	input [31:0]	data_rdata,

	input 			tlb_busy,
	input tlb_exc_t tlb_exc_mem,
	input  tlb_t 	read_tlb,
	output tlb_t	write_tlb,
	output tlb_req_t tlb_req,
	
	//SRAM-LIKE INTERFACE
	output         	m_data_req,
    output    		m_data_wr,
    output [1:0]	m_data_size,
    output [31:0] 	m_data_addr,
    output [31:0] 	m_data_wdata
    );

	wire [1:0] 		real_size;
	wire [1:0]		real_offset;

    wire [31:0]		m_badvaddr;
    wire [1:0]		m_addr_err;
    wire			m_addr_err_if;
    wire			m_req;
    wire			m_intovf;

    wire 			cp0_ready;
    cp0_op_t 		cp0_op;
    exc_info_t		exc_info;
    wire [31:0]		cp0_status;
    wire [31:0]		cp0_cause;
        
//DATA_ADDR_CHECK
	data_addr_check my_data_addr_check(
		.memreq(msig.memreq),
		.wr(msig.memwr),
		.addr({etom.ex_out[31:2], real_offset}),
		.size(real_size),
		.addr_err_if(etom.addr_err_if),
		.badvaddr_if(etom.pc),
		.badvaddr(m_badvaddr),
		.addr_err(m_addr_err),
		.m_req(m_req)
	);

//TLB_REQUESTOR
	tlb_requestor my_tlb_req(
		.in_req(msig.tlb_req),
		.addr_err(m_addr_err),		// "Address error - Data access" comes before TLB data access exceptions
		.reserved_instr(msig.reserved_instr),
		.intovf(etom.intovf),
		.tlb_exc_if(etom.tlb_exc_if),
		.cp0_ready(1'b1),
		.out_req(tlb_req)
	);
	
//EXC_HANDLER
	exc_handler my_exc_handler(
		//INPUT
		.m_is_instr(etom.is_instr),
		.cp0_epc(cp0_epc),
		.cp0_status(cp0_status),
		.cp0_cause(cp0_cause),
		.m_in_delay_slot(etom.in_delay_slot),
		.m_pc(etom.pc),
		.m_pcminus4(etom.pcminus4),
		.m_badvaddr(m_badvaddr),
		
		.m_addr_err(m_addr_err),
		.m_reserved_instr(msig.reserved_instr),
		.m_intovf(etom.intovf),
		.m_break(msig.mips_break),
		.m_syscall(msig.syscall),
		.m_eret(msig.eret),
		.m_mtc0(msig.cp0_wen),
		.m_tlb_req(tlb_req),
		.tlb_exc_if(etom.tlb_exc_if),
		.tlb_exc_mem(tlb_exc_mem),
		
		//OUTPUT
		.is_valid_exc(mtoh.is_valid_exc),
		.exc_addr(exc_addr),
		.cp0_op(cp0_op),
		.exc_info(exc_info)
	);

//CP0_REGFILE
	cp0_regfile my_cp0(
		.clk(clk),
		.rst(rst),
		.ext_int(ext_int),
		.m_stall(m_stall),

		//INPUT
		.ren(msig.mfc0),
		.wen(cp0_op != OP_NONE && !tlb_busy),
		.wtype(cp0_op),	
		.exc_info(exc_info),
		.read_tlb(read_tlb),
		.waddr(etom.rd),
		.wsel(etom.cp0_sel),
		.wdata(etom.rtdata),
		.raddr(etom.rd),
		.rsel(etom.cp0_sel),

		//OUTPUT
		.ready(cp0_ready),
		.rdata(mtow.cp0_rdata),
		.epc(cp0_epc),
		.status(cp0_status),
		.cause(cp0_cause),
		.write_tlb(write_tlb)
	);

//MEMSIG_ADJUST
	memsig_adjust memsig_adjust(
		.req(m_req),
		.wr(msig.memwr),
		.in(etom.rtdata),
		.size(msig.size),
		.memoffset(etom.ex_out[1:0]),
		.swlr(msig.swlr),
		.lwlr(msig.lwlr),
		.out(m_data_wdata),
		.real_size(real_size),
		.real_offset(real_offset)		// real_offset and real_size only changes at SWL/SWR
	);
	
//SRAM-LIKE INTERFACE
	assign 			m_data_req = m_req;
	assign			m_data_wr = msig.memwr;
	assign			m_data_size = real_size;
	assign			m_data_addr = {etom.ex_out[31:2], real_offset};

	rdata_extend m_rdata_extend(
    	.sign(msig.rdata_sign),
    	.rdata(data_rdata),
    	.rtdata(etom.rtdata),
    	.size(msig.size),
    	.memoffset(mtow.ex_out[1:0]),
    	.lwlr(msig.lwlr),
    	.out(mtow.rdata_out)
    );

// MtoW and MtoH signals
	assign mtow.ex_out = etom.ex_out ;
	assign mtow.rsdata = etom.rsdata ;
	assign mtow.rtdata = etom.rtdata ;
	assign mtow.reg_waddr = etom.reg_waddr ;
	assign mtow.pc = etom.pc ;
	assign mtow.pcplus8 = etom.pc + 32'd8;
	assign mtow.hi_wdata = etom.hi_wdata ;
	assign mtow.lo_wdata = etom.lo_wdata ;
	assign mtow.rd = etom.rd ;
	assign mtow.is_instr = etom.is_instr ;
	assign mtow.data_rdata = data_rdata ;

	assign mtoh.reg_waddr = etom.reg_waddr ;
	assign mtoh.regwrite  = msig.regwrite ;
	assign mtoh.memtoreg  = msig.memtoreg ;
	assign mtoh.mfc0  	 = msig.mfc0 ;
	assign mtoh.cp0_wen  = msig.cp0_wen ;
	assign mtoh.hi_wen   = msig.hi_wen ;
	assign mtoh.lo_wen   = msig.lo_wen ;
	assign mtoh.eret     = msig.eret ;
	assign mtoh.rt 		 = etom.rt;
	assign mtoh.rd 		 = etom.rd;
	assign mtoh.link 	 = msig.link;
	assign mtoh.cp0_ready = cp0_ready;

endmodule
