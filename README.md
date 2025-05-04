
# RISCV cpu core

this is a personal project of mine where i try to make a RISCV cpu core. it started off from a assignment my professor gave me -and it's come a long way.

#### the progress so far

i've made a cpu core using SystemVerilog, based on the RISCV32E ISA (future plans to use RISCV32I). it includes a program counter, decoder, registerfile, ALU, instruction memory, and data memory.

i've simulated everything on intel modelsim. there are a few bugs to fix, more tests to run, but it works pretty well

i've also implemented it on an FPGA. i used an altera DE2-115 (my university allows me to use them (big W honestly)), and intel quartus prime lite. -so all of my code is synthesizable.



## the core

![dataflow diagram](https://github.com/boneman420/RISCV-CPU-core-project/blob/main/pictures/RISCV_core_datapath.png)

#### notes:
there are a few differences between the simulation (modelsim) and FPGA (quartus) implementations. I am however trying to unify the modelsim and quartus implementations as much as possible (a few problems with quartus prime).

- data memory is not implemented in the quartus version -essentially the simuation has memory instructions, while the implementation doesnt, yet
- the instruction memory is different in the two versions. modelsim has an un-synthesizable instruction memory

## simulation

#### example programs:

1. [basic instructions](https://github.com/boneman420/RISCV-CPU-core-project/blob/main/programs/instructions.txt)
![basic instructions](https://github.com/boneman420/RISCV-CPU-core-project/blob/main/pictures/program%201%20modelsim.jpg)

2. [up counter at x31](https://github.com/boneman420/RISCV-CPU-core-project/blob/main/programs/example_program_1.txt)
![upcounter at x31](https://github.com/boneman420/RISCV-CPU-core-project/blob/main/pictures/program%202%20modelsim.jpg)

