// testbench to test the simple_mem module

`timescale 1 ns / 1 ps

module testbench_mem;

    // clock / reset
    logic clk = 1;
    logic resetn = 0;

    logic mem_valid;
    logic mem_instr;
    wire mem_ready = 1;

    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0] mem_wstrb;
    logic [31:0] mem_rdata;


    //set up clock and reset
    always #5 clk = ~clk;

    initial begin 
        clk = 0;
        resetn = 0;
        mem_valid = 0;
        mem_instr = 0;
        mem_addr  = 0;
        mem_wdata = 0;
        mem_wstrb = 0;

        repeat (10) @(posedge clk);
        resetn <= 1;

        // ---- Test 1: Write full word ----
        @(negedge clk);
        mem_addr  = 32'h00010000;   // inside RAM region
        mem_wdata = 32'hDEADBEEF;
        mem_wstrb = 4'b1111;
        mem_valid = 1;
        wait(mem_ready);
        @(negedge clk);
        mem_valid = 0;
        mem_wstrb = 0;
        #10;
    end
    

    //dut instantiation
    simple_mem #(
    ) mem (
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


endmodule