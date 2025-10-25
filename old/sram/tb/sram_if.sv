interface sram_if #(parameter ADDRWIDTH=13) (input bit clk);
    logic                 resetn;
    logic                 sram_sel; 
    logic [3:0]           wstrb;
    logic [ADDRWIDTH-1:0] addr;
    logic [31:0]          sram_data_i;
    logic                sram_ready;
    logic [31:0]         sram_data_o;
endinterface //sram_if