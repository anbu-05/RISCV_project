module ProgramCounter(
    input logic en,
    input logic rst,
    input logic clk,

    input logic signed [31:0] imm,
    input logic jmp,

	output logic [31:0] pc_out);

    logic [31:0] pc_reg;
    logic [31:0] pc_next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) pc_reg <= 32'b0;
        else if (en) pc_reg <= pc_next;
    end

    always_comb begin
        if (jmp) pc_next = pc_reg + (imm << 1);
        else pc_next = pc_reg + 4;
    end

    assign pc_out = pc_reg;
endmodule