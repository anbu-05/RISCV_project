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
	
	output logic [31:0] x31_data
	);

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

