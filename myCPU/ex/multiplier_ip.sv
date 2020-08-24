`timescale 1ns / 1ps

module multiplier_ip #(
	parameter CYCLES = 3
)(
	input clk,
	input rst,
	input in_valid,
	input sign,
	input [1:0] mode,
	input [31:0] srca,
	input [31:0] srcb,
	input [31:0] in_hi,
	input [31:0] in_lo,
	output logic out_valid,
	output logic [31:0] hi,
	output logic [31:0] lo
	);

logic [31:0] hi0, lo0, hi1, lo1, hi_reg, lo_reg;
logic [31:0] hi_add_reg, hi_sub_reg, lo_add_reg, lo_sub_reg;
logic [31:0] hi_addsub_reg, lo_addsub_reg;
logic [4:0] count;
// logic [130:0] in_reg;

// always_ff @(posedge clk) begin
// 	if (rst)
// 		in_reg <= '0;
// 	else
// 		in_reg <= {sign, mode, srca, srcb, in_hi, in_lo};
// end

always_ff @(posedge clk) begin
	if (!in_valid || rst)
		count <= 5'd0;
	else if (mode == 2'b00)
		count <= count < CYCLES ? count + 5'd1 : 5'd0;
	else
		count <= count < CYCLES + 2 ? count + 5'd1 : 5'd0;
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

always_ff @(posedge clk) begin
	hi_reg <= sign ? hi1 : hi0;
	lo_reg <= sign ? lo1 : lo0;
end

c_addsub_0 my_addsub(
  .A({in_hi, in_lo}),      // input wire [63 : 0] A
  .B({hi_reg, lo_reg}),      // input wire [63 : 0] B
  .CLK(clk),  // input wire CLK
  .ADD(mode == 2'b01),  // input wire ADD
  .S({hi_addsub_reg, lo_addsub_reg})      // output wire [63 : 0] S
);

// always_ff @(posedge clk) begin
// 	{hi_add_reg, lo_add_reg} <= {in_hi, in_lo} + {hi_reg, lo_reg};
// 	{hi_sub_reg, lo_sub_reg} <= {in_hi, in_lo} - {hi_reg, lo_reg};
// end

always_comb begin
	unique case (mode)
		2'b00:
		begin
			hi = sign ? hi1 : hi0;
			lo = sign ? lo1 : lo0;
			out_valid = count >= CYCLES;
		end
		default:
		begin
			hi = hi_addsub_reg;
			lo = lo_addsub_reg;
			out_valid = count >= CYCLES + 2;
		end
	endcase
end

    
endmodule
