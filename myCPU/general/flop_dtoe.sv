`include "cpu_defs.svh"

module flop_dtoe(
	input clk,
	input rst,
	input stall,
	input dp_dtoe in,
	output dp_dtoe out
    );
    
    integer i;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		out.addr_err_if <= '0;
            out.in_delay_slot <= '0;
            out.is_instr <= '0;
            out.cp0_sel <= '0;
            out.tlb_exc_if <= NO_EXC;
    	end else if (stall) begin
    		out <= out;
    	end else begin
    		out <= in;
    	end
    end
        
endmodule
