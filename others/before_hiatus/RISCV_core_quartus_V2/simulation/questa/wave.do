onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TB_RISCV_core/clk
add wave -noupdate /TB_RISCV_core/reset
add wave -noupdate /TB_RISCV_core/enable
add wave -noupdate -radix decimal /TB_RISCV_core/dut/PC1/pc_out
add wave -noupdate -radix decimal /TB_RISCV_core/dut/PC1/pc_next
add wave -noupdate -radix binary /TB_RISCV_core/dut/PC1/pc_jmp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 225
configure wave -valuecolwidth 97
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {704 ps}
