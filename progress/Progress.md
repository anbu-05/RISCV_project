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
- read the [[notes]]
- need to look into adding a submodule
```
hint: You've added another git repository inside your current repository.
hint: Clones of the outer repository will not contain the contents of
hint: the embedded repository and will not know how to obtain it.
hint: If you meant to add a submodule, use:
hint:
hint:   git submodule add <url> pico/picorv32
hint:
hint: If you added this path by mistake, you can remove it from the
hint: index with:
hint:
hint:   git rm --cached pico/picorv32
hint:
hint: See "git help submodule" for more information.
hint: Disable this message with "git config set advice.addEmbeddedRepo false"
```

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

- meeting [[MoM 13 Sep]]:
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

### 17 Sep
- i put a pause on running it on FPGA
- trying to run this on a simulator because they want this on a synthesis tool.
- converting all the files into something that can be run on modelsim
- made a new copy of the picorv32 project (as picorv32-sim)
- started learning about systemverilog testbenches and UVM testbench framework
- started making a top_tb.sv
---
- paused work on testbenches, because i forgot to change sram and mem_init -working rn to change sram and meminit to work on modelsim
- when changing from the grug pico to modelsim pico.
	- i want to keep this file structure: top.sv, sram.sv and mem_init.sv

- what im gonna do now:
	- restructure mem_init.sv to be simulator friendly
	- make a python script to convert grug's mem_init.sv to sim mem_init.sv
	- change sram.sv to use this new mem_init.sv while functioning the same way in top.sv
---
- ive given up on trying to use chatgpt to make it for me. ill go through sram.sv and do it myself. ill compile and reformat the c code myself.
---
- i am researching on this sram.v module ([ELI5 SRAM behavior](https://chatgpt.com/c/68cbf088-0d80-8322-92fd-6f1e1352348d)), and a few things are coming to my notice
	- if you want a single cycle cpu, whatever premade SRAM module we're using will need to be async/combinational. 
### 19 Sep
- here's my decisions for the sram.v module
	- read: i will implement both sync and async, and have a compiler directive to pick between the two.
	- read during write: write-through
	- it will have 32-bit aligned addresses. a 13 bit address line, but also a 4 bit wstrb.
	- here's about writestrobes: [RISCV_core - ELI5 SRAM behavior](https://chatgpt.com/c/68cbf088-0d80-8322-92fd-6f1e1352348d)
	- the data itself will be in a hex file and we will load it onto memory using `$readmemh`
- started work on the sram.sv file
	- made async mem read behavior -need to verify using chatgpt
	- working on mem write behavior

#### 26 Sep
- **few questions for prof: why do we use write strobes instead of just direct addresses?**
- [[SRAM implementation verification]]
- writing new sram behavior referred to this: https://chatgpt.com/s/t_68d7695722f481918379c2fe7a6f6adf
### 27 Sep
- ive decided async read would be too complicated to implement because of write through. i am gonna implement only sync read -the mem block will return data 1 cycle after the address is received.
- i made the first iteration, and ik for a fact it's full of misunderstandings. i need to go through [this](https://chatgpt.com/s/t_68d7d3f468a48191bc7ec89bfa873d01) to find required changes
- i read through chatgpt, made some more changes.
- ive realised that i need to make a testbench for this sram.sv module if i wanna develop it any further -because im at a point where everything seems like it will work right, but chatgpt tells me that it will work right logically, even in simulation, but it wont work right on sillicon.
https://chatgpt.com/s/t_68d8366faaa0819195eae2e6e3fca33e

>Nice — you’re very close. Your instinct (make the writes happen into a buffer, then write that into memory, then read memory) is reasonable _in simulation_, but it relies on implementation details and blocking-assignment behaviour that are fragile and can badly mismatch real hardware or synthesis tools. Below I’ll walk through the exact problems (ELI15), why they matter, and give a clean, robust replacement pattern you can drop in.

> ## Quick test ideas to convince yourself
> 
> - Write byte 1 only (`wstrb = 4'b0010`) to address A with data D. Immediately read address A in the same cycle. Expect read to return old_word with byte1 replaced by D[15:8] (merged result) — your testbench should assert this.
>     
> - Try halfword write (`wstrb = 4'b0011`) and verify both bytes changed.
>     
> - Try no-write (`wstrb = 4'b0000`) and ensure read returns the old memory.
>     
> - Run the tests both with the simulator and on FPGA (or with vendor memory model) if possible — behavior should match.

---
- i need to make a testbench for the sram module
- i need to recreate the github repo for this project properly (referring to how i did it for vyadh)

### Oct 5
- reformated the RISCV github page (didnt check the README tho)
	- discovered about worktrees, finally understood how branches work on the directory.

### Oct 9
- reading through chipverify to learn how to make testbenches
	- [SystemVerilog TestBench](https://www.chipverify.com/systemverilog/systemverilog-simple-testbench)
	- [SystemVerilog Testbench Example 1](https://www.chipverify.com/systemverilog/systemverilog-testbench-example-1)
	- [UVM Testbench Example 1](https://www.chipverify.com/uvm/uvm-testbench-example-1)
- taking reference from chatgpt on what files and code blocks to make [RISCV_core - Testbench example guidance](https://chatgpt.com/g/g-p-68c2b3f837f88191bf603055f1e243ba-riscv-core/c/68e6df5e-b3fc-8324-ad5b-657852e18a87)
---
had a meeting with jayakrishnan sir
- he needs to know the specs and usage of UART and timer
- needs to remove modules like LED controller, CDT (probably not CDT)
- needs to add a timer and an interrupt module
- he needs this for his a CDAC meeting which he has tomorrow afternoon

- this CPU probably needs a bus of sorts -everything is connected to everything, there is no bus in the top module
- checkout for the research work done on this: [[UART-Timer-Interrupt_Rev3]]

---
- note: there's this snippet of code in simpleuart.sv that might be useful in making the SRAM:
```
    always @(posedge clk) begin
        if (!resetn) begin
            cfg_divider <= DEFAULT_DIV;
        end else begin
            if (reg_div_we[0]) cfg_divider[ 7: 0] <= reg_div_di[ 7: 0];
            if (reg_div_we[1]) cfg_divider[15: 8] <= reg_div_di[15: 8];
            if (reg_div_we[2]) cfg_divider[23:16] <= reg_div_di[23:16];
            if (reg_div_we[3]) cfg_divider[31:24] <= reg_div_di[31:24];
        end
    end
```
- note: need to get to this point (seeing that command list -which i assume is the cpu displaying all of it's available commands in the sample program) using an FPGA: https://youtu.be/49mK_JVVM_0?list=PL7bIsDBNgNWsOMSPGQcaWWmu-4CNgrxn_&t=447


---
### Oct 12
- we have to look into whether picorv32 is pipelined
- if it is we have to look for alternatives/make our own riscv core
- we need to look into alternatives but oct 13 (monday), if we're modifying by oct 18 (end of the week), and if we're building from scratch -by oct 25 (2 weeks)
- we'll use the comp arch DA
	- we'll have to modify it to boot from the sram, instead of hardcoding the data onto the sram module, i.e, create an sram module
	- let the multiplication be multicycle, instead of making a combinational model
		- afrath and vikas have a multipler already -it takes 18 cycles.
		- few people have done division
	- we'll explore division later
	- we'll need to make an APB bus
- to be done: include SRAM (teusday) > multiplication (teusday) > APB

### Oct 14
- researched about bootloaders -their point. [[Bootloader]]

### Oct 16
- fixed and ran the Basic RISCV32I implementation that i was working on since the beginning. paused picorv32 for a while
- got everything working, but now ive realised that the compiler for the thing broke. im guessing the library im using to compile it has depreciated
- im gonna use an online compiler. but i need to fix this manual compiler somehow

### Oct 17
- updated readme and pushed the changes
- ive realised that the riscv-assembler library is dogshit. i am going to make my own riscv-assembler program.