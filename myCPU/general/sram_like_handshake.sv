module sram_like_handshake(
	input clk,
	input rst,
	input [31:0] unique_id,
	input force_req,
	input need_req,
	output busy,

    input addr_ok,
    input data_ok,
	output req
	);

logic [1:0] state;
logic [31:0] unique_id_prev;

always_ff @(posedge clk) begin
	if(rst)
		unique_id_prev <= 32'hffff_ffff;
	else if (req)
		unique_id_prev <= unique_id;
end

always_ff @(posedge clk) begin
	if (rst) begin
		state <= 2'b00;
	end else if (state == 2'b00) begin
        if (req && addr_ok && data_ok)
            state <= 2'b00;
        else if (req && addr_ok && !data_ok)
            state <= 2'b10;
        else if (req && !addr_ok && !data_ok)
            state <= 2'b01;
        else 
            state <= 2'b00;
	end else if (state == 2'b01) begin
		state <= data_ok && addr_ok ? 2'b00 : (addr_ok ? 2'b10 : 2'b01);
	end else if (state == 2'b10) begin
		state <= data_ok ? 2'b00 : 2'b10;
	end
end

assign req = state == 2'b00 ? need_req && (unique_id != unique_id_prev || force_req) :
			 (state == 2'b01 ? 1'b1 : 1'b0);

assign busy = (state == 2'b00 && req || state == 2'b01 || state == 2'b10) && !data_ok;

endmodule