module mux3#(parameter WIDTH=8)(
    
    input  logic [WIDTH-1:0] mux3_valA  ,
    input  logic [WIDTH-1:0] mux3_valB  ,
    input  logic [WIDTH-1:0] mux3_valC  ,

    input  logic [1:0]       mux3_sel   ,
    output logic [WIDTH-1:0] mux3_result  
);
             
assign mux3_result = mux3_sel[1] ? mux3_valC : (mux3_sel[0] ? mux3_valB : mux3_valA ) ;
    
endmodule