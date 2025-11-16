module simpleuart_axi_adapter #(
    parameter MEM_WORDS = 3,
    parameter REG_ORIGIN = 32'h00018000,
    parameter REG_LENGTH = 32'h0000000c
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
	output logic [31:0] mem_axi_rdata,

    //simpleuart interface

	input  logic        ser_tx,
	output logic        ser_rx,

	output logic [ 3:0] reg_div_we,
	output logic [31:0] reg_div_di,
	input  logic [31:0] reg_div_do,

	output logic        reg_dat_we,
	output logic        reg_dat_re,
	output logic [31:0] reg_dat_di,
	input  logic [31:0] reg_dat_do,
	input  logic        reg_dat_wait
);

    reg [31:0] memory [0:MEM_WORDS-1];

//---------axi read logic---------

	logic [31:0] mem_read_buffer;
	logic [31:0] mem_read_addr_buffer;
	logic [$clog2(MEM_WORDS)-1:0] read_word_index;
	typedef enum logic [1:0] {read_capture, load, hold} read_state_t;
	read_state_t read_fsm;

	reg [31:0] read_memory_buffer [0:MEM_WORDS-1];

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

					if ((mem_read_addr_buffer >= REG_ORIGIN && mem_read_addr_buffer < REG_ORIGIN + REG_LENGTH)) begin

						read_word_index = (mem_read_addr_buffer - REG_ORIGIN) >> 2;

						if (read_word_index < MEM_WORDS) begin 
							mem_read_buffer <= memory[read_word_index];

                        //---------uart receive logic---------
                            uart_div_do_buffer <= reg_div_do;

                            if (reg_dat_re) begin 
                                uart_dat_do_buffer <= reg_dat_do;
                            end
                            
                            read_fsm <= hold;
						end else read_fsm <= read_capture;

						mem_axi_arready <= 0;
					end else begin 
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

//---------axi write logic---------

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
							if ((mem_write_addr_buffer >= REG_ORIGIN && mem_write_addr_buffer < REG_ORIGIN + REG_LENGTH)) begin

								write_word_index = (mem_write_addr_buffer - REG_ORIGIN) >> 2;

								if (write_word_index < MEM_WORDS) begin 
                                    if (!reg_dat_wait) begin
                                        if (mem_axi_wstrb[0]) memory[write_word_index][ 7: 0] <= mem_axi_wdata[ 7: 0];
                                        if (mem_axi_wstrb[1]) memory[write_word_index][15: 8] <= mem_axi_wdata[15: 8];
                                        if (mem_axi_wstrb[2]) memory[write_word_index][23:16] <= mem_axi_wdata[23:16];
                                        if (mem_axi_wstrb[3]) memory[write_word_index][31:24] <= mem_axi_wdata[31:24];

                                //---------uart transmit logic---------
                                        if (write_word_index == 1) begin 
                                            reg_div_we <= mem_axi_wstrb;
                                            reg_div_di <= memory[write_word_index];
                                        end else if (write_word_index == 2) begin
                                            reg_dat_we <= mem_axi_wstrb;
                                            reg_dat_di <= memory[write_word_index];
                                        end
                                        write_fsm <= respond;
                                    end else write_fsm <= store; //we're gonna need to do something to make sure that the cpu doesnt send the next byte of data. idk if this would do that
								end else write_fsm <= write_capture;
                            end else begin 
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

endmodule