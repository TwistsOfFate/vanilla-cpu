`include "cpu_defs.svh"

module flop_etom(
	input clk,
	input rst,
	input stall,
	input dp_etom in,
	output dp_etom out
    );
    
    integer i;
    dp_etom tmp;
    
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
