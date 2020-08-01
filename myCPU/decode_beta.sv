`include"cpu_defs.svh"
module decode_beta(    
    input  logic[31:0] d_for_rsdata,
    input  logic[31:0] d_for_rtdata,
    input  logic[31:0] d_for_hi,
    input  logic[31:0] d_for_lo,
    input  logic       f_stall,

    input  logic[31:0] cp0_epc,
    input  logic       is_valid_exc ,

    input  ctrl_reg    dsig,
    // input  logic       alpha_is_jb,
    input  logic       eret,
    input  logic[31:0] pc_next_alpha,

    input  dp_ftod     ftod,
    input  logic[ 1:0] issue_method,

    output logic[31:0] f_nextpc,
    output logic       next_req,

    output branch_rel  dbranchcmp,

    output dp_dtoe     dtoe ,
    output instr_inf   dinstrinf,
    
    output dp_dtoh     dtoh
);

logic [31:0] pcnexteret ;
logic [31:0] d_signimm, d_signimmsh ;
logic [31:0] f_pcplus8 ;

assign next_req = 1 ;

// adder   pcadd1( 
//     .add_valA   (f_nowpc)      ,
//     .add_valB   (32'b1000)     ,
//     .add_result (f_pcplus8) 
// ) ; //add 4 to get the pc in the delay slot


// mux2 #(32) pceretmux(
//     .a          (f_pcplus8)    ,
//     .b          (cp0_epc+32'd4),
//     .sel        (eret)         ,
//     .out        (pcnexteret)
// ) ;

// mux2 #(32) pcexcmux(
//     .a          (pcnexteret)   ,
//     .b          (32'hBFC00384) ,
//     .sel        (is_valid_exc) ,
//     .out        (f_nextpc)
// ) ;

assign f_nextpc = pc_next_alpha + 32'd4 ;

// assign f_indelayslot    = dsig.isbranch || dsig.isjump;

assign dtoe.rs          = ftod.instr[25:21] ;
assign dtoe.rt          = ftod.instr[20:16] ;
assign dtoe.rd          = ftod.instr[15:11] ;
assign dtoe.sa          = ftod.instr[10:6]  ;
assign dtoe.imm		    = ftod.instr[15:0]  ;
assign dtoe.rsdata      = d_for_rsdata ;
assign dtoe.rtdata      = d_for_rtdata ;
assign dtoe.hi          = d_for_hi ;
assign dtoe.lo          = d_for_lo ;
assign dtoe.pc          = ftod.pc ;
assign dtoe.addr_err_if = ftod.addr_err_if ;
assign dtoe.in_delay_slot = ftod.in_delay_slot ;
assign dtoe.is_instr = ftod.is_instr ;

assign dinstrinf.branchfunct       = ftod.instr[20:16] ;
assign dinstrinf.c0funct           = ftod.instr[25:21] ;
assign dinstrinf.op                = ftod.instr[31:26] ;
assign dinstrinf.funct             = ftod.instr[5:0] ;


assign dtoh.isbranch = dsig.isbranch ; 
assign dtoh.isjump = dsig.isjump ; 
assign dtoh.out_sel = dsig.out_sel ;
assign dtoh.rs = dtoe.rs ;
assign dtoh.rt = dtoe.rt ;
assign dtoh.pcsrc = dsig.pcsrc ;
assign dtoh.pc = ftod.pc;

endmodule