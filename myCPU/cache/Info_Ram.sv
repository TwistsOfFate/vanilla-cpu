module dcache_Info_Ram #(
    parameter DATA_WIDTH   = 32,
              ADDR_WIDTH   = 4
)(
    input  logic                         clk, reset, flush,
    input  logic [ADDR_WIDTH - 1 : 0]    addr,
    input  logic                         new_valid,
    input  logic [DATA_WIDTH - 1 : 0]    din,
    output logic                         now_valid,
    output logic [DATA_WIDTH - 1 : 0]    wdata,
    output logic [31 : 0]                now_visit,
    input  logic                         en, wen
);
    logic [DATA_WIDTH - 1 : 0] RAM[2 ** ADDR_WIDTH - 1 : 0];
    logic [2 ** ADDR_WIDTH - 1 : 0] valid;
    logic [31 : 0] visit[2 ** ADDR_WIDTH - 1 : 0];

    assign wdata = RAM[addr];
    assign now_valid = valid[addr];
    assign now_visit = visit[addr];

    always_ff @(posedge clk)
        if (reset) begin
            valid <= '0;
        end else begin
            if (en && wen) valid[addr] <= new_valid;
        end
    
    always_ff @(posedge clk)
        if (flush) visit[addr] <= 0; 
        else if (en && wen) visit[addr] <= visit[addr] + 1;
    
    always_ff @(posedge clk)
        if (en && wen) RAM[addr] <= din;

endmodule

module icache_Info_Ram #(
    parameter DATA_WIDTH   = 32,
              ADDR_WIDTH   = 4
)(
    input  logic                         clk, reset,
    input  logic [ADDR_WIDTH - 1 : 0]    addr,
    input  logic                         new_valid,
    input  logic [DATA_WIDTH - 1 : 0]    din,
    output logic                         now_valid,
    output logic [DATA_WIDTH - 1 : 0]    wdata,
    input  logic                         wen
);
    logic [DATA_WIDTH - 1 : 0] RAM[2 ** ADDR_WIDTH - 1 : 0];
    logic [2 ** ADDR_WIDTH - 1 : 0] valid;

    assign wdata = RAM[addr];
    assign now_valid = valid[addr];

    always_ff @(posedge clk)
        if (reset) begin
          valid <= '0;
        end else if (wen) begin
          RAM[addr] <= din;
          valid[addr] <= new_valid;
        end

endmodule