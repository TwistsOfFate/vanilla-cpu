module axi_interconnect(
    input logic aclk, aresetn,
    
    // incoming AXI from icache (low priority)
    input  logic [3 :0] inst_arid         ,
    input  logic [31:0] inst_araddr       ,
    input  logic [7 :0] inst_arlen        ,
    input  logic [2 :0] inst_arsize       ,
    input  logic [1 :0] inst_arburst      ,
    input  logic [1 :0] inst_arlock       ,
    input  logic [3 :0] inst_arcache      ,
    input  logic [2 :0] inst_arprot       ,
    input  logic        inst_arvalid      ,
    output logic        inst_arready      ,
    //r           
    output logic [3 :0] inst_rid          ,
    output logic [31:0] inst_rdata        ,
    output logic [1 :0] inst_rresp        ,
    output logic        inst_rlast        ,
    output logic        inst_rvalid       ,
    input  logic        inst_rready       ,
    //aw          
    input  logic [3 :0] inst_awid         ,
    input  logic [31:0] inst_awaddr       ,
    input  logic [7 :0] inst_awlen        ,
    input  logic [2 :0] inst_awsize       ,
    input  logic [1 :0] inst_awburst      ,
    input  logic [1 :0] inst_awlock       ,
    input  logic [3 :0] inst_awcache      ,
    input  logic [2 :0] inst_awprot       ,
    input  logic        inst_awvalid      ,
    output logic        inst_awready      ,
    //w          
    input  logic [3 :0] inst_wid          ,
    input  logic [31:0] inst_wdata        ,
    input  logic [3 :0] inst_wstrb        ,
    input  logic        inst_wlast        ,
    input  logic        inst_wvalid       ,
    output logic        inst_wready       ,
    //b           
    output logic [3 :0] inst_bid          ,
    output logic [1 :0] inst_bresp        ,
    output logic        inst_bvalid       ,
    input  logic        inst_bready       ,
    
    // incoming AXI from dcache (high priority)
    input  logic [3 :0] data_arid         ,
    input  logic [31:0] data_araddr       ,
    input  logic [7 :0] data_arlen        ,
    input  logic [2 :0] data_arsize       ,
    input  logic [1 :0] data_arburst      ,
    input  logic [1 :0] data_arlock       ,
    input  logic [3 :0] data_arcache      ,
    input  logic [2 :0] data_arprot       ,
    input  logic        data_arvalid      ,
    output logic        data_arready      ,
    //r           
    output logic [3 :0] data_rid          ,
    output logic [31:0] data_rdata        ,
    output logic [1 :0] data_rresp        ,
    output logic        data_rlast        ,
    output logic        data_rvalid       ,
    input  logic        data_rready       ,
    //aw          
    input  logic [3 :0] data_awid         ,
    input  logic [31:0] data_awaddr       ,
    input  logic [7 :0] data_awlen        ,
    input  logic [2 :0] data_awsize       ,
    input  logic [1 :0] data_awburst      ,
    input  logic [1 :0] data_awlock       ,
    input  logic [3 :0] data_awcache      ,
    input  logic [2 :0] data_awprot       ,
    input  logic        data_awvalid      ,
    output logic        data_awready      ,
    //w          
    input  logic [3 :0] data_wid          ,
    input  logic [31:0] data_wdata        ,
    input  logic [3 :0] data_wstrb        ,
    input  logic        data_wlast        ,
    input  logic        data_wvalid       ,
    output logic        data_wready       ,
    //b           
    output logic [3 :0] data_bid          ,
    output logic [1 :0] data_bresp        ,
    output logic        data_bvalid       ,
    input  logic        data_bready       ,
            
    // outgoing AXI to external mem
    output logic [3 :0] arid   ,
    output logic [31:0] araddr ,
    output logic [7 :0] arlen  ,
    output logic [2 :0] arsize ,
    output logic [1 :0] arburst,
    output logic [1 :0] arlock ,
    output logic [3 :0] arcache,
    output logic [2 :0] arprot ,
    output logic        arvalid,
    input  logic        arready,
    
    input  logic [3 :0] rid    ,
    input  logic [31:0] rdata  ,
    input  logic [1 :0] rresp  ,
    input  logic        rlast  ,
    input  logic        rvalid ,
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
    input  logic        awready,
    
    output logic [3 :0] wid    ,
    output logic [31:0] wdata  ,
    output logic [3 :0] wstrb  ,
    output logic        wlast  ,
    output logic        wvalid ,
    input  logic        wready ,
    
    input  logic [3 :0] bid    ,
    input  logic [1 :0] bresp  ,
    input  logic        bvalid ,
    output logic        bready
);
    
    //////////////////////////
    // READ CHANNEL
    //////////////////////////
    
    // states
    // TODO: maybe we don't need state machines?
    enum logic {AXI_R0, AXI_R1} read_state, next_read_state;
    always_ff @ (posedge aclk)
        if (!aresetn) read_state <= AXI_R0;
        else read_state <= next_read_state;
    always_comb  // R1 (data read) has higher priority
    case (read_state)
        AXI_R0:
            if (rlast & rvalid) begin  // end of a inst read
                if (data_arvalid) next_read_state = AXI_R1;
                else if (inst_arvalid) next_read_state = AXI_R0;
                else next_read_state = AXI_R0;
                 // Inst reads tend to appear consecutively, so we keep AXI_R0 state despite low priority
            end
            else next_read_state = AXI_R0;
        AXI_R1:
            if (rlast & rvalid) begin  // end of a data read
                if (data_arvalid) next_read_state = AXI_R1;
                else if (inst_arvalid) next_read_state = AXI_R0;
                else next_read_state = AXI_R0; 
            end
            else next_read_state = AXI_R1;
    endcase
    
    // valid and ready signals
    always_comb
    case (read_state)
        AXI_R0:
        begin
            arvalid = inst_arvalid;
            rready  = inst_rready;
            
            inst_arready = arready;
            data_arready = 1'b0;
            
            inst_rvalid  = rvalid;
            data_rvalid  = 1'b0;
        end
        AXI_R1:
        begin
            arvalid = data_arvalid;
            rready  = data_rready;
            
            inst_arready = 1'b0;
            data_arready = arready;
            
            inst_rvalid  = 1'b0;
            data_rvalid  = rvalid;
        end
    endcase
    
    // r-signals (slave -> master)
    always_comb
    begin
        inst_rid     = rid; 
        inst_rdata   = rdata;
        inst_rresp   = rresp;
        inst_rlast   = rlast;
        
        data_rid     = rid; 
        data_rdata   = rdata;
        data_rresp   = rresp;
        data_rlast   = rlast;
    end
    
    // ar-signals (master -> slave)
    always_comb
    case (read_state)
        AXI_R0:
        begin
            arid    = inst_arid;
            araddr  = inst_araddr;
            arlen   = inst_arlen;
            arsize  = inst_arsize;
            arburst = inst_arburst;
            arlock  = inst_arlock;
            arcache = inst_arcache;
            arprot  = inst_arprot;
        end
        AXI_R1:
        begin
            arid    = data_arid;
            araddr  = data_araddr;
            arlen   = data_arlen;
            arsize  = data_arsize;
            arburst = data_arburst;
            arlock  = data_arlock;
            arcache = data_arcache;
            arprot  = data_arprot;
        end
    endcase
    
    
    
    
    //////////////////////////
    // WRITE CHANNEL
    //////////////////////////
    // In fact we never write instr, so the write channel can be simplified.
    
    // valid and ready signals
    always_comb
    begin
        awvalid = data_awvalid;
        wvalid  = data_wvalid;
        bready  = data_bready;
        
        inst_awready = 1'b0;
        inst_wready  = 1'b0;
        inst_bvalid  = 1'b0;
        
        data_awready = awready;
        data_wready  = wready ;
        data_bvalid  = bvalid ;
    end
    
    // b-signals (slave -> master)
    always_comb
    begin
        inst_bid     = bid; 
        inst_bresp   = bresp;
        
        data_bid     = bid; 
        data_bresp   = bresp;
    end
    
    // aw-signals, w-signals (master -> slave)
    always_comb
    begin
        awid    = data_awid;
        awaddr  = data_awaddr;
        awlen   = data_awlen;
        awsize  = data_awsize;
        awburst = data_awburst;
        awlock  = data_awlock;
        awcache = data_awcache;
        awprot  = data_awprot;
        
        wid     = data_wid;
        wdata   = data_wdata;
        wstrb   = data_wstrb;
        wlast   = data_wlast;
    end
    
endmodule
