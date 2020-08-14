module memsig_adjust(
	input req,
	input wr,
	input [31:0] in,
	input [1:0] size,
	input [1:0] memoffset,
    input [1:0] swlr,
    input [1:0] lwlr,
	output [31:0] out,
    output [1:0] real_size,
    output [1:0] real_offset
);

	logic [31:0] tmp;
	logic [1:0]	size_tmp, offset_tmp;
    
    always_comb begin
        unique case (swlr)
            2'b00: // Normal store
        	unique case (size)
        		// 8b->32b
        		2'b00:
        		begin
        			unique case (memoffset)
        				2'b00:		tmp = in;               
        				2'b01:		tmp = {in[23:0], 8'b0};
        				2'b10:		tmp = {in[15:0], 16'b0};
        				2'b11:		tmp = {in[7:0], 24'b0};
        			endcase
        		end
        		// 16b->32b
        		2'b01:
        		begin
        			unique case (memoffset)
        				2'b00:		tmp = in;
        				2'b10:		tmp = {in[15:0], 16'b0};
        			endcase
        		end
        		// 32b->32b
        		2'b10:				tmp = in;
                // 24b->32b
                2'b11:
                begin
                    unique case (memoffset)
                        2'b00:      tmp = {8'b0, in[23:0]};
                        2'b01:      tmp = {in[23:0], 8'b0};
                    endcase
                end
        	endcase
            2'b01: // SWL
            unique case (memoffset)
                2'b00:  tmp = {24'b0, in[31:24]};
                2'b01:  tmp = {16'b0, in[31:16]};
                2'b10:  tmp = {8'b0, in[31:8]};
                2'b11:  tmp = in;
            endcase
            2'b10: // SWR
            unique case (memoffset)
                2'b00:  tmp = in;
                2'b01:  tmp = {in[23:0], 8'b0};
                2'b10:  tmp = {in[15:0], 16'b0};
                2'b11:  tmp = {in[7:0], 24'b0};
            endcase
        endcase
    end

    always_comb
        unique case (swlr)
            2'b01:
            unique case (memoffset)
                2'b00:  size_tmp = 2'b00;
                2'b01:  size_tmp = 2'b01;
                2'b10:  size_tmp = 2'b11;
                2'b11:  size_tmp = 2'b10;
            endcase
            2'b10:
            unique case (memoffset)
                2'b00:  size_tmp = 2'b10;
                2'b01:  size_tmp = 2'b11;
                2'b10:  size_tmp = 2'b01;
                2'b11:  size_tmp = 2'b00;
            endcase
            default:
                size_tmp = 2'b00;
        endcase
    
    assign out = tmp;
    assign real_size = swlr == 2'b00 ? size : size_tmp;
    assign real_offset = swlr == 2'b01 || lwlr != 2'b00 ? 2'b00 : memoffset;
	
endmodule
