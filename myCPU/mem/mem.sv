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

	output 			cp0_ready,
	output [31:0] 	cp0_epc,
	output [31:0] 	cp0_index,
	output [31:0] 	cp0_random,
	output [31:0]	cp0_entryhi,

	input [31:0]	data_rdata,
	
	//MEM STAGE INPUT
	// input [31:0]	cp0_epc,
	// input [31:0]	cp0_status,
	// input [31:0]	cp0_cause,

	//EXCEPTION HANDLER OUTPUT
	output [31:0]	m_epc_wdata,
	output			m_cause_bd_wdata,
	output [4:0]	m_cause_exccode_wdata,
	// output			exc_cp0_wen,
	output [4:0]	m_cp0_waddr,
	output [31:0]	m_cp0_wdata,
	
	//SRAM-LIKE INTERFACE
	output         	m_data_req,
    output    		m_data_wr,
    output [1:0]	m_data_size,
    output [31:0] 	m_data_addr,
    output [31:0] 	m_data_wdata
    );
    

    wire [31:0]		m_badvaddr;
    wire [1:0]		m_addr_err;
    wire			m_addr_err_if;
    wire			m_req;
    wire			m_intovf;

    cp0_op_t 		cp0_op;
    exc_info_t		exc_info;
    wire [31:0]		cp0_status;
    wire [31:0]		cp0_cause;
        
//DATA_ADDR_CHECK
	data_addr_check my_data_addr_check(
		.memreq(msig.memreq),
		.wr(msig.memwr),
		.addr(etom.ex_out),
		.size(msig.size),
		.addr_err_if(etom.addr_err_if),
		.badvaddr_if(etom.pc),
		.badvaddr(m_badvaddr),
		.addr_err(m_addr_err),
		.m_req(m_req)
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
		
		//OUTPUT
		.is_valid_exc(mtoh.is_valid_exc),
		// .exc_cp0_wen(exc_cp0_wen),
		.cp0_op(cp0_op),
		.exc_info(exc_info)
		// .m_epc_wdata(m_epc_wdata),
		// .m_cause_bd_wdata(m_cause_bd_wdata),
		// .m_cause_exccode_wdata(m_cause_exccode_wdata),
		
		// .m_cp0_wen(exc_cp0_wen),
		// .m_cp0_waddr(m_cp0_waddr),
		// .m_cp0_wdata(m_cp0_wdata)
	);

//CP0_REGFILE
	cp0_regfile my_cp0(
		.clk(clk),
		.rst(rst),
		.ext_int(ext_int),

		//INPUT
		.ren(msig.mfc0 || cp0_op != NONE && cp0_op != MTC0),
		.wen(cp0_op != NONE),
		.wtype(cp0_op),	
		.exc_info(exc_info),
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
		.index(cp0_index),
		.random(cp0_random),
		.entryhi(cp0_entryhi)
	);

//WDATA_ADJUST
	sram_wsig_adjust sram_wsig_adjust(
		.req(m_req),
		.wr(msig.memwr),
		.in(etom.rtdata),
		.size(msig.size),
		.memoffset(etom.ex_out[1:0]),
		.out(m_data_wdata),
		.wen()
//		.wen(m_data_wen)
	);
	
//SRAM-LIKE INTERFACE
	assign 			m_data_req = m_req;
	assign			m_data_wr = msig.memwr;
	assign			m_data_size = msig.size;
	assign			m_data_addr = etom.ex_out;

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
