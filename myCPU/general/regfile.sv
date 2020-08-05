module regfile(
    input  logic        clk           ,
    input  logic        reset         ,
    input  logic		w_stall		  ,
    
    input  logic        regwrite_en   ,
    input  logic [ 4:0] regwrite_addr ,
    input  logic [31:0] regwrite_data ,
    
    input  logic [ 4:0] rs_addr       ,
    input  logic [ 4:0] rt_addr       ,
    
    output logic [31:0] rs_data       ,
    output logic [31:0] rt_data       
    );
    
    logic [31:0] RAM[31:0] ;
    integer i ;
    
    always_ff @(posedge clk)
        begin 
            if(reset)
                for(i = 0; i < 32; i = i + 1)
                    RAM[i] <= 0;
            else if (regwrite_en && !w_stall)
                RAM[regwrite_addr] <= regwrite_data ;
        end
        
    assign rs_data = (rs_addr != 0)? RAM[rs_addr] : 0 ;
    assign rt_data = (rt_addr != 0)? RAM[rt_addr] : 0 ;
                
endmodule
