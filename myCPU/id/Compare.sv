`timescale 1ns / 1ps

module Compare(
    
    input  logic signed [31:0] valA      ,
    
    output logic               greater   ,
    output logic               equal       
    
    );

assign greater   = (valA >  0) ;
assign equal     = (valA == 0) ;

    
endmodule
