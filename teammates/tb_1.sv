`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2025 10:54:56
// Design Name: 
// Module Name: tb_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_1();
reg clk;
reg rst;

reg div_en;
reg [15:0] div_in;

reg [31:0] d_in;

reg tx_en;
wire ser_tx;
wire tx_empty;

parameter clk_cyc = 20;



UART_v1 uart1 (.clk(clk), .rst(rst), .div_en(div_en), .div_in(div_in), .d_in(d_in), .tx_en(tx_en),
 .ser_tx(ser_tx), .tx_empty(tx_empty));

always begin            // Clock generation
    #(clk_cyc/2);
    clk = ~clk;
end

initial begin
    rst = 1'b1;
    clk = 1'b1;

    #(2*clk_cyc);

    rst = 1'b0;
    #(3*clk_cyc);    //Baud rate not set, No Communication
    tx_en = 1'b1;
    #(3*clk_cyc);    //tx_en is on but baud rate not set, No Communication

    // Setting Baud rate
    tx_en = 1'b0;
    
    div_in = 16'd2;
    
    div_en = 1'b1;  //div_en pulse
    #(clk_cyc);
    div_en = 1'b0;
    
    //Start Transmission
    tx_en = 1'b1;   //tx_en pulse
    #(clk_cyc);
    tx_en <= 1'b0;
    d_in <= 32'b10000001000000100000010000001000;
    #(160*clk_cyc);
    
    #(2*clk_cyc)
    
    rst = 1'b1;

    $finish;
end

endmodule
