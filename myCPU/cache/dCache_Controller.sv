`include "dCache.vh"

module dCache_Controller #(
    parameter OFFSET_WIDTH = `DCACHE_B,
              OFFSET_SIZE  = 2 ** (`DCACHE_B - 2),
              LINE_NUM     = `DCACHE_E
)(
    input  logic                                  clk, reset, cpu_req, w_en, hit,
    input  logic                                  set_valid, set_dirty, dirty,
    input  logic [ 1 : 0]             bit_pos,
    input  logic [OFFSET_WIDTH - 3 : 0]           addr_offset,
    output logic [OFFSET_WIDTH - 3 : 0]           addr_block_offset,
    output logic                      linew_en, new_valid, new_dirty, mw_en,
    output logic [ 1 : 0]             state,
    output logic                      mem_req,
    input  logic                      mem_data_ok,
    input  logic                      mem_addr_ok,
    input  logic [31 : 0]             mem_rdata,
    input  logic [31 : 0]             cpu_rdata,
    output logic [OFFSET_SIZE * 32 - 1 : 0]       line_data,
    output logic                                  line_data_ok,
    input  logic [ 1 : 0]             size,
    output logic [ 2 : 0]             wr_size,
    output logic                      wlast,
    output logic                      awvalid,
    input  logic                                  wb_ok,
    input  cache_req_t                            cache_op_req
);

    logic [31 : 0] load;
    logic [31 : 0] wb_line_done;

    logic zero;	
        
    always_ff @(posedge clk)
        begin
            if (reset | zero) begin
                load <= 0; line_data_ok <= 1'b0;
            end else begin
                if (!mem_data_ok) begin
                load <= load; line_data_ok <= 1'b0;
                end else begin
                    if (load < OFFSET_SIZE - 1) line_data_ok <= 1'b0; else line_data_ok <= 1'b1;
                    load <= load + 1;
                end
            end
        end

    always_ff @(posedge clk)
        begin
            if (reset) begin
                state <= 2'b00;
                mem_req <= 1'b0; // Set Initial
            end else if (cpu_req) begin
                case (state)
                    2'b01 : begin
                                awvalid <= 1'b0;
                                wlast <= 1'b0;
                                if (mem_req && mem_addr_ok) mem_req <= 1'b0;
                                else mem_req <= mem_req;
                                if (load <= OFFSET_SIZE - 1) begin
                                    state <= state; // not ready, ReadMem -> ReadMem
                                end else begin
                                    state <= 2'b00; // ReadMem -> Initial
                                end
                                line_data[load * 32 +: 32] <= mem_rdata;
                            end
                    2'b10 : begin
                                awvalid <= 1'b0;
                                if (load <= OFFSET_SIZE - 1) begin 
                                    state <= state; // not ready, WriteBack -> WriteBack
                                    if (load == OFFSET_SIZE - 2) wlast <= 1'b1; else wlast <= 1'b0;
                                    if (mem_data_ok == 1'b1) begin
                                        if (load < OFFSET_SIZE - 1) mem_req <= 1'b1;
                                        else mem_req <= 1'b0;
                                    end else if (mem_addr_ok == 1'b1) mem_req <= 1'b0;
                                    else mem_req <= mem_req;
                                end 
                                else begin 
                                    wlast <= 1'b0;
                                    if (cache_op_req != NO_CACHE && wb_line_done < LINE_NUM - 1)
                                        state <= 2'b11;
                                    else begin
                                        state <= 2'b01; // WriteBack -> ReadMem
                                        mem_req <= 1'b1;
                                    end
                                end
                            end
                    2'b11 : begin
                        if (!wb_ok) state <= state;
                        else begin 
                            state <= 2'b10;
                            wlast <= 1'b0;
                            mem_req <= 1'b1;
                            awvalid <= 1'b1;
                        end
                    end
                    default : begin
                        if (cache_op_req == IndexInvalid || cache_op_req == HitWbInvalid) begin 
                            if (hit) begin
                                state <= 2'b10; // Initial -> WriteBack
                                wb_line_done <= '0;
                                wlast <= 1'b0;
                                mem_req <= 1'b1;
                                awvalid <= 1'b1;
                            end else begin
                                state <= state; // Initial -> Initial
                                mem_req <= 1'b0;
                                wlast <= 1'b0;
                                awvalid <= 1'b0;
                            end
                        end
                        else if (hit) begin
                            state <= state; // Initial -> Initial
                            mem_req <= 1'b0;
                            wlast <= 1'b0;
                            awvalid <= 1'b0;
                            case (size)
                                2'b00 : line_data[addr_offset * 32 + bit_pos * 8 +: 8] <= cpu_rdata[bit_pos * 8 +: 8];
                                2'b01 : line_data[addr_offset * 32 + bit_pos * 8 +: 16] <= cpu_rdata[bit_pos * 8 +: 16];
                                2'b11 : line_data[addr_offset * 32 + bit_pos * 8 +: 24] <= cpu_rdata[bit_pos * 8 +: 24];
                                default : line_data[addr_offset * 32 +: 32] <= cpu_rdata;
                            endcase
                        end else begin
                            wlast <= 1'b0;
                            mem_req <= 1'b1;
                            if (dirty) begin
                                state <= 2'b10; // Initial -> WriteBack
                                awvalid <= 1'b1;
                            end else begin
                                state <= 2'b01; // Initial -> ReadMem
                                awvalid <= 1'b0;
                            end
                        end
                    end
                endcase
            end
        end
        
    always_comb
        case (state)
            2'b01 : begin
                        zero <= 1'b0;
                        addr_block_offset <= load[OFFSET_WIDTH - 3 : 0];
                        mw_en <= 1'b0;
                        new_dirty <= 1'b0;
                        linew_en <= 1'b1;
                        wr_size <= 3'b111;
                    end
            2'b10 : begin
						if (load > OFFSET_SIZE - 1) zero <= 1'b1;
						else zero <= 1'b0;
						addr_block_offset <= load[OFFSET_WIDTH - 3 : 0];
                        mw_en <= 1'b1;
                        new_dirty <= 1'b0;
                        linew_en <= 1'b0;
                        wr_size <= 3'b111;
                    end
            default : begin
                zero <= 1'b1;
                addr_block_offset <= addr_offset;
                if (w_en) new_dirty <= 1'b1;
                else if (cpu_req == IndexTag) new_dirty <= set_dirty;
                else new_dirty <= dirty;
                mw_en <= 1'b0;
                if (hit && w_en) linew_en <= 1'b1;
                else linew_en <= 1'b0;
                wr_size <= {1'b0, size};
            end 
        endcase
    
    always_comb
        case (cache_op_req)
            IndexInvalid : begin
                new_valid <= 1'b0;
            end
            IndexTag : begin
                new_valid <= 1'b0;
            end
            HitInvalid : begin
                new_valid <= set_valid;
            end
            HitWbInvalid : begin
                new_valid <= 1'b0;
            end
            default : begin
                new_valid <= 1'b1;
            end
        endcase
endmodule
