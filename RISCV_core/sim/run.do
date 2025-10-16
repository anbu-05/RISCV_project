vlib work
vmap work work

# Compile design RTL
vlog -sv ../rtl/*.sv

# Compile testbench
vlog -sv ../tb/*_tb.sv

# Simulate
# need the args to make sure questa doesnt optimize the run and hide certain variables.
vsim work.top_tb -voptargs="+acc" 

add wave *

# add wave top_tb/clk top_tb/reset top_tb/enable top_tb/DUT/addr top_tb/DUT/PC1/*

run 100ns
