`include "cpu_defs.svh"
module flop_ftod(
    input  clk,
    input  rst,
    input  stall,
    input  dp_ftod in,
    output dp_ftod out

) ;

dp_ftod tmp ;

always_ff @(posedge clk) begin
    if (rst) begin
        tmp <= 67'b0 ;
    end else if (stall) begin
        tmp <= tmp;
    end else begin
        tmp <= in;
    end
end
    
assign out = tmp;


endmodule