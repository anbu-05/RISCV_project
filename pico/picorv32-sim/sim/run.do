vlib work
vmap work work

# Compile design RTL
vlog ../rtl/*.sv

# Compile testbench files
#vlog ../tb/top_tb/*.sv

# Simulate
#vsim ProgramCounter_tb
vsim top
add wave *
run 200ps
