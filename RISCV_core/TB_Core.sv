import TypesPkg::*;


module TB_core;
reg enable, reset, clk;
wire [31:0] addr, instruction;
wire [4:0] rd, rs1, rs2;
wire [31:0] imm;
wire [31:0] rd_data1, rd_data2, rout;
reg [31:0] wr_data;

wire [1:0] pc_jmp_Decoder;

wire inst_type_t inst_type;
wire rd_en1, rd_en2;
wire [2:0] wr_en;
wire ALU_func_t ALU_func;


ProgramCounter PC1(enable, reset, clk, rout[0], pc_jmp_Decoder, imm, addr); 

InstructionMemory IM1(addr, instruction);

Decoder D1(instruction, rd, rs1, rs2, imm, inst_type, rd_en1, rd_en2, wr_en, ALU_func, pc_jmp_Decoder);

RegisterFile RF1(reset, wr_en[0], rd, wr_data, rd_en1, rs1, rd_data1, rd_en2, rs2, rd_data2);

ALU ALU1(rd_data1, rd_data2, imm, ALU_func, rout);

//always_comb begin
//	wr_data = wr_en[1] ? addr : rout;
//end

always_comb begin
	case(wr_en[2:1])
		1: wr_data = rout;
		2: wr_data = addr;
		3: wr_data = imm;
		default: wr_data = rout;
	endcase
end
	

initial begin
clk = 0;
enable = 1;
end

always #100 clk = ~clk;

initial begin
reset = 0; #100 reset = 1; #20 reset = 0;
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