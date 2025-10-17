














addi x1, x0, 10
addi x2, x0, 15
add x3, x1, x2
sub x4, x2, x1
xor x5, x1, x2
or x6, x1, x2
and x7, x1, x2
sll x8, x1, x0
slli x9, x1, 2
srl x10, x2, x1
sra x11, x1, 1
slt x12, x1, x2
sltu x13, x1, x2
add x31, x3, x4





addi x1, x0, -5
addi x2, x1, 12
xori x3, x2, 3
ori x4, x2, 8
andi x5, x2, 1
slli x6, x2, 1
srli x7, x2, 1
srai x8, x1, 1
slti x9, x1, 0
sltiu x10, x1, 0
add x31, x6, x7





addi x5, x0, 0x100
addi x1, x0, 0xAABBCCDD
sw x1, 0(x5)
lw x2, 0(x5)
sb x1, 4(x5)
lb x3, 4(x5)
lbu x4, 4(x5)
sh x1, 6(x5)
lh x6, 6(x5)
lhu x7, 6(x5)
add x31, x2, x4





addi x1, x0, 5
addi x2, x0, 5
beq x1, x2, br_eq_tgt

addi x31, x0, 99
br_eq_tgt:
addi x3, x0, 1
addi x4, x0, 2


bne x3, x4, br_ne_tgt

addi x31, x0, 98
br_ne_tgt:
addi x31, x0, 30


addi x5, x0, -1
addi x6, x0, 1
blt x5, x6, br_blt_tgt

addi x31, x0, 97
br_blt_tgt:
addi x31, x0, 31




jal x1, jal_target

addi x31, x0, 99
jal_target:
addi x2, x0, 7
jalr x3, x1, 0
addi x31, x0, 30




lui x8, 0x00012
auipc x9, 0x00001
addi x31, x8, 0




ebreak
ecall




