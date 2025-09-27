// 8192 bytes of inferred memory.
// reads from mem_init.hex file located ../prog/

module sram
  #(parameter ADDRWIDTH=13)
   (
    input logic                 clk, //
    input logic                 resetn,
    input logic                 sram_sel, //
    input logic [3:0]           wstrb,
    input logic [ADDRWIDTH-1:0] addr, //
    input logic [31:0]          sram_data_i,
    output logic                sram_ready, //
    output logic [31:0]         sram_data_o //
    );

  write [ADDRWIDTH-1:2] word_index = addr[ADDRWIDTH-1:2];

  //memory initialization
  reg [31:0] mem [0:2047]; //why [0:2047] and not [2048:0]: https://chatgpt.com/s/t_68cd528b06c081918c52d5ddd53c218a

// not doing async mem read as it overcomplicates write-through.
  // //memory read behaviour (async)
  // //im pretty sure the write-through logic ive written is just BAD
  // always_comb begin
  //   #0.005 //small delay to allow for write-through logic
  //   if (sram_sel && ~wr_flag) begin
  //     sram_ready <= 1'b1;
  //     sram_data_o <= mem[addr[ADDRWIDTH-1:2]]; 
  //    end
  //    else if (sram_sel & wr_flag) begin 
  //     #0.5 //half time-unit delay to allow write-through to complete
  //     sram_ready <= 1'b1;
  //     sram_data_o <= mem[addr[ADDRWIDTH-1:2]];
  //     wr_flag <= 0;
  //    end
  // end

//memory read + write behaviour (sync)
always_ff @(posedge clk) begin 
  if (sram_sel) begin 
    logic [31:0] write_buffer = mem[word_index];
    logic [31:0] read_buffer = mem[word_index]; 
    
    if (wstrb[0]) write_buffer[7:0] = sram_data_i[7:0];
    if (wstrb[1]) write_buffer[15:8] = sram_data_i[15:8];
    if (wstrb[2]) write_buffer[23:16] = sram_data_i[23:16];
    if (wstrb[3]) write_buffer[31:24] = sram_data_i[31:24];

    // the above 4 are blocking statements. which means they will always finish before the following two ifs

    if (|wstrb) mem[word_index] = write_buffer;
    read_buffer = mem[word_index];
  end
end

assign sram_data_o = read_buffer;


// why are we doing seperate write behaviour if the above always_ff handles write anyways
// //memory write behaviour
//   always_ff @(posedge clk) begin 
//     if (sram_sel) begin 
//       if (|wstrb) begin
//         sram_ready <= 1'b1;
//         unique case (wstrb) //im like 80% sure this logic is wrong, that im misunderstanding the use of write strobes
//           4'b0001 : mem[{addr[ADDRWIDTH-1:2],2'b00}] <= sram_data_i[7:0];
//           4'b0010 : mem[{addr[ADDRWIDTH-1:2],2'b01}] <= sram_data_i[15:8];
//           4'b0100 : mem[{addr[ADDRWIDTH-1:2],2'b10}] <= sram_data_i[23:16];
//           4'b1000 : mem[{addr[ADDRWIDTH-1:2],2'b11}] <= sram_data_i[31:24];
//         endcase
//         mem[{addr[ADDRWIDTH-1:2],2'b00}] <= sram_data_i; //ADDRWIDTH-1:2::12:2 -> first 11 bits of the 13 bit address
//       end
//     end
//   end

  //mem_valid behaviour
  always_ff @(posedge clk) begin
    if (!resetn && sram_sel) sram_ready <= 1'b0;
    else sram_ready <= sram_sel;
  end
endmodule
