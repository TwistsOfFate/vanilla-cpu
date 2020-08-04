`include "iCache.vh"

typedef logic[31:0] _int;

/* SRAM */
module iCache #(
	parameter TAG_WIDTH    = `ICACHE_T,
		      INDEX_WIDTH  = `ICACHE_S,
		      SET_NUM      = `ISET_NUM,
		      OFFSET_WIDTH = `ICACHE_B,
		      LINE_NUM     = `ICACHE_E,
		      OFFSET_SIZE  = 2 ** (`ICACHE_B - 2)
)(	
	/* CPU */
	input  logic           clk, reset, 
	input  logic [31 : 0]  instr_addr, // the request address
	input  logic           cpu_req,
	output logic           cpu_addr_ok,
	output logic           cpu_data_ok, // whether the data is transported
	output logic [31 : 0]  instr_rdata, // the data need to be read 
	
	/* Memory */	
	output logic           mem_req,
	output logic [31 : 0]  mem_read_addr,
	input  logic [31 : 0]  mem_read_data,
	input  logic           mem_addr_ok,
	input  logic           mem_data_ok
);
    
    logic [TAG_WIDTH - 1 : 0] instr_addr_tag, instr_addr_tag_0, instr_addr_tag_1;
    logic [INDEX_WIDTH - 1 : 0] instr_addr_index, instr_addr_index_0, instr_addr_index_1;
    logic [OFFSET_WIDTH - 3 : 0] instr_addr_offset, instr_addr_offset_0, instr_addr_offset_1;
    logic linew_en, new_valid;
    logic [31 : 0] ram_data[LINE_NUM - 1 : 0];
    logic [31 : 0] instr_rdata_0;
    logic [31 : 0] replaceID;
    logic [31 : 0] ram_addr;
    logic [OFFSET_WIDTH - 3 : 0] addr_block_offset, data_block_offset;
    logic state, hit, hit_0, hit_1;
    logic cpu_req_1;
    logic mem_addr_ok_1, mem_data_ok_1;
    logic cpu_data_ok_0;
    
    assign instr_addr_tag_0 = instr_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign instr_addr_index_0 = instr_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign instr_addr_offset_0 = instr_addr[OFFSET_WIDTH - 1 : 2];
    
//    iCache_Disambiguation icache_disambiguation (clk, instr_addr_tag, instr_addr_index, instr_addr_offset, wdata, data_ok);

	logic [TAG_WIDTH - 1 : 0] icache_line_tag[LINE_NUM - 1 : 0];
	logic [OFFSET_SIZE * 32 - 1 : 0] icache_line_data[LINE_NUM - 1 : 0];
	logic [OFFSET_SIZE * 32 - 1 : 0] line_data;
	logic line_data_ok;
	logic [LINE_NUM - 1 : 0] way_selector;
	logic [31:0] hit_line_num;
	logic [LINE_NUM - 1 : 0] icache_line_valid;
	
	// access cache
	// the data in the same cacheline was organized in the same ram
	// the `instr_addr_index` can be used to locate the accurate data position in both RAM
	
	assign instr_addr_tag = instr_addr_tag_0;
	assign instr_addr_index = instr_addr_index_0;
	assign instr_addr_offset = instr_addr_offset_0;
	
	genvar i;
	generate
		for (i = 0; i < LINE_NUM; i = i + 1) begin:AccessCache
			     
		    icache_Info_Ram  #(TAG_WIDTH, INDEX_WIDTH)
					 icache_tag_ram  (clk, reset, instr_addr_index, 
														1'b1, instr_addr_tag, 
														icache_line_valid[i], icache_line_tag[i], 
														(i == replaceID) & line_data_ok);
			iCache_Ram  #(OFFSET_SIZE * 32, OFFSET_SIZE) 
			     icache_data_ram (clk, reset, instr_addr_index, line_data, icache_line_data[i], (i == replaceID) & line_data_ok);
			always_comb
				if (icache_line_valid[i] && icache_line_tag[i] == instr_addr_tag_0) way_selector[i] <= 1;
				else way_selector[i] <= 0;
		end
	endgenerate
	
	
	iCache_Replacement icache_replacement(clk, reset, hit, state, replaceID);
	
	// getting results
	always_comb
	   begin
	       hit_line_num = 0;
	       for (int i = 0; i < LINE_NUM; i = i + 1)
	           begin
	               hit_line_num |= (way_selector[i] == 1) ? _int'(i) : 0;
	           end
	   end 
	  
    always_comb
        case (hit)
            1'b1 : instr_rdata_0 <= icache_line_data[hit_line_num][instr_addr_offset * 32 +: 32];
	       		default: instr_rdata_0 <= icache_line_data[replaceID][instr_addr_offset * 32 +: 32];
	   		endcase

    assign hit = (|way_selector) || !cpu_req;
	
	iCache_Controller icache_ctrl(clk, reset, mem_addr_ok, mem_data_ok, hit, instr_addr_offset, linew_en, 
    							  addr_block_offset, data_block_offset, state, mem_req,
    							  mem_read_data, line_data, line_data_ok);
 
    assign cpu_addr_ok = cpu_req & hit;

    assign hit_1 = hit;
    assign instr_rdata = instr_rdata_0;
    assign cpu_req_1 = cpu_req;  

    assign cpu_data_ok = hit_1 & cpu_req_1;

    assign mem_read_addr = {instr_addr_tag, instr_addr_index, addr_block_offset, 2'b00};

endmodule

