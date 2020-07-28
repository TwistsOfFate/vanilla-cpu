module divider_ip(
	input 			clk,
	input 			rst,
	input 			in_valid,
	input 			sign,
	input [31:0] 	srca,
	input [31:0] 	srcb,
	output 			out_valid,
	output [31:0] 	hi,
	output [31:0] 	lo
    );

wire [31:0] q0, q1, r0, r1;
wire out_valid0, out_valid1;
logic [64:0] in_reg;
logic [4:0] count;

div_gen_0 my_div_gen_0 (
  .aclk(clk),                                      	// input wire aclk
  .aresetn(~rst),                                	// input wire aresetn
  .s_axis_divisor_tvalid(in_valid & ~sign),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(srcb),      				// input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(in_valid & ~sign),  		// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(srca),    					// input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(out_valid0),          		// output wire m_axis_dout_tvalid
  .m_axis_dout_tdata({q0, r0})         				// output wire [63 : 0] m_axis_dout_tdata
);

div_gen_1 my_div_gen_1 (
  .aclk(clk),                                      	// input wire aclk
  .aresetn(~rst),                                	// input wire aresetn
  .s_axis_divisor_tvalid(in_valid & sign),    		// input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(srcb),      				// input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(in_valid & sign),  		// input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(srca),    					// input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(out_valid1),          		// output wire m_axis_dout_tvalid
  .m_axis_dout_tdata({q1, r1})         				// output wire [63 : 0] m_axis_dout_tdata
);

always_ff @(posedge clk) begin
  if (rst)
    in_reg <= 65'd0;
  else
    in_reg <= {sign, srca, srcb};
end

always_ff @(posedge clk) begin
  if (in_reg != {sign, srca, srcb} || !in_valid || rst)
    count <= 5'd0;
  else
    count <= count < 5'd15 ? count + 5'd1 : count;
end

assign out_valid = count >= 5'd15;
assign lo = sign ? q1 : q0;
assign hi = sign ? r1 : r0;
    
endmodule