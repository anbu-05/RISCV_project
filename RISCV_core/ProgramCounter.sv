module ProgramCounter(
input logic enable,
input logic reset,
input logic clk,
input logic pc_jmp_ALU,
input logic [1:0] pc_jmp_Decoder,
input logic signed [31:0] imm,
output logic [31:0] pc_out);

logic [31:0] pc_next;
logic [31:0] pc_reg;


logic [2:0] pc_jmp;

assign pc_jmp = {pc_jmp_ALU, pc_jmp_Decoder};



always_ff @(posedge clk or posedge reset) begin
	if (reset) pc_reg <= 32'b0;
	else if (enable) pc_reg <= pc_next;
end

//always_comb begin
//	if (pc_jmp_ALU && pc_jmp_Decoder[0]) pc_next = pc_reg + (imm << 1);
//	else if (~pc_jmp_ALU && pc_jmp_Decoder[0]) pc_next = pc_reg + (imm << 1);
//	else pc_next = pc_reg + 4;
//end

always_comb begin
	case(pc_jmp)
		3'b101: pc_next = pc_reg + (imm << 1);
		3'b010: pc_next = pc_reg + (imm << 1);
		3'b011: pc_next = imm << 1;
		default: pc_next = pc_reg + 4;
	endcase
end

assign pc_out = pc_reg;

endmodule