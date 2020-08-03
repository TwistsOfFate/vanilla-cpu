`include "dCache.vh"

module dCache_Replacement#(
    parameter TAG_WIDTH    = `DCACHE_T,
              OFFSET_WIDTH = `DCACHE_B,
              LINE_NUM     = `DCACHE_E
)(
    input  logic clk, reset, cpu_req,
    input  logic hit, 
    input  logic [ 1 : 0] state,
    output logic [31 : 0] replaceID 
);
    logic [5 : 0] check;
    
    always_ff @(posedge clk)
        begin
            if (hit) begin
                if (check > 2'b10) check <= check;
                else check <= check + 1;
            end else check <= 0;
            if (reset) replaceID <= '0;
            else if (cpu_req && hit && check == 0) begin
                if (replaceID >= LINE_NUM - 1) replaceID <= '0;
                else replaceID <= replaceID + 1;
            end else replaceID <= replaceID;
        end
endmodule