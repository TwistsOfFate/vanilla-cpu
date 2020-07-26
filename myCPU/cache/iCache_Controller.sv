`include "iCache.vh"

module iCache_Controller #(
	parameter OFFSET_WIDTH = `CACHE_B,
			  OFFSET_SIZE  = 2 ** (`CACHE_B - 2)
)(
	input  logic                                  clk, reset, mem_addr_ok, mem_data_ok, hit,
	input  logic [OFFSET_WIDTH - 3 : 0]           addr_offset,
	output logic                                  linew_en, 
	output logic [OFFSET_WIDTH - 3 : 0]           addr_block_offset,
	output logic [OFFSET_WIDTH - 3 : 0]           data_block_offset,
	output logic                                  offset_sel,
	output logic                                  state,
//	output logic                                  cpu_data_ok,
	output logic                                  mem_req,
	input  logic [31:0]                           mem_rdata,
	output logic [OFFSET_SIZE * 32 - 1 : 0]       line_data,
	output logic                                  line_data_ok
);

	logic [31 : 0] addr_load;
	logic [31 : 0] data_load;
	logic zero;	
	
	always_ff @(posedge clk)
		begin
			if (reset | zero) begin
			    addr_load <= 0;
			end else if (!mem_addr_ok) begin
			    addr_load <= addr_load;
//			    mem_req <= 0;
			end else if (addr_load <= OFFSET_SIZE - 1) begin
			    addr_load <= addr_load + 1;
//			    mem_req <= 1;
			end
		end
		
	always_ff @(posedge clk)
		begin
			if (reset | zero) begin
			     data_load <= 0; line_data_ok <= 1'b0;
			end
			else if (!mem_data_ok) begin
			     data_load <= data_load; line_data_ok <= 1'b0;
			end
			else begin
			     line_data[data_load * 32 +: 32] <= mem_rdata;
			     if (data_load < OFFSET_SIZE - 1) line_data_ok <= 1'b0; else line_data_ok <= 1'b1;
			     data_load <= data_load + 1;
			end
		end
	
	always_ff @(posedge clk)
		begin
			if (reset) begin
			    state <= 1'b0; // Set Initial
//			    cpu_data_ok <= 1'b0;
			    mem_req <= 1'b0;
			end else begin
				case (state)
					1'b0: if (hit) begin 
							state <= state; // Initial -> Initial
//							cpu_data_ok <= 1'b1;
							mem_req <= 1'b0;
						  end	
						  else begin
						  	state <= 1'b1; // Initial -> ReadMem
//						  	cpu_data_ok <= 1'b0;
						  	mem_req <= 1'b1;
						  end
					1'b1: if (addr_load <= OFFSET_SIZE - 1 || data_load <= OFFSET_SIZE - 1) begin
							state <= state; // not ready, ReadMem -> ReadMems
//							cpu_data_ok <= 1'b0;
							if (mem_data_ok == 1'b1) begin
							     if (data_load < OFFSET_SIZE - 1) mem_req <= 1'b1;
							     else mem_req <= 1'b0;
							end 
							else if (mem_addr_ok == 1'b1) mem_req <= 1'b0;
							else mem_req <= mem_req;
						  end
						  else begin
						    state <= 1'b0; // ReadMem -> Initial
//						    cpu_data_ok <= 1'b1;
						    mem_req <= 1'b0;
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
						if (hit) {linew_en, offset_sel} <= 2'b10;
						else linew_en <= 1'b0;
				//		mem_req <= 1'b0;
				   end 
			2'b1 : begin
						zero <= 1'b0;
						addr_block_offset <= addr_load[OFFSET_WIDTH - 3 : 0];
						data_block_offset <= data_load[OFFSET_WIDTH - 3 : 0];
						//if (addr_load > OFFSET_SIZE - 1) mem_req <= 1'b0;
					//	else mem_req <= 1'b1;
						linew_en <= 1'b1;
						offset_sel <= 1'b1;
				   end
		endcase
	
/*	always_ff @(posedge clk)
		begin
			if (reset | zero) begin
			    addr_load <= 0;
			end else if (!mem_addr_ok) begin
			    addr_load <= addr_load;
//			    mem_req <= 0;
			end else if (addr_load <= OFFSET_SIZE - 1) begin
			    addr_load <= addr_load + 1;
//			    mem_req <= 1;
			end
		end
		
	always_ff @(posedge clk)
		begin
			if (reset | zero) data_load <= 0;
			else if (!mem_data_ok) data_load <= data_load;
			else data_load <= data_load + 1;
		end
	
	always_ff @(posedge clk)
		begin
			if (reset) begin
			    state <= 1'b0; // Set Initial
			    cpu_data_ok <= 1'b0;
			end else begin
				case (state)
					1'b0: if (hit) begin 
							state <= state; // Initial -> Initial
							cpu_data_ok <= 1'b1;
						  end	
						  else begin
						  	state <= 1'b1; // Initial -> ReadMem
						  	cpu_data_ok <= 1'b0;
						  end
					1'b1: if (addr_load <= OFFSET_SIZE - 1 || data_load <= OFFSET_SIZE - 1) begin
							state <= state; // not ready, ReadMem -> ReadMems
							cpu_data_ok <= 1'b0;
						  end
						  else begin
						    state <= 1'b0; // ReadMem -> Initial
						    cpu_data_ok <= 1'b1;
						  end
				endcase
			end
		end
		
	always_comb
		case (state)
			2'b0 : begin
						zero <= 1'b1;
						addr_block_offset <= addr_offset[OFFSET_WIDTH - 1 : 2];
						data_block_offset <= addr_offset[OFFSET_WIDTH - 1 : 2];
						if (hit) {linew_en, offset_sel} <= 2'b10;
						else linew_en <= 1'b0;
						mem_req <= 1'b0;
				   end 
			2'b1 : begin
						zero <= 1'b0;
						addr_block_offset <= addr_load[OFFSET_WIDTH - 3 : 0];
						data_block_offset <= data_load[OFFSET_WIDTH - 3 : 0];
						if (addr_load > OFFSET_SIZE - 1) mem_req <= 1'b0;
						else mem_req <= 1'b1;
						linew_en <= 1'b1;
						offset_sel <= 1'b1;
				   end
		endcase*/
	
endmodule
