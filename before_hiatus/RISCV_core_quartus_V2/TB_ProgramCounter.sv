module TB_ProgramCounter;
reg enable, reset, clk;
wire [31:0] pc_out;
reg [12:1] imm12;
reg pc_jmp;

ProgramCounter PC1(enable, reset, clk, pc_jmp, imm12, pc_out);

initial begin
clk = 0;
enable = 1;
end

always #20 clk = ~clk;

initial begin
reset = 0; #30 reset = 1; #30 reset = 0;

#250 reset = 1; #30 reset = 0;
end

initial begin
pc_jmp = 0;
#120 pc_jmp = 1;
imm12 = 12'b000000000100;
#30 pc_jmp = 0;
end
endmodule
