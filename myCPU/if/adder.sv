`timescale 1ns / 1ps

module adder(
    input logic [31:0] add_valA, add_valB ,
    output logic [31:0] add_result 
    );
    assign add_result = add_valA + add_valB ; 
endmodule
