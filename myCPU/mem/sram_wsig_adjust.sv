module sram_wsig_adjust(
	input req,
	input wr,
	input [31:0] in,
	input [1:0] size,
	input [1:0] memoffset,
	output [31:0] out,
	output [3:0] wen
);

	logic [31:0] tmp;
	logic [3:0]	wen_tmp;
    
    always_comb begin
    	case (size)
    		// 8b->32b
    		2'b00:
    		begin
    			case (memoffset)
    				2'b00:		begin		tmp = in; 					wen_tmp = 4'b0001;			end
    				2'b01:		begin		tmp = {in[23:0], 8'b0}; 	wen_tmp = 4'b0010;			end
    				2'b10:		begin		tmp = {in[15:0], 16'b0}; 	wen_tmp = 4'b0100;			end
    				2'b11:		begin		tmp = {in[7:0], 24'b0}; 	wen_tmp = 4'b1000;			end
    			endcase
    		end
    		// 16b->32b
    		2'b01:
    		begin
    			case (memoffset)
    				2'b00:		begin		tmp = in; 					wen_tmp = 4'b0011;			end
    				2'b10:		begin		tmp = {in[15:0], 16'b0}; 	wen_tmp = 4'b1100;			end
    				default:	begin 		tmp = in;					wen_tmp = 4'b0000;			end		
    			endcase
    		end
    		// 32b->32b
    		2'b10:				begin		tmp = in; 					wen_tmp = 4'b1111;			end
    		default:			begin 		tmp = in;					wen_tmp = 4'b0000;			end
    	endcase
    end
    
    assign out = tmp;
    assign wen = (req && wr) ? wen_tmp : 4'b0;
	
endmodule
