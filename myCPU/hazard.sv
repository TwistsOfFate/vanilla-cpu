`include"cpu_defs.svh"
module hazard(
    input  clk,
    input  reset,

    input  dp_dtoh     d_alpha,
    input  dp_etoh     e_alpha,
    input  dp_mtoh     m_alpha,
    input  dp_wtoh     w_alpha,

    input  dp_dtoh     d_beta,
    input  dp_etoh     e_beta,
    input  dp_mtoh     m_beta,
    input  dp_wtoh     w_beta,

    output dp_htod     to_d_alpha,
    output dp_htoe     to_e_alpha,

    output dp_htod     to_d_beta,
    output dp_htoe     to_e_beta,

    input  stage_val_1 stall_ext_alpha,
    input  stage_val_1 flush_ext_alpha,

    input  stage_val_1 stall_ext_beta,
    input  stage_val_1 flush_ext_beta,

    output stage_val_1 stall_alpha,
    output stage_val_1 flush_alpha,

    output stage_val_1 stall_beta,
    output stage_val_1 flush_beta,
    
    // input  busy_ok     idmem,
    input  logic       imem_busy,
    input  logic       dmem_busy,
    input  logic[ 1:0] issue_method,

    output logic       fifo_wait
    );
               
    
logic lwstall, branchstall, hilostall, link_stall;
logic mfc0_stall, mtc0_stall, cp0_wconflict_stall, divider_stall;
logic imem_stall, dmem_stall;
logic jb_d_flush_db ;

logic [9:0] stall_flush_alpha, stall_flush_beta;

assign {stall_alpha.f, stall_alpha.d, stall_alpha.e, stall_alpha.m, stall_alpha.w, flush_alpha.f, flush_alpha.d, flush_alpha.e, flush_alpha.m, flush_alpha.w} = 
stall_flush_alpha | {stall_ext_alpha.f, stall_ext_alpha.d, stall_ext_alpha.e, stall_ext_alpha.m, stall_ext_alpha.w, 1'b0, flush_ext_alpha.d, flush_ext_alpha.e, flush_ext_alpha.m, flush_ext_alpha.w};

assign {stall_beta.f, stall_beta.d, stall_beta.e, stall_beta.m, stall_beta.w, flush_beta.f, flush_beta.d, flush_beta.e, flush_beta.m, flush_beta.w} = 
stall_flush_beta | {stall_ext_beta.f, stall_ext_beta.d, stall_ext_beta.e, stall_ext_beta.m, stall_ext_beta.w, 1'b0, flush_ext_beta.d, flush_ext_beta.e, flush_ext_beta.m, flush_ext_beta.w};

assign jb_d_flush_db  = ((d_alpha.pcsrc && d_alpha.isbranch) || d_alpha.isjump) && issue_method == 2'd2 ;
assign jb_d_flush_beta = ((d_alpha.pcsrc && d_alpha.isbranch) || d_alpha.isjump) && issue_method == 2'd1;

always_comb
    begin
        if((d_alpha.out_sel == 2'b10 || d_beta.out_sel == 2'b10) && m_beta.hi_wen)
            to_d_alpha.hi_forward = 3'b100 ;
        else if((d_alpha.out_sel == 2'b10 || d_beta.out_sel == 2'b10) && m_alpha.hi_wen)//HI
            to_d_alpha.hi_forward = 3'b010 ;
        else if((d_alpha.out_sel == 2'b10 || d_beta.out_sel == 2'b10) && w_beta.hi_wen)
            to_d_alpha.hi_forward = 3'b011 ;
        else if((d_alpha.out_sel == 2'b10 || d_beta.out_sel == 2'b10) && w_alpha.hi_wen)
            to_d_alpha.hi_forward = 3'b001 ;
        else
            to_d_alpha.hi_forward = 3'b000 ;

        if((d_alpha.out_sel == 2'b11 || d_beta.out_sel == 2'b11) && m_beta.lo_wen)
            to_d_alpha.lo_forward = 3'b100 ;
        else if((d_alpha.out_sel == 2'b11 || d_beta.out_sel == 2'b11) && m_alpha.lo_wen)//HI
            to_d_alpha.lo_forward = 3'b010 ;
        else if((d_alpha.out_sel == 2'b11 || d_beta.out_sel == 2'b11) && w_beta.lo_wen)
            to_d_alpha.lo_forward = 3'b011 ;
        else if((d_alpha.out_sel == 2'b11 || d_beta.out_sel == 2'b11) && w_alpha.lo_wen)
            to_d_alpha.lo_forward = 3'b001 ;
        else
            to_d_alpha.lo_forward = 3'b000 ;

    end 

assign to_d_beta.hi_forward = to_d_alpha.hi_forward ;
assign to_d_beta.lo_forward = to_d_alpha.lo_forward ;

always_comb
    begin
        if(d_alpha.rs != 0)
            if((d_alpha.rs == m_beta.reg_waddr) && m_beta.regwrite)  
                to_d_alpha.forwarda = 3'b100 ;
            else if((d_alpha.rs == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_d_alpha.forwarda = 3'b010 ;
            else if((d_alpha.rs == w_beta.reg_waddr) && w_beta.regwrite) 
                to_d_alpha.forwarda = 3'b011 ;
            else if((d_alpha.rs == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_d_alpha.forwarda = 3'b001 ;
            else 
                to_d_alpha.forwarda = 3'b000 ;
        else
            to_d_alpha.forwarda = 3'b000 ;

        if(d_alpha.rt != 0)
            if((d_alpha.rt == m_beta.reg_waddr) && m_beta.regwrite)  
                to_d_alpha.forwardb = 3'b100 ;
            else if((d_alpha.rt == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_d_alpha.forwardb = 3'b010 ;
            else if((d_alpha.rt == w_beta.reg_waddr) && w_beta.regwrite) 
                to_d_alpha.forwardb = 3'b011 ;
            else if((d_alpha.rt == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_d_alpha.forwardb = 3'b001 ;
            else 
                to_d_alpha.forwardb = 3'b000 ;
        else
            to_d_alpha.forwardb = 3'b000 ;



        if(d_beta.rs != 0)
            if((d_beta.rs == m_beta.reg_waddr) && m_beta.regwrite)  
                to_d_beta.forwarda = 3'b100 ;
            else if((d_beta.rs == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_d_beta.forwarda = 3'b010 ;
            else if((d_beta.rs == w_beta.reg_waddr) && w_beta.regwrite) 
                to_d_beta.forwarda = 3'b011 ;
            else if((d_beta.rs == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_d_beta.forwarda = 3'b001 ;
            else 
                to_d_beta.forwarda = 3'b000 ;
        else
            to_d_beta.forwarda = 3'b000 ;

        if(d_beta.rt != 0)
            if((d_beta.rt == m_beta.reg_waddr) && m_beta.regwrite)  
                to_d_beta.forwardb = 3'b100 ;
            else if((d_beta.rt == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_d_beta.forwardb = 3'b010 ;
            else if((d_beta.rt == w_beta.reg_waddr) && w_beta.regwrite) 
                to_d_beta.forwardb = 3'b011 ;
            else if((d_beta.rt == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_d_beta.forwardb = 3'b001 ;
            else 
                to_d_beta.forwardb = 3'b000 ;
        else
            to_d_beta.forwardb = 3'b000 ;

        
    end
    
always_comb
    begin
        if(e_alpha.rs != 0)
            if((e_alpha.rs == m_beta.reg_waddr) && m_beta.regwrite) 
                to_e_alpha.forwarda = 3'b100 ;
            else if((e_alpha.rs == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_e_alpha.forwarda = 3'b010 ;
            else if((e_alpha.rs == w_beta.reg_waddr) && w_beta.regwrite) 
                to_e_alpha.forwarda = 3'b011 ;
            else if ((e_alpha.rs == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_e_alpha.forwarda = 3'b001 ;
            else 
                to_e_alpha.forwarda = 3'b000 ;
        else
            to_e_alpha.forwarda = 3'b000 ;

        if(e_alpha.rt != 0)
            if((e_alpha.rt == m_beta.reg_waddr) && m_beta.regwrite) 
                to_e_alpha.forwardb = 3'b100 ;
            else if((e_alpha.rt == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_e_alpha.forwardb = 3'b010 ;
            else if((e_alpha.rt == w_beta.reg_waddr) && w_beta.regwrite) 
                to_e_alpha.forwardb = 3'b011 ;
            else if ((e_alpha.rt == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_e_alpha.forwardb = 3'b001 ;
            else 
                to_e_alpha.forwardb = 3'b000 ;
        else
            to_e_alpha.forwardb = 3'b000 ;

        if(e_beta.rs != 0)
            if((e_beta.rs == m_beta.reg_waddr) && m_beta.regwrite) 
                to_e_beta.forwarda = 3'b100 ;
            else if((e_beta.rs == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_e_beta.forwarda = 3'b010 ;
            else if((e_beta.rs == w_beta.reg_waddr) && w_beta.regwrite) 
                to_e_beta.forwarda = 3'b011 ;
            
            else if ((e_beta.rs == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_e_beta.forwarda = 3'b001 ;
            else 
                to_e_beta.forwarda = 3'b000 ;
        else
            to_e_beta.forwarda = 3'b000 ;

        if(e_beta.rt != 0)
            if((e_beta.rt == m_beta.reg_waddr) && m_beta.regwrite) 
                to_e_beta.forwardb = 3'b100 ;
            else if((e_beta.rt == m_alpha.reg_waddr) && m_alpha.regwrite) 
                to_e_beta.forwardb = 3'b010 ;
            else if((e_beta.rt == w_beta.reg_waddr) && w_beta.regwrite) 
                to_e_beta.forwardb = 3'b011 ;
            else if ((e_beta.rt == w_alpha.reg_waddr) && w_alpha.regwrite) 
                to_e_beta.forwardb = 3'b001 ;
            else 
                to_e_beta.forwardb = 3'b000 ;
        else
            to_e_beta.forwardb = 3'b000 ;
        
    end

assign link_stall = (e_alpha.regdst == 2'b10 || m_alpha.regdst == 2'b10) && 
(d_alpha.rs == 5'd31 || d_alpha.rt == 5'd31 || d_beta.rs == 5'd31 || d_beta.rt == 5'd31);

assign lwstall = (e_alpha.memtoreg && ((e_alpha.rt == d_alpha.rs) || (e_alpha.rt == d_alpha.rt)))
                ||(e_alpha.memtoreg && ((e_alpha.rt == d_beta.rs) || (e_alpha.rt == d_beta.rt))) ;

assign hilostall = ((e_alpha.hi_wen || e_beta.hi_wen) && d_alpha.out_sel == 2'b10) 
    || ((e_alpha.lo_wen || e_beta.lo_wen) && d_alpha.out_sel == 2'b11) 
    || ((e_alpha.hi_wen || e_beta.hi_wen) && d_beta.out_sel == 2'b10) 
    || ((e_alpha.lo_wen || e_beta.lo_wen) && d_beta.out_sel == 2'b11) ;

assign branchstall = ( d_alpha.isbranch || d_alpha.isjump ) && 
(      (e_alpha.regwrite && (e_alpha.reg_waddr == d_alpha.rs || e_alpha.reg_waddr == d_alpha.rt))
    || (e_beta.regwrite && (e_beta.reg_waddr == d_alpha.rs || e_beta.reg_waddr == d_alpha.rt)) 
    || (m_alpha.memtoreg &&  (m_alpha.reg_waddr == d_alpha.rs || m_alpha.reg_waddr == d_alpha.rt)) 
    || (m_beta.memtoreg &&  (m_beta.reg_waddr == d_alpha.rs || m_beta.reg_waddr == d_alpha.rt))         
);

assign mfc0_stall = (e_alpha.cp0_sel && (e_alpha.reg_waddr == d_alpha.rs || e_alpha.reg_waddr == d_alpha.rt)) 
|| (m_alpha.cp0_sel && (m_alpha.reg_waddr == d_alpha.rs || m_alpha.reg_waddr == d_alpha.rt)) 
|| (w_alpha.cp0_sel && (w_alpha.reg_waddr == d_alpha.rs || w_alpha.reg_waddr == d_alpha.rt))
|| (e_alpha.cp0_sel && (e_alpha.reg_waddr == d_beta.rs  || e_alpha.reg_waddr == d_beta.rt )) 
|| (m_alpha.cp0_sel && (m_alpha.reg_waddr == d_beta.rs  || m_alpha.reg_waddr == d_beta.rt)) 
|| (w_alpha.cp0_sel && (w_alpha.reg_waddr == d_beta.rs  || w_alpha.reg_waddr == d_beta.rt));

// assign mtc0_stall = d_alpha.cp0_sel && (e_alpha.cp0_wen || m_alpha.cp0_wen || w_alpha.cp0_wen)
// || d_beta.cp0_sel && (e_alpha.cp0_wen || m_alpha.cp0_wen || w_alpha.cp0_wen);

assign cp0_wconflict_stall = (m_alpha.exc_cp0_wen || m_beta.exc_cp0_wen) && w_alpha.cp0_wen ;

assign divider_stall = (e_alpha.div_en && !e_alpha.div_ready) || (e_beta.div_en && !e_beta.div_ready);

assign imem_stall = imem_busy;
assign dmem_stall = dmem_busy;

assign fifo_wait = lwstall || branchstall || hilostall || mfc0_stall || link_stall; 

always_comb 
begin
    if (dmem_stall)
        stall_flush_alpha = 10'b11111_00000;
    else if (imem_stall && (m_alpha.is_valid_exc || m_alpha.eret || m_beta.is_valid_exc || m_beta.eret))
        stall_flush_alpha = 10'b11111_00000;
    else if (cp0_wconflict_stall)
        stall_flush_alpha = 10'b11110_00001;
    else if (m_alpha.is_valid_exc || m_alpha.eret)
        stall_flush_alpha = 10'b00000_01111;
    else if (m_beta.is_valid_exc || m_beta.eret)
        stall_flush_alpha = 10'b00000_01110;
    else if (divider_stall)
        stall_flush_alpha = 10'b11111_00000;
    else if (imem_stall)
        stall_flush_alpha = 10'b11000_00100;
    else if (lwstall || branchstall || hilostall || mfc0_stall || link_stall/* || mtc0_stall*/)
        stall_flush_alpha = 10'b11000_00100;
    else if (jb_d_flush_db)
        stall_flush_alpha = 10'b00000_01000;
    else
        stall_flush_alpha = 10'b00000_00000;
end

always_comb 
begin
    if (dmem_stall)
        stall_flush_beta = stall_flush_alpha;
    else if (imem_stall && (m_alpha.is_valid_exc || m_alpha.eret || m_beta.is_valid_exc || m_beta.eret))
        stall_flush_beta = stall_flush_alpha;
    else if (cp0_wconflict_stall)
        stall_flush_beta = stall_flush_alpha;
    else if (m_alpha.is_valid_exc || m_alpha.eret || m_beta.is_valid_exc || m_beta.eret)
        stall_flush_beta = 10'b00000_01111;
    else if (divider_stall)
        stall_flush_beta = stall_flush_alpha;
    else if (imem_stall)
        stall_flush_beta = stall_flush_alpha;
    else if (lwstall || branchstall || hilostall || mfc0_stall || mtc0_stall || link_stall)
        stall_flush_beta = stall_flush_alpha;
    else if (jb_d_flush_db || jb_d_flush_beta)
        stall_flush_beta = 10'b00000_01000;
    else
        stall_flush_beta = 10'b00000_00000;
end

              
endmodule