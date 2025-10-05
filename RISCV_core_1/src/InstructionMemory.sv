module InstructionMemory(
    input logic [31:0] addr,
    output logic [31:0] data);

    reg [31:0] IMem [15:0];

    initial $readmemh("D:\Z\projects\RISCV_project\RISCV_core\programs\example_program_3.hex", IMem);
	//use only "programs/example_program_3.hex" if youre only gonna upload onto hardware
	//use the full path like above if you want to use questa and also upload onto hardware

    assign data = IMem[addr >> 2];
endmodule

