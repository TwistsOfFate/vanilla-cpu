`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/09 16:16:17
// Design Name: 
// Module Name: divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divider_ld(
	input sign,
	input [31:0] srca,
	input [31:0] srcb,
	output [31:0] hi,
	output [31:0] lo
    );
    
    logic [31:0] n, d, q, r;
    integer i;
    
    always_comb begin
        n = sign ? {1'b0, srca[30:0]} : srca;
        d = sign ? {1'b0, srcb[30:0]} : srcb;
        q = 32'b0;
        r = 32'b0;
        if (d == 0) begin
        end
        else begin
            for (i = 31; i >= 0; i = i - 1) begin
                r = r << 1;
                r[0] = n[i];
                if (r >= d) begin
                    r = r - d;
                    q[i] = 1'b1;
                end
            end
            q[31] = sign ? (srca[31] ^ srcb[31]) : q[31];
            r[31] = sign ? (srca[31] ^ srcb[31]) : r[31];
        end
    end
    
    assign hi = r;
    assign lo = q;
    
endmodule
