module issue_ctrl_wrap(
	input clk,
	input rst,
    input inst_data_ok,

	input [31:0] instr_alpha_addr,
	input [31:0] instr_beta_addr,
	input [31:0] instr_alpha_data,
	input [31:0] instr_beta_data,
	input instr_beta_valid,

	output logic issue_second,
	output logic inds_alpha,
	output logic inds_beta,
	output logic addr_err_alpha,
	output logic addr_err_beta
);

logic       instr_alpha_memreq, instr_beta_memreq    ;
logic       instr_alpha_regwrite, instr_beta_regwrite ;
logic [ 1:0]instr_alpha_regdst, instr_beta_regdst ;// include rt, rd, r31
logic       instr_alpha_hiwrite, instr_beta_hiwrite ;
logic       instr_alpha_lowrite, instr_beta_lowrite ;
logic       instr_alpha_is_jump, instr_alpha_is_branch, instr_beta_is_jump, instr_beta_is_branch  ;
logic       instr_alpha_cp0rel ;

logic       instr_alpha_needrs, instr_alpha_needrt, instr_alpha_needhi, instr_alpha_needlo ;
logic       instr_beta_needrs, instr_beta_needrt, instr_beta_needhi, instr_beta_needlo ;

logic       have_nop, instr_beta_cp0rel;

logic       jb_issueone, hazard_issueone, lwst_issueone, inds_issueone ;
logic [ 4:0]instr_alpha_writereg ;

logic  [5:0] instr_alpha_op, instr_alpha_funct ;
logic  [4:0] instr_alpha_rs, instr_alpha_rt, instr_alpha_rd, instr_alpha_branchfunct, instr_alpha_c0funct ;
logic  [5:0] instr_beta_op, instr_beta_funct ;
logic  [4:0] instr_beta_rs, instr_beta_rt, instr_beta_rd, instr_beta_branchfunct, instr_beta_c0funct ;

logic [31:0] last_jb_inst_addr;

always_ff @(posedge clk)
	if (rst)
		last_jb_inst_addr <= '1;
	else if (issue_second && inst_data_ok && (instr_beta_is_branch || instr_beta_is_jump))
		last_jb_inst_addr <= instr_beta_addr;
	else if (inst_data_ok && (instr_alpha_is_branch || instr_alpha_is_jump))
		last_jb_inst_addr <= instr_alpha_addr;

assign inds_alpha = last_jb_inst_addr + 32'd4 == instr_alpha_addr;
assign inds_beta = instr_alpha_is_branch || instr_alpha_is_jump;

// Check address error
assign addr_err_alpha = instr_alpha_addr[1:0] != 2'b00;
assign addr_err_beta = instr_beta_addr[1:0] != 2'b00;


// Determine the number of instructions to issue
assign jb_issueone = (instr_beta_is_branch || instr_beta_is_jump) ;
assign lwst_issueone = instr_beta_memreq ;
assign inds_issueone = inds_alpha ;
assign have_nop = (instr_alpha_data == 32'h00000000 || instr_beta_data == 32'h00000000) ;

always_comb 
begin
    if(instr_alpha_regdst == 2'b00)
        instr_alpha_writereg = instr_alpha_rt ;
    else if(instr_alpha_regdst == 2'b01)
        instr_alpha_writereg = instr_alpha_rd ;
    else if(instr_alpha_regdst == 2'b10)
        instr_alpha_writereg = 5'b11111 ;
    else
        instr_alpha_writereg = 5'b00000 ;
end

assign hazard_issueone = ((instr_alpha_regwrite && (instr_alpha_writereg == instr_beta_rs && instr_beta_needrs || instr_alpha_writereg == instr_beta_rt && instr_beta_needrt))
|| instr_alpha_hiwrite && instr_beta_needhi  
|| instr_alpha_lowrite && instr_beta_needlo) 
|| instr_alpha_cp0rel || instr_beta_cp0rel ;
always_comb
begin
    if (jb_issueone || lwst_issueone || hazard_issueone || inds_issueone || !instr_beta_valid)
    	issue_second = 1'b0;
    else
    	issue_second = 1'b1;
end

// Decoders
assign instr_alpha_op          = instr_alpha_data[31:26] ;
assign instr_alpha_funct       = instr_alpha_data[5:0]   ;
assign instr_alpha_rs          = instr_alpha_data[25:21] ;
assign instr_alpha_rt          = instr_alpha_data[20:16] ;
assign instr_alpha_rd          = instr_alpha_data[15:11] ;
assign instr_alpha_c0funct     = instr_alpha_data[25:21] ;
assign instr_alpha_branchfunct = instr_alpha_data[20:16] ;

assign instr_beta_op          = instr_beta_data[31:26] ;
assign instr_beta_funct       = instr_beta_data[5:0]   ;
assign instr_beta_rs          = instr_beta_data[25:21] ;
assign instr_beta_rt          = instr_beta_data[20:16] ;
assign instr_beta_rd          = instr_beta_data[15:11] ;
assign instr_beta_c0funct     = instr_beta_data[25:21] ;
assign instr_beta_branchfunct = instr_beta_data[20:16] ;

issue_controller is_ctrl_instr_alpha(
    .d_op           (instr_alpha_op),
    .d_funct        (instr_alpha_funct),
    .d_branchfunct  (instr_alpha_branchfunct),
    .d_c0funct      (instr_alpha_c0funct),

    .d_memreq       (instr_alpha_memreq),
    .d_regwrite     (instr_alpha_regwrite),
    .d_regdst       (instr_alpha_regdst),
    .d_hiwrite      (instr_alpha_hiwrite),
    .d_lowrite      (instr_alpha_lowrite),

    .d_isbranch     (instr_alpha_is_branch),
    .d_isjump       (instr_alpha_is_jump),

    .d_needrs       (instr_alpha_needrs),
    .d_needrt       (instr_alpha_needrt),
    .d_needhi       (instr_alpha_needhi),
    .d_needlo       (instr_alpha_needlo),
    .d_cp0rel       (instr_alpha_cp0rel)
) ;

issue_controller is_ctrl_instr_beta(
    .d_op           (instr_beta_op),
    .d_funct        (instr_beta_funct),
    .d_branchfunct  (instr_beta_branchfunct),
    .d_c0funct      (instr_beta_c0funct),

    .d_memreq       (instr_beta_memreq),
    .d_regwrite     (instr_beta_regwrite),
    .d_regdst       (instr_beta_regdst),
    .d_hiwrite      (instr_beta_hiwrite),
    .d_lowrite      (instr_beta_lowrite),

    .d_isbranch     (instr_beta_is_branch),
    .d_isjump       (instr_beta_is_jump),
    
    .d_needrs       (instr_beta_needrs),
    .d_needrt       (instr_beta_needrt),
    .d_needhi       (instr_beta_needhi),
    .d_needlo       (instr_beta_needlo),
    .d_cp0rel       (instr_beta_cp0rel)
) ;

endmodule