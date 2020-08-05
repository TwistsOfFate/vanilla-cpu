`timescale 1ns / 1ps

module HI_regfile(
    input  logic        clk     ,
    input  logic        reset   ,

    input  logic        HI_wen  ,
    input  logic [31:0] HI_wdata,

    output logic [31:0] HI_rdata
);

logic  [31:0]HI_RAM ;

always@(posedge clk)
begin
    if(reset)
        HI_RAM <= 0 ;
    else if(HI_wen)
        HI_RAM <= HI_wdata ;
    else
        HI_RAM <= HI_RAM ;
end

assign HI_rdata = HI_RAM ;

endmodule