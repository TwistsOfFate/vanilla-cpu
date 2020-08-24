`include "cpu_defs.svh"

module flop_tlb_exc(
	input clk,
	input rst,
	input stall,
	input tlb_exc_t in,
	output tlb_exc_t out
    );
    
    integer i;
    tlb_exc_t tmp;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		tmp <= NO_EXC;
    	end else if (stall) begin
    		tmp <= tmp;
    	end else begin
    		tmp <= in;
    	end
    end
    
    assign out = tmp;
    
endmodule
