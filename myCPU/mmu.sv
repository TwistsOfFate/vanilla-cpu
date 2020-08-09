module mmu(
	input [31:0]	vaddr,
	output logic [31:0]	paddr,
	output logic    cached
);

// always_comb begin
// 	if (vaddr < 32'h8000_0000) begin					//kuseg
// 		paddr = vaddr;
// 		cached = 1'b1;
// 	end else if (vaddr < 32'hA000_0000) begin			//kseg0
// 		paddr = vaddr - 32'h8000_0000;
// 		cached = 1'b1;
// 	end else if (vaddr < 32'hC000_0000) begin			//kseg1
// 		paddr = vaddr - 32'hA000_0000;
// 		cached = 1'b0;
// 	end else begin										//kseg2, kseg3
// 		paddr = vaddr;
// 		cached = 1'b1;
// 	end
// end

always_comb
	unique case (vaddr[31:28])
		4'hf: begin paddr = vaddr; cached = 1'b1; end
		4'he: begin paddr = vaddr; cached = 1'b1; end
		4'hd: begin paddr = vaddr; cached = 1'b1; end
		4'hc: begin paddr = vaddr; cached = 1'b1; end
		4'hb: begin paddr = {4'h1, vaddr[27:0]}; cached = 1'b0; end
		4'ha: begin paddr = {4'h0, vaddr[27:0]}; cached = 1'b0; end
		4'h9: begin paddr = {4'h1, vaddr[27:0]}; cached = 1'b1; end
		4'h8: begin paddr = {4'h0, vaddr[27:0]}; cached = 1'b1; end
		4'h7: begin paddr = vaddr; cached = 1'b1; end
		4'h6: begin paddr = vaddr; cached = 1'b1; end
		4'h5: begin paddr = vaddr; cached = 1'b1; end
		4'h4: begin paddr = vaddr; cached = 1'b1; end
		4'h3: begin paddr = vaddr; cached = 1'b1; end
		4'h2: begin paddr = vaddr; cached = 1'b1; end
		4'h1: begin paddr = vaddr; cached = 1'b1; end
		4'h0: begin paddr = vaddr; cached = 1'b1; end
	endcase
	
endmodule
