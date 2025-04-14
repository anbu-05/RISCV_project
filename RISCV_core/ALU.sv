import TypesPkg::*;


module ALU(
input logic [31:0] r1, r2,
input logic signed [31:0] imm,
input ALU_func_t ALU_func,
output logic [31:0] rout
);

always_comb begin
	case(ALU_func)
		ADD: rout = r1 + r2;
		SUB: rout = r1 - r2;
		SLL: rout = r1 << r2[4:0];
		SLT: rout = (r1 < r2) ? 1 : 0;
		XOR: rout = r1 ^ r2;
		SRL: rout = r1 >> r2[4:0];
		SRA: rout = r1 >>> r2[4:0];
		AND: rout = r1 & r2;
		OR: rout = r1 | r2;
		
		ADDI: rout = r1 + imm;
		
		EQL: rout = (r1 == r2) ? 1 : 0;
		default: rout = 0;
	endcase
end
endmodule

