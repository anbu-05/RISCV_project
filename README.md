# Custom RISCV core

this is a custom RISCV core that I made. im trying to implement all the instructions.

## how to use
### running the core
the main directory is [RISCV_core](/Basic_RISCV_core/RISCV_core/)

the directory consists of:
- rtl: design files
- tb: test bench files
- sim: simulator's files (and run.do)

I designed this core with questa sim in mind

open a terminal in [/Basic_RISCV_core/RISCV_core/sim/](/Basic_RISCV_core/RISCV_core/sim/), and run the following

```
vsim
do run.do
```

edit the [run.do](/Basic_RISCV_core/RISCV_core/sim/run.do) file based on what waves you want to see

use the [compiler](#compiler) to create a hex file and put it in the [/RISCV_core/programs](/Basic_RISCV_core/RISCV_core/programs/) folder

edit `initial $readmemh("../programs/rv32i_tests.hex", IMem);`  in [Instruction Memory](/Basic_RISCV_core/RISCV_core/rtl/InstructionMemory.sv) with the hex file from above

when questa opens, verify you are in the right directory (/Basic_RISCV_core/RISCV_core/sim) using `pwd`

in questa, run: `do run.do`

### compiler

ive created a simple python based compiler using the [riscv-assembler library by celebi](https://github.com/celebi-pkg/riscv-assembler/tree/main), since the goal is not efficiency, rather simplicity

there are some things you need to watch out for when writing the programs:
 - Instructions are 4 bytes each (word-aligned).
 - For numeric B- and J-type immediates use the "x2" rule: 

`imm = (target_byte_address - current_pc_bytes) / 2`

Example: branch at PC=24 to byte address 32 -> byte_offset=8 -> imm=4

 - jalr uses a raw I-type immediate (no x2 scaling).
 - LUI loads imm into bits[31:12] (imm << 12).

you can write your programs like usual assembly, but i recommend writing it this way
```
addi x1, x0, 10         ; addr=0
addi x2, x0, 15         ; addr=4
add x3, x1, x2          ; addr=8
sub x4, x2, x1          ; addr=12
xor x5, x1, x2          ; addr=16
or x6, x1, x2           ; addr=20
and x7, x1, x2          ; addr=24
sll x8, x1, x0          ; addr=28
slli x9, x1, 2          ; addr=32
srl x10, x2, x1         ; addr=36
sra x11, x1, 1          ; addr=40
slt x12, x1, x2         ; addr=44
sltu x13, x1, x2        ; addr=48
add x31, x3, x4         ; addr=52
```
with the addresses in commented after each line, so that you can keep track of where each instruction is

this is because this core is still in development, and ive found this to be very helpful in debugging

after that, run [preprocessor.py](/Basic_RISCV_core/program_compiler/preprocessor.py) to remove the comments (the python based compiler)

and after that, using the output file from the preprocessor, run the compiler: [riscv_compiler.py](/Basic_RISCV_core/program_compiler/riscv_compiler.py)

```
python3 preprocessor.py XYZ.s xyz.s
python3 riscv_compiler.py xyz.s [xyz.hex]
```
now you can take move this file to the [RISCV core program directory](/Basic_RISCV_core/RISCV_core/programs/)
