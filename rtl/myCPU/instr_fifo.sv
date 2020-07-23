// 16 instrs in the fifo
module fifo(
    input  logic        clk,
    input  logic        reset,

    //I decide to add the fifo between f and d, instead of d and e.
    //I need to write the relative inf of instr to the fifo
    //such as addr(means pc), data(means instr itself), addr_err(means an exception), isindelayslot(maybe it is not necessary) 

    input  logic        fifo_instr1_wen,
    input  logic        fifo_instr2_wen,

    // I think it is the same to the f_stall, and when the rest of the pipeline need to stall, we just don't issue the instr.
    input  logic        fifo_stall, 

    input  logic [31:0] fifo_instr1_addr,
    input  logic [31:0] fifo_instr2_addr,
    input  logic [31:0] fifo_instr1_data,
    input  logic [31:0] fifo_instr2_data,
    input  logic        fifo_instr1_addr_err,
    input  logic        fifo_instr2_addr_err,
    
    input  logic        out_alpha_ren,
    input  logic        out_beta_ren,
    
    output logic [31:0] out_addr_alpha,
    output logic [31:0] out_addr_beta,
    output logic [31:0] out_instr_alpha,
    output logic [31:0] out_instr_beta,
    output logic        out_addr_err_alpha,
    output logic        out_addr_err_beta,       

    output logic        fifo_isfull,
    output logic        fifo_willfull
);


logic [31:0] instr_alpha_data, instr_beta_data, instr_alpha_addr, instr_beta_addr ;
logic        addr_err_alpha, addr_err_beta ;



logic [31:0]fifo_addr[15:0] ; //16*32 fifo
logic [31:0]fifo_data [15:0] ;
logic [15:0]fifo_addr_err    ;

logic [ 4:0]write_pointer    ;// point to the space for next write
logic [ 4:0]read_pointer     ;// point to the space for next read

logic       fifo_left_one_ele ;
logic       fifo_isempty        ;

logic       choosenotissue    ;
logic       chooseissueone    ;
logic       chooseissuetwo    ;

logic       instr_alpha_memreq, instr_beta_memreq    ;
logic       instr_alpha_regwrite, instr_beta_regwrite ;
logic [ 1:0]instr_alpha_regdst, instr_beta_regdst ;// include rt, rd, r31
logic       instr_alpha_cp0write, instr_beta_cp0write ;
logic       instr_alpha_hiwrite, instr_beta_hiwrite ;
logic       instr_alpha_lowrite, instr_beta_lowrite ;
logic       instr_alpha_is_jump, instr_alpha_is_branch, instr_beta_is_jump, instr_beta_is_branch  ;

logic       instr_alpha_needrs, instr_alpha_needrt, instr_alpha_needhi, instr_alpha_needlo, instr_alpha_needcp0 ;
logic       instr_beta_needrs, instr_beta_needrt, instr_beta_needhi, instr_beta_needlo, instr_beta_needcp0 ;

logic       jb_issueone, hazard_issueone, lwst_issueone ;
logic [ 4:0]instr_alpha_writereg ;

logic  [5:0] instr_alpha_op, instr_alpha_funct ;
logic  [4:0] instr_alpha_rs, instr_alpha_rt, instr_alpha_rd, instr_alpha_branchfunct, instr_alpha_c0funct ;

logic  [5:0] instr_beta_op, instr_beta_funct ;
logic  [4:0] instr_beta_rs, instr_beta_rt, instr_beta_rd, instr_beta_branchfunct, instr_beta_c0funct ;

logic  instr_alpha_sys_jump, instr_beta_sys_jump ;

// for example instr1_regdst == 2'b00 and instr1_regwrite and instr1_rt == instr2_rs / rt

assign fifo_isfull = ( (write_pointer[3:0] == read_pointer[3:0]) && (write_pointer[4] == ~read_pointer[4]) )  ;
assign fifo_left_one_ele = ((write_pointer - read_pointer) == 1 ) ;
assign fifo_isempty = (write_pointer == read_pointer) ;

//instr1/2 in this place stands for the instr in the front of the queue

//issueone: 1.instr2 is j/b 2.instr1 and instr2 is both load/store
//3. instr2 depends on the data of the instr1 get

assign jb_issueone = (instr_beta_is_branch || instr_beta_is_jump) ;
assign lwst_issueone = instr_beta_memreq ;

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

assign hazard_issueone = (instr_alpha_regwrite && (((instr_alpha_writereg == instr_beta_rs) && instr_beta_needrs) || ((instr_alpha_writereg == instr_beta_rt) && instr_beta_needrt)))
|| (instr_alpha_hiwrite && instr_beta_needhi)  || (instr_alpha_lowrite && instr_beta_needlo) || (instr_alpha_cp0write && instr_beta_needcp0) ; 


always_comb
begin
    if(fifo_stall || fifo_isempty)
    begin
        choosenotissue = 1 ;
        chooseissueone = 0 ;
        chooseissuetwo = 0 ;
    end
    else if(jb_issueone || lwst_issueone || hazard_issueone || fifo_left_one_ele)
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

assign instr_alpha_addr = fifo_addr[read_pointer[3:0]] ;
assign instr_beta_addr  = fifo_addr[read_pointer[3:0]+4'b1] ;
assign instr_alpha_data = fifo_data[read_pointer[3:0]] ;
assign instr_beta_data  = fifo_data[read_pointer[3:0]+4'b1] ;
assign addr_err_alpha   = fifo_addr_err[read_pointer[3:0]] ;
assign addr_err_beta    = fifo_addr_err[read_pointer[3:0]+4'b1] ;

// logic writenum ;
// assign writenum = fifo_instr1_wen + fifo_instr2_wen ;

integer i ;

always_ff @(posedge clk, negedge reset)
begin
    if(reset)
    begin
        for(i=0;i<=15;i=i+1)
        begin
            fifo_addr[i] <= 0 ;
            fifo_data[i] <= 0 ;
            fifo_addr_err[i] <= 0 ;
            fifo_addr[i] <= 0 ;
            fifo_data[i] <= 0 ;
            fifo_addr_err[i] <= 0 ;
        end
        write_pointer <= 0 ;
        fifo_willfull = 1'b0 ;        
    end
    else if(fifo_instr1_wen && fifo_instr2_wen)
    begin
        fifo_addr[write_pointer[3:0]] <= fifo_instr1_addr ;
        fifo_data[write_pointer[3:0]] <= fifo_instr1_data ;
        fifo_addr_err[write_pointer[3:0]] <= fifo_instr1_addr_err ;
        fifo_addr[write_pointer[3:0]+4'b1] <= fifo_instr2_addr ;
        fifo_data[write_pointer[3:0]+4'b1] <= fifo_instr2_data ;
        fifo_addr_err[write_pointer[3:0]+4'b1] <= fifo_instr2_addr_err ;

        write_pointer <= write_pointer + 2 ;
        fifo_willfull <= 1'b0 ;
    end
    else if(fifo_instr1_wen && !fifo_instr2_wen)
    begin
        fifo_addr[write_pointer[3:0]] <= fifo_instr1_addr ;
        fifo_data[write_pointer[3:0]] <= fifo_instr1_data ;
        fifo_addr_err[write_pointer[3:0]] <= fifo_instr1_addr_err ;

        write_pointer <= write_pointer + 1 ;
        fifo_willfull <= 1'b0 ;
        
    end
    else if(fifo_instr2_wen && !fifo_instr1_wen)
    begin
        fifo_addr[write_pointer[3:0]] <= fifo_instr2_addr ;
        fifo_data[write_pointer[3:0]] <= fifo_instr2_data ;
        fifo_addr_err[write_pointer[3:0]] <= fifo_instr2_addr_err ;

        write_pointer <= write_pointer + 1 ;
        fifo_willfull <= 1'b0 ;
    end
    else
    begin
        fifo_willfull <= 1'b0 ;
        write_pointer <= write_pointer ;
    end
end

always_comb
begin
    if(choosenotissue || reset)
    begin
        out_addr_alpha = 32'b0 ;
        out_addr_err_alpha = 1'b0 ;
        out_instr_alpha = 32'b0 ;
        out_addr_beta = 32'b0 ;
        out_addr_err_beta = 1'b0 ;
        out_instr_beta = 32'b0 ;
    end
    else if(chooseissueone)
    begin
        out_addr_alpha = instr_alpha_addr ;
        out_instr_alpha = instr_alpha_data ;
        out_addr_err_alpha = addr_err_alpha ;
        out_addr_beta = 32'b0 ; 
        out_addr_err_beta = 1'b0 ;
        out_instr_beta = 32'b0 ;
    end
    else if(chooseissuetwo)
    begin
        out_addr_alpha = instr_alpha_addr ;
        out_instr_alpha = instr_alpha_data ;
        out_addr_err_alpha = addr_err_alpha ;
        out_addr_beta = instr_beta_addr ;
        out_instr_beta = instr_beta_data ;
        out_addr_err_beta = addr_err_beta ;
    end
end

always_ff @(posedge clk)
begin
    if(reset)
        read_pointer <= 5'b0000 ;
    else if(choosenotissue)
    begin
        read_pointer <= read_pointer ;
    end
    else if(chooseissueone)
    begin
        read_pointer <= read_pointer + 1 ;
//        fifo_elenum <= fifo_elenum - 1 ;
    end    
    else if(chooseissuetwo)
    begin
        read_pointer <= read_pointer + 2 ;
//        fifo_elenum <= fifo_elenum - 2 ;
    end    
    else
    begin
        read_pointer <= read_pointer ;
//        fifo_elenum <= fifo_elenum ;
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
    .d_cp0write     (instr_alpha_cp0write),
    .d_hiwrite      (instr_alpha_hiwrite),
    .d_lowrite      (instr_alpha_lowrite),

    .d_isbranch     (instr_alpha_is_branch),
    .d_isjump       (instr_alpha_is_jump),

    .d_needrs       (instr_alpha_needrs),
    .d_needrt       (instr_alpha_needrt),
    .d_needhi       (instr_alpha_needhi),
    .d_needlo       (instr_alpha_needlo),
    .d_needcp0      (instr_alpha_needcp0)
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
    .d_cp0write     (instr_beta_cp0write),
    .d_hiwrite      (instr_beta_hiwrite),
    .d_lowrite      (instr_beta_lowrite),

    .d_isbranch     (instr_beta_is_branch),
    .d_isjump       (instr_beta_is_jump),
    
    .d_needrs       (instr_beta_needrs),
    .d_needrt       (instr_beta_needrt),
    .d_needhi       (instr_beta_needhi),
    .d_needlo       (instr_beta_needlo),
    .d_needcp0      (instr_beta_needcp0)
//    .d_sys_jump     (instr_beta_sys_jump)


) ;







endmodule 

