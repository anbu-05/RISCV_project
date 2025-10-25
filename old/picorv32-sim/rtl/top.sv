/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */
/* Top-level module (fixed parameter ordering and missing wires) */

`timescale 1ns/1ps

module top #(
   // parameters must be declared before ports if used in port declarations
   parameter integer LED_COUNT = 8, // set default here so port declaration can use it
   parameter [0:0] BARREL_SHIFTER = 0,
   parameter [0:0] ENABLE_MUL = 0,
   parameter [0:0] ENABLE_DIV = 0,
   parameter [0:0] ENABLE_FAST_MUL = 0,
   parameter [0:0] ENABLE_COMPRESSED = 0,
   parameter [0:0] ENABLE_IRQ_QREGS = 0,
   parameter integer MEMBYTES = 8192,      // This is not easy to change
   parameter [31:0] STACKADDR = (MEMBYTES), // Grows down.  Software should set it.
   parameter [31:0] PROGADDR_RESET = 32'h0000_0000,
   parameter [31:0] PROGADDR_IRQ   = 32'h0000_0000
) (
   input  wire                  clk,
   input  wire                  reset_button_n,
   input  wire                  uart_rx,
   output wire                  uart_tx,
`ifdef USE_LA
   output wire                  clk_out,
   output wire                  mem_instr,
   output wire                  mem_valid,
   output wire                  mem_ready,
   output wire                  b25,
   output wire                  b24,
   output wire                  b17,
   output wire                  b16,
   output wire                  b09,
   output wire                  b08,
   output wire                  b01,
   output wire                  b00,
   output wire [3:0]            mem_wstrb,
`endif
   output wire [LED_COUNT-1:0]  leds
);

   // internal signals
   wire                       reset_n;
   wire                       mem_valid;
   wire                       mem_instr;
   wire [31:0]                mem_addr;
   wire [31:0]                mem_wdata;
   wire [31:0]                mem_rdata;
   wire [3:0]                 mem_wstrb;
   wire                       mem_ready;

   wire                       leds_sel;
   wire                       leds_ready;
   wire [31:0]                leds_data_o;

   wire                       sram_sel;
   wire                       sram_ready;
   wire [31:0]                sram_data_o;

   wire                       cdt_sel;
   wire                       cdt_ready;
   wire [31:0]                cdt_data_o;

   wire                       uart_sel;
   wire [31:0]                uart_data_o;
   wire                       uart_ready;

`ifdef USE_LA
   // Assigns for external logic analyzer connection
   assign clk_out = clk;
   assign b25 = mem_rdata[25];
   assign b24 = mem_rdata[24];
   assign b17 = mem_rdata[17];
   assign b16 = mem_rdata[16];
   assign b09 = mem_rdata[9];
   assign b08 = mem_rdata[8];
   assign b01 = mem_rdata[1];
   assign b00 = mem_rdata[0];
`endif

   // Establish memory map for all slaves:
   //   SRAM 00000000 - 00001fff  (8192 bytes -> 0x2000)
   //   LED  80000000
   //   UART 80000008 - 8000000f
   //   CDT  80000010 - 80000014
   assign sram_sel = mem_valid && (mem_addr < 32'h00002000);
   assign leds_sel = mem_valid && (mem_addr == 32'h80000000);
   assign uart_sel = mem_valid && ((mem_addr & 32'hfffffff8) == 32'h80000008);
   assign cdt_sel  = mem_valid && (mem_addr == 32'h80000010);

   // Core can proceed regardless of *which* slave was targetted and is now ready.
   assign mem_ready = mem_valid & (sram_ready | leds_ready | uart_ready | cdt_ready);

   // Select which slave's output data is to be fed to core.
   assign mem_rdata = sram_sel ? sram_data_o :
                     //  leds_sel ? leds_data_o :
                      uart_sel ? uart_data_o :
                      cdt_sel  ? cdt_data_o  : 32'h0;

   // reset controller
   reset_control reset_controller (
      .clk(clk),
      .reset_button_n(reset_button_n),
      .reset_n(reset_n)
   );

   // uart wrap
   uart_wrap uart (
      .clk(clk),
      .reset_n(reset_n),
      .uart_tx(uart_tx),
      .uart_rx(uart_rx),
      .uart_sel(uart_sel),
      .addr(mem_addr[3:0]),
      .uart_wstrb(mem_wstrb),
      .uart_di(mem_wdata),
      .uart_do(uart_data_o),
      .uart_ready(uart_ready)
   );

   // countdown timer
   countdown_timer cdt (
      .clk(clk),
      .reset_n(reset_n),
      .cdt_sel(cdt_sel),
      .cdt_data_i(mem_wdata),
      .we(mem_wstrb),
      .cdt_ready(cdt_ready),
      .cdt_data_o(cdt_data_o)
   );

   // sram with 13-bit addr -> 8kbytes
   sram #(.ADDRWIDTH(13)) memory (
      .clk(clk),
      .resetn(reset_n),
      .sram_sel(sram_sel),
      .wstrb(mem_wstrb),
      .addr(mem_addr[12:0]),
      .sram_data_i(mem_wdata),
      .sram_ready(sram_ready),
      .sram_data_o(sram_data_o)
   );

   // // FPGA LEDs wrapper
   // fpga_leds #(.LED_COUNT(LED_COUNT), .ACTIVE_LOW(1'b0)) soc_leds (
   //    .clk(clk),
   //    .reset_n(reset_n),
   //    .leds_sel(leds_sel),
   //    .leds_data_i(mem_wdata),
   //    .we(mem_wstrb[0]),
   //    .leds_ready(leds_ready),
   //    .leds_data_o(leds_data_o),
   //    .led_pins(leds)
   // );

   // picorv32 core
   picorv32 #(
      .STACKADDR(STACKADDR),
      .PROGADDR_RESET(PROGADDR_RESET),
      .PROGADDR_IRQ(PROGADDR_IRQ),
      .BARREL_SHIFTER(BARREL_SHIFTER),
      .COMPRESSED_ISA(ENABLE_COMPRESSED),
      .ENABLE_MUL(ENABLE_MUL),
      .ENABLE_DIV(ENABLE_DIV),
      .ENABLE_FAST_MUL(ENABLE_FAST_MUL),
      .ENABLE_IRQ(1),
      .ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS)
   ) cpu (
      .clk       (clk),
      .resetn    (reset_n),
      .mem_valid (mem_valid),
      .mem_instr (mem_instr),
      .mem_ready (mem_ready),
      .mem_addr  (mem_addr),
      .mem_wdata (mem_wdata),
      .mem_wstrb (mem_wstrb),
      .mem_rdata (mem_rdata),
      .irq       (1'b0)
   );

endmodule // top
