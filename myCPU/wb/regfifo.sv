module regfifo(
    input  logic      clk,
    input  logic      reset,
    input  logic      w_stall,

    input  logic [31:0]  debug_wb_pc_alpha,
    input  logic [ 3:0]  debug_wb_rf_wen_alpha,
    input  logic [ 4:0]  debug_wb_rf_wnum_alpha,
    input  logic [31:0]  debug_wb_rf_wdata_alpha,

    input  logic [31:0]  debug_wb_pc_beta,
    input  logic [ 3:0]  debug_wb_rf_wen_beta,
    input  logic [ 4:0]  debug_wb_rf_wnum_beta,
    input  logic [31:0]  debug_wb_rf_wdata_beta,

    output logic [31:0]  output_debug_wb_pc,
    output logic [ 3:0]  output_debug_wb_rf_wen,
    output logic [ 4:0]  output_debug_wb_rf_wnum,
    output logic [31:0]  output_debug_wb_rf_wdata

);
    
logic [31:0]fifo_pc[63:0] ;
logic [3:0]fifo_wen[63:0] ;
logic [4:0]fifo_wnum[63:0];
logic [31:0]fifo_wdata[63:0] ;

logic [6:0]write_pointer ;
logic [6:0]read_pointer  ;

//暂时就先不考虑满的情况了吧，我觉得不大可能满，大不了再多开一点
integer i ;

logic fifo_isempty ;
assign fifo_isempty = (write_pointer == read_pointer) ;

always_ff @(posedge clk)
begin
    if(reset)
    begin
        for(i=0;i<=63;i=i+1)
        begin
            fifo_pc[i] <= 'b0 ;
            fifo_wen[i] <= 'b0 ;
            fifo_wnum[i] <= 'b0 ;
            fifo_wdata[i] <= 'b0 ;
        end
        write_pointer <= 'b0 ;
    end
    else if(debug_wb_rf_wen_alpha && debug_wb_rf_wen_beta && !w_stall && debug_wb_rf_wnum_alpha != 5'd0 && debug_wb_rf_wnum_beta != 5'd0)
    begin
        fifo_pc[write_pointer[5:0]] <= debug_wb_pc_alpha ;
        fifo_wen[write_pointer[5:0]] <= debug_wb_rf_wen_alpha ;
        fifo_wnum[write_pointer[5:0]] <= debug_wb_rf_wnum_alpha ;
        fifo_wdata[write_pointer[5:0]] <= debug_wb_rf_wdata_alpha ;

        fifo_pc[write_pointer[5:0]+6'b1] <= debug_wb_pc_beta ;
        fifo_wen[write_pointer[5:0]+6'b1] <= debug_wb_rf_wen_beta ;
        fifo_wnum[write_pointer[5:0]+6'b1] <= debug_wb_rf_wnum_beta ;
        fifo_wdata[write_pointer[5:0]+6'b1] <= debug_wb_rf_wdata_beta ;

        write_pointer <= write_pointer + 2 ;
    end
    else if(debug_wb_rf_wen_alpha && !w_stall && debug_wb_rf_wnum_alpha != 5'd0)
    begin
        fifo_pc[write_pointer[5:0]] <= debug_wb_pc_alpha ;
        fifo_wen[write_pointer[5:0]] <= debug_wb_rf_wen_alpha ;
        fifo_wnum[write_pointer[5:0]] <= debug_wb_rf_wnum_alpha ;
        fifo_wdata[write_pointer[5:0]] <= debug_wb_rf_wdata_alpha ;
        
        write_pointer <= write_pointer + 1 ;
    end
    else if(debug_wb_rf_wen_beta && !w_stall && debug_wb_rf_wnum_beta != 5'd0)
    begin
        fifo_pc[write_pointer[5:0]] <= debug_wb_pc_beta ;
        fifo_wen[write_pointer[5:0]] <= debug_wb_rf_wen_beta ;
        fifo_wnum[write_pointer[5:0]] <= debug_wb_rf_wnum_beta ;
        fifo_wdata[write_pointer[5:0]] <= debug_wb_rf_wdata_beta ;

        write_pointer <= write_pointer + 1 ;
    end
    else 
    begin
        write_pointer <= write_pointer ;
    end
end

always_comb
begin
    if(reset)
    begin
        output_debug_wb_pc = 'b0 ;
        output_debug_wb_rf_wen = 'b0 ;
        output_debug_wb_rf_wnum = 'b0 ;
        output_debug_wb_rf_wdata = 'b0 ;
    end
    else if(fifo_isempty)
    begin
        output_debug_wb_pc = 'b0 ;
        output_debug_wb_rf_wen = 'b0 ;
        output_debug_wb_rf_wnum = 'b0 ;
        output_debug_wb_rf_wdata = 'b0 ;
    end
    else 
    begin
        output_debug_wb_pc = fifo_pc[read_pointer[5:0]] ;
        output_debug_wb_rf_wen = fifo_wen[read_pointer[5:0]] ;
        output_debug_wb_rf_wnum = fifo_wnum[read_pointer[5:0]] ;
        output_debug_wb_rf_wdata = fifo_wdata[read_pointer[5:0]] ;
    end
end

always_ff @(posedge clk) 
begin
    if(reset)
        read_pointer <= 'b0 ;
    else if(fifo_isempty)
        read_pointer <= read_pointer ;
    else 
        read_pointer <= read_pointer + 1 ;
end





endmodule