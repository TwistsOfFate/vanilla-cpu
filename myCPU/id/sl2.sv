module sl2(
    input  logic [31:0] sl2_valA    ,
    output logic [31:0] sl2_result
    );
    
    assign sl2_result = {sl2_valA[29:0],2'b00} ;
endmodule
