module TB_RISCV_core;
	logic clk, reset, enable;
	
	RISCV_core dut(.enable(enable), .clk(clk), .reset(reset)); //(device under test)
	
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	initial begin
		enable = 0;
		reset = 0; #10 reset = 1; #20 reset = 0;

		enable = 1;

		#500;
	end

endmodule
		