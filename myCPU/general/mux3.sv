module mux3#(parameter WIDTH=8)(
    
    input  logic [WIDTH-1:0] mux3_valA  ,
    input  logic [WIDTH-1:0] mux3_valB  ,
    input  logic [WIDTH-1:0] mux3_valC  ,

    input  logic [1:0]       mux3_sel   ,
    output logic [WIDTH-1:0] mux3_result  
);

always_comb
    unique case (mux3_sel)
        2'b00: mux3_result = mux3_valA;
        2'b01: mux3_result = mux3_valB;
        2'b10: mux3_result = mux3_valC;
    endcase

// always_comb begin
//     if (mux3_sel == 2'b00)
//         mux3_result = mux3_valA;
//     else if (mux3_sel == 2'b01)
//         mux3_result = mux3_valB;
//     else if (mux3_sel == 2'b10)
//         mux3_result = mux3_valC;
//     else
//         mux3_result = mux3_valA;
// end
    
endmodule