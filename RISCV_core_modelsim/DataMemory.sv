module DataMemory(
	input logic clk, data_reset, reset,
	input logic [31:0] addr,
	
	input logic wr_en,
	input logic [31:0] wr_data,

	input logic rd_en,
	output logic [31:0] rd_data
	);

	logic [31:0] registers [31:0];

	always_ff @(posedge clk or posedge reset) begin
		if (data_reset) begin
			for (int i = 0; i < 32; i++) begin
				registers[i] = 32'b0;
			end
		end
		
		else if (wr_en) begin
			registers[addr] = wr_data;
		end
	end

	always_comb begin
		rd_data = (rd_en) ? registers[addr] : 32'b0;
	end


endmodule

