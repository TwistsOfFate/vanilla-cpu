`include"cpu_defs.svh"
module mem(
	input			clk,

	input  ctrl_reg msig,
	input  dp_etom	etom,
	output dp_mtow  mtow,
	output dp_mtoh  mtoh,

	input [31:0]	data_rdata,
	
	//MEM STAGE INPUT
	input [31:0]	cp0_epc,
	input [31:0]	cp0_status,
	input [31:0]	cp0_cause,

	//EXCEPTION HANDLER OUTPUT
	output [31:0]	m_epc_wdata,
	output			m_cause_bd_wdata,
	output [4:0]	m_cause_exccode_wdata,
	output			exc_cp0_wen,
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
		.m_badvaddr(m_badvaddr),
		
		.m_addr_err(m_addr_err),
		.m_reserved_instr(msig.reserved_instr),
		.m_intovf(etom.intovf),
		.m_break(msig.mips_break),
		.m_syscall(msig.syscall),
		.m_eret(msig.eret),
		
		//OUTPUT
		.is_valid_exc(mtoh.is_valid_exc),
		.m_epc_wdata(m_epc_wdata),
		.m_cause_bd_wdata(m_cause_bd_wdata),
		.m_cause_exccode_wdata(m_cause_exccode_wdata),
		
		.m_cp0_wen(exc_cp0_wen),
		.m_cp0_waddr(m_cp0_waddr),
		.m_cp0_wdata(m_cp0_wdata)
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
	
	assign mtow.ex_out = etom.ex_out ;
	assign mtow.rsdata = etom.rsdata ;
	assign mtow.rtdata = etom.rtdata ;
	assign mtow.reg_waddr = etom.reg_waddr ;
	assign mtow.pc = etom.pc ;
	assign mtow.hi_wdata = etom.hi_wdata ;
	assign mtow.lo_wdata = etom.lo_wdata ;
	assign mtow.rd = etom.rd ;
	assign mtow.is_instr = etom.is_instr ;
	assign mtow.data_rdata = data_rdata ;

	assign mtoh.reg_waddr = etom.reg_waddr ;
	assign mtoh.regwrite  = msig.regwrite ;
	assign mtoh.memtoreg  = msig.memtoreg ;
	assign mtoh.cp0_sel  = msig.cp0_sel ;
	assign mtoh.hi_wen   = msig.hi_wen ;
	assign mtoh.lo_wen   = msig.lo_wen ;
	assign mtoh.exc_cp0_wen = exc_cp0_wen ;
	assign mtoh.eret     = msig.eret ;


endmodule
