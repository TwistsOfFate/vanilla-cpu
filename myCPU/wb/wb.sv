`include"cpu_defs.svh"
module wb(
	input  dp_mtow   	mtow ,
	input  ctrl_reg  	wsig ,

	output dp_wtoh   	wtoh ,
    output logic        w_tlbw,
	output logic [31:0]	w_reg_wdata
	
    );
    
    wire [31:0]		w_rdata_out;
	wire [31:0]		w_memreg_out;
	wire [31:0]		w_link_out;

    assign w_tlbw = wsig.tlb_req == TLBWI || wsig.tlb_req == TLBWR;
    assign w_rdata_out = mtow.rdata_out;

	// rdata_extend w_rdata_extend(
 //    	.sign(wsig.rdata_sign),
 //    	.rdata(mtow.data_rdata),
 //    	.size(wsig.size),
 //    	.memoffset(mtow.ex_out[1:0]),
 //    	.out(w_rdata_out)
 //    );

    always_comb
        if (wsig.sc)
            w_reg_wdata = 32'b1;
        else if (wsig.mfc0)
            w_reg_wdata = mtow.cp0_rdata;
        else if (wsig.link)
            w_reg_wdata = mtow.pcplus8;
        else if (wsig.memtoreg)
            w_reg_wdata = w_rdata_out;
        else
            w_reg_wdata = mtow.ex_out;

    // mux2 memtoreg_mux2(
    // 	.a(mtow.ex_out),
    // 	.b(w_rdata_out),
    // 	.sel(wsig.memtoreg),
    // 	.out(w_memreg_out)
    // );
    
    // mux2 link_mux2(
    // 	.a(w_memreg_out),
    // 	.b(mtow.pcplus8),
    // 	.sel(wsig.link),
    // 	.out(w_link_out)
    // );
    
    // mux2 mfc0_mux2(
    // 	.a(w_link_out),
    // 	.b(mtow.cp0_rdata),
    // 	.sel(wsig.mfc0),
    // 	.out(w_reg_wdata)
    // );
    
	assign wtoh.rd = mtow.rd ;
	assign wtoh.reg_waddr = mtow.reg_waddr ;
	assign wtoh.regwrite = wsig.regwrite ;
	assign wtoh.mfc0 = wsig.mfc0 ;
	assign wtoh.hi_wen = wsig.hi_wen ;
	assign wtoh.lo_wen = wsig.lo_wen ;
	assign wtoh.cp0_wen = wsig.cp0_wen ;
    assign wtoh.tlb_req = wsig.tlb_req;
    assign wtoh.sc      = wsig.sc;
    
endmodule
