module setdelayslot(
    input  logic        clk   , 
    input  logic        reset,

    input  logic        en    ,
    input  logic [31:0] addr  ,

    output logic        delayslot_sig  ,
    output logic [31:0] delayslot_addr
 
    );

always_comb
begin
    if(reset)
    begin
        delayslot_sig  = 0     ;
        delayslot_addr = 32'b0 ; 
    end
    else if(en)
    begin
        delayslot_addr = addr  ;
        delayslot_sig  = 1     ;
    end
    else
    begin
        delayslot_addr = delayslot_addr ;
        delayslot_sig  = 0  ;
    end

end




endmodule    