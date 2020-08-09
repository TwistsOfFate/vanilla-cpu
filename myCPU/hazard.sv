`include"cpu_defs.svh"
module hazard(
    input  dp_dtoh     d_alpha,
    input  dp_etoh     e_alpha,
    input  dp_mtoh     m_alpha,
    input  dp_wtoh     w_alpha,

    input  logic       bfrome,

    output dp_htod     to_d_alpha,
    output dp_htoe     to_e_alpha,

    output logic       d_guess_taken,

    output stage_val_1 stall,
    output stage_val_1 flush,

    input busy_ok     idmem
    );
               
    
logic lwstall, jrstall, hilostall, link_stall, linkr_stall;
logic mfc0_stall, cp0_busy_stall;
logic divider_stall, multiplier_stall;
logic imem_stall, dmem_stall;

logic [9:0] stall_flush;

assign {stall.f, stall.d, stall.e, stall.m, stall.w, flush.f, flush.d, flush.e, flush.m, flush.w} = stall_flush;


always_comb
    begin
        if(d_alpha.out_sel == 3'b010 && m_alpha.hi_wen)//HI
            to_d_alpha.hi_forward = 2'b10 ;
        else if(d_alpha.out_sel == 3'b010 && w_alpha.hi_wen)
            to_d_alpha.hi_forward = 2'b01 ;
        else
            to_d_alpha.hi_forward = 2'b00 ;

        if(d_alpha.out_sel == 3'b011 && m_alpha.lo_wen)//LO
            to_d_alpha.lo_forward = 2'b10 ;
        else if(d_alpha.out_sel == 3'b011 && w_alpha.lo_wen)
            to_d_alpha.lo_forward = 2'b01 ;
        else
            to_d_alpha.lo_forward = 2'b00 ;    
    end 

always_comb
    begin
        if(d_alpha.rs != 0)
            if((d_alpha.rs == m_alpha.reg_waddr) && m_alpha.regwrite) to_d_alpha.forwarda = 2'b10 ;
            else if((d_alpha.rs == w_alpha.reg_waddr) && w_alpha.regwrite) to_d_alpha.forwarda = 2'b01 ;
            else to_d_alpha.forwarda = 2'b00 ;
        else
            to_d_alpha.forwarda = 2'b00 ;
        if(d_alpha.rt != 0)
            if((d_alpha.rt == m_alpha.reg_waddr) && m_alpha.regwrite) to_d_alpha.forwardb = 2'b10 ;
            else if((d_alpha.rt == w_alpha.reg_waddr) && w_alpha.regwrite) to_d_alpha.forwardb = 2'b01 ;
            else to_d_alpha.forwardb = 2'b00 ;
        else
            to_d_alpha.forwardb = 2'b00 ;
    end
    
always_comb
    begin
        if(e_alpha.rs != 0)
            if((e_alpha.rs == m_alpha.reg_waddr) && m_alpha.regwrite) to_e_alpha.forwarda = 2'b10 ;
            else if ((e_alpha.rs == w_alpha.reg_waddr) && w_alpha.regwrite) to_e_alpha.forwarda = 2'b01 ;
            else to_e_alpha.forwarda = 2'b00 ;
        else
            to_e_alpha.forwarda = 2'b00 ;
        if(e_alpha.rt != 0)
            if((e_alpha.rt == m_alpha.reg_waddr) && m_alpha.regwrite) to_e_alpha.forwardb = 2'b10 ;
            else if ((e_alpha.rt == w_alpha.reg_waddr) && w_alpha.regwrite) to_e_alpha.forwardb = 2'b01 ;
            else to_e_alpha.forwardb = 2'b00 ;
        else
            to_e_alpha.forwardb = 2'b00 ;
    end

assign d_guess_taken = d_alpha.isbranch && ((e_alpha.regwrite && (e_alpha.reg_waddr == d_alpha.rs 
|| e_alpha.reg_waddr == d_alpha.rt)) || (m_alpha.memtoreg && (m_alpha.reg_waddr == d_alpha.rs || m_alpha.reg_waddr == d_alpha.rt)));

assign link_stall = (e_alpha.link || m_alpha.link) && (d_alpha.rs == 5'd31 || d_alpha.rt == 5'd31);

assign linkr_stall = e_alpha.link && (d_alpha.rs == e_alpha.rd || d_alpha.rt == e_alpha.rd)
|| m_alpha.link && (d_alpha.rs == m_alpha.rd || d_alpha.rt == m_alpha.rd);
    
assign lwstall = (e_alpha.memtoreg && (e_alpha.rt == d_alpha.rs || e_alpha.rt == d_alpha.rt))
                /*|| (m_alpha.memtoreg && (m_alpha.rt == d_alpha.rs || m_alpha.rt == d_alpha.rt))*/ ;

assign hilostall = (e_alpha.hi_wen && d_alpha.out_sel == 3'b010) || (e_alpha.lo_wen && d_alpha.out_sel == 3'b011) ;

assign jrstall = d_alpha.jump[0] && ((e_alpha.regwrite && e_alpha.reg_waddr == d_alpha.rs) || (m_alpha.memtoreg && m_alpha.reg_waddr == d_alpha.rs)) ;

assign mfc0_stall = (e_alpha.mfc0 && (e_alpha.reg_waddr == d_alpha.rs || e_alpha.reg_waddr == d_alpha.rt)) 
|| (m_alpha.mfc0 && (m_alpha.reg_waddr == d_alpha.rs || m_alpha.reg_waddr == d_alpha.rt)) 
|| (w_alpha.mfc0 && (w_alpha.reg_waddr == d_alpha.rs || w_alpha.reg_waddr == d_alpha.rt));

assign cp0_busy_stall = !m_alpha.cp0_ready;

assign divider_stall = e_alpha.div_en && !e_alpha.div_ready;
assign multiplier_stall = e_alpha.mul_en && !e_alpha.mul_ready;

assign imem_stall = idmem.imem_busy;
assign dmem_stall = idmem.dmem_busy;


always_comb begin
    if (dmem_stall || cp0_busy_stall)
        stall_flush = 10'b11111_00000;
    else if (imem_stall && (m_alpha.is_valid_exc || m_alpha.eret))
        stall_flush = 10'b11111_00000;
    else if (m_alpha.is_valid_exc || m_alpha.eret)
        stall_flush = 10'b00000_01111;
    else if (divider_stall || multiplier_stall)
        stall_flush = 10'b11111_00000;
    else if (imem_stall && bfrome)
        stall_flush = 10'b11111_00000;
    else if (imem_stall)
        stall_flush = 10'b11000_00100;
    else if (bfrome)
        stall_flush = 10'b00000_01000;
    else if (lwstall || jrstall || hilostall || mfc0_stall || link_stall || linkr_stall/* || mtc0_stall*/)
        stall_flush = 10'b11000_00100;
    else
        stall_flush = 10'b0;
end 
              
              
endmodule