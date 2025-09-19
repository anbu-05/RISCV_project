// 8192 bytes of inferred memory.
// reads from mem_init.hex file located ../prog/

module sram
  #(parameter ADDRWIDTH=13)
   (
    input wire                 clk, //
    input wire                 resetn,
    input wire                 sram_sel, //
    input wire [3:0]           wstrb,
    input wire [ADDRWIDTH-1:0] addr, //
    input wire [31:0]          sram_data_i,
    output wire                sram_ready, //
    output wire [31:0]         sram_data_o //
    );

  //memory initialization
  reg [31:0] mem [0:2047]; //why [0:2047] and not [2048:0]: https://chatgpt.com/s/t_68cd528b06c081918c52d5ddd53c218a

  //memory read behaviour (async)
  always @(posedge clk) begin
    if (sram_sel) begin
      sram_ready <= 1'b1;
      sram_data_o = mem[addr[ADDRWIDTH:2]];
     end
  end

  //memory write behaviour
  always @(posedge clk) begin 
    if (sram_sel) begin 
      sram_ready <= 1'b1
      // unique case (wstrb) 
      //   0 : mem[addr[ADDRWIDTH:2]] = sram_data_i
      // endcase
      mem[addr[ADDRWIDTH:2]] = sram_data_i
    end
  end

  //mem_valid behaviour
  reg ready = 1'b0;
  assign sram_ready = ready;

  always @(posedge clk) 
    if (sram_sel) ready <= 1'b1;
    else ready <= 1'b0;


endmodule
