`include "cpu_defs.svh"

module flop_mtow(
	input clk,
	input rst,
	input stall,
	input dp_mtow in,
	output dp_mtow out
    );
    
    integer i;
    dp_mtow tmp;
    
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
