module pc_flop_beta #(
	parameter WIDTH=32
)(
	input clk,
	input rst,
	input stall,
	input [WIDTH-1:0] in,
	output [WIDTH-1:0] out
    );
    
    integer i;
    logic [WIDTH-1:0] tmp;
    
    always_ff @(posedge clk) begin
    	if (rst) begin
    		tmp <= 32'hBFC0_0004;
    	end else if (stall) begin
    		tmp <= tmp;
    	end else begin
    		tmp <= in;
    	end
    end
    
    assign out = tmp;
    
endmodule
