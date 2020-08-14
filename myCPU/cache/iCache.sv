`include "iCache.vh"
`include "cpu_defs.svh"

typedef logic[31:0] _int;

/* SRAM */
module iCache #(
    parameter TAG_WIDTH    = `ICACHE_T,
              INDEX_WIDTH  = `ICACHE_S,
              SET_NUM      = `ISET_NUM,
              OFFSET_WIDTH = `ICACHE_B,
              LINE_NUM     = `ICACHE_E,
              OFFSET_SIZE  = 2 ** (`ICACHE_B - 2),
              LINE_WIDTH   = `ICACHE_LINE_WIDTH
)(	
    /* CPU */
    input  logic           clk, reset, 
    input  logic [31 : 0]  inst_addr, // the request address
    input  logic           cpu_req,
    input  cache_req_t     cache_op_req,
    output logic           cache_op_ok,
    output logic           cpu_addr_ok,
    output logic           cpu_data_ok, // whether the data is transported
    output logic [31 : 0]  inst_rdata, // the data need to be read 

    output logic           icache_busy,
    input  logic [31 : 0]  taglo,
    
    /* Memory */	
    output logic           mem_req,
    output logic [31 : 0]  mem_read_addr,
    input  logic [31 : 0]  mem_read_data,
    input  logic           mem_addr_ok,
    input  logic           mem_data_ok
);
    
    logic [TAG_WIDTH - 1 : 0] inst_addr_tag;
    logic [INDEX_WIDTH - 1 : 0] inst_addr_index;
    logic [OFFSET_WIDTH - 3 : 0] inst_addr_offset;
    logic [LINE_WIDTH - 1 : 0] inst_addr_way;
    logic [31 : 0] replaceID;
    logic [OFFSET_WIDTH - 3 : 0] addr_block_offset, data_block_offset;
    logic state, hit, valid;
    
    assign inst_addr_tag = cache_op_req == IndexTag ? taglo[31 : INDEX_WIDTH + OFFSET_WIDTH] : inst_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign inst_addr_index = inst_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign inst_addr_offset = inst_addr[OFFSET_WIDTH - 1 : 2];
    assign inst_addr_width = inst_addr[INDEX_WIDTH + OFFSET_WIDTH + LINE_WIDTH - 1 : INDEX_WIDTH + OFFSET_WIDTH];

    logic [TAG_WIDTH - 1 : 0] icache_line_tag[LINE_NUM - 1 : 0];
    logic [OFFSET_SIZE * 32 - 1 : 0] icache_line_data[LINE_NUM - 1 : 0];
    logic [OFFSET_SIZE * 32 - 1 : 0] line_data;
    logic line_data_ok;
    logic [LINE_NUM - 1 : 0] way_selector;
    logic [31:0] hit_line_num;
    logic [LINE_NUM - 1 : 0] icache_line_valid;
    
    // access cache
    // the data in the same cacheline was organized in the same ram
    // the `inst_addr_index` can be used to locate the accurate data position in both RAM
    
    genvar i;
    generate
        for (i = 0; i < LINE_NUM; i = i + 1) begin:AccessCache
                 
            icache_Info_Ram  #(TAG_WIDTH, INDEX_WIDTH)
                icache_tag_ram  (clk, reset, inst_addr_index, 
                                 valid, inst_addr_tag, 
                                 icache_line_valid[i], icache_line_tag[i], 
                                 (state == 1'b0 && ((cache_op_req == IndexInvalid && addr_way == i) || (cache_op_req == IndexTag && addr_way == i) || (cache_op_req == HitInvalid && way_selector[i]))) || ((i == replaceID) && line_data_ok));

            iCache_Ram  #(OFFSET_SIZE * 32, OFFSET_SIZE) 
                icache_data_ram (clk, inst_addr_index, line_data, icache_line_data[i], (i == replaceID) && line_data_ok);

            always_comb
                if (icache_line_valid[i] && icache_line_tag[i] == inst_addr_tag) way_selector[i] <= 1;
                else way_selector[i] <= 0;
        end
    endgenerate
    
    iCache_Replacement icache_replacement(clk, reset, hit, replaceID);
    
    // getting results
    always_comb
       begin
           hit_line_num = 0;
           for (int i = 0; i < LINE_NUM; i = i + 1)
               hit_line_num |= (way_selector[i] == 1'b1) ? _int'(i) : 0;
       end 
      
    always_comb
        case (hit)
            1'b1 : inst_rdata <= icache_line_data[hit_line_num][inst_addr_offset * 32 +: 32];
            default : inst_rdata <= icache_line_data[replaceID][inst_addr_offset * 32 +: 32];
        endcase

    assign hit = (|way_selector) || !cpu_req;
    
    iCache_Controller icache_ctrl(clk, reset, cpu_req, mem_addr_ok, mem_data_ok, hit, inst_addr_offset, linew_en, 
                                  addr_block_offset, data_block_offset, state, mem_req,
                                  mem_read_data, line_data, line_data_ok, cache_op_req, taglo[7], valid);
 
    assign cpu_addr_ok = cpu_req & hit; 
    assign cpu_data_ok = hit & cpu_req;

    assign cache_op_ok = cache_op_req != NO_CACHE;
    assign icache_busy = state;

    assign mem_read_addr = {inst_addr_tag, inst_addr_index, addr_block_offset, 2'b00};

endmodule

