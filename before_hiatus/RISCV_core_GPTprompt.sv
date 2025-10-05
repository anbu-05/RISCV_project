package TypesPkg;

	typedef enum logic [2:0] {R, I, B, J, U} inst_type_t;

	typedef enum logic [4:0] {ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND, 
							  ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI,
							  EQL, LT, GE} ALU_func_t;

	typedef enum logic [2:0] {
		addsub = 3'b000,
		sll    = 3'b001,
		slt    = 3'b010,
		xor_op = 3'b100,
		srlsra = 3'b101,
		or_op  = 3'b110,
		and_op = 3'b111
	} R_funct3_t;
	
	typedef enum logic [2:0] {
		addi   = 3'b000,
		slti   = 3'b010,
		xori   = 3'b100,
		ori    = 3'b110,
		andi   = 3'b111,
		slli   = 3'b001,
		srli_srai = 3'b101  // Distinguish by funct7[5]
	} I_funct3_t;
	
	typedef enum logic [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101
	} B_funct3_t;

endpackage

import TypesPkg::*;


module RISCV_core(
	input reg enable, reset, clk); //negedge of reset to reset, posedge of clk to work, enable = 1 to work
	
	logic [31:0] addr, instruction;
	logic [4:0] rd, rs1, rs2;
	logic [31:0] imm;
	logic [31:0] rd_data1, rd_data2, rout;
	logic [31:0] wr_data;

	logic [1:0] pc_jmp_Decoder;
	logic rd_en1, rd_en2;
	logic [2:0] wr_en;
	
	// logic clk_1hz;

	inst_type_t inst_type;
	ALU_func_t ALU_func;
	
//	clk_divider(~clk, ~reset, clk_1hz);

	ProgramCounter PC1(enable, reset, ~clk, rout[0], pc_jmp_Decoder, imm, addr); 

	InstructionMemory IM1(addr, instruction);

	Decoder D1(instruction, rd, rs1, rs2, imm, inst_type, rd_en1, rd_en2, wr_en, ALU_func, pc_jmp_Decoder);

	RegisterFile RF1(~clk, reset, wr_en[0], rd, wr_data, rd_en1, rs1, rd_data1, rd_en2, rs2, rd_data2, x31_data, debug_a, debug_b, debug_led);

	ALU ALU1(rd_data1, rd_data2, imm, ALU_func, rout);
	
	wr_data_mux wrmux(wr_en[2:1], rout, addr, imm, wr_data);
	
//	assign LED_x31 = x31_data[15:0];
	
	//assign LED_x31 = 16'b0000111100001111;
	
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
	
//module clk_divider(
//	input logic clk, reset,
//	output logic clk_1Hz
//);
//	
//	logic [31:0] counter = 0;
//	logic clk_reg = 0;
//	
//	parameter DIVISOR = 50_000_000;
//	
//	always_ff @(posedge clk or posedge reset) begin
//		if (reset) begin
//			counter <= 0;
//			clk_reg <= 0;
//		end
//		else begin
//			if (counter == (DIVISOR/2 - 1)) begin
//				clk_reg <= ~clk_reg;
//				counter <= 0;
//			end
//			else begin
//				counter <= counter + 1;
//			end
//		end
//	end
//	
//	assign clk_1hz = clk_reg;
//	
//endmodule


import TypesPkg::*;


module Decoder(
	input logic [31:0] instruction,

	output logic [4:0] rd, rs1, rs2,
	output logic signed [31:0] imm,

	output inst_type_t inst_type,
	output logic rd_en1, rd_en2,
	output logic [2:0] wr_en,
	output ALU_func_t ALU_func,
	output logic [1:0] pc_jmp_Decoder
	
	);

	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;

	assign opcode = instruction[6:0];
	assign rd     = instruction[11:7];
	assign funct3 = instruction[14:12];
	assign rs1    = instruction[19:15];
	assign rs2    = instruction[24:20];
	assign funct7 = instruction[31:25];

	R_funct3_t R_funct3;
	I_funct3_t I_funct3;
	B_funct3_t B_funct3;

	assign R_funct3 = R_funct3_t'(funct3);
	assign I_funct3 = I_funct3_t'(funct3);
	assign B_funct3 = B_funct3_t'(funct3);

	always_comb begin
		case(opcode)
		7'b0110011: inst_type = R;
		7'b0010011: inst_type = I;
		7'b1100011: inst_type = B;
		7'b1101111: inst_type = J;
		7'b0110111: inst_type = U;
		default: inst_type = R;
		endcase
	end

	always_comb begin
		case (inst_type)
			I: imm <= {{20{instruction[31]}}, instruction[31:20]};
			B: imm <= {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			U: imm <= (instruction[31:12] << 12);
			J: imm <= {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			default: imm <= 32'b0;
		endcase
	end

	always_comb begin
		rd_en1 = 0;
		rd_en2 = 0;
		wr_en = 0;
		ALU_func = ALU_func_t'(0);
		pc_jmp_Decoder = 0;
		case (inst_type)
			R: begin
				rd_en1 = 1; rd_en2 = 1; wr_en[0] = 1;
				case(R_funct3)
					addsub: begin
						ALU_func = funct7[5] ? SUB : ADD;
					end
					sll: begin
						ALU_func = SLL;
					end
					slt: begin
						ALU_func = SLT;
					end
					xor_op: begin
						ALU_func = XOR;
					end
					srlsra: begin
						ALU_func = funct7[5] ? SRA : SRL;
					end
					or_op: begin
						ALU_func = OR;
					end
					and_op: begin
						ALU_func = AND;
					end
				endcase
			end
			
			I: begin
				rd_en1 = 1; wr_en[0] = 1;
				case(I_funct3)
					addi: begin
						ALU_func = ADDI;
					end
					slti: begin
						ALU_func = SLTI;
					end
					xori: begin
						ALU_func = XORI;
					end
					ori: begin
						ALU_func = ORI;
					end
					andi: begin
						ALU_func = ANDI;
					end
					slli: begin
						ALU_func = SLLI;
					end
					srli_srai: begin
						ALU_func = funct7[5] ? SRAI : SRLI;
					end
				endcase
			end
			
			B: begin
				rd_en1 = 1; rd_en2 = 1;
				case(B_funct3)
					beq: begin
						ALU_func = EQL;
						pc_jmp_Decoder = 2'b10;
					end
					bne: begin
						ALU_func = EQL;
						pc_jmp_Decoder = 2'b11;
					end
					blt: begin
						ALU_func = LT;
						pc_jmp_Decoder = 2'b10;
					end
					bge: begin
						ALU_func = GE;
						pc_jmp_Decoder = 2'b10;
					end
				endcase
			end
			
			J: begin
				pc_jmp_Decoder = 2'b01;
				wr_en[0] = 1;
				wr_en[2:1] = 2;
			end
			
			U: begin
				wr_en[0] = 1;
				wr_en[2:1] = 3;
			end
		endcase
	end

endmodule
		
module InstructionMemory(
	input logic [31:0] addr,
	output logic [31:0] data);

	reg [31:0] IMem [255:0];
	
	
	initial $readmemh("D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/programs/example_program_3.hex", IMem);
	//use only "programs/example_program_3.hex" if youre only gonna upload onto hardware
	//use the full path like above if you want to use questa and also upload onto hardware
	
	assign data = IMem[addr >> 2];
	
endmodule

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
			3'b110: pc_next = pc_reg + (imm << 1);
			3'b011: pc_next = pc_reg + (imm << 1);		//this line is only for bne function
			3'b001: pc_next = imm << 1;
			default: pc_next = pc_reg + 4;
		endcase
	end

	assign pc_out = pc_reg;

endmodule

module RegisterFile(
	input logic clk, reset, wr_en,
	input logic [4:0] wr_index,
	input logic [31:0] wr_data,

	input logic rd_en1,
	input logic [4:0] rd_index1,
	output logic [31:0] rd_data1,

	input logic rd_en2,
	input logic [4:0] rd_index2,
	output logic [31:0] rd_data2,
	
	output logic [31:0] x31_data,
	
	input logic debug_a, debug_b,
	output logic debug_led
	);
	
	assign debug_led = debug_a && debug_b;

	logic [31:0] registers [31:0];

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			for (int i = 0; i < 32; i++) begin
				registers[i] = 32'b0;
			end
		end
		
		else if (wr_en) begin
			registers[wr_index] = wr_data;
		end
	end
	
	assign x31_data = registers[31];

	always_comb begin
		rd_data1 = (rd_en1) ? registers[rd_index1] : 32'b0;
		rd_data2 = (rd_en2) ? registers[rd_index2] : 32'b0;
	end


endmodule

