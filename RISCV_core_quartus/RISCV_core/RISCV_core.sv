import TypesPkg::*;


module RISCV_core(
	input reg enable, reset, clk,
	output logic [15:0] LED_x31,
	
	input logic debug_a, debug_b,
	output logic debug_led
	);
	
	logic [31:0] addr, instruction;
	logic [4:0] rd, rs1, rs2;
	logic [31:0] imm;
	logic [31:0] rd_data1, rd_data2, rout;
	logic [31:0] wr_data;

	logic [1:0] pc_jmp_Decoder;
	logic rd_en1, rd_en2;
	logic [2:0] wr_en;
	logic [31:0] x31_data;
	
	logic clk_1hz;

	inst_type_t inst_type;
	ALU_func_t ALU_func;
	
	clk_divider(~clk, ~reset, clk_1hz);

	ProgramCounter PC1(enable, ~reset, ~clk, rout[0], pc_jmp_Decoder, imm, addr); 

	InstructionMemory IM1(addr, instruction);

	Decoder D1(instruction, rd, rs1, rs2, imm, inst_type, rd_en1, rd_en2, wr_en, ALU_func, pc_jmp_Decoder);

	RegisterFile RF1(~clk, ~reset, wr_en[0], rd, wr_data, rd_en1, rs1, rd_data1, rd_en2, rs2, rd_data2, x31_data, debug_a, debug_b, debug_led);

	ALU ALU1(rd_data1, rd_data2, imm, ALU_func, rout);
	
	wr_data_mux wrmux(wr_en[2:1], rout, addr, imm, wr_data);
	
	assign LED_x31 = x31_data[15:0];
	
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
	
module clk_divider(
	input logic clk, reset,
	output logic clk_1Hz
);
	
	logic [31:0] counter = 0;
	logic clk_reg = 0;
	
	parameter DIVISOR = 50_000_000;
	
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			counter <= 0;
			clk_reg <= 0;
		end
		else begin
			if (counter == (DIVISOR/2 - 1)) begin
				clk_reg <= ~clk_reg;
				counter <= 0;
			end
			else begin
				counter <= counter + 1;
			end
		end
	end
	
	assign clk_1hz = clk_reg;
	
endmodule
			
	
	
	
	