
module HI_regfile(
    input  logic        clk     ,
    input  logic        reset   ,

    input  logic        HI_wen_alpha  ,
    input  logic [31:0] HI_wdata_alpha,

    input  logic        HI_wen_beta  ,
    input  logic [31:0] HI_wdata_beta,

    output logic [31:0] HI_rdata
);

logic  [31:0]HI_RAM ;

always@(posedge clk)
begin
    if(reset)
        HI_RAM <= '0 ;
    else if(HI_wen_alpha || HI_wen_beta)
    begin
        if(HI_wen_beta)
            HI_RAM <= HI_wdata_beta  ;
        else if(HI_wen_alpha)
            HI_RAM <= HI_wdata_alpha ;
        
    end
end

assign HI_rdata = HI_RAM ;

endmodule