`timescale 1ns/1ps

module simple_counter_tb();

// Testbench signals
logic clk;
logic reset;
logic [3:0] count;

// Instantiate the design under test (DUT)
simple_counter DUT (
    .clk(clk),
    .reset(reset),
    .count(count)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period = 100MHz
end

// Test stimulus
initial begin
    // Initialize signals
    reset = 1;
    
    // Wait for a few clock cycles
    #20;
    
    // Release reset
    reset = 0;
    
    // Let the counter run for several cycles
    #100;
    
    // Apply reset again
    reset = 1;
    #10;
    reset = 0;
    
    // Run for more cycles
    #80;
    
    // End simulation
    $finish;
end

// Monitor the signals
initial begin
    $monitor("Time=%0t, clk=%b, reset=%b, count=%d", 
             $time, clk, reset, count);
end

endmodule
