`include "dCache.vh"
/**
 * en         : en in cache module
 * w_en      : cache writing enable signal, from w_en in cache module
 * hit, dirty : from set module
 *
 * linew_en       : writing enable signal to cache line
 * mw_en      : writing enable signal to memory , controls whether to write to memory
 * new_valid  : control signal for cache line
 * new_dirty  : control signal for cache line
 * offset_sel : control signal for cache line and this may be used in other places
 */
module dCache_Controller #(
    parameter OFFSET_WIDTH = `CACHE_B,
              OFFSET_SIZE  = 2 ** (`CACHE_B - 2)
)(
    input  logic                                  clk, reset, en, w_en, hit, dirty,
    input  logic [ 1 : 0]             bit_pos,
    input  logic [OFFSET_WIDTH - 3 : 0]           addr_offset,
    output logic [OFFSET_WIDTH - 3 : 0]           addr_block_offset,
    output logic [OFFSET_WIDTH - 3 : 0]           data_block_offset,
    output logic                      linew_en, new_valid, new_dirty, mw_en,
    output logic                      offset_sel,
    output logic [ 1 : 0]             state,
//	output logic                      cpu_data_ok,
    output logic                      mem_req,
    input  logic                      mem_data_ok,
    input  logic                      mem_addr_ok,
    input  logic [31 : 0]             mem_rdata,
    input  logic [31 : 0]             cpu_rdata,
    output logic [OFFSET_SIZE * 32 - 1 : 0]       line_data,
    output logic                                  line_data_ok,
    input  logic [ 1 : 0]             size,
    output logic [ 1 : 0]             wr_size
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
            end else if (addr_load <= OFFSET_SIZE - 1) begin
                addr_load <= addr_load + 1;
            end
        end
        
    always_ff @(posedge clk)
        begin
            if (reset | zero) begin
                 data_load <= 0; line_data_ok <= 1'b0;
            end else begin
                if (!mem_data_ok) begin
                 data_load <= data_load; line_data_ok <= 1'b0;
                end else begin
                    if (data_load < OFFSET_SIZE - 1) line_data_ok <= 1'b0; else line_data_ok <= 1'b1;
                    data_load <= data_load + 1;
                end
            end
        end

    always_ff @(posedge clk)
        begin
            if (reset) begin
                state <= 2'b00;
                mem_req <= 1'b0; // Set Initial
            end else if (en) begin
                case (state)
                    2'b01 : begin
                                if (addr_load <= OFFSET_SIZE - 1 || data_load <= OFFSET_SIZE - 1) begin
                                    state <= state; // not ready, ReadMem -> ReadMem
                                    wr_size <= 2'b11;
                                    if (mem_data_ok == 1'b1) begin
                                        if (data_load < OFFSET_SIZE - 1) mem_req <= 1'b1;
                                        else mem_req <= 1'b0;
                                    end else if (mem_addr_ok == 1'b1) mem_req <= 1'b0;
                                    else mem_req <= mem_req;
                //							 cpu_data_ok <= 1'b0;
                                end else begin
                                    wr_size <= size;
                                    state <= 2'b00; // ReadMem -> Initial
                                    mem_req <= 1'b0;
                //						     cpu_data_ok <= 1'b1;
                                end
                                line_data[data_load * 32 +: 32] <= mem_rdata;
                            end
                    2'b10 : begin
                                wr_size <= 2'b11;
                                if  (addr_load <= OFFSET_SIZE - 1 || data_load <= OFFSET_SIZE - 1) begin
                                    state <= state; // not ready, WriteBack -> WriteBack
                                    if (mem_data_ok == 1'b1) begin
                                        if (data_load < OFFSET_SIZE - 1) mem_req <= 1'b1;
                                        else mem_req <= 1'b0;
                                    end else if (mem_addr_ok == 1'b1) mem_req <= 1'b0;
                                    else mem_req <= mem_req;
//							 cpu_data_ok <= 1'b0;
                                
                                end else begin
                                    state <= 2'b01; // WriteBack -> ReadMem
                                    mem_req <= 1'b1;
                                end
                            end
                    default : if (hit) begin
                                state <= state; // Initial -> Initial
                                wr_size <= size;
                                mem_req <= 1'b0;
                                case (size)
                                    2'b00 : line_data[addr_offset * 32 + bit_pos * 8 +: 8] <= cpu_rdata[bit_pos * 8 +: 8];
                                    2'b01 : line_data[addr_offset * 32 + bit_pos * 8 +: 16] <= cpu_rdata[bit_pos * 8 +: 8];
                                    default : line_data[addr_offset * 32 +: 32] <= cpu_rdata;
                                endcase
//		    				     cpu_data_ok <= 1'b1;
                              end else begin
//					    	   	 cpu_data_ok <= 1'b0;
                                mem_req <= 1'b1;
                                if (dirty)	state <= 2'b10; // Initial -> WriteBack
                                else state <= 2'b01; // Initial -> ReadMem
                                wr_size <= 2'b10;
                              end
                endcase
            end
        end
        
    always_comb
        case (state)
            2'b00 : begin
                        zero <= 1'b1;
                        addr_block_offset <= addr_offset;
                        data_block_offset <= addr_offset;
                        new_valid <= 1'b1;
                        if (w_en) new_dirty <= 1'b1;
                        else new_dirty <= dirty;
                        mw_en <= 1'b0;
                        if (hit && w_en) linew_en <= 1'b1;
                        else linew_en <= 1'b0;
                        offset_sel <= 1'b1;
                    end 
            2'b01 : begin
                        zero <= 1'b0;
                        addr_block_offset <= addr_load[OFFSET_WIDTH - 3 : 0];
                        data_block_offset <= data_load[OFFSET_WIDTH - 3 : 0];
                        mw_en <= 1'b0;
                        {new_valid, new_dirty} <= 2'b10;
                        linew_en <= 1'b1;
                        offset_sel <= 1'b0;
                    end
            2'b10 : begin
						if (data_load > OFFSET_SIZE - 1) zero <= 1'b1;
						else zero <= 1'b0;
						addr_block_offset <= addr_load[OFFSET_WIDTH - 3 : 0];
						data_block_offset <= data_load[OFFSET_WIDTH - 3 : 0];
						mw_en <= 1'b1;
                        offset_sel <= 1'b0;
                        linew_en <= 1'b0;
                    end
        endcase
endmodule
