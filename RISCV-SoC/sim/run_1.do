# create & map work library
vlib work
vmap work work

# Compile design RTL (adjust path if needed)
# If you want compressed-isa defines like the Makefile, use +define+COMPRESSED_ISA
vlog ../rtl/picorv32.v
vlog ../rtl/simple_mem.sv
vlog ../rtl/top.sv

# Compile the tiny testbench (file in current dir)
vlog ../tb/testbench_0.v
vlog ../tb/testbench_ez.v
vlog ../tb/testbench_1.sv

# Launch simulation with accessibility for internal signals
vsim work.testbench_1 -voptargs="+acc"


add wave sim:/testbench_1/clk
add wave sim:/testbench_1/resetn
add wave sim:/testbench_1/dut/mem_valid
add wave sim:/testbench_1/dut/mem_instr
add wave sim:/testbench_1/dut/mem_ready
add wave sim:/testbench_1/dut/mem_addr
add wave sim:/testbench_1/dut/mem_wdata
add wave -radix binary sim:/testbench_1/dut/mem_wstrb
add wave sim:/testbench_1/dut/mem_rdata

run 5us
