`include "iCache.vh"

module iCache_Replacement#(
    parameter TAG_WIDTH    = `ICACHE_T,
              OFFSET_WIDTH = `ICACHE_B,
              LINE_NUM     = `ICACHE_E
)(
    input  logic clk, reset, 
    input  logic hit, state,
    output logic [31 : 0] replaceID 
);
    logic [5 : 0] check;
    
    always_ff @(posedge clk)
       begin
           
        if (~hit) begin
            if (check > 2'b10) check <= check;
            else check <= check + 1;
        end
        else check <= 0;
        if (reset) replaceID <= 1'b0;
        else if (~hit && check == 0) begin
            if (replaceID >= LINE_NUM - 1) replaceID <= 1'b0;
            else replaceID <= replaceID + 1;
        end
       end
endmodule