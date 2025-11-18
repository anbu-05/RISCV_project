# create & map work library
vlib work
vmap work work

# Compile design RTL (adjust path if needed)
# If you want compressed-isa defines like the Makefile, use +define+COMPRESSED_ISA
vlog ../rtl/picorv32.v
vlog ../rtl/simple_mem_axi.sv
vlog ../rtl/simpleuart.v
vlog ../rtl/uart_axi_adapter.sv
vlog ../rtl/top_uart_axi.sv

# Compile the tiny testbench (file in current dir)
vlog ../tb/testbench_3_uart_axi.sv

# Launch simulation with accessibility for internal signals
vsim work.testbench_3_uart_axi -voptargs="+acc"

add wave -divider "Clock and Reset"
add wave sim:/testbench_3_uart_axi/clk
add wave sim:/testbench_3_uart_axi/resetn

add wave -divider "uart signals"
add wave sim:/testbench_3_uart_axi/dut/uart/ser_tx
add wave sim:/testbench_3_uart_axi/dut/uart/ser_rx

add wave sim:/testbench_3_uart_axi/dut/uart/reg_div_we
add wave sim:/testbench_3_uart_axi/dut/uart/reg_div_di
add wave sim:/testbench_3_uart_axi/dut/uart/reg_div_do

add wave sim:/testbench_3_uart_axi/dut/uart/reg_dat_we
add wave sim:/testbench_3_uart_axi/dut/uart/reg_dat_re
add wave sim:/testbench_3_uart_axi/dut/uart/reg_dat_di
add wave sim:/testbench_3_uart_axi/dut/uart/reg_dat_do
add wave sim:/testbench_3_uart_axi/dut/uart/reg_dat_wait

add wave -divider "AXI Interface signals"

add wave -divider "Clock and Reset"
add wave sim:/testbench_3_uart_axi/clk
add wave sim:/testbench_3_uart_axi/resetn

add wave -divider "read signals"
add wave sim:/testbench_3_uart_axi/dut/mem/read_fsm
add wave -divider "   - Read Address Channel"
add wave sim:/testbench_3_uart_axi/dut/mem_axi_arvalid
add wave sim:/testbench_3_uart_axi/dut/mem_axi_arready
add wave sim:/testbench_3_uart_axi/dut/mem_axi_araddr
add wave sim:/testbench_3_uart_axi/dut/mem_axi_arprot

add wave -divider "   - Read Data Channel"
add wave sim:/testbench_3_uart_axi/dut/mem_axi_rvalid
add wave sim:/testbench_3_uart_axi/dut/mem_axi_rready
add wave sim:/testbench_3_uart_axi/dut/mem_axi_rdata

add wave -divider "Clock and Reset"
add wave sim:/testbench_3_uart_axi/clk
add wave sim:/testbench_3_uart_axi/resetn

add wave -divider "write signals"
add wave sim:/testbench_3_uart_axi/dut/mem/write_fsm
add wave sim:/testbench_3_uart_axi/dut/mem/write_word_index
add wave sim:/testbench_3_uart_axi/dut/mem/mem_write_addr_buffer
add wave sim:/testbench_3_uart_axi/dut/mem/debug

add wave -divider "write signals"
add wave sim:/testbench_3_uart_axi/dut/mem/write_fsm
add wave -divider "   - Write Address Channel"
add wave sim:/testbench_3_uart_axi/dut/mem_axi_awvalid
add wave sim:/testbench_3_uart_axi/dut/mem_axi_awready
add wave sim:/testbench_3_uart_axi/dut/mem_axi_awaddr
add wave sim:/testbench_3_uart_axi/dut/mem_axi_awprot

add wave -divider "   - Write Data Channel"
add wave sim:/testbench_3_uart_axi/dut/mem_axi_wvalid
add wave sim:/testbench_3_uart_axi/dut/mem_axi_wready
add wave sim:/testbench_3_uart_axi/dut/mem_axi_wdata
add wave sim:/testbench_3_uart_axi/dut/mem_axi_wstrb

add wave -divider "   - Write Response Channel"
add wave sim:/testbench_3_uart_axi/dut/mem_axi_bvalid
add wave sim:/testbench_3_uart_axi/dut/mem_axi_bready

run 2us
