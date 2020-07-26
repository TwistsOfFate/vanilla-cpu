`timescale 1ns / 1ps

module multiplier_ip(
	input clk,
	input rst,
	input in_valid,
	input sign,
	input [31:0] srca,
	input [31:0] srcb,
	output out_valid,
	output [31:0] hi,
	output [31:0] lo
	);

logic [31:0] hi0, lo0, hi1, lo1;
logic [31:0] count;
logic [63:0] ops_reg;

always_ff @(posedge clk) begin
	if (rst)
		ops_reg <= 64'd0;
	else
		ops_reg <= {srca, srcb};
end

always_ff @(posedge clk) begin
	if (ops_reg != {srca, srcb} || !in_valid || rst)
		count <= 32'd0;
	else
		count <= count < 32'd3 ? count + 32'd1 : count;
end

mult_gen_0 my_mult_gen_0(
    .CLK(clk),
    .A(srca),
    .B(srcb),
    .P({hi0, lo0})
);

mult_gen_1 my_mult_gen_1(
    .CLK(clk),
    .A(srca),
    .B(srcb),
    .P({hi1, lo1})
);

assign out_valid = count >= 32'd3;
assign hi = sign ? hi1 : hi0;
assign lo = sign ? lo1 : lo0;

    
endmodule
