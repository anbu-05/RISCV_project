import TypesPkg::*;


module Decoder(
	input logic [31:0] instruction,

	output logic [4:0] rd, rs1, rs2,
	output logic signed [31:0] imm,

	output inst_type_t inst_type,
	output logic rd_en1, rd_en2,
	output logic [3:0] wr_en,
	output ALU_func_t ALU_func,
	output logic [1:0] pc_jmp_Decoder,
	
	output logic data_rd_en, data_wr_en
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
	S_funct3_t S_funct3;

	assign R_funct3 = R_funct3_t'(funct3);
	assign I_funct3 = I_funct3_t'(funct3);
	assign B_funct3 = B_funct3_t'(funct3);
	assign S_funct3 = S_funct3_t'(funct3);

	always_comb begin
		case(opcode)
		7'b0110011: inst_type = R;
		7'b0010011: inst_type = I;
		7'b1100011: inst_type = B;
		7'b1101111: inst_type = J;
		7'b0110111: inst_type = U;
		7'b0100011: inst_type = S;
		7'b0000011: inst_type = L;
		default: inst_type = R;
		endcase
	end

	always_comb begin
		case (inst_type)
			I: imm <= {{20{instruction[31]}}, instruction[31:20]};
			B: imm <= {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			U: imm <= (instruction[31:12] << 12);
			J: imm <= {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			S: imm <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
			L: imm <= {{20{instruction[31]}}, instruction[31:20]};
			default: imm <= 32'b0;
		endcase
	end

	always_comb begin
		rd_en1 = 0;
		rd_en2 = 0;
		wr_en = 0;
		
		data_wr_en = 0;
		data_rd_en = 0;
		
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
				wr_en[3:1] = 3;
			end
			
			S: begin
				data_wr_en = 1;
				rd_en1 = 1; rd_en2 = 1;
				case(S_funct3)
					sw: begin
						ALU_func = ADDI;
					end
				endcase	
			end
			L: begin
				data_rd_en = 1;
				rd_en1 = 1; wr_en[3:1] = 4;
				ALU_func = ADDI;
			end
		endcase
	end

endmodule
		
