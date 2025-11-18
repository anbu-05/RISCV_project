// testbench for the first axi simpleuart adapter + simpleuart implementation

`timescale 1 ns / 1 ps

module testbench_3_uart_axi;

    // clock / reset
    reg clk = 1;
    reg resetn = 0;

    //set up clock and reset
    always #5 clk = ~clk;

    initial begin 
        repeat (10) @(posedge clk);
        resetn <= 1;
    end
    

    //dut instantiation
    top_uart_axi dut(
        .clk(clk),
        .resetn(resetn)
    );


endmodule