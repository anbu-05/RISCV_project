vlib work
vmap work work

# Compile design RTL
vlog src/*.sv

# Compile testbench
vlog sim/*_tb.sv

# Simulate
vsim ProgramCounter_tb
add wave *
run 200ps
