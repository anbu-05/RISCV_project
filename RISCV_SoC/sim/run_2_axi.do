# create & map work library
vlib work
vmap work work

# Compile design RTL (adjust path if needed)
# If you want compressed-isa defines like the Makefile, use +define+COMPRESSED_ISA
vlog ../rtl/picorv32.v
vlog ../rtl/simple_mem_axi.sv
vlog ../rtl/top_axi.sv

# Compile the tiny testbench (file in current dir)
vlog ../tb/testbench_2_axi.sv

# Launch simulation with accessibility for internal signals
vsim work.testbench_2_axi -voptargs="+acc"

add wave -divider "Clock and Reset"
add wave sim:/testbench_2_axi/clk
add wave sim:/testbench_2_axi/resetn

add wave -divider "AXI Interface signals"

add wave -divider "Clock and Reset"
add wave sim:/testbench_2_axi/clk
add wave sim:/testbench_2_axi/resetn

add wave -divider "read signals"
add wave sim:/testbench_2_axi/dut/mem/read_fsm
add wave -divider "   - Read Address Channel"
add wave sim:/testbench_2_axi/dut/mem_axi_arvalid
add wave sim:/testbench_2_axi/dut/mem_axi_arready
add wave sim:/testbench_2_axi/dut/mem_axi_araddr
add wave sim:/testbench_2_axi/dut/mem_axi_arprot

add wave -divider "   - Read Data Channel"
add wave sim:/testbench_2_axi/dut/mem_axi_rvalid
add wave sim:/testbench_2_axi/dut/mem_axi_rready
add wave sim:/testbench_2_axi/dut/mem_axi_rdata

add wave -divider "Clock and Reset"
add wave sim:/testbench_2_axi/clk
add wave sim:/testbench_2_axi/resetn

add wave -divider "write signals"
add wave sim:/testbench_2_axi/dut/mem/write_fsm
add wave -divider "   - Write Address Channel"
add wave sim:/testbench_2_axi/dut/mem_axi_awvalid
add wave sim:/testbench_2_axi/dut/mem_axi_awready
add wave sim:/testbench_2_axi/dut/mem_axi_awaddr
add wave sim:/testbench_2_axi/dut/mem_axi_awprot

add wave -divider "   - Write Data Channel"
add wave sim:/testbench_2_axi/dut/mem_axi_wvalid
add wave sim:/testbench_2_axi/dut/mem_axi_wready
add wave sim:/testbench_2_axi/dut/mem_axi_wdata
add wave sim:/testbench_2_axi/dut/mem_axi_wstrb

add wave -divider "   - Write Response Channel"
add wave sim:/testbench_2_axi/dut/mem_axi_bvalid
add wave sim:/testbench_2_axi/dut/mem_axi_bready

#add wave -divider "memory bus signals"
#add wave sim:/testbench_2_axi/dut/mem_valid
#add wave sim:/testbench_2_axi/dut/mem_instr
#add wave sim:/testbench_2_axi/dut/mem_ready
#add wave sim:/testbench_2_axi/dut/mem_addr
#add wave sim:/testbench_2_axi/dut/mem_wdata
#add wave -radix binary sim:/testbench_2_axi/dut/mem_wstrb
#add wave sim:/testbench_2_axi/dut/mem_rdata

run 10us
