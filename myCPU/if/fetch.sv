module fetch(
	input 				clk,
	input 				rst,

	input 				f_stall,
	input 				d_stall,
	input 				d_flush_alpha,
	input 				d_flush_beta,

	input 				inst_data_ok,
	input 				second_data_ok,

	input 				jb_req,
	input [31:0] 		jb_addr,

	input [31:0] 		inst_rdata_1,
	input [31:0] 		inst_rdata_2,
	
	output logic [31:0] inst_addr_1,
	output logic [31:0] inst_addr_2,

	output logic [31:0] out_addr_alpha,
	output logic [31:0] out_addr_beta,
	output logic [31:0] out_instr_alpha,
	output logic [31:0] out_instr_beta,
	output logic        out_addr_err_alpha,
    output logic        out_addr_err_beta,
    output logic        out_inds_alpha,
    output logic        out_inds_beta,
    output logic [ 1:0] issue_method// ?
);

logic [31:0] pre_inst_addr_1;

logic [31:0] instr_alpha_data, instr_beta_data;
logic issue_second, inds_alpha, inds_beta, addr_err_alpha, addr_err_beta;

// Generate inst_addr for icache -------------------------------------------------------------------------
always_comb
	if (jb_req)
		pre_inst_addr_1 = jb_addr;
	else if (issue_second)
		pre_inst_addr_1 = inst_addr_1 + 32'd8;
	else 
		pre_inst_addr_1 = inst_addr_1 + 32'd4;

pc_flop #(32) inst_addr_flop(clk, rst, f_stall, pre_inst_addr_1, inst_addr_1);

assign inst_addr_2 = inst_addr_1 + 32'd4;

// Read data from icache and store temporarily until the next data_ok arrives ----------------------------
logic [31:0] instr_alpha_data_reg, instr_beta_data_reg;
logic instr_beta_valid, instr_beta_valid_reg;

always_ff @(posedge clk)
	if (rst) begin
		instr_alpha_data_reg <= '0;
		instr_beta_data_reg <= '0;
		instr_beta_valid_reg <= 1'b0;
	end else if (inst_data_ok) begin
		instr_alpha_data_reg <= inst_rdata_1;
		instr_beta_data_reg <= inst_rdata_2;
		instr_beta_valid_reg <= second_data_ok;
	end

assign instr_alpha_data = inst_data_ok ? inst_rdata_1 : instr_alpha_data_reg;
assign instr_beta_data = inst_data_ok ? inst_rdata_2 : instr_beta_data_reg;
assign instr_beta_valid = inst_data_ok ? second_data_ok : instr_beta_valid_reg;

issue_ctrl_wrap my_issue_ctrl(
	.clk(clk),
	.rst(rst),
	.inst_data_ok(inst_data_ok),
	.instr_alpha_addr(inst_addr_1),
	.instr_beta_addr(inst_addr_2),
	.instr_alpha_data(instr_alpha_data),
	.instr_beta_data(instr_beta_data),
	.instr_beta_valid(instr_beta_valid),

	.issue_second(issue_second),
	.inds_alpha(inds_alpha),
	.inds_beta(inds_beta),
	.addr_err_alpha(addr_err_alpha),
	.addr_err_beta(addr_err_beta)
);

// Flops to Decode stage ------------------------------------------------------------------------------------
flop #(32) fd_addr_alpha(clk, rst | d_flush_alpha, d_stall, inst_addr_1, out_addr_alpha);
flop #(32) fd_instr_alpha(clk, rst | d_flush_alpha, d_stall, instr_alpha_data, out_instr_alpha);
flop #(1) fd_inds_alpha(clk, rst | d_flush_alpha, d_stall, inds_alpha, out_inds_alpha);
flop #(1) fd_addr_err_alpha(clk, rst | d_flush_alpha, d_stall, addr_err_alpha, out_addr_err_alpha);

flop #(32) fd_addr_beta(clk, rst | d_flush_beta, d_stall, issue_second ? inst_addr_2 : 32'd0, out_addr_beta);
flop #(32) fd_instr_beta(clk, rst | d_flush_beta, d_stall, issue_second ? instr_beta_data : 32'd0, out_instr_beta);
flop #(1) fd_inds_beta(clk, rst | d_flush_beta, d_stall, issue_second ? inds_beta : 1'd0, out_inds_beta);
flop #(1) fd_addr_err_beta(clk, rst | d_flush_beta, d_stall, issue_second ? addr_err_beta : 1'd0, out_addr_err_beta);

flop #(2) fd_issue_method(clk, rst | d_flush_alpha & d_flush_beta, d_stall, issue_second && !d_flush_alpha && !d_flush_beta ? 2'd2 : 2'd1, issue_method);

endmodule