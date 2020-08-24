`include"cpu_defs.svh"
module decode(    
    input  logic[31:0] d_for_rsdata,
    input  logic[31:0] d_for_rtdata,
    input  logic[31:0] d_for_hi,
    input  logic[31:0] d_for_lo,
    input  logic[31:0] f_nowpc,
    input  logic[31:0] f_pcplus4,
    input  logic[31:0] cp0_epc,
    input  logic       is_valid_exc ,
    input  logic[31:0] exc_addr,
    input  ctrl_reg    dsig,

    input  logic       d_guess_taken,
    input  logic       bfrome,
    input  logic       eret,
    input  dp_ftod     ftod,

    output logic[31:0] f_nextpc,
    output logic       f_indelayslot,
    output logic       d_rtzero,

    output dp_dtoe     dtoe ,
    output instr_inf   dinstrinf,
    output dp_dtoh     dtoh
);

logic [31:0] pcnextbr, d_pcbranch, pcnextjr, pcnexteret,pcnextjpc, pcbfrome;
logic [31:0] d_signimm, d_signimmsh ;
branch_rel dbranchcmp;
logic pcsrc;
logic [7:0] branch;

assign d_rtzero = d_for_rtdata == 32'd0;

assign dbranchcmp.equal = d_for_rsdata == d_for_rtdata;
assign dbranchcmp.e0 = d_for_rsdata == 32'd0;
assign dbranchcmp.g0 = ~d_for_rsdata[31] & ~dbranchcmp.e0;

assign branch[0] = (dsig.branch == 3'b000) &&  dbranchcmp.equal  && dsig.isbranch ;
assign branch[1] = (dsig.branch == 3'b001) && !dbranchcmp.equal  && dsig.isbranch ;
assign branch[2] = (dsig.branch == 3'b010) &&  (dbranchcmp.g0 | dbranchcmp.e0) && dsig.isbranch ;
assign branch[3] = (dsig.branch == 3'b011) &&  dbranchcmp.g0  && dsig.isbranch ;
assign branch[4] = (dsig.branch == 3'b100) &&  !dbranchcmp.g0 && dsig.isbranch ;
assign branch[5] = (dsig.branch == 3'b101) && (!dbranchcmp.g0 && !dbranchcmp.e0) && dsig.isbranch ;
assign branch[6] = (dsig.branch == 3'b110) && (dbranchcmp.g0 | dbranchcmp.e0) && dsig.isbranch ;
assign branch[7] = (dsig.branch == 3'b111) && (!dbranchcmp.g0 && !dbranchcmp.e0) && dsig.isbranch ;

assign pcsrc = |branch ;

assign d_signimm = {{16{ftod.instr[15]}}, ftod.instr[15:0]};
assign d_signimmsh = {d_signimm[29:0], 2'b00};
assign d_pcbranch = ftod.pcplus4 + d_signimmsh;

mux2 #(32) pcbrmux(
    .a  		(f_pcplus4)     ,
    .b  		(d_pcbranch)    ,
    .sel   		(pcsrc || d_guess_taken)       ,
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

mux2 #(32) pcbfromemux(
    .a(pcnextjr),
    .b(ftod.pcplus4),
    .sel(bfrome),
    .out(pcbfrome)
);

mux2 #(32) pceretmux(
    .a          (pcbfrome)     ,
    .b          (cp0_epc)      ,
    .sel        (eret)       ,
    .out        (pcnexteret)
) ;

mux2 #(32) pcexcmux(
    .a          (pcnexteret)   ,
    .b          (exc_addr) ,         
    .sel        (is_valid_exc) ,
    .out        (f_nextpc)
) ;

assign f_indelayslot    = dsig.isbranch || dsig.isjump;

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
assign dtoe.cp0_sel = ftod.instr[2:0];
assign dtoe.tlb_exc_if = ftod.tlb_exc_if;

assign dinstrinf.branchfunct       = ftod.instr[20:16] ;
assign dinstrinf.c0funct           = ftod.instr[25:21] ;
assign dinstrinf.op                = ftod.instr[31:26] ;
assign dinstrinf.funct             = ftod.instr[5:0] ;


assign dtoh.isbranch = dsig.isbranch ; 
assign dtoh.isjump = dsig.isjump ; 
assign dtoh.out_sel = dsig.out_sel ;
assign dtoh.rs = dtoe.rs ;
assign dtoh.rt = dtoe.rt ;
assign dtoh.mfc0 = dsig.mfc0;
assign dtoh.jump = dsig.jump;
assign dtoh.tlb_req = dsig.tlb_req;
assign dtoh.pcsrc = pcsrc;
assign dtoh.likely = dsig.likely;


endmodule