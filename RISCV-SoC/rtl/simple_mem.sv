module simple_mem #(
    parameter MEM_WORDS = 65536 //64KiB (MEM_WORDS * 4 bytes)
) (
    input logic clk,
    input logic resetn,

    input logic mem_valid,
    input logic mem_instr,
    output logic mem_ready,
    input logic [31:0] mem_addr,
    input logic [31:0] mem_wdata,
    input logic [3:0] mem_wstrb,
    output logic [31:0] mem_rdata
);

    reg [31:0] memory [0:MEM_WORDS-1];

	always @(posedge clk) begin
		mem_ready <= 0;
		if (mem_valid && !mem_ready) begin
			if (mem_addr < 1024) begin
				mem_ready <= 1;
				mem_rdata <= memory[mem_addr >> 2];
				if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
				if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
				if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
				if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
			end
			/* add memory-mapped IO here */
		end
	end

    always @(posedge clk) begin 
        if (resetn) begin 
            if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
            if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
            if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
        end
    end

    initial $readmemh("../programs/firmware.hex", memory);
    
endmodule