// testbench with a slightly bigger assembly file

`timescale 1 ns / 1 ps

module testbench_1;

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


    //set up clock and reset
    always #5 clk = ~clk;

    initial begin 
        repeat (10) @(posedge clk);
        resetn <= 1;
    end
    

    //dut instantiation
    top dut(
        .clk(clk),
        .resetn(resetn)
    );


endmodule