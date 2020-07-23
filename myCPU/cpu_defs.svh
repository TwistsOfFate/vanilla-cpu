`ifndef CPU_DEFS_SVH
`define CPU_DEFS_SVH

typedef enum logic [6:0] {
	OP_ADD, OP_ADDI, OP_ADDU, OP_ADDIU, OP_SUB, OP_SUBU,
	OP_SLT, OP_SLTI, OP_SLTU, OP_SLTIU,
	OP_DIV, OP_DIVU,
	OP_MULT, OP_MULTU,
	OP_AND, OP_ANDI, OP_LUI, OP_NOR, OP_OR, OP_ORI, OP_XOR, OP_XORI,
	OP_SLLV, OP_SLL, OP_SRAV, OP_SRA, OP_SRLV, OP_SRL,
	OP_BEQ, OP_BNE, OP_BGEZ, OP_BGTZ, OP_BLEZ, OP_BLTZ,
	OP_BGEZAL, OP_BLTZAL,
	OP_J, OP_JAL, OP_JR, OP_JALR,
	OP_MFHI, OP_MFLO, OP_MTHI, OP_MTLO,
	OP_BREAK, OP_SYSCALL,
	OP_LB, OP_LBU, OP_LH, OP_LHU, OP_LW,
	OP_SB, OP_SH, OP_SW,
	OP_ERET, OP_MFC0, OP_MTC0
} op_t;

`define CP0_BADVADDR 	5'd8
`define CP0_COUNT		5'd9
`define CP0_STATUS		5'd12
`define CP0_CAUSE		5'd13
`define CP0_EPC			5'd14

`define EXCCODE_INT		5'h0
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
	logic 	 	 memtoreg ;
	logic 	 	 regwrite ;
	logic [ 1:0] regdst   ;
	logic	 	 memreq   ;
	logic  	 	 memwr 	;
	logic [ 2:0] alu_func ;
	logic [ 1:0] sft_func ;
	logic 		 imm_sign ;
	logic		 mul_sign ;
	logic 		 div_en   ;
	logic		 div_sign ;
	logic		 intovf_en;
	logic [ 1:0] out_sel  ;
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
	logic		 cp0_sel;
	logic		 cp0_wen;
	logic		 eret;
	logic		 pcsrc;
	logic		 isbranch;
	logic [ 2:0] branch;
	logic  		 isjump;
	logic [ 1:0] jump;
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
	logic        addr_err_if   ;
	logic		 is_instr	   ;
	logic 		 in_delay_slot ;
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
} dp_dtoe;

typedef struct packed {
	logic		  in_delay_slot;
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
} dp_etom;

typedef struct packed {
	logic	[31:0]ex_out;
	logic	[31:0]rsdata;
	logic	[31:0]rtdata;
	logic	[ 4:0]reg_waddr;
	logic	[31:0]pc;
	logic	[31:0]hi_wdata;
	logic	[31:0]lo_wdata;
	logic	[ 4:0]rd;
	logic		  is_instr;
	logic   [31:0]data_rdata;
} dp_mtow;

typedef struct packed {
	logic		  isbranch;
	logic		  isjump;
	logic	[ 1:0]out_sel;
	logic	[ 4:0]rs;
	logic	[ 4:0]rt;
} dp_dtoh;

typedef struct packed {
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  memtoreg ;
	logic	[ 1:0]out_sel  ;
	logic		  cp0_sel  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  div_en   ;
	logic	[ 4:0]rs;
	logic	[ 4:0]rt;
	logic	[ 4:0]rd;
	logic		  div_ready;
} dp_etoh;

typedef struct packed {
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  memtoreg ;
	logic		  cp0_sel  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  exc_cp0_wen;
	logic		  eret;
	logic		  is_valid_exc;
} dp_mtoh;

typedef struct packed {
	logic	[ 4:0]rd;
	logic	[ 4:0]reg_waddr;
	logic 	 	  regwrite ;
	logic		  cp0_sel  ;
	logic		  hi_wen   ;
	logic		  lo_wen   ;
	logic		  cp0_wen  ;
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