module mux5 #(
	parameter WIDTH = 32
)(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [WIDTH-1:0] c,
	input [WIDTH-1:0] d,
    input [WIDTH-1:0] e,
	input [2:0] sel,
	output logic[WIDTH-1:0] out
    );
    
    always_comb 
    begin
        if (sel == 3'b000)
            out = a;
        else if (sel == 3'b001)
            out = b;
        else if (sel == 3'b010)
            out = c;
        else if (sel == 3'b011)
            out = d;
        else if (sel == 3'b100)
            out = e ;
        else 
            out = a ;

    end

endmodule
