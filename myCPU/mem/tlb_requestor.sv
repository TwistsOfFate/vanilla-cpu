`include "cpu_defs.svh"

module tlb_requestor(
	input tlb_req_t in_req,

	input [1:0] addr_err,
	input reserved_instr,
	input intovf,
    input tlb_exc_t tlb_exc_if,
    input cp0_ready,

    output tlb_req_t out_req
);

always_comb
	if (addr_err != 2'b00 || reserved_instr || intovf || tlb_exc_if != NO_EXC || !cp0_ready)
		out_req = NO_REQ;
	else
		out_req = in_req;

endmodule