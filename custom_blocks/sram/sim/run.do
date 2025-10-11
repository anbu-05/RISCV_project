vlib work
vmap work work

# Compile design RTL
vlog ../rtl/*.sv

# Compile testbench files
#vlog ../tb/*.sv

# Simulate
#vsim top
vsim top
add wave *
run 200ps