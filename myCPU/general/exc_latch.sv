module exc_latch(
	input clk,
	input rst,
	input stall,
	input flush,
	input data_ok,
	input tlb_exc_t in,
	output tlb_exc_t out
);

	tlb_exc_t tmp;
	
	flop_tlb_exc	tmp_ff		(clk, rst | flush, stall & ~data_ok, in, tmp);
	
	assign out = data_ok ? in : tmp;
		
endmodule