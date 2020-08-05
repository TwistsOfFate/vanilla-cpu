`timescale 1ns / 1ps

module LO_regfile(
    input  logic        clk     ,
    input  logic        reset   ,

    input  logic        LO_wen  ,
    input  logic [31:0] LO_wdata,

    output logic [31:0] LO_rdata
);

logic  [31:0]LO_RAM ;

always@(posedge clk)
begin
    if(reset)
        LO_RAM <= 0 ;
    else if(LO_wen)
        LO_RAM <= LO_wdata ;
    else
        LO_RAM <= LO_RAM ;
end

assign LO_rdata = LO_RAM ;

endmodule