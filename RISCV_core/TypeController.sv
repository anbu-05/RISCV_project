typedef enum logic [2:0] {R, I, B, J, U} inst_type_t;
typedef enum logic [3:0] {ADD, SUB} ALU_func_t
typedef enum logic [2:0] {addsub = 3'b000,
						  sll = 3'b001,
						  slt = 3'b010,
						  xor = 3'b100,
						  srlsra = 3'b101,
						  or = 3'b110,
						  and = 3'b111,
						  } R_funct3_t;

module TypeController(
input logic reset, clk,
input inst_type_t inst_type;
output logic rd_en1, rd_en2, wr_en,
output ALU_func_t ALU_func);

R_funct3_t R_funct3;

always_comb begin
	rd_en1 = 0;
	rd_en2 = 0;
	wr_en = 0;
	ALU_func = ALU_func_reg;
	next_state = state;
	case(inst_type)
		R: begin
			case(R_funct3)
				addsub

			

endmodule