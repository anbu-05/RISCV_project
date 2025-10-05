transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/ProgramCounter.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/RegisterFile.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/types.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus/RISCV_core {D:/Z/projects/RISCV project/RISCV_core_quartus/RISCV_core/RISCV_core.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/InstructionMemory.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/decoder.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/ALU.sv}

