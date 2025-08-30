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
### 31 Aug
- there's been a second hiatus. great
- met with professor. now there's some direction to this project
- started restructuring the entire project. since i learnt about testbench automation/testcases/running scripts, CLI simulation and stuff, i am gonna follow that

- created a new RISCV_core project on quartus.
- remade the program counter -and made it a bit simpler.
- found out the required testcases for testing a program counter and made a testbench that saves the testcases' result in a log file: [Program counter testbench](https://chatgpt.com/c/68b3447f-b1a4-8330-b84a-c14acbbfe17e)
- trying to make the new restructure be both simulation and synthesis friendly.

- i am using vscode for running the commands. need to dualboot linux asap to move to that
- trying to simulate the testbench: [questa testbench simulation](https://chatgpt.com/c/68b350fe-cd4c-832f-a9e0-d57896a86450)