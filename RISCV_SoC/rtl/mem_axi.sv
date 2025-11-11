module simple_mem_axi #(
    parameter MEM_WORDS = 131072, //128KiB (MEM_WORDS * 4 bytes) (till address 0x00020000)
    parameter ROM_ORIGIN = 32'h00000000,
    parameter ROM_LENGTH = 32'h00010000, // 64 KiB
    parameter RAM_ORIGIN = 32'h00010000,
    parameter RAM_LENGTH = 32'h00008000 // 32 KiB
) (
	input logic clk, resetn,

	// AXI4-lite master memory interface

	input  logic        mem_axi_awvalid,
	output logic        mem_axi_awready,
	input  logic [31:0] mem_axi_awaddr,
	input  logic [ 2:0] mem_axi_awprot,

	input  logic        mem_axi_wvalid,
	output logic        mem_axi_wready,
	input  logic [31:0] mem_axi_wdata,
	input  logic [ 3:0] mem_axi_wstrb,

	output logic        mem_axi_bvalid,
	input  logic        mem_axi_bready,

	input  logic        mem_axi_arvalid,
	output logic        mem_axi_arready,
	input  logic [31:0] mem_axi_araddr,
	input  logic [ 2:0] mem_axi_arprot,

	output logic        mem_axi_rvalid,
	input  logic        mem_axi_rready,
	output logic [31:0] mem_axi_rdata
);

//note: need to implement support for unaligned addresses
// chatgpt:
// "No alignment check — you currently accept any byte address. 
// If master sends an unaligned address (low two bits ≠ 0) you will compute an index but return the whole 32-bit word; 
// that may be unexpected. Either check alignment and return a default/error, or support byte granularity. 
// I recommend adding a simple alignment test (mem_addr_buffer[1:0] == 2'b00)."

    reg [31:0] memory [0:MEM_WORDS-1];

	logic [31:0] mem_read_buffer;
	logic [31:0] mem_addr_buffer;
	typedef enum logic [1:0] {capture, load, hold} read_state_t;
	read_state_t read_fsm;

	always_ff @(posedge clk or negedge resetn) begin : read_logic
		if (!resetn) begin 
			mem_read_buffer <= 0;
			mem_addr_buffer <= 0;
			mem_axi_rvalid <= 0;
			mem_axi_rdata <= 0;
			mem_axi_arready <= 1; //note, you'll need to control arready even during write logic, hence im not setting it to anything in the capture fsm
			read_fsm <= capture;
		end else begin 
			case (read_fsm)
				capture: begin 
					mem_axi_rvalid <= 0;
					mem_axi_rdata <= 0;

					if (mem_axi_arvalid && mem_axi_arready) begin
						mem_addr_buffer <= mem_axi_araddr;
						read_fsm <= load;
					end
				end

				load: begin 
					mem_axi_rvalid <= 0;
					mem_axi_rdata <= 0;

					int unsigned word_index; //note: do this word_index dance in write logic too

					if ((mem_addr_buffer >= ROM_ORIGIN && mem_addr_buffer < ROM_ORIGIN + ROM_LENGTH)) begin

						word_index = (mem_addr_buffer - ROM_ORIGIN) >> 2;

						if (word_index < MEM_WORDS) begin 
							mem_read_buffer <= memory[word_index];
							read_fsm <= hold;
						end else read_fsm <= capture;

						mem_axi_arready <= 0;
					end
					else if ((mem_addr_buffer >= RAM_ORIGIN && mem_addr_buffer < RAM_ORIGIN + RAM_LENGTH)) begin

						word_index = (mem_addr_buffer - RAM_ORIGIN) >> 2;

						if (word_index < MEM_WORDS) begin 
							mem_read_buffer <= memory[word_index];
							read_fsm <= hold;
						end else read_fsm <= capture;

						mem_axi_arready <= 0;
					end
					else begin 
						read_fsm <= capture;
						mem_axi_arready <= 1;
					end
				end

				hold: begin 
					mem_axi_rvalid <= 1;
					mem_axi_rdata <= mem_read_buffer;
					if (mem_axi_rready) begin
						mem_axi_rvalid <= 0;
						read_fsm <= capture;
						mem_axi_arready <= 1;
					end
				end

				default: read_fsm <= capture;
			endcase
		end
	end
endmodule