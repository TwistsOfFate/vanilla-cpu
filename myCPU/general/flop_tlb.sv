`include "cpu_defs.svh"

module flop_tlb(
	input clk,
	input rst,
	input stall,
	input tlb_t in,
	output tlb_t out
    );
    
    integer i;
    tlb_t tmp;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		tmp <= '0;
    	end else if (stall) begin
    		tmp <= tmp;
    	end else begin
    		tmp <= in;
    	end
    end
    
    assign out = tmp;
    
endmodule
