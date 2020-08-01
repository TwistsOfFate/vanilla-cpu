
module LO_regfile(
    input  logic        clk     ,
    input  logic        reset   ,

    input  logic        LO_wen_alpha  ,
    input  logic [31:0] LO_wdata_alpha,

    input  logic        LO_wen_beta  ,
    input  logic [31:0] LO_wdata_beta,

    output logic [31:0] LO_rdata
);

logic  [31:0]LO_RAM ;

always@(posedge clk)
begin
    if(reset)
        LO_RAM <= '0 ;
    else if(LO_wen_alpha || LO_wen_beta)
    begin
        if(LO_wen_beta)
            LO_RAM <= LO_wdata_beta  ;
        else if(LO_wen_alpha)
            LO_RAM <= LO_wdata_alpha ;
        
    end
end

assign LO_rdata = LO_RAM ;

endmodule