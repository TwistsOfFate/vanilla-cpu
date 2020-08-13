`include "cpu_defs.svh"

module flop_mtow(
	input clk,
	input rst,
	input stall,
	input dp_mtow in,
	output dp_mtow out
    );
    
    integer i;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		out.is_instr <= '0;
    	end else if (stall) begin
    		out <= out;
    	end else begin
    		out <= in;
    	end
    end
        
endmodule
