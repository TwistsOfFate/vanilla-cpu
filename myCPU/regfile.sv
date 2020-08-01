module regfile(
    input  logic        clk           ,
    input  logic        reset         ,
    input  logic		w_stall		  ,
    
    input  logic        regwrite_en_alpha   ,
    input  logic [ 4:0] regwrite_addr_alpha ,
    input  logic [31:0] regwrite_data_alpha ,

    input  logic        regwrite_en_beta   ,
    input  logic [ 4:0] regwrite_addr_beta ,
    input  logic [31:0] regwrite_data_beta ,
    
    input  logic [ 4:0] rs_addr_alpha       ,
    input  logic [ 4:0] rt_addr_alpha       ,
    output logic [31:0] rs_data_alpha       ,
    output logic [31:0] rt_data_alpha       ,

    input  logic [ 4:0] rs_addr_beta        ,
    input  logic [ 4:0] rt_addr_beta        ,
    output logic [31:0] rs_data_beta        ,
    output logic [31:0] rt_data_beta       
    );
    
    logic [31:0] RAM[31:0] ;
    integer i ;
    
    always_ff @(posedge clk)
        begin 
            if(reset)
               for(i = 0; i < 32; i = i + 1)
                    RAM[i] <= 0;
            else
            begin
                if(!w_stall)
                begin
                    if(regwrite_en_alpha && regwrite_en_beta && (regwrite_addr_beta == regwrite_addr_alpha))
                        RAM[regwrite_addr_beta] <= regwrite_data_beta ;
                    else 
                    begin
                        if(regwrite_en_beta)
                            RAM[regwrite_addr_beta] <= regwrite_data_beta ;
                        if(regwrite_en_alpha)
                            RAM[regwrite_addr_alpha] <= regwrite_data_alpha ;
                    end 
                end
            end
        end
        
    assign rs_data_alpha = (rs_addr_alpha != 0)? RAM[rs_addr_alpha] : 0 ;
    assign rt_data_alpha = (rt_addr_alpha != 0)? RAM[rt_addr_alpha] : 0 ;
    
    assign rs_data_beta = (rs_addr_beta != 0)? RAM[rs_addr_beta] : 0 ;
    assign rt_data_beta = (rt_addr_beta != 0)? RAM[rt_addr_beta] : 0 ;


endmodule
