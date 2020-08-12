`include"cpu_defs.svh"

module TLB #(
    parameter TLBEntries = 32
)(
    input  logic        clk,

    input  logic [31:0]	inst_vaddr,
    input  tlb_t        inst_info,
    input  logic        inst_req,
    output tlb_t        inst_res,
    output tlb_exc_t    inst_err,
    output logic [31:0] inst_paddr,
    output logic        inst_TLB_done,

    input  logic [31:0]	data_vaddr,
    input  tlb_t        data_info,
    input  logic        data_req,
    input  logic        data_wr,
    output tlb_t        data_res,
    output tlb_exc_t    data_err,
    output logic [31:0] data_paddr,
    output logic        data_TLB_done,
    // input  logic [26:0] inst_EntryHi,
    // output logic [24:0] inst_EntryLo0,
    // output logic [24:0] inst_EntryLo1,
    // input  logic        inst_wr,
    // output logic [31:0]	inst_paddr,
    output logic        inst_unmapped_uncached,
    output logic        inst_unmapped_cached,
    output logic        inst_unmapped,
    output logic        inst_TLB_cached,
    output logic        inst_TLB_uncached,
    // output logic        inst_TLBInvalid,
    // output logic        inst_TLBModified,
    // output logic        inst_TLBMiss,

    // input  logic [31:0]	data_vaddr,
    // input  logic [26:0] data_EntryHi,
    // output logic [24:0] data_EntryLo0,
    // output logic [24:0] data_EntryLo1,
    // input  logic        data_wr,
    // output logic [31:0]	data_paddr,
    output logic        data_unmapped_uncached,
    output logic        data_unmapped_cached,
    output logic        data_unmapped,
    output logic        data_TLB_cached,
    output logic        data_TLB_uncached,
    // output logic        data_TLBInvalid,
    // output logic        data_TLBModified,
    // output logic        data_TLBMiss,
    input tlb_req_t    tlb_req,
    output logic        tlb_ok
    
);

    logic [ 7 : 0] inst_EntryHi_ASID, data_EntryHi_ASID;
    logic [18 : 0] inst_EntryHi_VPN2, data_EntryHi_VPN2;

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
        if (inst_unmapped || !inst_req) begin
            inst_state = 1'b0;
            inst_TLB_done = 1'b0;
            inst_err = NO_EXC;
        end else begin
            inst_state = 1'b1;
            inst_found = 1'b0;
            if (tlb_req == NO_REQ) begin
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
                        if (inst_v == 0 && inst_req) inst_err = INVALID_L;
                        else inst_err = NO_EXC;
                        inst_found = 1; 
                        break;
                    end
                end 
                inst_TLB_done = 1'b1;
                if (inst_req && !inst_found) inst_err = REFILL_L;
                else inst_err = NO_EXC;
            end else begin
                inst_TLB_done = 1'b0;
                inst_err = NO_EXC;
            end
            inst_TLB_cached = inst_TLB_done;
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
    assign data_EntryHi_VPN2 = data_info.entryhi[31:13];

    logic data_state;
    logic [4:0] data_index;
    assign data_index = data_info.index[4:0];
    
    always_ff @(posedge clk)
        if (data_unmapped || (tlb_req == NO_REQ && !data_req)) begin
            data_state = 1'b0;
            data_TLB_done = 1'b0;
            data_err = NO_EXC;
            tlb_ok = 1'b0;
        end else begin
            data_state = 1'b1;
            data_found = 1'b0;
            data_err = NO_EXC;
            data_TLB_done = 1'b0;
            case (tlb_req)
                TLBR : begin
                    if (data_index < TLBEntries) begin
                        data_res.pagemask = '0;
                        data_res.entryhi = {TLB_VPN2[data_index], 5'b0, TLB_ASID[data_index]};
                        data_res.entrylo1 = {6'b0, TLB_PFN1[data_index], TLB_C1[data_index], TLB_D1[data_index], TLB_V1[data_index], TLB_G[data_index]};
                        data_res.entrylo0 = {6'b0, TLB_PFN0[data_index], TLB_C0[data_index], TLB_D0[data_index], TLB_V0[data_index], TLB_G[data_index]};
                    end
                end
                TLBWI : begin
                    TLB_VPN2[data_index] = data_info.entryhi[31:13];
                    TLB_ASID[data_index] = data_info.entryhi[7:0];
                    TLB_G[data_index] = data_info.entrylo1[0] & data_info.entrylo0[0];
                    TLB_PFN1[data_index] = data_info.entrylo1[25:6];
                    TLB_C1[data_index] = data_info.entrylo1[5:3];
                    TLB_D1[data_index] = data_info.entrylo1[2];
                    TLB_V1[data_index] = data_info.entrylo1[1];
                    TLB_PFN0[data_index] = data_info.entrylo0[25:6];
                    TLB_C0[data_index] = data_info.entrylo0[5:3];
                    TLB_D0[data_index] = data_info.entrylo0[2];
                    TLB_V0[data_index] = data_info.entrylo0[1];
                end
                TLBWR : begin
                    TLB_VPN2[data_index] = data_info.entryhi[31:13];
                    TLB_ASID[data_index] = data_info.entryhi[7:0];
                    TLB_G[data_index] = data_info.entrylo1[0] & data_info.entrylo0[0];
                    TLB_PFN1[data_index] = data_info.entrylo1[25:6];
                    TLB_C1[data_index] = data_info.entrylo1[5:3];
                    TLB_D1[data_index] = data_info.entrylo1[2];
                    TLB_V1[data_index] = data_info.entrylo1[1];
                    TLB_PFN0[data_index] = data_info.entrylo0[25:6];
                    TLB_C0[data_index] = data_info.entrylo0[5:3];
                    TLB_D0[data_index] = data_info.entrylo0[2];
                    TLB_V0[data_index] = data_info.entrylo0[1];
                end
                default : begin
                    for (integer i = 0; i < TLBEntries; i = i + 1) begin
                        if ((TLB_VPN2[i] == data_EntryHi_VPN2) && (TLB_G[i] || TLB_ASID[i] == data_EntryHi_ASID)) begin
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
                            if (data_v == 0 && data_req)
                                data_err = data_wr ? INVALID_S : INVALID_L;
                            if (data_v == 1 && data_d == 0 && data_wr && data_req) 
                                data_err = MODIFIED;
                            data_found = 1;
                            data_res.index = i;
                            break;
                        end
                    end
                    if (!data_found) begin
                        data_err = data_req ? data_wr ? REFILL_S : REFILL_L : NO_EXC;
                        // if (data_req) 
                        //     if (data_wr) data_err = REFILL_S;
                        //     else data_err = REFILL_L;
                        // else data_err = NO_EXC;
                        // data_err = (tlb_req == TLBP || !data_req) ? NO_EXC : (data_wr ? REFILL_S : REFILL_L);
                        data_res.index = {1'b1, 31'b0};
                    end;
                    if (data_req) data_TLB_done = 1'b1;
                end
            endcase
            tlb_ok = tlb_req != NO_REQ;
            data_TLB_cached = tlb_req != NO_REQ;
        end   
        
    
endmodule   