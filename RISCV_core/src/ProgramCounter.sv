module ProgramCounter(
    input logic enable,
    input logic reset,
    input logic clk,

    input logic signed [31:0] imm,
    input logic jump,

	output logic [31:0] pc_out);

    logic [31:0] pc_reg;
    logic [31:0] pc_next;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 32'b0;
        else if (enable) pc_reg <= pc_next;
    end

    always_comb begin
        if (jump) pc_next = pc_reg + (imm << 1);
        else pc_next = pc_reg + 4;
    end

    assign pc_out = pc_reg;
endmodule