module signext(
    input  logic [15:0] ext_valA   ,
    output logic [31:0] ext_result  
    );
    
    assign ext_result = {{16{ext_valA[15]}}, ext_valA} ;
    
endmodule
