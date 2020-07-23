module mycpu_top (
    input logic[5:0] ext_int,  //high active

    input logic aclk,
    input logic aresetn,   //low active

    output logic [3:0] arid,
    output logic [31:0] araddr,
    output logic [7:0] arlen,
    output logic [2 :0] arsize ,
    output logic [1 :0] arburst,
    output logic [1 :0] arlock ,
    output logic [3 :0] arcache,
    output logic [2 :0] arprot ,
    output logic        arvalid,
    input logic        arready,
    input logic [3 :0] rid    ,
    input logic [31:0] rdata  ,
    input logic [1 :0] rresp  ,
    input logic        rlast  ,
    input logic        rvalid ,
    output logic        rready ,
    output logic [3 :0] awid   ,
    output logic [31:0] awaddr ,
    output logic [7 :0] awlen  ,
    output logic [2 :0] awsize ,
    output logic [1 :0] awburst,
    output logic [1 :0] awlock ,
    output logic [3 :0] awcache,
    output logic [2 :0] awprot ,
    output logic        awvalid,
    input logic        awready,
    output logic [3 :0] wid    ,
    output logic [31:0] wdata  ,
    output logic [3 :0] wstrb  ,
    output logic        wlast  ,
    output logic        wvalid ,
    input logic        wready ,
    input logic [3 :0] bid    ,
    input logic [1 :0] bresp  ,
    input logic        bvalid ,
    output logic        bready ,

    //debug interface
    output logic [31:0] debug_wb_pc,
    output logic [3:0] debug_wb_rf_wen,
    output logic [4:0] debug_wb_rf_wnum,
    output logic [31:0] debug_wb_rf_wdata
);
    logic inst_req, data_req;
    logic inst_wr, data_wr;
    logic [1:0]inst_size, data_size;
    logic [31:0] inst_addr, data_addr;
    logic [31:0] inst_wdata, data_wdata;
    logic [31:0] inst_rdata, data_rdata;
    logic inst_addr_ok, data_addr_ok;
    logic inst_data_ok, data_data_ok;
    cpu_axi_interface cpu_axi_interface(
        .clk(aclk), .resetn(aresetn),
        .inst_req, .inst_wr, .inst_size, .inst_addr, .inst_wdata, .inst_rdata, .inst_addr_ok, .inst_data_ok,
        .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
        .arid, .araddr, .arlen, .arsize, .arburst, .arlock, .arcache, .arprot, .arvalid , .arready,
        .rid, .rdata, .rresp, .rlast, .rvalid, .rready, 
        .awid, .awaddr, .awlen, .awsize, .awburst, .awlock, .awcache, .awprot, .awvalid, .awready,
        .wid, .wdata, .wstrb, .wlast, .wvalid, .wready, 
        .bid, .bresp, .bvalid, .bready
    );
    mycpu mycpu(
        .clk(aclk), .resetn(aresetn), .ext_int,
        .inst_req, .inst_wr, .inst_size, .inst_addr, .inst_wdata, .inst_rdata, .inst_addr_ok, .inst_data_ok,
        .data_req, .data_wr, .data_size, .data_addr, .data_wdata, .data_rdata, .data_addr_ok, .data_data_ok,
        .debug_wb_pc, .debug_wb_rf_wen, .debug_wb_rf_wnum, .debug_wb_rf_wdata
    );
endmodule