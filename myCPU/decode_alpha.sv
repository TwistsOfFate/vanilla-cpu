`include"cpu_defs.svh"
module decode_alpha(
    input  logic       clk,
    input  logic       rst,

    input  logic       d_stall,
    input  logic       d_flush,

    input  logic[31:0] d_for_rsdata,
    input  logic[31:0] d_for_rtdata,
    input  logic[31:0] d_for_hi,
    input  logic[31:0] d_for_lo,

    // input  logic[31:0] f_nowpc,
    input  logic[31:0] cp0_epc,
    input  logic       is_valid_exc ,

    input  ctrl_reg    dsig,
    input  logic       eret,

    input  dp_ftod     ftod,
    input  logic [1:0] issue_method,

    output logic       d_inst_req,
    output logic [31:0]d_inst_addr,

    output branch_rel  dbranchcmp,
    // output logic       beta_indelayslot,

    output dp_dtoe     dtoe ,
    output instr_inf   dinstrinf,
    output dp_dtoh     dtoh
);

logic jb_yes;
logic [31:0] jb_inst_addr, jb_target;
logic [31:0] pcnextbr, d_pcbranch, pcnextjr, pcnexteret,pcnextjpc,pcnextexc ;
logic [31:0] d_signimm, d_signimmsh ;
logic [31:0] f_pcplus4 ;

//跳转且双发（单发会发延迟槽） flushD_alpha _beta
// 跳转且单发， 给一个flushD_beta

assign f_pcplus4 = ftod.pc + 32'd4;


eqcmp   cmpeq(
    .a  (d_for_rsdata)  ,
    .b  (d_for_rtdata)  ,
    .eq (dbranchcmp.equal)    
);


Compare cmp0(
    .valA    (d_for_rsdata) ,
    .greater (dbranchcmp.g0)   ,
    .equal   (dbranchcmp.e0) 
);

signext se(
    .ext_valA   (ftod.instr[15:0]) ,
    .ext_result (d_signimm)     
) ; //imm extends to 32 bits

sl2     immsh(
    .sl2_valA   (d_signimm)     ,
    .sl2_result (d_signimmsh)   
) ; //imm shifts left 2

adder   pcadd3(
    .add_valA   (f_pcplus4)     ,
    .add_valB   (d_signimmsh)   ,
    .add_result (d_pcbranch)          
) ; //add pc in the delay slot and imm

mux2 #(32) pcbrmux(
    .a  		(0)     ,
    .b  		(d_pcbranch)    ,
    .sel   		(dsig.pcsrc)       ,
    .out		(pcnextbr)      
) ;//next pc


mux2 #(32) pcjmux(
    .a  		(pcnextbr)                                ,
    .b  		({f_pcplus4[31:28],ftod.instr[25:0],2'b00})  ,
    .sel   		(~dsig.jump[0] && dsig.isjump)                  ,
    .out		(pcnextjpc)
) ;

mux2 #(32) pcjrmux(
    .a  		(pcnextjpc)    ,
    .b  		(d_for_rsdata) ,
    .sel   		(dsig.jump[0] && dsig.isjump)    ,
    .out		(pcnextjr)     
) ;

mux2 #(32) pceretmux(
    .a          (pcnextjr)     ,
    .b          (cp0_epc)      ,
    .sel        (eret)       ,
    .out        (pcnexteret)
) ;

mux2 #(32) pcexcmux(
    .a          (pcnexteret)   ,
    .b          (32'hBFC00380) ,         
    .sel        (is_valid_exc) ,
    .out        (jb_inst_addr)
) ;

// flop #(1) jb_yes_flop(clk, rst | d_flush, d_stall, dsig.pcsrc | dsig.isjump, jb_yes);

// always_ff @(posedge clk)
//     if (rst) jb_target <= 32'h0000_0000;
//     else if (dsig.pcsrc || dsig.isjump) jb_target <= jb_inst_addr;

// assign d_inst_req = issue_method == 2'd2 && (dsig.pcsrc || !dsig.jump[0] && dsig.isjump || dsig.jump[0] && dsig.isjump)
//                      || eret || is_valid_exc || ftod.in_delay_slot && jb_yes;

// assign d_inst_addr = ftod.in_delay_slot ? jb_target : jb_inst_addr;

assign d_inst_req = dsig.pcsrc || !dsig.jump[0] && dsig.isjump || dsig.jump[0] && dsig.isjump || eret || is_valid_exc;

assign d_inst_addr = jb_inst_addr;


assign dtoe.rs          = ftod.instr[25:21] ;
assign dtoe.rt          = ftod.instr[20:16] ;
assign dtoe.rd          = ftod.instr[15:11] ;
assign dtoe.sa          = ftod.instr[10:6]  ;
assign dtoe.imm         = ftod.instr[15:0]  ;
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
assign dtoh.pc = ftod.pc ;

endmodule