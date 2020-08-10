`include "cpu_defs.svh"

module flop_ctrl(
	input clk,
	input rst,
	input stall,
	input ctrl_reg in,
	output ctrl_reg out
    );
    
    integer i;
    ctrl_reg tmp;
    
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
