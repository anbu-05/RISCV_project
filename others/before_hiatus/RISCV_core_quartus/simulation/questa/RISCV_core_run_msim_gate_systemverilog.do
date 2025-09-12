transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {RISCV_core.svo}

vlog -sv -work work +incdir+D:/Z/projects/RISCV\ project/RISCV_core_quartus {D:/Z/projects/RISCV project/RISCV_core_quartus/TB_Core.sv}

vsim -t 1ps -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  TB_core

add wave *
view structure
view signals
run -all
