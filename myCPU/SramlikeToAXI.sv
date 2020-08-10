module SramlikeToAXI
(
    input  logic        clk,
    input  logic [3 :0] reqType ,
    input  logic        req     ,
    input  logic        wr      ,
    input  logic [1 :0] size    ,
    input  logic [31:0] addr    ,
    input  logic [31:0] sram_wdata   ,
    output logic [31:0] sram_rdata   ,
    output logic        addr_ok ,
    output logic        data_ok ,
    input  logic [7 :0] burst_len,
    input  logic [2 :0] burst_size,
    input  logic [1 :0] burst_type,
    input  logic        burst_wlast,
    input  logic        addr_awvalid,

    //axi
    //ar
    output logic [3 :0] arid         ,
    output logic [31:0] araddr       ,
    output logic [7 :0] arlen        ,
    output logic [2 :0] arsize       ,
    output logic [1 :0] arburst      ,
    output logic [1 :0] arlock        ,
    output logic [3 :0] arcache      ,
    output logic [2 :0] arprot       ,
    output logic        arvalid      ,
    input  logic        arready      ,
    //r           
    input  logic [31:0] rdata        ,
    input  logic        rvalid       ,
    output logic        rready       ,
    //aw          
    output logic [3 :0] awid         ,
    output logic [31:0] awaddr       ,
    output logic [7 :0] awlen        ,
    output logic [2 :0] awsize       ,
    output logic [1 :0] awburst      ,
    output logic [1 :0] awlock       ,
    output logic [3 :0] awcache      ,
    output logic [2 :0] awprot       ,
    output logic        awvalid      ,
    input  logic        awready      ,
    //w          
    output logic [3 :0] wid          ,
    output logic [31:0] wdata        ,
    output logic [3 :0] wstrb        ,
    output logic        wlast        ,
    output logic        wvalid       ,
    input  logic        wready       ,
    //b           
    output logic        bready       ,
    input  logic        bvalid       ,

    output logic        wb_ok
);

    assign arid = reqType;
    assign araddr = addr;
    assign arlen = burst_len;
    assign arsize = burst_size;
    assign arburst = burst_type;
    assign arlock = '0;
    assign arcache = '0;
    assign arprot = '0;
    assign arvalid = req & !wr;

    assign sram_rdata = rdata;

    always_ff @(posedge clk)
        if (rready) rready <= 1'b0;
        else rready <= rvalid;

    assign awid = 4'b0001;
    assign awaddr = addr;
    assign awlen = burst_len;
    assign awsize = burst_size;
    assign awburst = burst_type;
    assign awlock = '0;
    assign awcache = '0;
    assign awprot = '0;
    assign awvalid = addr_awvalid;

    assign wid = 4'b0001;
    assign wdata = sram_wdata;
    always_comb begin
        case ({size, addr[1 : 0]})
            4'b0000 : wstrb = 4'b0001;
            4'b0001 : wstrb = 4'b0010;
            4'b0010 : wstrb = 4'b0100;
            4'b0011 : wstrb = 4'b1000;
            4'b0100 : wstrb = 4'b0011;
            4'b0110 : wstrb = 4'b1100;
            default : wstrb = 4'b1111;
        endcase
    end
    assign wlast = burst_wlast;
    assign wvalid = req & wr;
    assign bready = 1'b1;

    assign addr_ok = wr ? awvalid & awready : arvalid & arready;
    assign data_ok = wr ? wvalid & wready : rready & rvalid;
    assign wb_ok = wr ? bvalid & bready : data_ok;
endmodule
