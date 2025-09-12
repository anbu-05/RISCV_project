transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/ProgramCounter.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/RegisterFile.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/types.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/RISCV_core {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/RISCV_core/RISCV_core.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/InstructionMemory.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/decoder.sv}
vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/ALU.sv}

vlog -sv -work work +incdir+D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2 {D:/Z/projects/RISCV_project/before_hiatus/RISCV_core_quartus_V2/TB_RISCV_core.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  TB_RISCV_core

add wave *
view structure
view signals
run -all
