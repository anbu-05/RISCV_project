module InstructionMemory(
	input logic [31:0] addr,
	output logic [31:0] data);

	reg [7:0] IMem [1023:0];
	
	//int [31:0] Program;
	
	//assign Program = {32'h00c00093,
	//				  32'h01000113
	//				  }
	
	//first Program
	/*
	
	initial begin
		write_instr(0, 32'b00000000110000000000000010010011); 
		
		write_instr(4, 32'b00000001000000000000000100010011);
		
		write_instr(8, 32'b00000000001000001000001100110011);
		
		write_instr(12, 32'b01000000000100010000001110110011);
		
		write_instr(16, 32'b00000000001000000000001010010011);
		
		write_instr(20, 32'b00000000010100111001010000110011);
		
		write_instr(24, 32'b00000000001001000000010001100011);
		
		write_instr(40, 32'b00000000110101000000101000010011);
		
		write_instr(44, 32'b00000000000010000000111000110111);
		
		write_instr(48, 32'b01111111111100000000111010010011);
		
		write_instr(52, 32'b00000000100010100001100001100011);
		
		write_instr(84, 32'b00000001000001000000101010010011);
		
		write_instr(88, 32'b00000001010000000000111111101111);
		
	end
	
	*/
	
	//example program 1
	initial begin
		write_instr(0, 32'h00000f93);
		write_instr(4, 32'h00f00313);
		write_instr(8, 32'h001f8f93);
		write_instr(12, 32'hfe6fcfe3);
		write_instr(16, 32'hffff8f93);
		write_instr(20, 32'hfe0f9fe3);
		write_instr(24, 32'h0040006f);
	end
	

	/*
	task write_program(input int [31:0] Program);
		for (int i = 0; i <= 1023; i++) begin
			write_instr(i*4, Program[i]);
		end
	endtask
	
	task write_instr(input int addr, input int instr);
		IMem[addr]     = instr[7:0];
		IMem[addr + 1] = instr[15:8];
		IMem[addr + 2] = instr[23:16];
		IMem[addr + 3] = instr[31:24];
	endtask
	*/
	
	task write_instr(input int addr, input logic [31:0] instr);
		IMem[addr]     = instr[7:0];
		IMem[addr + 1] = instr[15:8];
		IMem[addr + 2] = instr[23:16];
		IMem[addr + 3] = instr[31:24];
	endtask

	assign data = {IMem[addr + 3], IMem[addr + 2], IMem[addr + 1], IMem[addr]};

endmodule
