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

//---------read logic---------

	logic [31:0] mem_read_buffer;
	logic [31:0] mem_read_addr_buffer;
	logic [$clog2(MEM_WORDS)-1:0] read_word_index;
	typedef enum logic [1:0] {read_capture, load, hold} read_state_t;
	read_state_t read_fsm;

	always_ff @(posedge clk or negedge resetn) begin : read_logic
		if (!resetn) begin 
			mem_read_buffer <= 0;
			mem_read_addr_buffer <= 0;
			mem_axi_rvalid <= 0;
			mem_axi_rdata <= 0;
			mem_axi_arready <= 1; //note, you'll need to control arready even during write logic, hence im not setting it to anything in the read_capture fsm
			//further note: the fsm wont move on from read_capture state unless you reset it once. this is because arread is left floating till reset is applied
			read_fsm <= read_capture;
		end else begin 
			case (read_fsm)
				read_capture: begin 
					mem_axi_rvalid <= 0;
					mem_axi_rdata <= 0;
					//maybe add mem_axi_arready <= 1; if youre facing problems when using the memory without resetting
					if (mem_axi_arvalid && mem_axi_arready) begin
						mem_read_addr_buffer <= mem_axi_araddr;
						read_fsm <= load;
					end
				end

				load: begin 
					mem_axi_rvalid <= 0;
					mem_axi_rdata <= 0;

					//note: do this word_index dance in write logic too

					if ((mem_read_addr_buffer >= ROM_ORIGIN && mem_read_addr_buffer < ROM_ORIGIN + ROM_LENGTH)) begin

						read_word_index = (mem_read_addr_buffer - ROM_ORIGIN) >> 2;

						if (read_word_index < MEM_WORDS) begin 
							mem_read_buffer <= memory[read_word_index];
							read_fsm <= hold;
						end else read_fsm <= read_capture;

						mem_axi_arready <= 0;
					end
					else if ((mem_read_addr_buffer >= RAM_ORIGIN && mem_read_addr_buffer < RAM_ORIGIN + RAM_LENGTH)) begin

						read_word_index = (mem_read_addr_buffer - RAM_ORIGIN) >> 2;

						if (read_word_index < MEM_WORDS) begin 
							mem_read_buffer <= memory[read_word_index];
							read_fsm <= hold;
						end else read_fsm <= read_capture;

						mem_axi_arready <= 0;
					end
					else begin 
						read_fsm <= read_capture;
						mem_axi_arready <= 1;
					end
				end

				hold: begin 
					mem_axi_rvalid <= 1;
					mem_axi_rdata <= mem_read_buffer;
					if (mem_axi_rready) begin
						read_fsm <= read_capture;
						mem_axi_arready <= 1;
					end
				end

				default: read_fsm <= read_capture;
			endcase
		end
	end

//---------write logic---------

	//note: picorv32 does not have a bresp channel. it doesnt have the full implementation of axi lite

	logic [31:0] mem_write_buffer;
	logic [31:0] mem_write_addr_buffer;
	logic [$clog2(MEM_WORDS)-1:0] write_word_index;
	typedef enum logic [1:0] {write_capture, store, respond} write_state_t;
	write_state_t write_fsm;

	always_ff @(posedge clk or negedge resetn) begin : write_logic
		if (!resetn) begin 
			mem_write_buffer <= 0;
			mem_write_addr_buffer <= 0;
			mem_axi_awready <= 1;
			mem_axi_wready <= 0;
			write_fsm <= write_capture;
		end else begin 
			case (write_fsm)
				write_capture: begin 
					mem_axi_bvalid <= 0;
					if (mem_axi_awvalid && mem_axi_awready) begin
						mem_axi_wready <= 1;
						mem_write_addr_buffer <= mem_axi_awaddr;
						write_fsm <= store;
					end
				end

				store: begin
						if (mem_axi_wvalid && mem_axi_wready) begin
							if ((mem_write_addr_buffer >= ROM_ORIGIN && mem_write_addr_buffer < ROM_ORIGIN + ROM_LENGTH)) begin

								write_word_index = (mem_write_addr_buffer - ROM_ORIGIN) >> 2;

								if (write_word_index < MEM_WORDS) begin 
									if (mem_axi_wstrb[0]) memory[write_word_index][ 7: 0] <= mem_axi_wdata[ 7: 0];
									if (mem_axi_wstrb[1]) memory[write_word_index][15: 8] <= mem_axi_wdata[15: 8];
									if (mem_axi_wstrb[2]) memory[write_word_index][23:16] <= mem_axi_wdata[23:16];
									if (mem_axi_wstrb[3]) memory[write_word_index][31:24] <= mem_axi_wdata[31:24];
									write_fsm <= respond;
								end else write_fsm <= write_capture;
							end
							else if ((mem_write_addr_buffer >= RAM_ORIGIN && mem_write_addr_buffer < RAM_ORIGIN + RAM_LENGTH)) begin

								write_word_index = (mem_write_addr_buffer - RAM_ORIGIN) >> 2;

								if (write_word_index < MEM_WORDS) begin 
									if (mem_axi_wstrb[0]) memory[write_word_index][ 7: 0] <= mem_axi_wdata[ 7: 0];
									if (mem_axi_wstrb[1]) memory[write_word_index][15: 8] <= mem_axi_wdata[15: 8];
									if (mem_axi_wstrb[2]) memory[write_word_index][23:16] <= mem_axi_wdata[23:16];
									if (mem_axi_wstrb[3]) memory[write_word_index][31:24] <= mem_axi_wdata[31:24];
									write_fsm <= respond;
								end else write_fsm <= write_capture;
							end
							else begin 
								write_fsm <= write_capture;
							end
						end else if (mem_axi_awvalid && mem_axi_awready) write_fsm <= store;
						else write_fsm <= write_capture;
					end

				respond: begin
					mem_axi_bvalid <= 1;
					mem_axi_wready <= 0;
					if (mem_axi_bready) begin
						write_fsm <= write_capture;
					end
				end

				default: write_fsm <= write_capture;
			endcase
		end
	end

//---------loading program into memory---------
	// if ROM_ORIGIN is non-zero, load hex starting at that offset in the array
    initial begin
		$readmemh("../programs/smoke_test.hex", memory, ROM_ORIGIN);
    end
endmodule