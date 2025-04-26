import TypesPkg::*;


module RISCV_core(
	input reg enable, reset, clk
	);
	
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

	ProgramCounter PC1(enable, reset, clk, rout[0], pc_jmp_Decoder, imm, addr); 

	InstructionMemory IM1(addr, instruction);

	Decoder D1(instruction, rd, rs1, rs2, imm, inst_type, rd_en1, rd_en2, wr_en, ALU_func, pc_jmp_Decoder);

	RegisterFile RF1(clk, reset, wr_en[0], rd, wr_data, rd_en1, rs1, rd_data1, rd_en2, rs2, rd_data2);

	ALU ALU1(rd_data1, rd_data2, imm, ALU_func, rout);
	
	wr_data_mux wrmux(wr_en[2:1], rout, addr, imm, wr_data);

	//always_comb begin
	//	wr_data = wr_en[1] ? addr : rout;
	//end

	/*
	always_comb begin
		case(wr_en[2:1])
			1: wr_data = rout;
			2: wr_data = addr;
			3: wr_data = imm;
			default: wr_data = rout;
		endcase
	end
	*/


endmodule

module wr_data_mux(
	input logic [1:0] sel,
	input logic [31:0] rout, addr, imm,
	output logic [31:0] wr_data
);
	always_comb begin
		case(sel)
			1: wr_data = rout;
			2: wr_data = addr;
			3: wr_data = imm;
			default: wr_data = rout;
		endcase
	end
endmodule
	
	
	
	
	
	
	
	
	