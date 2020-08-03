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
  logic [3 :0] inst_arid         ;
  logic [31:0] inst_araddr       ;
  logic [7 :0] inst_arlen        ;
  logic [2 :0] inst_arsize       ;
  logic [1 :0] inst_arburst      ;
  logic [1 :0] inst_arlock        ;
  logic [3 :0] inst_arcache      ;
  logic [2 :0] inst_arprot       ;
  logic        inst_arvalid      ;
  logic         inst_arready      ;
  //r           
  logic  [3 :0] inst_rid          ;
  logic  [31:0] inst_rdata        ;
  logic  [1 :0] inst_rresp        ;
  logic         inst_rlast        ;
  logic         inst_rvalid       ;
  logic        inst_rready       ;
  //aw          
  logic [3 :0] inst_awid         ;
  logic [31:0] inst_awaddr       ;
  logic [7 :0] inst_awlen        ;
  logic [2 :0] inst_awsize       ;
  logic [1 :0] inst_awburst      ;
  logic [1 :0] inst_awlock       ;
  logic [3 :0] inst_awcache      ;
  logic [2 :0] inst_awprot       ;
  logic        inst_awvalid      ;
  logic         inst_awready      ;
  //w          
  logic [3 :0] inst_wid          ;
  logic [31:0] inst_wdata        ;
  logic [3 :0] inst_wstrb        ;
  logic        inst_wlast        ;
  logic        inst_wvalid       ;
  logic         inst_wready       ;
  //b           
  logic  [3 :0] inst_bid          ;
  logic  [1 :0] inst_bresp        ;
  logic         inst_bvalid       ;
  logic        inst_bready       ;

  logic [3 :0] data_arid         ;
  logic [31:0] data_araddr       ;
  logic [7 :0] data_arlen        ;
  logic [2 :0] data_arsize       ;
  logic [1 :0] data_arburst      ;
  logic [1 :0] data_arlock        ;
  logic [3 :0] data_arcache      ;
  logic [2 :0] data_arprot       ;
  logic        data_arvalid      ;
  logic         data_arready      ;
  //r           
  logic  [3 :0] data_rid          ;
  logic  [31:0] data_rdata        ;
  logic  [1 :0] data_rresp        ;
  logic         data_rlast        ;
  logic         data_rvalid       ;
  logic        data_rready       ;
  //aw          
  logic [3 :0] data_awid         ;
  logic [31:0] data_awaddr       ;
  logic [7 :0] data_awlen        ;
  logic [2 :0] data_awsize       ;
  logic [1 :0] data_awburst      ;
  logic [1 :0] data_awlock       ;
  logic [3 :0] data_awcache      ;
  logic [2 :0] data_awprot       ;
  logic        data_awvalid      ;
  logic         data_awready      ;
  //w          
  logic [3 :0] data_wid          ;
  logic [31:0] data_wdata        ;
  logic [3 :0] data_wstrb        ;
  logic        data_wlast        ;
  logic        data_wvalid       ;
  logic         data_wready       ;
  //b           
  logic  [3 :0] data_bid          ;
  logic  [1 :0] data_bresp        ;
  logic         data_bvalid       ;
  logic        data_bready       ;
  
  /*
    axi_interconnect_0 cpu_axi_interconnect(
        aclk, aresetn,
        
        , aclk,
        inst_awid, inst_awaddr, inst_awlen, inst_awsize, inst_awburst, inst_awlock, inst_awcache,
         inst_awprot, , inst_awvalid,  // out
        inst_awready,  // in
        // inst_wid,
        inst_wdata, inst_wstrb, inst_wlast, inst_wvalid,  // out
        inst_wready,  // in
        inst_bid, inst_bresp, inst_bvalid,  // in
        inst_bready,  // out
        inst_arid, inst_araddr, inst_arlen, inst_arsize, inst_arburst, inst_arlock, inst_arcache,
         inst_arprot, , inst_arvalid,  // out from CPU
        inst_arready,  // in to CPU
        inst_rid, inst_rdata, inst_rresp, inst_rlast, inst_rvalid,  // in
        inst_rready,  // out
        
        , aclk,
        data_awid, data_awaddr, data_awlen, data_awsize, data_awburst, data_awlock, data_awcache,
         data_awprot, , data_awvalid, data_awready,
        // data_wid,
        data_wdata, data_wstrb, data_wlast, data_wvalid, data_wready,
        data_bid, data_bresp, data_bvalid, data_bready,
        data_arid, data_araddr, data_arlen, data_arsize, data_arburst, data_arlock, data_arcache,
         data_arprot, , data_arvalid, data_arready,
        data_rid, data_rdata, data_rresp, data_rlast, data_rvalid, data_rready,
        
        , aclk,
        awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, , awvalid, awready,
        // wid,
        wdata, wstrb, wlast, wvalid, wready, 
        bid, bresp, bvalid, bready,
        arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, , arvalid, arready,
        rid, rdata, rresp, rlast, rvalid, rready
    );
  */
  axi_interconnect cpu_axi_interconnect
  (
        aclk, aresetn,
        
        inst_arid, inst_araddr, inst_arlen, inst_arsize, inst_arburst, inst_arlock, inst_arcache,
         inst_arprot, inst_arvalid,  // out from CPU
        inst_arready,  // in to CPU
        inst_rid, inst_rdata, inst_rresp, inst_rlast, inst_rvalid,  // in
        inst_rready,  // out
        inst_awid, inst_awaddr, inst_awlen, inst_awsize, inst_awburst, inst_awlock, inst_awcache,
         inst_awprot, inst_awvalid,  // out
        inst_awready,  // in
        inst_wid, inst_wdata, inst_wstrb, inst_wlast, inst_wvalid,  // out
        inst_wready,  // in
        inst_bid, inst_bresp, inst_bvalid,  // in
        inst_bready,  // out
        
        data_arid, data_araddr, data_arlen, data_arsize, data_arburst, data_arlock, data_arcache,
         data_arprot, data_arvalid, data_arready,
        data_rid, data_rdata, data_rresp, data_rlast, data_rvalid, data_rready,
        data_awid, data_awaddr, data_awlen, data_awsize, data_awburst, data_awlock, data_awcache,
         data_awprot, data_awvalid, data_awready,
        data_wid, data_wdata, data_wstrb, data_wlast, data_wvalid, data_wready,
        data_bid, data_bresp, data_bvalid, data_bready,
        
        arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arvalid, arready,
        rid, rdata, rresp, rlast, rvalid, rready,
        awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awvalid, awready,
        wid, wdata, wstrb, wlast, wvalid, wready, 
        bid, bresp, bvalid, bready
  );
    
    mycpu mycpu(
        aclk, aresetn, ext_int,
        
        inst_arid, inst_araddr, inst_arlen, inst_arsize, inst_arburst, inst_arlock, inst_arcache,
         inst_arprot, inst_arvalid,  // out from CPU
        inst_arready,  // in to CPU
        inst_rid, inst_rdata, inst_rresp, inst_rlast, inst_rvalid,  // in
        inst_rready,  // out
        inst_awid, inst_awaddr, inst_awlen, inst_awsize, inst_awburst, inst_awlock, inst_awcache,
         inst_awprot, inst_awvalid,  // out
        inst_awready,  // in
        inst_wid, inst_wdata, inst_wstrb, inst_wlast, inst_wvalid,  // out
        inst_wready,  // in
        inst_bid, inst_bresp, inst_bvalid,  // in
        inst_bready,  // out
        
        data_arid, data_araddr, data_arlen, data_arsize, data_arburst, data_arlock, data_arcache,
         data_arprot, data_arvalid, data_arready,
        data_rid, data_rdata, data_rresp, data_rlast, data_rvalid, data_rready,
        data_awid, data_awaddr, data_awlen, data_awsize, data_awburst, data_awlock, data_awcache,
         data_awprot, data_awvalid, data_awready,
        data_wid, data_wdata, data_wstrb, data_wlast, data_wvalid, data_wready,
        data_bid, data_bresp, data_bvalid, data_bready,
        
        debug_wb_pc, debug_wb_rf_wen, debug_wb_rf_wnum, debug_wb_rf_wdata
    );
endmodule
