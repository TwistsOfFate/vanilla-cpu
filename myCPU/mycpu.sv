`include "iCache.vh"
`include "dCache.vh"
`include "cpu_defs.svh"

module mycpu #(
    parameter ICACHE_BURST_LEN = 2 ** (`ICACHE_B - 2),
              DCACHE_BURST_LEN = 2 ** (`DCACHE_B - 2)
)(
  input  logic         clk          ,
  input  logic         resetn       ,
  input  logic  [ 5:0] ext_int	  , 

  output [3 :0] inst_arid         ,
  output [31:0] inst_araddr       ,
  output [7 :0] inst_arlen        ,
  output [2 :0] inst_arsize       ,
  output [1 :0] inst_arburst      ,
  output [1 :0] inst_arlock        ,
  output [3 :0] inst_arcache      ,
  output [2 :0] inst_arprot       ,
  output        inst_arvalid      ,
  input         inst_arready      ,
  //r           
  input  [3 :0] inst_rid          ,
  input  [31:0] inst_rdata        ,
  input  [1 :0] inst_rresp        ,
  input         inst_rlast        ,
  input         inst_rvalid       ,
  output        inst_rready       ,
  //aw          
  output [3 :0] inst_awid         ,
  output [31:0] inst_awaddr       ,
  output [7 :0] inst_awlen        ,
  output [2 :0] inst_awsize       ,
  output [1 :0] inst_awburst      ,
  output [1 :0] inst_awlock       ,
  output [3 :0] inst_awcache      ,
  output [2 :0] inst_awprot       ,
  output        inst_awvalid      ,
  input         inst_awready      ,
  //w          
  output [3 :0] inst_wid          ,
  output [31:0] inst_wdata        ,
  output [3 :0] inst_wstrb        ,
  output        inst_wlast        ,
  output        inst_wvalid       ,
  input         inst_wready       ,
  //b           
  input  [3 :0] inst_bid          ,
  input  [1 :0] inst_bresp        ,
  input         inst_bvalid       ,
  output        inst_bready       ,

  output [3 :0] data_arid         ,
  output [31:0] data_araddr       ,
  output [7 :0] data_arlen        ,
  output [2 :0] data_arsize       ,
  output [1 :0] data_arburst      ,
  output [1 :0] data_arlock        ,
  output [3 :0] data_arcache      ,
  output [2 :0] data_arprot       ,
  output        data_arvalid      ,
  input         data_arready      ,
  //r           
  input  [3 :0] data_rid          ,
  input  [31:0] data_rdata        ,
  input  [1 :0] data_rresp        ,
  input         data_rlast        ,
  input         data_rvalid       ,
  output        data_rready       ,
  //aw          
  output [3 :0] data_awid         ,
  output [31:0] data_awaddr       ,
  output [7 :0] data_awlen        ,
  output [2 :0] data_awsize       ,
  output [1 :0] data_awburst      ,
  output [1 :0] data_awlock       ,
  output [3 :0] data_awcache      ,
  output [2 :0] data_awprot       ,
  output        data_awvalid      ,
  input         data_awready      ,
  //w          
  output [3 :0] data_wid          ,
  output [31:0] data_wdata        ,
  output [3 :0] data_wstrb        ,
  output        data_wlast        ,
  output        data_wvalid       ,
  input         data_wready       ,
  //b           
  input  [3 :0] data_bid          ,
  input  [1 :0] data_bresp        ,
  input         data_bvalid       ,
  output        data_bready       ,
/*  //inst sram-like 
  output logic         inst_req     ,
  output logic         inst_wr      ,
  output logic  [ 1:0] inst_size    ,
  output logic  [31:0] inst_addr    ,
  output logic  [31:0] inst_wdata   ,
  
  input  logic  [31:0] inst_rdata   ,
  input  logic         inst_addr_ok ,
  input  logic         inst_data_ok ,
  
  
  //data sram-like 
  output logic         data_req     ,
  output logic         data_wr      ,
  output logic  [ 1:0] data_size    ,
  output logic  [31:0] data_addr    ,
  output logic  [31:0] data_wdata   ,
  
  input  logic  [31:0] data_rdata   ,
  input  logic         data_addr_ok ,
  input  logic         data_data_ok ,*/
  
  //debug signals
  output logic [31:0]  debug_wb_pc	,
  output logic [ 3:0]  debug_wb_rf_wen,
  output logic [ 4:0]  debug_wb_rf_wnum,
  output logic [31:0]  debug_wb_rf_wdata
); 

    logic icached, dcached;
    logic inst_wb_ok, data_wb_ok;
    logic inst_cpu_cache_req, data_cpu_cache_req;
    logic inst_cpu_mem_req, data_cpu_mem_req;

    logic dcache_wlast, data_burst_wlast;
    logic data_cache_awvalid, data_mem_awvalid;
    logic [7 :0] icache_burst_len, inst_burst_len;
    logic [7 :0] dcache_burst_len, data_burst_len;

    logic [31:0] inst_mem_rdata, data_mem_rdata, data_mem_wdata;

    logic inst_cache_addr_ok, inst_cache_data_ok, inst_cache_req;
    logic [31:0] inst_cache_addr;
    logic [31:0] inst_cache_rdata;

    logic inst_cpu_addr_ok, inst_cpu_data_ok, inst_cpu_req;
    // logic [31:0] inst_cpu_addr;
    logic [31:0] inst_cpu_vaddr, inst_cpu_paddr;
    logic [31:0] inst_cpu_rdata;

    logic data_cache_req, data_cache_wr, data_cache_data_ok, data_cache_addr_ok;
    logic [31:0] data_cache_addr;
    logic [31:0] data_cache_wdata;
    logic [31:0] data_cache_rdata;

    logic data_cpu_addr_ok, data_cpu_data_ok, data_cpu_req, data_cpu_wr;
    logic [ 1:0] data_cpu_size;
    // logic [31:0] data_cpu_addr;
    logic [31:0] data_cpu_vaddr, data_cpu_paddr;
    logic [31:0] data_cpu_rdata;
    logic [31:0] data_cpu_wdata;

    logic inst_req, inst_wr, inst_addr_ok, inst_data_ok;
    logic [ 1:0] inst_size;
    logic [31:0] inst_addr;
    
    logic data_req, data_wr, data_addr_ok, data_data_ok;
    logic [ 1:0] data_size;
    logic [31:0] data_addr;

    logic [31:0] inst_EntryHi, inst_EntryLo0, inst_EntryLo1;
    logic [31:0] data_EntryHi, data_EntryLo0, data_EntryLo1;

    logic inst_unmapped_uncached, inst_unmapped_cached, inst_unmapped, inst_TLB_cached, inst_TLB_uncached;
    logic data_unmapped_uncached, data_unmapped_cached, data_unmapped, data_TLB_cached, data_TLB_uncached;
    logic inst_TLBInvalid, inst_TLBModified, inst_TLBMiss, inst_TLB_done;
    logic data_TLBInvalid, data_TLBModified, data_TLBMiss, data_TLB_done;

    tlb_exc_t inst_err, data_err;
    tlb_t inst_info, data_info, inst_res, data_res;
    tlb_req_t tlb_req;
    logic tlb_ok;

    assign icache_burst_len = ICACHE_BURST_LEN - 1;
    assign dcache_burst_len = DCACHE_BURST_LEN - 1;

    mypipeline mypipeline(
        .clk                (clk)               ,
        .resetn             (resetn)            ,
        .ext_int            (ext_int)           ,
        .inst_req           (inst_cpu_req)      ,
        .inst_wr            (inst_wr)           ,
        .inst_size          (inst_size)         , 
        .inst_addr          (inst_cpu_vaddr)     , 
        .inst_wdata         (inst_wdata)        , 
        .inst_rdata         (inst_cpu_rdata)    , 
        .inst_addr_ok       (inst_cpu_addr_ok)  , 
        .inst_data_ok       (inst_cpu_data_ok)  ,
        .data_req           (data_cpu_req)      , 
        .data_wr            (data_cpu_wr)       , 
        .data_size          (data_cpu_size)     , 
        .data_addr          (data_cpu_vaddr)     , 
        .data_wdata         (data_cpu_wdata)    , 
        .data_rdata         (data_cpu_rdata)    , 
        .data_addr_ok       (data_cpu_addr_ok)  , 
        .data_data_ok       (data_cpu_data_ok)  ,
        .f_tlb_exc_if       (inst_err)          ,
        .m_tlb_exc_mem      (data_err),
        .m_read_tlb         (data_res),
        .m_write_tlb        (data_info),
        .tlb_req            (tlb_req),
        .m_tlb_ok           (tlb_ok),
        .debug_wb_pc        (debug_wb_pc)       , 
        .debug_wb_rf_wen    (debug_wb_rf_wen)   , 
        .debug_wb_rf_wnum   (debug_wb_rf_wnum)  , 
        .debug_wb_rf_wdata  (debug_wb_rf_wdata) ,
        .icached            ()           ,
        .dcached            ()
    );

    // mmu immu(inst_cpu_vaddr, inst_cpu_paddr, icached);
    // mmu dmmu(data_cpu_vaddr, data_cpu_paddr, dcached);

    TLB TLB(
        .clk                      (clk)                     ,

        .inst_vaddr               (inst_cpu_vaddr)          ,
        .inst_info                (inst_info)               ,
        .inst_req                 (inst_cpu_req)            ,
        .inst_res                 (inst_res)                ,
        .inst_err                 (inst_err)                ,
        .inst_paddr               (inst_cpu_paddr)          ,
        .inst_unmapped_uncached   (inst_unmapped_uncached)  ,
        .inst_unmapped_cached     (inst_unmapped_cached)    ,
        .inst_unmapped            (inst_unmapped)           ,
        .inst_TLB_cached          (inst_TLB_cached)         ,
        .inst_TLB_uncached        (inst_TLB_uncached)       ,
        .inst_TLB_done            (inst_TLB_done)           ,

        .data_vaddr               (data_cpu_vaddr)          ,
        .data_info                (data_info)               ,
        .data_req                 (data_cpu_req)            ,
        .data_wr                  (data_cpu_wr)             ,
        .data_res                 (data_res)                ,
        .data_err                 (data_err)                ,
        .data_paddr               (data_cpu_paddr)          ,
        .data_unmapped_uncached   (data_unmapped_uncached)  ,
        .data_unmapped_cached     (data_unmapped_cached)    ,
        .data_unmapped            (data_unmapped)           ,
        .data_TLB_cached          (data_TLB_cached)         ,
        .data_TLB_uncached        (data_TLB_uncached)       ,
        .data_TLB_done            (data_TLB_done)           ,
        .tlb_ok                   (tlb_ok)                  ,
        .tlb_req                  (tlb_req)
    );

    assign icached = inst_unmapped_cached; //~inst_unmapped_uncached;//inst_unmapped_cached || inst_TLB_cached;
    assign dcached = data_unmapped_cached; //~data_unmapped_uncached;//data_unmapped_cached || data_TLB_cached;

    assign inst_cpu_cache_req = inst_cpu_req & icached;// & (inst_unmapped_cached || (inst_TLB_done && ~inst_unmapped_cached && inst_err == NO_EXC));
    assign data_cpu_cache_req = data_cpu_req & dcached;// & (data_unmapped_cached || (data_TLB_done && ~data_unmapped_cached && data_err == NO_EXC));

    assign inst_cpu_mem_req = inst_cpu_req & (!icached) & (inst_unmapped_uncached || (inst_TLB_done && ~inst_unmapped_uncached && inst_err == NO_EXC));
    assign data_cpu_mem_req = data_cpu_req & (!dcached) & (data_unmapped_uncached || (data_TLB_done && ~data_unmapped_uncached && data_err == NO_EXC));

    // assign inst_cpu_cache_req = inst_cpu_req & icached;
    // assign data_cpu_cache_req = data_cpu_req & dcached;

    iCache icache(
        .clk                (clk)               ,
        .reset              (~resetn)           ,
        .cpu_req            (inst_cpu_cache_req)      ,
        .instr_addr         (inst_cpu_paddr)     ,
        .instr_rdata        (inst_cache_rdata)    ,
        .cpu_addr_ok        (inst_cache_addr_ok)  ,
        .cpu_data_ok        (inst_cache_data_ok)  ,
        .mem_req            (inst_cache_req)          ,
        .mem_read_addr      (inst_cache_addr)         ,
        .mem_read_data      (inst_mem_rdata)        ,
        .mem_addr_ok        (inst_addr_ok)      ,
        .mem_data_ok        (inst_data_ok)
    ); 

    mux2 #(1) i_mem_req_mux2(inst_cpu_req, inst_cache_req, icached, inst_req);
    mux2 #(32) i_mem_addr_mux2(inst_cpu_paddr, inst_cache_addr, icached, inst_addr);
    mux2 #(1) i_cpu_data_ok_mux2(inst_err == NO_EXC ? inst_data_ok : 1'b1, inst_err == NO_EXC ? inst_cache_data_ok : 1'b1, icached, inst_cpu_data_ok);
    mux2 #(1) i_cpu_addr_ok_mux2(inst_err == NO_EXC ? inst_addr_ok : 1'b1, inst_err == NO_EXC ? inst_cache_addr_ok : 1'b1, icached, inst_cpu_addr_ok);
    mux2 #(32) i_cpu_rdata_mux2(inst_mem_rdata, inst_cache_rdata, icached, inst_cpu_rdata);
    mux2 #(8) i_burst_len_mux2(8'b0, icache_burst_len, icached, inst_burst_len);

    dCache dcache(
        .clk                (clk)               ,
        .reset              (~resetn)           ,
        .cpu_req            (data_cpu_cache_req)      ,
        .wr                 (data_cpu_wr)       ,
        .size               (data_cpu_size)     ,
        .data_addr          (data_cpu_paddr)     ,
        .wdata              (data_cpu_wdata)    ,
        .data_rdata         (data_cache_rdata)    ,
        .cpu_addr_ok        (data_cache_addr_ok)  ,
        .cpu_data_ok        (data_cache_data_ok)  ,
        .mem_req            (data_cache_req)          ,
        .mem_wen            (data_cache_wr)           ,
        .mem_addr           (data_cache_addr)         ,
        .mem_wdata          (data_cache_wdata)        ,
        .mem_rdata          (data_mem_rdata)        ,
        .mem_addr_ok        (data_addr_ok)      ,
        .mem_data_ok        (data_data_ok)      ,
        .wlast              (dcache_wlast)      ,
        .awvalid            (data_cache_awvalid)
    );

    mux2 #(2) d_mem_size_mux2(data_cpu_size, 2'b10, dcached, data_size);
    mux2 #(1) d_mem_req_mux2(data_cpu_req, data_cache_req, dcached, data_req);
    mux2 #(1) d_mem_wen_mux2(data_cpu_wr, data_cache_wr, dcached, data_wr);
    mux2 #(32) d_mem_addr_mux2(data_cpu_paddr, data_cache_addr, dcached, data_addr);
    mux2 #(32) d_mem_wdata_mux2(data_cpu_wdata, data_cache_wdata, dcached, data_mem_wdata);
    // mux2 #(1) d_cpu_data_ok_mux2(data_data_ok, data_cache_data_ok, dcached, data_cpu_data_ok);
    // mux2 #(1) d_cpu_addr_ok_mux2(data_addr_ok, data_cache_addr_ok, dcached, data_cpu_addr_ok);

    mux2 #(1) d_cpu_data_ok_mux2(data_err == NO_EXC ? data_wb_ok : 1'b1, data_err == NO_EXC ? data_cache_data_ok : 1'b1, dcached, data_cpu_data_ok);
    mux2 #(1) d_cpu_addr_ok_mux2(data_err == NO_EXC ? data_addr_ok : 1'b1, data_err == NO_EXC ? data_cache_addr_ok : 1'b1, dcached, data_cpu_addr_ok);
    mux2 #(32) d_cpu_rdata_mux2(data_mem_rdata, data_cache_rdata, dcached, data_cpu_rdata);
    mux2 #(8) d_burst_len_mux2(8'b0, dcache_burst_len, dcached, data_burst_len);
    mux2 #(1) d_burst_wlast_mux2(1'b1, dcache_wlast, dcached, data_burst_wlast);
    mux2 #(1) d_burst_wvalid_mux2(data_req & data_wr, data_cache_awvalid, dcached, data_mem_awvalid);
//assign data_burst_wlast = 1'b1;
    // assign data_size = data_cpu_size;
    // assign data_req = data_cpu_req;
    // assign data_wr = data_cpu_wr;
    // assign data_addr = data_cpu_addr;
    // assign data_mem_wdata = data_cpu_wdata;
    // assign data_cpu_data_ok = data_data_ok;
    // assign data_cpu_addr_ok = data_addr_ok;
    // assign data_cpu_rdata = data_mem_rdata; 

    SramlikeToAXI inst_axi(
        .clk                  (clk),
        .reqType              (4'b0000),
        .req                  (inst_req)      ,
        .wr                   (inst_wr)           ,
        .size                 (inst_size)         , 
        .addr                 (inst_addr)     , 
        .sram_wdata           (32'b0)    , 
        .sram_rdata           (inst_mem_rdata)    , 
        .addr_ok              (inst_addr_ok)  , 
        .data_ok              (inst_data_ok)  ,
        .burst_len            (inst_burst_len),
        .burst_size           ({1'b0, inst_size}),
        .burst_type           (2'b01),
        .burst_wlast          (1'b1),
        .addr_awvalid         (1'b0),

        .arid                 (inst_arid),
        .araddr               (inst_araddr),
        .arlen                (inst_arlen),
        .arsize               (inst_arsize),
        .arburst              (inst_arburst),
        .arlock               (inst_arlock),
        .arcache              (inst_arcache),
        .arprot               (inst_arprot),
        .arvalid              (inst_arvalid),
        .arready              (inst_arready),
        
        .rdata                (inst_rdata),
        .rvalid               (inst_rvalid),
        .rready               (inst_rready),
        
        .awid                 (inst_awid),
        .awaddr               (inst_awaddr),
        .awlen                (inst_awlen),
        .awsize               (inst_awsize),
        .awburst              (inst_awburst),
        .awlock               (inst_awlock),
        .awcache              (inst_awcache),
        .awprot               (inst_awprot),
        .awvalid              (inst_awvalid),
        .awready              (inst_awready),
        
        .wid                  (inst_wid),
        .wdata                (inst_wdata),
        .wstrb                (inst_wstrb),
        .wlast                (inst_wlast),
        .wvalid               (inst_wvalid),
        .wready               (inst_wready),
        
        .bready               (inst_bready),
        .bvalid               (inst_bvalid),

        .wb_ok                (inst_wb_ok)
    );

    SramlikeToAXI data_axi(
        .clk                  (clk)               ,
        .reqType              (4'b0001),
        .req                  (data_req)      ,
        .wr                   (data_wr)           ,
        .size                 (data_size)         , 
        .addr                 (data_addr)     , 
        .sram_wdata           (data_mem_wdata)    , 
        .sram_rdata           (data_mem_rdata)    , 
        .addr_ok              (data_addr_ok)  , 
        .data_ok              (data_data_ok)  ,
        .burst_len            (data_burst_len),
        .burst_size           ({1'b0, data_size}),
        .burst_type           (2'b01),
        .burst_wlast          (data_burst_wlast),
        .addr_awvalid         (data_mem_awvalid),

        .arid                 (data_arid),
        .araddr               (data_araddr),
        .arlen                (data_arlen),
        .arsize               (data_arsize),
        .arburst              (data_arburst),
        .arlock               (data_arlock),
        .arcache              (data_arcache),
        .arprot               (data_arprot),
        .arvalid              (data_arvalid),
        .arready              (data_arready),
        
        .rdata                (data_rdata),
        .rvalid               (data_rvalid),
        .rready               (data_rready),
        
        .awid                 (data_awid),
        .awaddr               (data_awaddr),
        .awlen                (data_awlen),
        .awsize               (data_awsize),
        .awburst              (data_awburst),
        .awlock               (data_awlock),
        .awcache              (data_awcache),
        .awprot               (data_awprot),
        .awvalid              (data_awvalid),
        .awready              (data_awready),
        
        .wid                  (data_wid),
        .wdata                (data_wdata),
        .wstrb                (data_wstrb),
        .wlast                (data_wlast),
        .wvalid               (data_wvalid),
        .wready               (data_wready),
        
        .bready               (data_bready),
        .bvalid               (data_bvalid),

        .wb_ok                (data_wb_ok)
    );

endmodule