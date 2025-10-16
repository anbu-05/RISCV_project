`timescale 1ns/1ps

module top_tb;
    logic clk;
    logic reset;   // active-low reset (assumes modules use `negedge reset` for reset)
    logic enable;

    // Clock period settings
    localparam int CLK_HALF = 5; // half period in ns => 10 ns period (100 MHz)

    // DUT instantiation
    top DUT (
        .enable(enable),
        .reset(reset),
        .clk(clk)
    );

    // Initialize signals
    initial begin
        // Time formatting for nicer $display prints
        $timeformat(-9, 1, " ns", 10);

        $display("[%0t] TESTBENCH: start", $time);

        clk    = 0;
        reset  = 0; // deasserted (inactive) since reset is active-low
        enable = 0;

        // let everything settle for a couple clocks
        # (CLK_HALF * 4);

        // Assert reset (active low)
        $display("[%0t] TESTBENCH: asserting reset (active-low)", $time);
        reset = 1;
        # (CLK_HALF * 4);

        // Release reset
        $display("[%0t] TESTBENCH: releasing reset", $time);
        reset = 0;
        # (CLK_HALF * 2);

        // Turn on enable to let design run
        $display("[%0t] TESTBENCH: enabling DUT", $time);
        enable = 1;

        // Let DUT run for a while so you can inspect waves
        #500; // 500 ns, adjust as needed

        $display("[%0t] TESTBENCH: finishing simulation", $time);
        $finish;
    end

    // Clock generator
    always #CLK_HALF clk = ~clk;

    // Optional: produce a VCD for offline viewing / quick waveform capture.
    // Questa GUI already captures signals to WLF, but VCD can be handy.
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end
endmodule
