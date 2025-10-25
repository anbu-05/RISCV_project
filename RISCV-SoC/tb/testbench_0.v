`timescale 1 ns / 1 ps

// tiny testbench: only clock + simple reset; instantiates picorv32 as uut
module testbench_0;

    // clock / reset
    reg clk = 1;
    reg resetn = 0;


    wire mem_valid;
    wire mem_instr;
    reg mem_ready = 1;

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    reg [31:0] mem_rdata;

    picorv32 uut (
        .clk(clk),
        .resetn(resetn),     
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    always #5 clk = ~clk;

    initial begin 
        // repeat (100) @(posedge clk);
        #100
        resetn <= 1;
    end

	reg [31:0] memory [0:255];

	// initial begin
    //     memory[0] = 32'h00a00013; //addi x0, x0, 10
    //     memory[1] = 32'h00a00093; //addi x1, x0, 10
    //     memory[2] = 32'h00008133; //add x2, x1, x0
	// end

    // always @(posedge clk) begin
    //     mem_ready <= 0;
    //     if (mem_valid && !mem_ready) begin
    //         mem_ready <= 1;
    //         mem_rdata <= memory[mem_addr >> 2];
    //     end
    // end

	initial begin
		memory[0] = 32'h 3fc00093; //       li      x1,1020
		memory[1] = 32'h 0000a023; //       sw      x0,0(x1)
		memory[2] = 32'h 0000a103; // loop: lw      x2,0(x1)
		memory[3] = 32'h 00110113; //       addi    x2,x2,1
		memory[4] = 32'h 0020a023; //       sw      x2,0(x1)
		memory[5] = 32'h ff5ff06f; //       j       <loop>
	end

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

endmodule
