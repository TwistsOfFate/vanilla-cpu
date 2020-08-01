// 16 instrs in the fifo

typedef struct packed {
    logic [31:0]        addr;
    logic [31:0]        data;
    logic               addr_err;
} fifo_ele_t;

module fifo #(
    parameter SIZE_WIDTH = 4,
    parameter SIZE = 2 ** SIZE_WIDTH
)(
    input  logic        clk,
    input  logic        reset,
    input  logic        countreset,

    //I decide to add the fifo between f and d, instead of d and e.
    //I need to write the relative inf of instr to the fifo
    //such as addr(means pc), data(means instr itself), addr_err(means an exception), isindelayslot(maybe it is not necessary) 

    input  logic        fifo_instr1_wen,
    input  logic        fifo_instr2_wen,

    // I think it is the same to the f_stall, and when the rest of the pipeline need to stall, we just don't issue the instr.
    input  logic        d_stall,
    input  logic        d_flush,

    input  logic        imem_busy,

    input  logic        jb_req,
    input  logic [31:0] jb_addr,

    input  logic [31:0] fifo_instr1_addr,       //f_nextpc_alpha
    input  logic [31:0] fifo_instr2_addr,       //f_nextpc_beta
    input  logic [31:0] fifo_instr1_data,       //f_instr_alpha
    input  logic [31:0] fifo_instr2_data,       //f_instr_beta
    input  logic        fifo_instr1_addr_err,
    input  logic        fifo_instr2_addr_err,

    output logic        inst_req,
    output logic [31:0] inst_addr,
    
    output logic [31:0] out_addr_alpha,
    output logic [31:0] out_addr_beta,
    output logic [31:0] out_instr_alpha,
    output logic [31:0] out_instr_beta,
    output logic        out_addr_err_alpha,
    output logic        out_addr_err_beta,
    output logic        out_inds_alpha,
    output logic        out_inds_beta,
    output logic [ 1:0] issue_method,

    output logic        isempty,
    output logic        busy
);

//------------------------------ Initialize input structs -----------------------------------------

// fifo_ele_t eles[SIZE-1:0];
// fifo_ele_t input_ele1, input_ele2;

// assign input_ele1.addr = fifo_instr1_addr;
// assign input_ele1.data = fifo_instr1_data;
// assign input_ele1.addr_err = fifo_instr1_addr_err;

// assign input_ele2.addr = fifo_instr2_addr;
// assign input_ele2.data = fifo_instr2_data;
// assign input_ele2.addr_err = fifo_instr2_addr_err;

//--------------------------------------------------------------------------------------------

logic fifo_inst_req;
logic [31:0] fifo_inst_addr;
logic [31:0] instr_alpha_data, instr_beta_data, instr_alpha_addr, instr_beta_addr ;
logic        addr_err_alpha, addr_err_beta ;
logic        inds_alpha, inds_beta ;

logic [31:0]notissuenum, issueonenum, issuetwonum ;

logic fifo_wen[15:0];
logic [31:0]fifo_addr[15:0], fifo_addr_new[15:0] ; //16*32 fifo
logic [31:0]fifo_data[15:0], fifo_data_new[15:0] ;
logic fifo_addr_err[15:0], fifo_addr_err_new[15:0];
logic fifo_inds[15:0], fifo_inds_new[15:0];
logic fifo_inds_wen[15:0];

logic [ 3:0]jb_ptr;
logic [ 3:0]write_pointer_new;
logic [ 3:0]write_pointer    ;
logic [ 3:0]read_pointer     ;

logic       [ 3:0]fifo_elenum ;

logic       choosenotissue    ;
logic       chooseissueone    ;
logic       chooseissuetwo    ;

logic       instr_alpha_memreq, instr_beta_memreq    ;
logic       instr_alpha_regwrite, instr_beta_regwrite ;
logic [ 1:0]instr_alpha_regdst, instr_beta_regdst ;// include rt, rd, r31
logic       instr_alpha_hiwrite, instr_beta_hiwrite ;
logic       instr_alpha_lowrite, instr_beta_lowrite ;
logic       instr_alpha_is_jump, instr_alpha_is_branch, instr_beta_is_jump, instr_beta_is_branch  ;
logic       instr_alpha_cp0rel ;

logic       instr_alpha_needrs, instr_alpha_needrt, instr_alpha_needhi, instr_alpha_needlo ;
logic       instr_beta_needrs, instr_beta_needrt, instr_beta_needhi, instr_beta_needlo ;

logic       jb_issueone, hazard_issueone, lwst_issueone, inds_issueone ;
logic [ 4:0]instr_alpha_writereg ;

logic  [5:0] instr_alpha_op, instr_alpha_funct ;
logic  [4:0] instr_alpha_rs, instr_alpha_rt, instr_alpha_rd, instr_alpha_branchfunct, instr_alpha_c0funct ;

logic  [5:0] instr_beta_op, instr_beta_funct ;
logic  [4:0] instr_beta_rs, instr_beta_rt, instr_beta_rd, instr_beta_branchfunct, instr_beta_c0funct ;

logic  instr_alpha_sys_jump, instr_beta_sys_jump ;
logic  two_nop ;
logic have_nop ;

assign isempty = fifo_elenum == 0;

assign fifo_inst_req = fifo_elenum < 4'd12;
assign fifo_inst_addr = (fifo_wen[write_pointer_new - 4'd1] ? fifo_addr_new[write_pointer_new - 4'd1] : fifo_addr[write_pointer_new - 4'd1]) + 32'd4;

assign write_pointer_new = write_pointer + (fifo_instr1_wen ? 4'd1 : 4'd0) + (fifo_instr2_wen ? 4'd1 : 4'd0);

//instr1/2 in this place stands for the instr in the front of the queue

//issueone: 1.instr2 is j/b 2.instr1 and instr2 is both load/store
//3. instr2 depends on the data of the instr1 get


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

assign hazard_issueone = ((instr_alpha_regwrite && (((instr_alpha_writereg == instr_beta_rs) && instr_beta_needrs) || ((instr_alpha_writereg == instr_beta_rt) && instr_beta_needrt)))
|| (instr_alpha_hiwrite && instr_beta_needhi)  || (instr_alpha_lowrite && instr_beta_needlo) || instr_alpha_cp0rel || instr_beta_cp0rel) 
&& !have_nop ;


always_comb
begin
    if(fifo_elenum == 0)
    begin
        choosenotissue = 1 ;
        chooseissueone = 0 ;
        chooseissuetwo = 0 ;
    end
    else if(jb_issueone || lwst_issueone || hazard_issueone || inds_issueone || fifo_elenum == 1)
    begin
        choosenotissue = 0 ;
        chooseissueone = 1 ;
        chooseissuetwo = 0 ;
    end
    else
    begin
        choosenotissue = 0 ;
        chooseissueone = 0 ;
        chooseissuetwo = 1 ;
    end
end

always_ff @(posedge clk)
begin
    if(choosenotissue && !d_stall)
        notissuenum <= notissuenum + 1 ;
    else if(chooseissueone && !d_stall)
        issueonenum <= issueonenum + 1 ;
    else if(chooseissuetwo && !d_stall)
        issuetwonum <= issuetwonum + 1 ;
end


// Read-first assignment
assign instr_alpha_addr = fifo_wen[read_pointer] ? fifo_addr_new[read_pointer[3:0]] : fifo_addr[read_pointer[3:0]] ;
assign instr_alpha_data = fifo_wen[read_pointer] ? fifo_data_new[read_pointer[3:0]] : fifo_data[read_pointer[3:0]] ;
assign addr_err_alpha   = fifo_wen[read_pointer] ? fifo_addr_err_new[read_pointer[3:0]] : fifo_addr_err[read_pointer[3:0]] ;
assign inds_alpha       = fifo_inds_wen[read_pointer[3:0]] ? fifo_inds_new[read_pointer[3:0]] : fifo_inds[read_pointer[3:0]];

assign instr_beta_addr  = fifo_wen[read_pointer+4'b1] ? fifo_addr_new[read_pointer[3:0]+4'b1] : fifo_addr[read_pointer[3:0]+4'b1] ;
assign instr_beta_data  = fifo_wen[read_pointer+4'b1] ? fifo_data_new[read_pointer[3:0]+4'b1] : fifo_data[read_pointer[3:0]+4'b1] ;
assign addr_err_beta    = fifo_wen[read_pointer+4'b1] ? fifo_addr_err_new[read_pointer[3:0]+4'b1] : fifo_addr_err[read_pointer[3:0]+4'b1] ;
assign inds_beta        = fifo_inds_wen[read_pointer[3:0]+4'b1] ? fifo_inds_new[read_pointer[3:0]+4'b1] : fifo_inds[read_pointer[3:0]+4'b1] ;


// Setting output signals accroding to "chooseissue"

always_ff @(posedge clk)
begin
    if (reset || d_flush) begin
        out_addr_alpha <= 32'b0 ;
        out_addr_err_alpha <= 1'b0 ;
        out_instr_alpha <= 32'b0 ;
        out_inds_alpha <= 1'b0 ;
        out_addr_beta <= 32'b0 ;
        out_addr_err_beta <= 1'b0 ;
        out_instr_beta <= 32'b0 ;
        out_inds_beta <= 1'b0 ;
        issue_method <= 2'b00 ;
    end else if (d_stall) begin
        // Do nothing
    end else if(choosenotissue)
    begin
        out_addr_alpha <= 32'b0 ;
        out_addr_err_alpha <= 1'b0 ;
        out_instr_alpha <= 32'b0 ;
        out_inds_alpha <= 1'b0 ;
        out_addr_beta <= 32'b0 ;
        out_addr_err_beta <= 1'b0 ;
        out_instr_beta <= 32'b0 ;
        out_inds_beta <= 1'b0 ;
        issue_method <= 2'b00 ;
    end
    else if(chooseissueone)
    begin
        out_addr_alpha <= instr_alpha_addr ;
        out_instr_alpha <= instr_alpha_data ;
        out_addr_err_alpha <= addr_err_alpha ;
        out_inds_alpha <= inds_alpha ;
        out_addr_beta <= 32'b0 ; 
        out_addr_err_beta <= 1'b0 ;
        out_instr_beta <= 32'b0 ;
        out_inds_beta <= 1'b0 ;
        issue_method <= 2'b01 ;
    end
    else if(chooseissuetwo)
    begin
        out_addr_alpha <= instr_alpha_addr ;
        out_instr_alpha <= instr_alpha_data ;
        out_addr_err_alpha <= addr_err_alpha ;
        out_inds_alpha <= inds_alpha ;
        out_addr_beta <= instr_beta_addr ;
        out_instr_beta <= instr_beta_data ;
        out_addr_err_beta <= addr_err_beta ;
        out_inds_beta <= inds_beta ;
        issue_method <= 2'b10 ;
    end
    else 
    begin
        out_addr_alpha <= 32'b0 ;
        out_addr_err_alpha <= 1'b0 ;
        out_instr_alpha <= 32'b0 ;
        out_inds_alpha <= 1'b0 ;
        out_addr_beta <= 32'b0 ;
        out_addr_err_beta <= 1'b0 ;
        out_instr_beta <= 32'b0 ;
        out_inds_beta <= 1'b0 ;
        issue_method <= 2'b00 ;
    end
end



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
//    .d_sys_jump     (instr_alpha_sys_jump)

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
//    .d_sys_jump     (instr_beta_sys_jump)


) ;







endmodule 

