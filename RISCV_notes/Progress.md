### 13 may
- finally got simulation working on quartus prime after a lot of work
- [can you make an easy-to-follow tutorial to get the simulation up and running?...](https://www.perplexity.ai/search/can-you-make-an-easy-to-follow-3E0_5UZYRbGqW0mCqE26Vw) -this convo's last prompt has everything you need to get everything up and running
- need to go through the previous files that ive worked on. study everything, and remake this cpu core from scratch. need to make it in a much cleaner way this time, since ive gotten used to the workflow.

### 14 may
- copied everything to a new project, set up the workspace
---
- made a list of all the instructions, with if theyre implemented or not, and if they need testing or not
- noted down the progress before the hiatus from notebook

### 20 may
- fixed the compiler to not add 0x infront of each line
- changed IMem file such that it can be simulated on questa and synthesized 
- tried example_program_3 -the program works fine but there are some problems with my implementation of branch and jump instructions compared to the RISCV32I ISA. i need to check, and make notes, and redo all the branch and jump instructions

----
### 30 Aug
- there's been a second hiatus. great
- met with professor. now there's some direction to this project
- started restructuring the entire project. since i learnt about testbench automation/testcases/running scripts, CLI simulation and stuff, i am gonna follow that

- created a new RISCV_core project on quartus.
- remade the program counter -and made it a bit simpler.
- found out the required testcases for testing a program counter and made a testbench that saves the testcases' result in a log file: [Program counter testbench](https://chatgpt.com/c/68b3447f-b1a4-8330-b84a-c14acbbfe17e)
- trying to make the new restructure be both simulation and synthesis friendly.

- i am using vscode for running the commands. need to dualboot linux asap to move to that
- trying to simulate the testbench: [questa testbench simulation](https://chatgpt.com/c/68b350fe-cd4c-832f-a9e0-d57896a86450)

- need to fix README.md

### 31 Aug
- setting up simulation environment: https://chatgpt.com/s/t_68b3e52e1d888191bf106327f6f85d1a, https://chatgpt.com/s/t_68b3ee2b9c18819189ade1abd3c0ceaf
- `vsim` to run modelsim/questa (`vsim -c` doesnt work for the next command for some reason)
- `do sim/run.do` to run simulation
- finally got a .do file working to initiate modelsim for simulation

(need to include a way to program the IMem when making it)


### 1 Sep
- added more testcases to ProgramCounter module

### 2 Sep
- finished the first fully functional testbench with logging
- [Fixing testbench errors](https://chatgpt.com/c/68b6e851-c094-8325-b1d8-841f7c2958e3)
- need to discuss the core specs with saravana

---
### 12 Sep
- restructured RISCV_core based on a structure taught in SLV class
- going through grug huhler's picoRV32. his goals are very aligned to ours
- read the notes [here](Team/notes.md)
- need to look into adding a submodule
`hint: You've added another git repository inside your current repository.`
`hint: Clones of the outer repository will not contain the contents of`
`hint: the embedded repository and will not know how to obtain it.`
`hint: If you meant to add a submodule, use:`
`hint:`
`hint:   git submodule add <url> pico/picorv32`
`hint:`
`hint: If you added this path by mistake, you can remove it from the`
`hint: index with:`
`hint:`
`hint:   git rm --cached pico/picorv32`
`hint:`
`hint: See "git help submodule" for more information.`
`hint: Disable this message with "git config set advice.addEmbeddedRepo false"`

---
- trying to modify grug huhler's picorv32 to get it working on a DE2-115
- everything else is fine, only top.v, sram.v, and gowin_sp.v are creating problems
- when compiling in quartus, Quartus expects a different name for the top level entitiy: fix for that:
## ✅ Fix
You need to **tell Quartus the correct top-level entity**:
1. Open your `.qsf` (project settings file) in a text editor or Quartus GUI.
2. Find the line:
    `set_global_assignment -name TOP_LEVEL_ENTITY picorv32-DE2115`
3. Change it to:
    `set_global_assignment -name TOP_LEVEL_ENTITY top`
(or whichever module you want as the FPGA top — probably `top` in `top.v`).

- sram.v and gowin_sp.v are causing problems because they are files designed for the tang nano 9k FPGA. read about it [RISCV_core - Compare RISCV cores (last prompt)](https://chatgpt.com/g/g-p-68c2b3f837f88191bf603055f1e243ba/c/68c2b6be-b6d4-832e-8d5e-baee84fe72a3)
- since quartus prefers inferred ram, i will be changing gowin_sp to inferred ram. quartus will automatically map this to it's M9K memory
- i will need to change mem_init.sv to mem_init.hex as well

- made the changes. now the sram problem is probably fixed and everything compiles.

tomorrow:
- need to figure out what this program that ive loaded in mem_init.hex actually does + need to change the LED init file as that also changes for DE2-115
- need to go through sram_infer

### 13 Sep

- meeting:
	- looked into picorv32 implementation by grug huhler (https://github.com/grughuhler/picorv32/tree/main)
	- we need to split into two teams
		- implement this on different synthesis tool like cadence/synopsis
		- make a block diagram -refer to ravensoc and based on grug huhler's picorv32
	
	- there are other teams working on SoCs -we have competition, and we need to make the best core to get budget for tapeout.
	- try to make RAM a peripheral
	- grug huhler's implementation might not be a single cycle CPU - need to check it.
	- we are looking for a new person -we need confirmation by wednesday
- did pin assignments for all input and output of top module
- need to check sda file, and probably add a clock module to reduce 50mhz to 27mhz