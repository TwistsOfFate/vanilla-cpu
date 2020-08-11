module tlb_latch(
	input clk,
	input rst,
	input stall,
	input flush,
	input data_ok,
	input tlb_t in,
	output tlb_t out
);

	tlb_t tmp;
	
	flop_tlb	tmp_ff		(clk, rst | flush, stall & ~data_ok, in, tmp);
	
	assign out = data_ok ? in : tmp;
		
endmodule