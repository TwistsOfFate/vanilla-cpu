`ifndef CPU_DEFS_SVH
`define CPU_DEFS_SVH

// typedef enum logic [6:0] {
// 	OP_ADD, OP_ADDI, OP_ADDU, OP_ADDIU, OP_SUB, OP_SUBU,
// 	OP_SLT, OP_SLTI, OP_SLTU, OP_SLTIU,
// 	OP_DIV, OP_DIVU,
// 	OP_MULT, OP_MULTU,
// 	OP_AND, OP_ANDI, OP_LUI, OP_NOR, OP_OR, OP_ORI, OP_XOR, OP_XORI,
// 	OP_SLLV, OP_SLL, OP_SRAV, OP_SRA, OP_SRLV, OP_SRL,
// 	OP_BEQ, OP_BNE, OP_BGEZ, OP_BGTZ, OP_BLEZ, OP_BLTZ,
// 	OP_BGEZAL, OP_BLTZAL,
// 	OP_J, OP_JAL, OP_JR, OP_JALR,
// 	OP_MFHI, OP_MFLO, OP_MTHI, OP_MTLO,
// 	OP_BREAK, OP_SYSCALL,
// 	OP_LB, OP_LBU, OP_LH, OP_LHU, OP_LW,
// 	OP_SB, OP_SH, OP_SW,
// 	OP_ERET, OP_MFC0, OP_MTC0
// } op_t;

typedef enum logic [3:0] {
	OP_NONE, OP_MTC0, OP_EXC, OP_BADVA, OP_ERET,
	OP_TLB_EXC, OP_TLBW, OP_TLBR, OP_TLBP, OP_WAIT
} cp0_op_t;

typedef enum logic [4:0] {
	INDEX, RANDOM, ENTRYLO0, ENTRYLO1, CONTEXT,
	PAGEMASK, WIRED, HWRENA, BADVADDR, COUNT,
	ENTRYHI, COMPARE, STATUS, CAUSE, EPC,
	PRID, CONFIG, LLADDR, WATCHLO, WATCHHI,
	R20, R21, R22, DEBUG, DEPC,
	PERFCNT, ERRCTL, CACHEERR, TAGLO, TAGHI,
	ERROREPC, DESAVE
} cp0_reg_t;

typedef enum logic [2:0] {
	NO_EXC, REFILL_L, REFILL_S, INVALID_L, INVALID_S, MODIFIED
} tlb_exc_t;

typedef enum logic [2:0] {
	NO_REQ, TLBWI, TLBWR, TLBR, TLBP
} tlb_req_t;

`define CP0_INDEX		8'b000_00000
`define CP0_RANDOM		8'b000_00001
`define CP0_ENTRYLO0	8'b000_00010
`define CP0_ENTRYLO1	8'b000_00011
`define CP0_CONTEXT		8'b000_00100
`define CP0_PAGEMASK	8'b000_00101
`define CP0_WIRED		8'b000_00110
`define CP0_R7			8'b000_00111 // Not implemented
`define CP0_BADVADDR 	8'b000_01000
`define CP0_COUNT		8'b000_01001
`define CP0_ENTRYHI		8'b000_01010
`define CP0_COMPARE		8'b000_01011
`define CP0_STATUS		8'b000_01100
`define CP0_CAUSE		8'b000_01101
`define CP0_EPC			8'b000_01110
`define CP0_PRID		8'b000_01111
`define CP0_CONFIG		8'b000_10000
`define CP0_CONFIG1		8'b001_10000
`define CP0_LLADDR		8'b000_10001 // Not implemented
`define CP0_WATCHLO		8'b000_10010 // Not implemented
`define CP0_WATCHHI		8'b000_10011 // Not implemented
`define CP0_R20			8'b000_10100 // Not implemented
`define CP0_R21			8'b000_10101 // Not implemented
`define CP0_R22			8'b000_10110 // Not implemented
`define CP0_R23			8'b000_10111 // Not implemented
`define CP0_R24			8'b000_11000 // Not implemented
`define CP0_PERFCNT		8'b000_11001 // Not implemented
`define CP0_ERRCTL		8'b000_11010 // Not implemented
`define CP0_CACHEERR	8'b000_11011 // Not implemented
`define CP0_TAGLO		8'b000_11100
`define CP0_TAGHI		8'b000_11101 // Not implemented
`define CP0_ERROREPC	8'b000_11110 // Not implemented
`define CP0_R31			8'b000_11111 // Not implemented

`define EXCCODE_INT		5'h0
`define EXCCODE_MOD		5'h1
`define EXCCODE_TLBL	5'h2
`define EXCCODE_TLBS	5'h3
`define EXCCODE_ADEL	5'h4
`define EXCCODE_ADES	5'h5
`define EXCCODE_SYS		5'h8
`define EXCCODE_BP		5'h9
`define EXCCODE_RI		5'hA
`define EXCCODE_OV		5'hC

typedef struct packed {
	logic f;
	logic d;
	logic e;
	logic m;
	logic w;
} stage_val_1;

typedef struct packed {
	logic [31:0] epc;
	logic cause_bd;
	logic [4:0] cause_exccode;
	logic [31:0] badvaddr;
} exc_info_t;

typedef struct packed {
	logic [31:0] index;
	logic [31:0] random;
	logic [31:0] entryhi;
	logic [31:0] pagemask;
	logic [31:0] entrylo0;
	logic [31:0] entrylo1;
} tlb_t;

typedef struct packed {
	logic 	 	 memtoreg ;
	logic 	 	 regwrite ;
	logic [ 1:0] regdst   ;
	logic	 	 memreq   ;
	logic  	 	 memwr 	;
	logic [ 2:0] alu_func ;
	logic [ 1:0] sft_func ;
	logic 		 imm_sign ;
	logic		 mul_en	  ;
	logic		 mul_sign ;
	logic 		 div_en   ;
	logic		 div_sign ;
	logic		 intovf_en;
	logic [ 2:0] out_sel  ;
	logic		 alu_srcb_sel_rt ;
	logic		 sft_srca_sel_imm;
	logic		 sft_srcb_sel_rs ;
	logic		 link;
	logic		 reserved_instr;
	logic		 mips_break;
	logic		 syscall;
	logic		 rdata_sign;
	logic [ 1:0] hi_sel;
	logic [ 1:0] lo_sel;
	logic [ 1:0] size;
	logic 		 hi_wen;
	logic		 lo_wen;
	logic		 mfc0;
	logic		 cp0_wen;
	logic		 eret;
	logic		 isbranch;
	logic [ 2:0] branch;
	logic  		 isjump;
	logic [ 1:0] jump;
	logic 		 cl_mode;
	logic [ 1:0] mul_mode;
	tlb_req_t	 tlb_req;
	logic [ 1:0] swlr;
	logic [ 1:0] lwlr;
	logic 		 op_wait;
} ctrl_reg ;

typedef struct packed {
	logic [ 5:0] op ;
	logic [ 5:0] funct ;
	logic [ 4:0] branchfunct; 
	logic [ 4:0] c0funct;
} instr_inf ;

typedef struct packed {
	logic equal ;
	logic e0 ;
	logic g0 ;
} branch_rel ;

typedef struct packed {
	logic		  inst_data_ok;
	logic		  data_data_ok;
	logic		  imem_busy;
	logic		  dmem_busy;
} busy_ok;

typedef struct packed {
	logic [31:0] instr         ;
	logic [31:0] pc 	 	   ;
	logic [31:0] pcplus4	   ;
	logic        addr_err_if   ;
	logic		 is_instr	   ;
	logic 		 in_delay_slot ;
	tlb_exc_t    tlb_exc_if	   ;
} dp_ftod;

typedef struct packed {
	logic	[ 4:0]rs;
	logic	[ 4:0]rt;
	logic	[ 4:0]rd;
	logic	[ 4:0]sa;
	logic	[31:0]rsdata;
	logic	[31:0]rtdata;
	logic	[15:0]imm;
	logic	[31:0]hi;
	logic	[31:0]lo;
	logic	[31:0]pc;
	logic		  addr_err_if;
	logic		  in_delay_slot;
	logic		  is_instr	   ;
	logic   [ 2:0]cp0_sel;
	tlb_exc_t    tlb_exc_if	   ;
} dp_dtoe;

typedef struct packed {
	logic		  in_delay_slot;
	logic	[ 4:0]rt;
	logic	[31:0]rsdata;
	logic	[31:0]rtdata;
	logic	[31:0]ex_out;
	logic	[31:0]pc;
	logic	[ 4:0]reg_waddr;
	logic	[ 4:0]rd;
	logic	[31:0]hi_wdata;
	logic	[31:0]lo_wdata;
	logic		  addr_err_if;
	logic		  intovf;
	logic		  is_instr	   ;
	logic 	[31:0]pcminus4;
	logic 	[31:0]pcplus4;
	logic   [ 2:0]cp0_sel;
	tlb_exc_t    tlb_exc_if	   ;
} dp_etom;

typedef struct packed {
	logic	[31:0]ex_out;
	logic	[31:0]rsdata;
	logic	[31:0]rtdata;
	logic	[ 4:0]reg_waddr;
	logic	[31:0]pc;
	logic   [31:0]pcplus8;
	logic	[31:0]hi_wdata;
	logic	[31:0]lo_wdata;
	logic	[ 4:0]rd;
	logic		  is_instr;
	logic   [31:0]data_rdata;
	logic	[31:0]cp0_rdata;
	logic  	[31:0]rdata_out;
} dp_mtow;

typedef struct packed {
	logic		  isbranch;
	logic		  isjump;
	logic	[ 2:0]out_sel;
	logic	[ 4:0]rs;
	logic	[ 4:0]rt;
	logic		  mfc0;
	logic   [ 1:0]jump;
	tlb_req_t	  tlb_req;
} dp_dtoh;

typedef struct packed {
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  memtoreg ;
	logic	[ 2:0]out_sel  ;
	logic		  mfc0  ;
	logic		  cp0_wen  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  div_en   ;
	logic		  mul_en   ;
	logic	[ 4:0]rs;
	logic	[ 4:0]rt;
	logic	[ 4:0]rd;
	logic		  div_ready;
	logic		  mul_ready;
	logic		  link;
	tlb_req_t	  tlb_req;
} dp_etoh;

typedef struct packed {
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  memtoreg ;
	logic		  mfc0  ;
	logic		  cp0_wen  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  eret;
	logic		  is_valid_exc;
	logic	[ 4:0]rt;
	logic   [ 4:0]rd;
	logic		  link;
	logic 		  cp0_ready;
	tlb_req_t	  tlb_req;
	logic 		  op_wait;
} dp_mtoh;

typedef struct packed {
	logic	[ 4:0]rd;
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  mfc0  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  cp0_wen  ;
	tlb_req_t	  tlb_req;
} dp_wtoh;

typedef struct packed {
	logic	[ 1:0]forwarda;
	logic	[ 1:0]forwardb;
	logic	[ 1:0]hi_forward;
	logic	[ 1:0]lo_forward;
} dp_htod;

typedef struct packed {
	logic	[ 1:0]forwarda;
	logic	[ 1:0]forwardb;
} dp_htoe;



`endif