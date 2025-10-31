# create & map work library
vlib work
vmap work work

# Compile design RTL (adjust path if needed)
# If you want compressed-isa defines like the Makefile, use +define+COMPRESSED_ISA
vlog ../rtl/simple_mem.sv

# Compile the tiny testbench (file in current dir)
vlog ../tb/testbench_mem.sv

# Launch simulation with accessibility for internal signals
vsim work.testbench_mem -voptargs="+acc"


add wave sim:/testbench_mem/clk
add wave sim:/testbench_mem/resetn
add wave sim:/testbench_mem/mem/mem_valid
add wave sim:/testbench_mem/mem/mem_instr
add wave sim:/testbench_mem/mem/mem_ready
add wave sim:/testbench_mem/mem/mem_addr
add wave sim:/testbench_mem/mem/mem_wdata
add wave -radix binary sim:/testbench_mem/mem/mem_wstrb
add wave sim:/testbench_mem/mem/mem_rdata

run 5us
