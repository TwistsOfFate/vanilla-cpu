`include "cpu_defs.svh"

module flop_dtoe(
	input clk,
	input rst,
	input stall,
	input dp_dtoe in,
	output dp_dtoe out
    );
    
    integer i;
    dp_dtoe tmp;
    
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
