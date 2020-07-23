`include"cpu_defs.svh"
module hazard(
    input  dp_dtoh     d_alpha,
    input  dp_etoh     e_alpha,
    input  dp_mtoh     m_alpha,
    input  dp_wtoh     w_alpha,

    output dp_htod     to_d_alpha,
    output dp_htoe     to_e_alpha,

    output stage_val_1 stall,
    output stage_val_1 flush,
    input stage_val_1 stall_ext,
    input stage_val_1 flush_ext,

    input busy_ok     idmem
    );
               
    
logic lwstall, branchstall, hilostall;
logic cp0_unavailable_stall, cp0_wconflict_stall, divider_stall;
logic imem_stall, dmem_stall;

logic [9:0] stall_flush;

assign {stall.f, stall.d, stall.e, stall.m, stall.w, flush.f, flush.d, flush.e, flush.m, flush.w} = 
stall_flush | {stall_ext.f, stall_ext.d, stall_ext.e, stall_ext.m, 1'b0, 1'b0, flush_ext.d, flush_ext.e, flush_ext.m, flush_ext.w};


always_comb
    begin
        if(d_alpha.out_sel == 2'b10 && m_alpha.hi_wen)//HI
            to_d_alpha.hi_forward = 2'b10 ;
        else if(d_alpha.out_sel == 2'b10 && w_alpha.hi_wen)
            to_d_alpha.hi_forward = 2'b01 ;
        else
            to_d_alpha.hi_forward = 2'b00 ;

        if(d_alpha.out_sel == 2'b11 && m_alpha.lo_wen)//LO
            to_d_alpha.lo_forward = 2'b10 ;
        else if(e_alpha.out_sel == 2'b11 && w_alpha.lo_wen)
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

   
    
assign lwstall = e_alpha.memtoreg && ((e_alpha.rt == d_alpha.rs) || (e_alpha.rt == d_alpha.rt)) ;

assign hilostall = (e_alpha.hi_wen && d_alpha.out_sel == 2'b10) || (e_alpha.lo_wen && d_alpha.out_sel == 2'b11) ;

assign branchstall = ( d_alpha.isbranch || d_alpha.isjump ) && ((e_alpha.regwrite && ((e_alpha.reg_waddr == d_alpha.rs) 
|| (e_alpha.reg_waddr == d_alpha.rt))) || (m_alpha.memtoreg &&  ((m_alpha.reg_waddr == d_alpha.rs) || (m_alpha.reg_waddr == d_alpha.rt)))) ;

assign cp0_unavailable_stall = (e_alpha.cp0_sel && (e_alpha.reg_waddr == d_alpha.rs || e_alpha.reg_waddr == d_alpha.rt)) 
|| (m_alpha.cp0_sel && (m_alpha.reg_waddr == d_alpha.rs || m_alpha.reg_waddr == d_alpha.rt)) 
|| (w_alpha.cp0_sel && (w_alpha.reg_waddr == d_alpha.rs || w_alpha.reg_waddr == d_alpha.rt));

assign cp0_wconflict_stall = m_alpha.exc_cp0_wen && w_alpha.cp0_wen ;

assign divider_stall = e_alpha.div_en && !e_alpha.div_ready;

assign imem_stall = idmem.imem_busy;
assign dmem_stall = idmem.dmem_busy;


always_comb begin
	if (dmem_stall)
		stall_flush = 10'b11111_00000;
	else if (imem_stall && (m_alpha.is_valid_exc || m_alpha.eret))
		stall_flush = 10'b11111_00000;
	else if (imem_stall && divider_stall)
		stall_flush = 10'b11100_00010;
	else if (imem_stall)
		stall_flush = 10'b11000_00100;
	else if (cp0_wconflict_stall)
		stall_flush = 10'b11110_00001;
	else if (m_alpha.is_valid_exc || m_alpha.eret)
		stall_flush = 10'b00000_01111;
	else if (divider_stall)
		stall_flush = 10'b11100_00010;
	else if (lwstall || branchstall || hilostall || cp0_unavailable_stall)
		stall_flush = 10'b11000_00100;
	else
		stall_flush = 10'b0;
end  
              
              
endmodule