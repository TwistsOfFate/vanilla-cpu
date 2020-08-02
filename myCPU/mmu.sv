module mmu(
	input [31:0]	vaddr,
	output logic [31:0]	paddr,
	output logic    cached
);

always_comb begin
	if (vaddr < 32'h8000_0000) begin					//kuseg
		paddr = vaddr;
		cached = 1'b1;
	end else if (vaddr < 32'hA000_0000) begin			//kseg0
		paddr = vaddr - 32'h8000_0000;
		cached = 1'b1;
	end else if (vaddr < 32'hC000_0000) begin			//kseg1
		paddr = vaddr - 32'hA000_0000;
		cached = 1'b0;
	end else begin										//kseg2, kseg3
		paddr = vaddr;
		cached = 1'b1;
	end
end

endmodule
