`define STATE_IDLE 2'b00
`define STATE_THRU 2'b01 			// Direct read or write
`define STATE_QUEUED 2'b10  		// Queue writing into memory

typedef struct packed {
	logic [1:0]				size;
	logic [31:0]			addr;
	logic [31:0]			wdata;
} sbuffer_element_t;

module store_buffer #(
	parameter SIZE_WIDTH = 8,
	parameter SIZE = 2 ** SIZE_WIDTH
)(
	input 					clk,
	input					resetn,

//CPU Signals
	input 					cpu_req,
	input					cpu_wr,
	input  [1:0]			cpu_size,
	input  [31:0]			cpu_addr,
	input  [31:0]			cpu_wdata,

	output logic [31:0]		cpu_rdata,
	output logic 			cpu_addr_ok,
	output logic			cpu_data_ok,

	input					cpu_dcached,

//Memory Signals
	output logic 			mem_req,
	output logic			mem_wr,
	output logic [1:0]		mem_size,
	output logic [31:0]		mem_addr,
	output logic [31:0]		mem_wdata,

	input  [31:0]			mem_rdata,
	input 					mem_addr_ok,
	input					mem_data_ok,

	output logic			mem_dcached
	);

logic [31:0] ticks;
sbuffer_element_t queue[SIZE-1:0];
logic [SIZE_WIDTH-1:0] head_ptr, tail_ptr;
logic [1:0] state;
wire queue_req;
wire queue_full, queue_empty;
wire need_clear_queue, need_queue, need_thru;

// Set up flags
assign queue_full = (tail_ptr + 1 == head_ptr) ? 1'b1 : 1'b0;
assign queue_empty = (tail_ptr == head_ptr);

// A summary of request types, ordered by priority
assign need_clear_queue = cpu_req & ~cpu_wr & ~queue_empty | queue_full;
assign need_thru = cpu_req & (~cpu_wr | ~cpu_dcached);
assign need_queue = cpu_req & (cpu_wr & cpu_dcached);

// FSM: Choose data from either CPU(uncached) or queue
always_ff @(posedge clk)
	if (~resetn)
		state <= `STATE_IDLE;
	else if (state == `STATE_IDLE)
		if (need_clear_queue)
			state <= `STATE_QUEUED;
		else if (need_thru)
			state <= `STATE_THRU;
		else if (!queue_empty)
			state <= `STATE_QUEUED;
		else
			state <= `STATE_IDLE;
	else if (state == `STATE_THRU)
		state <= mem_data_ok ? `STATE_IDLE : `STATE_THRU;
	else if (state == `STATE_QUEUED)
		state <= mem_data_ok ? `STATE_IDLE : `STATE_QUEUED;

// Send signals to memory according to FSM
always_comb
	if (state == `STATE_QUEUED || state == `STATE_IDLE && (need_clear_queue || !queue_empty)) begin
		mem_req = queue_req;
		mem_wr = 1'b1;
		mem_size = queue[head_ptr].size;
		mem_addr = queue[head_ptr].addr;
		mem_wdata = queue[head_ptr].wdata;
		mem_dcached = 1'b0;
	end else/* if (state == `STATE_THRU || state == `STATE_IDLE && need_thru)*/ begin
		mem_req = cpu_req;
		mem_wr = cpu_wr;
		mem_size = cpu_size;
		mem_addr = cpu_addr;
		mem_wdata = cpu_wdata;
		mem_dcached = cpu_dcached;
	end

// Send signals to CPU according to FSM
assign cpu_rdata = mem_rdata;

always_comb
	if (need_clear_queue && (state == `STATE_QUEUED || state == `STATE_IDLE)) begin
		cpu_addr_ok = 1'b0;
		cpu_data_ok = 1'b0;
	end else if (need_queue && (state == `STATE_QUEUED || state == `STATE_IDLE)) begin
		cpu_addr_ok = 1'b1;
		cpu_data_ok = 1'b1;
	end else begin
		cpu_addr_ok = mem_addr_ok;
		cpu_data_ok = mem_data_ok;
	end

// Write into queue
always_ff @(posedge clk)
	if (~resetn) begin
		tail_ptr <= '0;
	end else if (!queue_full && need_queue) begin
		queue[tail_ptr].addr <= cpu_addr;
		queue[tail_ptr].size <= cpu_size;
		queue[tail_ptr].wdata <= cpu_wdata;
		tail_ptr <= tail_ptr + 1;
	end

// Read from queue and write into memory
always_ff @(posedge clk)
	if (~resetn) begin
		head_ptr <= '0;
	end else if (state == `STATE_QUEUED && mem_data_ok) begin
		head_ptr <= head_ptr + 1;
	end

sram_like_handshake queue_handshake(
	.clk(clk),
	.rst(~resetn),
	.unique_id({ {32-SIZE_WIDTH{1'd0}}, head_ptr }),
	.need_req(need_clear_queue | ~need_thru & ~queue_empty),
	.busy(),
	.addr_ok(mem_addr_ok),
	.data_ok(mem_data_ok),
	.req(queue_req)
	);


endmodule