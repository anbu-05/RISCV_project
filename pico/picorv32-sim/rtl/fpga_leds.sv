// Parameterized tang_leds (works on Tang or DE2 with small top.v edits)
// Keeps the same port names as the original so top.v instantiation remains compatible.

module fpga_leds
  #(
    parameter integer LED_COUNT = 6,      // number of user LEDs used
    parameter ACTIVE_LOW = 1'b1           // set 1 if LEDs are active-low (Tang), 0 if active-high (DE2 typical)
   )
  (
   input  wire         clk,
   input  wire         reset_n,
   input  wire         leds_sel,
   input  wire [31:0]  leds_data_i,   // accept full 32-bit write; low bits used
   input  wire         we,
   output wire         leds_ready,
   output wire [31:0]  leds_data_o,
   output wire [LED_COUNT-1:0] led_pins // optional mapping to physical pins
   );

   // internal register to hold LED state (width LED_COUNT)
   reg [LED_COUNT-1:0] leds_reg;

   // readback: zero-extend internal LEDs into 32-bit read data (LSB = LED0)
   assign leds_data_o = {{(32-LED_COUNT){1'b0}}, leds_reg};

   // peripheral ready: combinational -> ready same cycle as sel (same as original)
   assign leds_ready = leds_sel;

   // drive output pins with configurable polarity
   generate
     if (ACTIVE_LOW) begin
       assign led_pins = ~leds_reg;
     end else begin
       assign led_pins = leds_reg;
     end
   endgenerate

   // latch writes (leds_sel combined with write enable)
   always @(posedge clk or negedge reset_n) begin
     if (!reset_n)
       leds_reg <= {LED_COUNT{1'b0}};
     else if (leds_sel && we)
       leds_reg <= leds_data_i[LED_COUNT-1:0];
   end

endmodule
