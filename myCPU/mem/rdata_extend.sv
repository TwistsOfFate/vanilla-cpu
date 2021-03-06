`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/11 11:10:02
// Design Name: 
// Module Name: rdata_extend
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


module rdata_extend(
	input sign,
	input [31:0] rdata,
    input [31:0] rtdata,
	input [1:0] size,
	input [1:0] memoffset,
    input [1:0] lwlr,
	output [31:0] out
    );
    
    logic [31:0] tmp;
    
    always_comb
        unique case (lwlr)
            2'b00: // Normal load
        	unique case (size)
        		// 8b->32b
        		2'b00:
        		begin
        			unique case (memoffset)
        				2'b00:		tmp = sign ? {{24{rdata[7]}}, rdata[7:0]} : {24'b0, rdata[7:0]};
        				2'b01:		tmp = sign ? {{24{rdata[15]}}, rdata[15:8]} : {24'b0, rdata[15:8]};
        				2'b10:		tmp = sign ? {{24{rdata[23]}}, rdata[23:16]} : {24'b0, rdata[23:16]};
        				2'b11:		tmp = sign ? {{24{rdata[31]}}, rdata[31:24]} : {24'b0, rdata[31:24]};
        			endcase
        		end
        		// 16b->32b
        		2'b01:
        		begin
        			unique case (memoffset)
        				2'b00:		tmp = sign ? {{16{rdata[15]}}, rdata[15:0]} : {16'b0, rdata[15:0]};
        				2'b10:		tmp = sign ? {{16{rdata[31]}}, rdata[31:16]} : {16'b0, rdata[31:16]};
        			endcase
        		end
        		// 32b->32b
        		2'b10:		tmp = rdata;
        	endcase
            2'b01: // LWL
            unique case (memoffset)
                2'b00:      tmp = {rdata[7:0], rtdata[23:0]};
                2'b01:      tmp = {rdata[15:0], rtdata[15:0]};
                2'b10:      tmp = {rdata[23:0], rtdata[7:0]};
                2'b11:      tmp = rdata;
            endcase
            2'b10: // LWR
            unique case (memoffset)
                2'b00:      tmp = rdata;
                2'b01:      tmp = {rtdata[31:24], rdata[31:8]};
                2'b10:      tmp = {rtdata[31:16], rdata[31:16]};
                2'b11:      tmp = {rtdata[31:8], rdata[31:24]};
            endcase
        endcase
    
    assign out = tmp;
    
endmodule
