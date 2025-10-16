import TypesPkg::*;

module top(
	input logic enable, reset, clk); //negedge of reset to reset, posedge of clk to work, enable = 1 to work
	
	logic [31:0] addr, instruction;
	logic [4:0] rd, rs1, rs2;
	logic [31:0] imm;
	logic [31:0] rd_data1, rd_data2, rout;
	logic [31:0] wr_data;

	logic [1:0] pc_jmp_Decoder;
	logic rd_en1, rd_en2;
	logic [2:0] wr_en;

	inst_type_t inst_type;
	ALU_func_t ALU_func;

	ProgramCounter PC1 (
		.enable(enable),
		.reset(reset),
		.clk(clk),
		.pc_jmp_ALU(rout[0]),
		.pc_jmp_Decoder(pc_jmp_Decoder),
		.imm(imm),
		.pc_out(addr)
	);

	InstructionMemory IM1 (
		.addr(addr),
		.data(instruction)
	);

	Decoder D1 (
		.instruction(instruction),
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.imm(imm),
		.inst_type(inst_type),
		.rd_en1(rd_en1),
		.rd_en2(rd_en2),
		.wr_en(wr_en),
		.ALU_func(ALU_func),
		.pc_jmp_Decoder(pc_jmp_Decoder)
	);

	RegisterFile RF1 (
		.clk(clk),
		.reset(reset),
		.wr_en(wr_en[0]),
		.wr_index(rd),
		.wr_data(wr_data),

		.rd_en1(rd_en1),
		.rd_index1(rs1),
		.rd_data1(rd_data1),

		.rd_en2(rd_en2),
		.rd_index2(rs2),
		.rd_data2(rd_data2)
	);

	ALU ALU1 (
		.r1(rd_data1),
		.r2(rd_data2),
		.imm(imm),
		.ALU_func(ALU_func),
		.rout(rout)
	);
	
	wr_data_mux wrmux (
		.sel(wr_en[2:1]),
		.rout(rout),
		.addr(addr),
		.imm(imm),
		.wr_data(wr_data)
	);
	
endmodule

module wr_data_mux(
	input logic [1:0] sel,
	input logic [31:0] rout, addr, imm,
	output logic [31:0] wr_data
);
	always_comb begin
		case(sel)
			2'b01: wr_data = rout;
			2'b10: wr_data = addr;
			2'b11: wr_data = imm;
			default: wr_data = rout;
		endcase
	end
endmodule
