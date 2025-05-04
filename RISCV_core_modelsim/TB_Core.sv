import TypesPkg::*;


module TB_core;
	reg enable, reset, clk;
	reg data_reset;
	wire [31:0] addr, instruction;
	wire [4:0] rd, rs1, rs2;
	wire [31:0] imm;
	wire [31:0] rd_data1, rd_data2, rout;
	logic [31:0] wr_data;

	wire [1:0] pc_jmp_Decoder;

	wire inst_type_t inst_type;
	wire rd_en1, rd_en2;
	wire [3:0] wr_en;
	wire ALU_func_t ALU_func;
	logic [31:0] x31_data;
	
	wire data_rd_en, data_wr_en;
	logic [31:0] rd_data;
	
	
	ProgramCounter PC1(enable, reset, clk, rout[0], pc_jmp_Decoder, imm, addr); 

	InstructionMemory IM1(addr, instruction);

	Decoder D1(instruction, rd, rs1, rs2, imm, inst_type, rd_en1, rd_en2, wr_en, ALU_func, pc_jmp_Decoder, data_rd_en, data_wr_en);

	RegisterFile RF1(clk, reset, wr_en[0], rd, wr_data, rd_en1, rs1, rd_data1, rd_en2, rs2, rd_data2, x31_data);

	ALU ALU1(rd_data1, rd_data2, imm, ALU_func, rout);
	
	DataMemory DM1(clk, data_reset, reset, rout, data_wr_en, rd_data2, data_rd_en, rd_data);
	
	wr_data_mux wrmux(wr_en[3:1], rout, addr, imm, rd_data, wr_data);

		
		

	initial begin
	clk = 0;
	enable = 1;
	data_reset = 1;
	end

	always #100 clk = ~clk;

	initial begin
	//reset = 0; #100 
	reset = 1; #20 reset = 0;
	end

	always @(posedge clk) begin
		$display("------ Register File Dump ------");
		for (int i = 0; i <= 28; i = i + 4) begin
			$display("[x%2d = %4d] [x%2d = %4d] [x%2d = %4d] [x%2d = %4d]", 
						i, RF1.registers[i], 
						i+1, RF1.registers[i+1], 
						i+2, RF1.registers[i+2], 
						i+3, RF1.registers[i+3]);
		end
		/*
		$display("--------------------------------");
		$display(PC1.pc_jmp_ALU);
		$display(PC1.pc_jmp_Decoder);
		$display(PC1.imm12);
		$display("--------------------------------");
		*/
	end


endmodule


module wr_data_mux(
	input logic [2:0] sel,
	input logic [31:0] rout, addr, imm, rd_data,
	output logic [31:0] wr_data
);

	always_comb begin
		case(sel)
			1: wr_data = rout;
			2: wr_data = addr;
			3: wr_data = imm;
			4: wr_data = rd_data;
			default: wr_data = rout;
		endcase
	end
endmodule