# Custom RISC-V Core

This is a custom RISC-V core I built. The goal is to implement all the base instructions, one step at a time.

## Overview

Main directory: `/Basic_RISCV_core/`

Folder structure:

```
/Basic_RISCV_core/
├─ program_compiler/ 
│  └─ programs/          # storage for files
├─ RISCV_core/           # Main CPU design
│  ├─ rtl/               # Design (ALU, RegisterFile, Decoder, etc.)
│  ├─ tb/                # Testbench files
│  └─ sim/               # Questa simulation setup (run.do and configs)
└─ README.md
```

The core is designed to work with Intel/Altera QuestaSim.

## Running the Core

1. Open a terminal in `/Basic_RISCV_core/RISCV_core/sim/`
2. Edit `run.do` to select which waveforms you want to view.

   (note: you need to use `-voptargs="+acc"` in your `run.do`, or questa doesnt show all the memory mappings properly for some reason)
3. Use the compiler (see below) to generate a `.hex` file for your program and place it in the `programs/` folder.
4. In `InstructionMemory.sv`, update the following line with your hex file name:
   ```verilog
   initial $readmemh("../programs/rv32i_tests.hex", IMem);
   ```
5. Start Intel/Altera Questa sim
   ```
   vsim &
   ```
6. Verify you are in the correct directory inside Questa:
   ```bash
   pwd
   ```
   It should be `/Basic_RISCV_core/RISCV_core/sim`.
7. &#x20;run the simulation:
   ```tcl
   do run.do
   ```

## Compiler

I made a simple Python-based compiler using the `riscv-assembler` library by celebi. The focus here is simplicity, not optimization.

### Writing Programs

Keep these rules in mind:

- Each instruction is 4 bytes (word-aligned).
- For B- and J-type immediates, use the “x2 rule”:
  ```
  imm = (target_byte_address - current_pc_bytes) / 2
  ```
  Example: branch at PC = 24 to byte address 32 → offset = 8 → imm = 4
- `jalr` uses a raw I-type immediate (no x2 scaling).
- `lui` loads `imm` into bits [31:12] (imm << 12).

You can write your programs like normal assembly, but I recommend keeping track of addresses in comments:

```assembly
addi x1, x0, 10         ; addr = 0
addi x2, x0, 15         ; addr = 4
add  x3, x1, x2         ; addr = 8
sub  x4, x2, x1         ; addr = 12
xor  x5, x1, x2         ; addr = 16
or   x6, x1, x2         ; addr = 20
and  x7, x1, x2         ; addr = 24
sll  x8, x1, x0         ; addr = 28
slli x9, x1, 2          ; addr = 32
srl  x10, x2, x1        ; addr = 36
sra  x11, x1, 1         ; addr = 40
slt  x12, x1, x2        ; addr = 44
sltu x13, x1, x2        ; addr = 48
add  x31, x3, x4        ; addr = 52
```

This format makes debugging much easier while the core is still under development.

### Preprocessing and Compilation

1. Run the preprocessor to remove comments:
   ```bash
   python3 preprocessor.py XYZ.s xyz.s
   ```
2. Compile the program:
   ```bash
   python3 riscv_compiler.py xyz.s xyz.hex
   ```
3. Move the generated `.hex` file to `/Basic_RISCV_core/RISCV_core/programs/`

Your custom RISC-V program is now ready to run on the core.

