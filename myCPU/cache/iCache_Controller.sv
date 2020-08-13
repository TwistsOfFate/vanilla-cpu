`include "iCache.vh"

module iCache_Controller #(
	parameter OFFSET_WIDTH = `ICACHE_B,
			  OFFSET_SIZE  = 2 ** (`ICACHE_B - 2)
)(
	input  logic                                  clk, reset, cpu_req,
	input  logic                                  mem_addr_ok, mem_data_ok, hit,
	input  logic [OFFSET_WIDTH - 3 : 0]           addr_offset,
	output logic                                  linew_en, 
	output logic [OFFSET_WIDTH - 3 : 0]           addr_block_offset,
	output logic [OFFSET_WIDTH - 3 : 0]           data_block_offset,
	output logic                                  state,
//	output logic                                  cpu_data_ok,
	output logic                                  mem_req,
	input  logic [31:0]                           mem_rdata,
	output logic [OFFSET_SIZE * 32 - 1 : 0]       line_data,
	output logic                                  line_data_ok,
	input  cache_req_t                            cache_op_req,
	input  logic                                  wr_valid,
	output logic                                  valid
);

	logic [31 : 0] load;
	logic zero;	
		
	always_ff @(posedge clk)
		begin
			if (reset | zero) begin
			     load <= 0; line_data_ok <= 1'b0;
			end
			else if (!mem_data_ok) begin
			     load <= load; line_data_ok <= 1'b0;
			end
			else begin
			     line_data[load * 32 +: 32] <= mem_rdata;
			     if (load < OFFSET_SIZE - 1) line_data_ok <= 1'b0; else line_data_ok <= 1'b1;
			     load <= load + 1;
			end
		end
	
	always_ff @(posedge clk)
		begin
			if (reset) begin
			    state <= 1'b0; // Set Initial
			    mem_req <= 1'b0;
			end else if (cpu_req) begin
				case (state)
					1'b0: if (hit) begin 
							state <= state; // Initial -> Initial
							mem_req <= 1'b0;
						  end	
						  else begin
						  	state <= 1'b1; // Initial -> ReadMem
						  	mem_req <= 1'b1;
						  end
					1'b1: begin
							if (mem_req && mem_addr_ok) mem_req <= 1'b0;
							else mem_req <= mem_req;
							if (load <= OFFSET_SIZE - 1) begin
								state <= state; // not ready, ReadMem -> ReadMems
							end
							else begin
								state <= 1'b0; // ReadMem -> Initial
							end
						end
				endcase
			end
		end
		
	always_comb
		case (state)
			2'b0 : begin
						zero <= 1'b1;
						addr_block_offset <= addr_offset;
						data_block_offset <= addr_offset;
						if (hit) linew_en <= 1'b1;
						else linew_en <= 1'b0;
				   end 
			2'b1 : begin
						zero <= 1'b0;
						addr_block_offset <= load[OFFSET_WIDTH - 3 : 0];
						data_block_offset <= load[OFFSET_WIDTH - 3 : 0];
						linew_en <= 1'b1;
				   end
		endcase
	
	always_comb
		case (cache_op_req) 
			IndexInvalid : begin
				valid <= 1'b0;
			end
			IndexTag : begin
				valid <= wr_valid;
			end
			HitInvalid : begin
				valid <= 1'b0;
			end
			default : begin
				valid <= 1'b1;
			end
		endcase
endmodule
