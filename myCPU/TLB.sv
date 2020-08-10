module TLB #(
    parameter TLBEntries = 32
)(
    input  logic        clk,

    input  logic [31:0]	inst_vaddr,
    input  tlb_t        inst_info,
    input  tlb_req_t    inst_req,
    output tlb_t        inst_res,
    output tlb_exc_t    inst_err,
    output logic [31:0] inst_paddr,

    input  logic [31:0]	data_vaddr,
    input  tlb_t        data_info,
    input  tlb_req_t    data_req,
    output tlb_t        data_res,
    output tlb_exc_t    data_err,
    output logic [31:0] data_paddr,
    // input  logic [26:0] inst_EntryHi,
    // output logic [24:0] inst_EntryLo0,
    // output logic [24:0] inst_EntryLo1,
    // input  logic        inst_wr,
    // output logic [31:0]	inst_paddr,
    // output logic        inst_unmapped_uncached,
    // output logic        inst_unmapped_cached,
    // output logic        inst_unmapped,
    // output logic        inst_TLBInvalid,
    // output logic        inst_TLBModified,
    // output logic        inst_TLBMiss,
    output logic        inst_TLB_done,

    // input  logic [31:0]	data_vaddr,
    // input  logic [26:0] data_EntryHi,
    // output logic [24:0] data_EntryLo0,
    // output logic [24:0] data_EntryLo1,
    // input  logic        data_wr,
    // output logic [31:0]	data_paddr,
    // output logic        data_unmapped_uncached,
    // output logic        data_unmapped_cached,
    // output logic        data_unmapped,
    // output logic        data_TLBInvalid,
    // output logic        data_TLBModified,
    // output logic        data_TLBMiss,
    output logic        data_TLB_done
    
);

    logic [ 7 : 0] inst_EntryHi_ASID, data_EntryHi_ASID;

    logic [18 : 0] TLB_VPN2[TLBEntries - 1 : 0];
    logic [ 7 : 0] TLB_ASID[TLBEntries - 1 : 0];
    logic [TLBEntries - 1 : 0] TLB_G;
    logic [19 : 0] TLB_PFN0[TLBEntries - 1 : 0];
    logic [ 2 : 0] TLB_C0[TLBEntries - 1 : 0];
    logic [TLBEntries - 1 : 0] TLB_D0, TLB_V0;
    logic [19 : 0] TLB_PFN1[TLBEntries - 1 : 0];
    logic [ 2 : 0] TLB_C1[TLBEntries - 1 : 0];
    logic [TLBEntries - 1 : 0] TLB_D1, TLB_V1;

    logic [19 : 0] inst_pfn, data_pfn;
    logic [ 2 : 0] inst_c, data_c;
    logic inst_v, inst_d, data_v, data_d;
    logic inst_found, data_found;

    always_comb 
        if (inst_vaddr < 32'h8000_0000) begin					//kuseg
            inst_paddr = {inst_pfn[19 : 0], inst_vaddr[11 : 0]};
            inst_unmapped_uncached <= 1'b0;
            inst_unmapped_cached <= 1'b0;
            inst_unmapped <= 1'b0;
        end else if (inst_vaddr < 32'hA000_0000) begin			//kseg0
            inst_paddr = inst_vaddr - 32'h8000_0000;
            inst_unmapped_uncached <= 1'b0;
            inst_unmapped_cached <= 1'b1;
            inst_unmapped <= 1'b1;
        end else if (inst_vaddr < 32'hC000_0000) begin			//kseg1
            inst_paddr = inst_vaddr - 32'hA000_0000;
            inst_unmapped_uncached <= 1'b1;
            inst_unmapped_cached <= 1'b0;
            inst_unmapped <= 1'b1;
        end else begin										//kseg2, kseg3
            inst_paddr = {inst_pfn[19 : 0], inst_vaddr[11 : 0]};
            inst_unmapped_uncached <= 1'b0;
            inst_unmapped_cached <= 1'b0;
            inst_unmapped <= 1'b0;
        end
    
    assign inst_EntryHi_ASID = inst_info.entryhi[7 : 0];

    logic inst_state;
    
    always_ff @(posedge clk)
        if (inst_unmapped) begin
            inst_state <= 1'b0;
            inst_TLB_done <= 1'b1;
        end else begin
            inst_state <= 1'b1;
            case (inst_tlb_req_t)
                TLBR : begin
                    if (inst_info.index < TLBEntries) begin
                        inst_res.pagemask = '0;
                        inst_res.entryhi = {TLB_VPN2[inst_info.index], 5'b0, TLB_ASID[inst_info.index]};
                        inst_res.entrylo1 = {2'b0, TLB_PFN1[inst_info.index], TLB_C1[inst_info.index], TLB_D1[inst_info.index], TLB_V1[inst_info.index], TLB_G[inst_info.index]}; inst_res.entrylo0 = {2'b0, TLB_PFN0[inst_info.index], TLB_C0[inst_info.index], TLB_D0[inst_info.index], TLB_V0[inst_info.index], TLB_G[inst_info.index]};
                    end
                end
                TLBWI : begin
                    TLB_VPN2[inst_info.index] = inst_info.entryhi[31:13];
                    TLB_ASID[inst_info.index] = inst_info.entryhi[7:0];
                    TLB_G[inst_info.index] = inst_info.entrylo1[0] & inst_info.entrylo0[0];
                    TLB_PFN1[inst_info.index] = inst_info.entrylo1[25:6];
                    TLB_C1[inst_info.index] = inst_info.entrylo1[5:3];
                    TLB_D1[inst_info.index] = inst_info.entrylo1[2]
                    TLB_V1[inst_info.index] = inst_info.entrylo1[1];
                    TLB_PFN0[inst_info.index] = inst_info.entrylo0[25:6];
                    TLB_C0[inst_info.index] = inst_info.entrylo0[5:3];
                    TLB_D0[inst_info.index] = inst_info.entrylo0[2]
                    TLB_V0[inst_info.index] = inst_info.entrylo0[1];
                end
                TLBWR : begin
                    TLB_VPN2[inst_info.index] = inst_info.entryhi[31:13];
                    TLB_ASID[inst_info.index] = inst_info.entryhi[7:0];
                    TLB_G[inst_info.index] = inst_info.entrylo1[0] & inst_info.entrylo0[0];
                    TLB_PFN1[inst_info.index] = inst_info.entrylo1[25:6];
                    TLB_C1[inst_info.index] = inst_info.entrylo1[5:3];
                    TLB_D1[inst_info.index] = inst_info.entrylo1[2]
                    TLB_V1[inst_info.index] = inst_info.entrylo1[1];
                    TLB_PFN0[inst_info.index] = inst_info.entrylo0[25:6];
                    TLB_C0[inst_info.index] = inst_info.entrylo0[5:3];
                    TLB_D0[inst_info.index] = inst_info.entrylo0[2]
                    TLB_V0[inst_info.index] = inst_info.entrylo0[1];
                end
                default : begin
                    for (integer i = 0; i < TLBEntries; i = i + 1) begin
                        if ((TLB_VPN2[i] == inst_vaddr[31 : 13]) && (TLB_G[i] || TLB_ASID[i] == inst_EntryHi_ASID)) begin
                            if (inst_vaddr[12] == 0) begin
                                inst_pfn = TLB_PFN0[i];
                                inst_v = TLB_V0[i];
                                inst_c = TLB_C0[i];
                                inst_d = TLB_D0[i];
                            end else begin
                                inst_pfn = TLB_PFN1[i];
                                inst_v = TLB_V1[i];
                                inst_c = TLB_C1[i];
                                inst_d = TLB_D1[i];
                            end
                            if (inst_v == 0)
                                inst_err = INVALID_L;
                            // if (inst_d == 0 && inst_wr) 
                            //     inst_err = MODIFIED;
                            inst_found = 1; break;
                        end
                    end
                    if (!inst_found) begin
                        inst_err = REFILL_L;
                        inst_TLB_done <= 1'b0;
                    end
                end
            endcase
        end 

    always_comb 
        if (data_vaddr < 32'h8000_0000) begin					//kuseg
            data_paddr = {data_pfn[19 : 0], data_vaddr[11 : 0]};
            data_unmapped_uncached <= 1'b0;
            data_unmapped_cached <= 1'b0;
            data_unmapped <= 1'b0;
        end else if (data_vaddr < 32'hA000_0000) begin			//kseg0
            data_paddr = data_vaddr - 32'h8000_0000;
            data_unmapped_uncached <= 1'b0;
            data_unmapped_cached <= 1'b1;
            data_unmapped <= 1'b1;
        end else if (data_vaddr < 32'hC000_0000) begin			//kseg1
            data_paddr = data_vaddr - 32'hA000_0000;
            data_unmapped_uncached <= 1'b1;
            data_unmapped_cached <= 1'b0;
            data_unmapped <= 1'b1;
        end else begin										//kseg2, kseg3
            data_paddr = {data_pfn[19 : 0], data_vaddr[11 : 0]};
            data_unmapped_uncached <= 1'b0;
            data_unmapped_cached <= 1'b0;
            data_unmapped <= 1'b0;
        end
    
    assign data_EntryHi_ASID = data_info.entryhi[7 : 0];

    logic data_state;
    
    always_ff @(posedge clk)
        if (data_unmapped) begin
            data_state <= 1'b0;
            data_TLB_done <= 1'b1;
        end else begin
            data_state <= 1'b1;
            case (data_tlb_req_t)
                TLBR : begin
                    if (data_info.index < TLBEntries) begin
                        data_res.pagemask = '0;
                        data_res.entryhi = {TLB_VPN2[data_info.index], 5'b0, TLB_ASID[data_info.index]};
                        data_res.entrylo1 = {2'b0, TLB_PFN1[data_info.index], TLB_C1[data_info.index], TLB_D1[data_info.index], TLB_V1[data_info.index], TLB_G[data_info.index]}; data_res.entrylo0 = {2'b0, TLB_PFN0[data_info.index], TLB_C0[data_info.index], TLB_D0[data_info.index], TLB_V0[data_info.index], TLB_G[data_info.index]};
                    end
                end
                TLBWI : begin
                    TLB_VPN2[data_info.index] = data_info.entryhi[31:13];
                    TLB_ASID[data_info.index] = data_info.entryhi[7:0];
                    TLB_G[data_info.index] = data_info.entrylo1[0] & data_info.entrylo0[0];
                    TLB_PFN1[data_info.index] = data_info.entrylo1[25:6];
                    TLB_C1[data_info.index] = data_info.entrylo1[5:3];
                    TLB_D1[data_info.index] = data_info.entrylo1[2]
                    TLB_V1[data_info.index] = data_info.entrylo1[1];
                    TLB_PFN0[data_info.index] = data_info.entrylo0[25:6];
                    TLB_C0[data_info.index] = data_info.entrylo0[5:3];
                    TLB_D0[data_info.index] = data_info.entrylo0[2]
                    TLB_V0[data_info.index] = data_info.entrylo0[1];
                end
                TLBWR : begin
                    TLB_VPN2[data_info.index] = data_info.entryhi[31:13];
                    TLB_ASID[data_info.index] = data_info.entryhi[7:0];
                    TLB_G[data_info.index] = data_info.entrylo1[0] & data_info.entrylo0[0];
                    TLB_PFN1[data_info.index] = data_info.entrylo1[25:6];
                    TLB_C1[data_info.index] = data_info.entrylo1[5:3];
                    TLB_D1[data_info.index] = data_info.entrylo1[2]
                    TLB_V1[data_info.index] = data_info.entrylo1[1];
                    TLB_PFN0[data_info.index] = data_info.entrylo0[25:6];
                    TLB_C0[data_info.index] = data_info.entrylo0[5:3];
                    TLB_D0[data_info.index] = data_info.entrylo0[2]
                    TLB_V0[data_info.index] = data_info.entrylo0[1];
                end
                default : begin
                    for (integer i = 0; i < TLBEntries; i = i + 1) begin
                        if ((TLB_VPN2[i] == data_vaddr[31 : 13]) && (TLB_G[i] || TLB_ASID[i] == data_EntryHi_ASID)) begin
                            if (data_vaddr[12] == 0) begin
                                data_pfn = TLB_PFN0[i];
                                data_v = TLB_V0[i];
                                data_c = TLB_C0[i];
                                data_d = TLB_D0[i];
                            end else begin
                                data_pfn = TLB_PFN1[i];
                                data_v = TLB_V1[i];
                                data_c = TLB_C1[i];
                                data_d = TLB_D1[i];
                            end
                            if (data_v == 0)
                                data_err = data_wr ? INVALID_S : INVALID_L;
                            if (data_d == 0 && data_wr) 
                                data_err = MODIFIED;
                            data_found = 1; break;
                        end
                    end
                    if (!data_found) begin
                        data_err = data_wr ? REFILL_S : REFILL_L;
                        data_TLB_done <= 1'b0;
                    end
                end
            endcase
        end   
        
    
endmodule