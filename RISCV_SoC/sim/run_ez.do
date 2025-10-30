# create & map work library
vlib work
vmap work work

# Compile design RTL (adjust path if needed)
# If you want compressed-isa defines like the Makefile, use +define+COMPRESSED_ISA
vlog +define+COMPRESSED_ISA ../rtl/picorv32.v
vlog ../rtl/simple_mem.sv
vlog ../rtl/top.sv

# Compile the tiny testbench (file in current dir)
vlog ../tb/testbench_ez.v

# Launch simulation with accessibility for internal signals
vsim work.testbench_ez -voptargs="+acc"

add wave sim:/testbench_ez/clk
add wave sim:/testbench_ez/resetn
add wave sim:/testbench_ez/uut/mem_valid
add wave sim:/testbench_ez/uut/mem_instr
add wave sim:/testbench_ez/uut/mem_ready
add wave sim:/testbench_ez/uut/mem_addr
add wave sim:/testbench_ez/uut/mem_wdata
add wave -radix binary sim:/testbench_ez/uut/mem_wstrb
add wave sim:/testbench_ez/uut/mem_rdata

run 1us
