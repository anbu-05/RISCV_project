1. ISA support: RISCV32M but with a modular structure so that it can be easily converted to a RISCV32E
2. single cycle
3. 32 x 32 bit general purpose registers
4. 1 x 64 (or 32) bit flag register to control the mux for different instruction types (we could have more than one flag registers based on external modules like UART)
5. 1 x 32 bit Instruction (buffer) register (this will load instruction from data memory and into the chip for the decoder to use) (need to discuss whether we need more than 1)
6. Program counter:
	- 32 Bit
	- increments by 4 for every clock cycle -for byte accessibility
	- will have jump options for word accessiblity
	- 