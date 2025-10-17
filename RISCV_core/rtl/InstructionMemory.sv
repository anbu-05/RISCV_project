module InstructionMemory(
    input logic [31:0] addr,
    output logic [31:0] data);

    reg [31:0] IMem [255:0];

    initial $readmemh("../programs/rv32i_tests.hex", IMem);
	//use only "programs/example_program_3.hex" if youre only gonna upload onto hardware
	//use the full path like above if you want to use questa and also upload onto hardware

    assign data = IMem[addr >> 2];
endmodule

