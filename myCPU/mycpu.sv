module mycpu(
  input  logic         clk          ,
  input  logic         resetn       ,
  input  logic  [ 5:0] ext_int	  , 

  //inst sram-like 
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
  input  logic         data_data_ok ,
  
  //debug signals
  output logic [31:0]  debug_wb_pc	,
  output logic [ 3:0]  debug_wb_rf_wen,
  output logic [ 4:0]  debug_wb_rf_wnum,
  output logic [31:0]  debug_wb_rf_wdata
); 
    logic inst_cpu_addr_ok, inst_cpu_data_ok, inst_cpu_req_1, inst_cpu_req_2;
    logic [31:0] inst_cpu_addr_1, inst_cpu_addr_2;
    logic [31:0] inst_cpu_rdata_1, inst_cpu_rdata_2;
    logic second_data_ok;

    logic data_cache_req, data_cache_wr, data_cache_data_ok, data_cache_addr_ok;
    logic [31:0] data_cache_addr;
    logic [31:0] data_cache_wdata;
    logic [31:0] data_cache_rdata;

    logic data_cpu_addr_ok, data_cpu_data_ok, data_cpu_req, data_cpu_wr;
    logic [ 1:0] data_cpu_size;
    logic [31:0] data_cpu_addr;
    logic [31:0] data_cpu_rdata;
    logic [31:0] data_cpu_wdata;

    logic icached, dcached;
    
    // TODO : adjust following ports -- inst_rdata_1, inst_rdata_2, inst_addr_1, inst_addr_2, second_data_ok
    mypipeline mypipeline(
        .clk                (clk)               ,
        .resetn             (resetn)            ,
        .ext_int            (ext_int)           ,
        .inst_req_1         (inst_cpu_req_1)    ,
        .inst_req_2         (inst_cpu_req_2)    ,
        .inst_wr            (inst_wr)           ,
        .inst_size          (inst_size)         , 
        .inst_addr_1        (inst_cpu_addr_1)   , // new
        .inst_addr_2        (inst_cpu_addr_2)   , // new
        .inst_wdata         (inst_wdata)        , 
        .inst_rdata_1       (inst_cpu_rdata_1)  , // new
        .inst_rdata_2       (inst_cpu_rdata_2)  , // new
        .second_data_ok     (second_data_ok)    , // new
        .inst_addr_ok       (inst_cpu_addr_ok)  , 
        .inst_data_ok       (inst_cpu_data_ok)  ,
        .data_req           (data_cpu_req)      , 
        .data_wr            (data_cpu_wr)       , 
        .data_size          (data_cpu_size)     , 
        .data_addr          (data_cpu_addr)     , 
        .data_wdata         (data_cpu_wdata)    , 
        .data_rdata         (data_cpu_rdata)    , 
        .data_addr_ok       (data_cpu_addr_ok)  , 
        .data_data_ok       (data_cpu_data_ok)  ,
        .debug_wb_pc        (debug_wb_pc)       , 
        .debug_wb_rf_wen    (debug_wb_rf_wen)   , 
        .debug_wb_rf_wnum   (debug_wb_rf_wnum)  , 
        .debug_wb_rf_wdata  (debug_wb_rf_wdata) ,
        .icached            (icached)           ,
        .dcached            (dcached)
    );

    iCache icache(
        .clk                (clk)               ,
        .reset              (~resetn)           ,
        .cpu_req_1          (inst_cpu_req_1)    ,
        .cpu_req_2          (inst_cpu_req_2)    ,
        .instr_addr_1       (inst_cpu_addr_1)   , // new
        .instr_addr_2       (inst_cpu_addr_2)   , // new
        .instr_rdata_1      (inst_cpu_rdata_1)  , // new
        .instr_rdata_2      (inst_cpu_rdata_2)  , // new
        .second_data_ok     (second_data_ok)    , // new
        .cpu_addr_ok        (inst_cpu_addr_ok)  ,
        .cpu_data_ok        (inst_cpu_data_ok)  ,
        .mem_req            (inst_req)          ,
        .mem_read_addr      (inst_addr)         ,
        .mem_read_data      (inst_rdata)        ,
        .mem_addr_ok        (inst_addr_ok)      ,
        .mem_data_ok        (inst_data_ok)
    ); 

    dCache dcache(
        .clk                (clk)               ,
        .reset              (~resetn)           ,
        .cpu_req            (data_cpu_req & dcached)      ,
        .wr                 (data_cpu_wr)       ,
        .size               (data_cpu_size)     ,
        .data_addr          (data_cpu_addr)     ,
        .wdata              (data_cpu_wdata)    ,
        .data_rdata         (data_cache_rdata)    ,
        .cpu_addr_ok        (data_cache_addr_ok)  ,
        .cpu_data_ok        (data_cache_data_ok)  ,
        .mem_req            (data_cache_req)          ,
        .mem_wen            (data_cache_wr)           ,
        .mem_addr           (data_cache_addr)         ,
        .mem_wdata          (data_cache_wdata)        ,
        .mem_rdata          (data_rdata)        ,
        .mem_addr_ok        (data_addr_ok)      ,
        .mem_data_ok        (data_data_ok)
    );

    mux2 #(2) mem_size_mux2(data_cpu_size, 2'b10, dcached, data_size);
    mux2 #(1) mem_req_mux2(data_cpu_req, data_cache_req, dcached, data_req);
    mux2 #(1) mem_wen_mux2(data_cpu_wr, data_cache_wr, dcached, data_wr);
    mux2 #(32) mem_addr_mux2(data_cpu_addr, data_cache_addr, dcached, data_addr);
    mux2 #(32) mem_wdata_mux2(data_cpu_wdata, data_cache_wdata, dcached, data_wdata);
    mux2 #(1) cpu_data_ok_mux2(data_data_ok, data_cache_data_ok, dcached, data_cpu_data_ok);
    mux2 #(1) cpu_addr_ok_mux2(data_addr_ok, data_cache_addr_ok, dcached, data_cpu_addr_ok);
    mux2 #(32) cpu_rdata_mux2(data_rdata, data_cache_rdata, dcached, data_cpu_rdata);

// assign data_req = data_cpu_req;
// assign data_wr = data_cpu_wr;
// assign data_size = data_cpu_size;
// assign data_wdata = data_cpu_wdata;
// assign data_addr = data_cpu_addr;
// assign data_cpu_rdata = data_rdata;
// assign data_cpu_addr_ok = data_addr_ok;
// assign data_cpu_data_ok = data_data_ok;

endmodule