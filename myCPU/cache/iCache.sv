`include "iCache.vh"

typedef logic[31:0] _int;

/* SRAM */
module iCache #(
    parameter TAG_WIDTH    = `CACHE_T,
              INDEX_WIDTH  = `CACHE_S,
              SET_NUM      = `SET_NUM,
              OFFSET_WIDTH = `CACHE_B,
              LINE_NUM     = `CACHE_E,
              OFFSET_SIZE  = 2 ** (`CACHE_B - 2)
)(	
    /* CPU */
    input  logic           clk, reset, 
    input  logic [31 : 0]  instr_addr_1, // the request address
    input  logic [31 : 0]  instr_addr_2,
    output logic           second_data_ok,
    input  logic           cpu_req_1,
    input  logic           cpu_req_2,
    output logic           cpu_addr_ok,
    output logic           cpu_data_ok, // whether the data is transported
    output logic [31 : 0]  instr_rdata_1, // the data need to be read
    output logic [31 : 0]  instr_rdata_2, 
    
    /* Memory */	
    output logic           mem_req,
    output logic [31 : 0]  mem_read_addr,
    input  logic [31 : 0]  mem_read_data,
    input  logic           mem_addr_ok,
    input  logic           mem_data_ok
);
    
    logic [TAG_WIDTH - 1 : 0] instr_addr_tag, instr_addr_tag_1, instr_addr_tag_2;
    logic [INDEX_WIDTH - 1 : 0] instr_addr_index, instr_addr_index_1, instr_addr_index_2;
    logic [OFFSET_WIDTH - 3 : 0] instr_addr_offset, instr_addr_offset_1, instr_addr_offset_2;
    logic linew_en, new_valid, offset_sel, strategy_en;
    logic [31 : 0] mem_data_addr;
    logic [31 : 0] replaceID;
    logic [31 : 0] ram_addr;
    logic [31 : 0] instr_rdata_1_0, instr_rdata_2_0;
    logic [OFFSET_WIDTH - 3 : 0] addr_block_offset, data_block_offset;
    logic state, hit, hit_0, hit_1;
    logic cpu_req_1_1;
    logic mem_addr_ok_1, mem_data_ok_1;
    logic cpu_data_ok_0;
    logic second_data_ok_0;
    
    assign instr_addr_tag_1 = instr_addr_1[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign instr_addr_index_1 = instr_addr_1[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign instr_addr_offset_1 = instr_addr_1[OFFSET_WIDTH - 1 : 2];
    assign instr_addr_offset_2 = instr_addr_2[OFFSET_WIDTH - 1 : 2];

    logic [TAG_WIDTH - 1 : 0] icache_line_tag[LINE_NUM - 1 : 0];
    logic [OFFSET_SIZE * 32 - 1 : 0] icache_line_data[LINE_NUM - 1 : 0];
    logic [OFFSET_SIZE * 32 - 1 : 0] line_data;
    logic line_data_ok;
    logic [LINE_NUM - 1 : 0] way_selector;
    logic [31:0] hit_line_num;

    assign instr_addr_tag = instr_addr_tag_1;
    assign instr_addr_index = instr_addr_index_1;
    assign instr_addr_offset = instr_addr_offset_1;
    
    // access cache
    // the data in the same cacheline was organized in the same ram
    // the `instr_addr_index` can be used to locate the accurate data position in both RAM
    genvar i;
    generate
        for (i = 0; i < LINE_NUM; i = i + 1) begin:AccessCache
            iCache_Ram  #(TAG_WIDTH, OFFSET_SIZE)
                 icache_tag_ram  (clk, reset, instr_addr_index, instr_addr_tag, icache_line_tag[i], (i == replaceID) & line_data_ok);
            iCache_Ram  #(OFFSET_SIZE * 32, OFFSET_SIZE) 
                 icache_data_ram (clk, reset, instr_addr_index, line_data, icache_line_data[i], (i == replaceID) & line_data_ok);
            always_comb
                if (icache_line_tag[i] == instr_addr_tag) way_selector[i] <= 1;
                else way_selector[i] <= 0;
        end
    endgenerate
    
    iCache_Replacement icache_replacement(clk, reset, hit, state, replaceID);
    
    // getting results
    always_comb begin
        hit_line_num = 0;
        for (int i = 0; i < LINE_NUM; i = i + 1) 
            hit_line_num |= (way_selector[i] == 1) ? _int'(i) : 0;
    end 
      
    always_comb
        case (hit)
            1'b1 : begin
                    instr_rdata_1_0 <= icache_line_data[hit_line_num][instr_addr_offset * 32 +: 32];
                    if (cpu_req_2 && instr_addr_1[31 : OFFSET_WIDTH] == instr_addr_2[31 : OFFSET_WIDTH]) begin
                        instr_rdata_2_0 <= icache_line_data[hit_line_num][instr_addr_offset_2 * 32 +: 32];
                        second_data_ok_0 <= 1'b1;
                    end else begin
                        instr_rdata_2_0 <= '0;
                        second_data_ok_0 <= 1'b0;
                    end
                   end
            default : begin
                        instr_rdata_1_0 <= icache_line_data[replaceID][instr_addr_offset * 32 +: 32];
                        if (cpu_req_2 && instr_addr_1[31 : OFFSET_WIDTH] == instr_addr_2[31 : OFFSET_WIDTH]) begin
                            instr_rdata_2_0 <= icache_line_data[replaceID][instr_addr_offset_2 * 32 +: 32];
                            second_data_ok_0 <= 1'b1;
                        end else begin
                            instr_rdata_2_0 <= '0;
                            second_data_ok_0 <= 1'b0;
                        end
                      end
        endcase
    
    assign hit = (|way_selector) || !cpu_req_1;
    
    iCache_Controller icache_ctrl(clk, reset, mem_addr_ok, mem_data_ok, hit, instr_addr_offset, linew_en, 
                                  addr_block_offset, data_block_offset, offset_sel, state, mem_req,
                                  mem_read_data, line_data, line_data_ok);
    
 
    assign cpu_addr_ok = cpu_req_1 & hit;
    
    // TODO: removed icache_flop
    flop #(67) icache_flop(clk, reset, 1'b0, {hit  , instr_rdata_1_0, instr_rdata_1_0, second_data_ok_0, cpu_req_1  },
                                             {hit_1, instr_rdata_1  , instr_rdata_2  , second_data_ok  , cpu_req_1_1});
    assign cpu_data_ok = hit_1 & cpu_req_1_1;
        
    assign mem_read_addr = {instr_addr_tag, instr_addr_index, addr_block_offset, 2'b00};
    assign mem_data_addr = {instr_addr_tag, instr_addr_index, data_block_offset, 2'b00};

endmodule

