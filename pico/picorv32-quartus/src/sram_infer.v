// sram_infer.v  - inferred RAM replacement for Gowin sram.v
// 8192 bytes (2048 x 32-bit). Matches original sram interface.
// Designed for Intel/Altera Quartus (Cyclone IV E M9K on DE2-115)
//
// Notes:
// * Infers M9K block RAM in Quartus
// * Supports byte write strobes
// * Synchronous read with 1-clock latency
// * Ready asserted next cycle after sram_sel
// * Optional initialization from "mem_init.hex" (one 32-bit word per line)
//
// Format of mem_init.hex: one 32-bit word per line, in hex (8 digits)
// Example:
//   E3933323
//   1337193E
//   313E3133
//   3B3B3831
//   ...

module sram
  #(parameter ADDRWIDTH = 13) // byte address width (8KB total)
   (
    input  wire                 clk,
    input  wire                 resetn,
    input  wire                 sram_sel,
    input  wire [3:0]           wstrb,        // byte strobes (1 = write)
    input  wire [ADDRWIDTH-1:0] addr,         // byte address
    input  wire [31:0]          sram_data_i,
    output wire                 sram_ready,
    output wire [31:0]          sram_data_o
    );

   // derive number of 32-bit words: address is byte-addressed, so drop low 2 bits
   localparam WORDS = 1 << (ADDRWIDTH - 2);

   reg [31:0] mem [0:WORDS-1];

   // optional: initialize memory from hex file (Quartus supports $readmemh -> MIF)
   // create mem_init.hex and put it in project directory
   initial begin
      $readmemh("mem_init.hex", mem);
   end

   reg [31:0] read_reg;
   reg        ready_reg;

   // ✅ Declarations must be outside always block in Verilog-2001
   integer wa;
   reg [31:0] cur;
   reg [31:0] nxt;

   // access logic: synchronous read, byte-write on sram_sel & wstrb
   always @(posedge clk) begin
      if (!resetn) begin
         ready_reg <= 1'b0;
         read_reg  <= 32'b0;
      end else begin
         if (sram_sel) begin
            // compute word address (drop 2 LSBs)
            wa = addr[ADDRWIDTH-1:2];

            // read current word (for write-modify-read semantics)
            cur = mem[wa];

            // build next word depending on byte strobes
            nxt = cur;
            if (wstrb[0]) nxt[ 7: 0] = sram_data_i[ 7: 0];
            if (wstrb[1]) nxt[15: 8] = sram_data_i[15: 8];
            if (wstrb[2]) nxt[23:16] = sram_data_i[23:16];
            if (wstrb[3]) nxt[31:24] = sram_data_i[31:24];

            // perform write if any strobe asserted
            if (|wstrb) begin
               mem[wa] <= nxt;
               // reflect written data on read (write-first behavior)
               read_reg <= nxt;
            end else begin
               // no write, just return memory content
               read_reg <= cur;
            end

            // ready asserted next cycle (same behavior as original sram.v)
            ready_reg <= 1'b1;
         end else begin
            ready_reg <= 1'b0;
         end
      end
   end

   assign sram_data_o = read_reg;
   assign sram_ready  = ready_reg;

endmodule
