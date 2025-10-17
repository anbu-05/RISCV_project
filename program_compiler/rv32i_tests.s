
# ENCODING / ASSEMBLY REMINDERS (drop this on top of every program)
#
# - Instructions are 4 bytes each (word-aligned).
# - For numeric B- and J-type immediates use the "x2" rule:
#     imm = (target_byte_address - current_pc_bytes) / 2
#   Example: branch at PC=24 to byte address 32 -> byte_offset=8 -> imm=4
# - jalr uses a raw I-type immediate (no x2 scaling).
# - LUI loads imm into bits[31:12] (imm << 12).

# -----------------------
# R-TYPE ALU TESTS
# expected final quick-check: x31 = 30
# -----------------------

addi x1, x0, 10         # x1 = 10                    ; addr=0
addi x2, x0, 15         # x2 = 15                    ; addr=4
add x3, x1, x2         # x3 = 25                    ; addr=8
sub x4, x2, x1         # x4 = 5                     ; addr=12
xor x5, x1, x2         # x5 = 10 ^ 15 = 5           ; addr=16
or x6, x1, x2         # x6 = 10 | 15 = 15          ; addr=20
and x7, x1, x2         # x7 = 10 & 15 = 10          ; addr=24
sll x8, x1, x0         # x8 = 10 << 0 = 10          ; addr=28
slli x9, x1, 2          # x9 = 10 << 2 = 40          ; addr=32
srl x10, x2, x1        # x10 = 15 >> 10 = 0         ; addr=36
sra x11, x1, 1         # x11 = 10 >> 1 (arith) = 5  ; addr=40
slt x12, x1, x2        # x12 = 1                    ; addr=44
sltu x13, x1, x2        # x13 = 1                    ; addr=48
add x31, x3, x4        # x31 = 25 + 5 = 30  (pass)  ; addr=52

# -----------------------
# I-TYPE ALU TESTS
# expected final quick-check: x31 = 17
# -----------------------
addi x1, x0, -5         # x1 = -5                    ; addr=56
addi x2, x1, 12         # x2 = 7                     ; addr=60
xori x3, x2, 3          # x3 = 7 ^ 3 = 4             ; addr=64
ori x4, x2, 8          # x4 = 7 | 8 = 15            ; addr=68
andi x5, x2, 1          # x5 = 7 & 1 = 1             ; addr=72
slli x6, x2, 1          # x6 = 7 << 1 = 14           ; addr=76
srli x7, x2, 1          # x7 = 7 >> 1 = 3            ; addr=80
srai x8, x1, 1          # x8 = -5 >> 1 = -3 (arith)  ; addr=84
slti x9, x1, 0          # x9 = 1                     ; addr=88
sltiu x10, x1, 0        # x10 = 0 (unsigned)         ; addr=92
add x31, x6, x7        # x31 = 14 + 3 = 17  (pass)  ; addr=96

# -----------------------
# LOAD/STORE TESTS
# (assumes memory at an accessible data region; adjust base if required)
# -----------------------
addi x5, x0, 0x100      # x5 = base = 0x100          ; addr=100
addi x1, x0, 0xAABBCCDD # x1 = test pattern (bottom 32b) ; addr=104
sw x1, 0(x5)          # M[x5+0] = 0xAABBCCDD      ; addr=108
lw x2, 0(x5)          # x2 = 0xAABBCCDD           ; addr=112
sb x1, 4(x5)          # store low byte at x5+4    ; addr=116
lb x3, 4(x5)          # x3 = sign-extended byte   ; addr=120
lbu x4, 4(x5)          # x4 = zero-extended byte (0xDD) ; addr=124
sh x1, 6(x5)          # store halfword at x5+6    ; addr=128
lh x6, 6(x5)          # signed halfword load      ; addr=132
lhu x7, 6(x5)          # unsigned halfword load    ; addr=136
add x31, x2, x4        # x31 = 0xAABBCCDD + 0xDD  (pass marker) ; addr=140

# -----------------------
# BRANCH TESTS (labels with x2 immediate comment)
# -----------------------
# block 1: beq taken
addi x1, x0, 5          # x1 = 5                     ; addr=144
addi x2, x0, 5          # x2 = 5                     ; addr=148
beq x1, x2, br_eq_tgt  # if equal -> branch to br_eq_tgt
                        # (br_eq_tgt at byte addr 160, here pc=152 -> imm = (160-152)/2 = 4) ; addr=152
addi x31, x0, 99        # ERROR if reached           ; addr=156
br_eq_tgt:
addi x3, x0, 1          # branch target              ; addr=160
addi x4, x0, 2          #                            ; addr=164

# block 2: bne taken
bne x3, x4, br_ne_tgt  # x3!=x4 -> taken
                        # (br_ne_tgt at byte addr 176, here pc=168 -> imm=(176-168)/2=4) ; addr=168
addi x31, x0, 98        # ERROR if reached           ; addr=172
br_ne_tgt:
addi x31, x0, 30        # pass marker                ; addr=176

# signed compare tests
addi x5, x0, -1         # x5 = -1                    ; addr=180
addi x6, x0, 1          # x6 = 1                     ; addr=184
blt x5, x6, br_blt_tgt # signed less -> taken
                        # (br_blt_tgt at byte=196, here pc=188 -> imm=(196-188)/2=4) ; addr=188
addi x31, x0, 97        # ERROR if reached           ; addr=192
br_blt_tgt:
addi x31, x0, 31        # pass marker                ; addr=196

# -----------------------
# JUMP (J-type) and JALR tests
# -----------------------
jal x1, jal_target      # x1 = return_addr (PC+4), jump to jal_target
                        # (example: here pc=200, jal_target at 216 -> imm=(216-200)/2=8) ; addr=200
addi x31, x0, 99        # should be skipped if jal worked ; addr=204
jal_target:
addi x2, x0, 7          # jal target body            ; addr=208
jalr x3, x1, 0          # jump to address in x1 (return) ; addr=212
addi x31, x0, 30        # final pass marker          ; addr=216

# -----------------------
# U-TYPE (LUI/AUIPC) tests
# -----------------------
lui x8, 0x00012        # x8 = 0x00012 << 12 = 0x12000 ; addr=220
auipc x9, 0x00001       # x9 = PC + (0x1 << 12)         ; addr=224
addi x31, x8, 0         # x31 = x8 (quick store)        ; addr=228

# -----------------------
# SYSTEM (ecall/ebreak) - these will trap; catch in TB
# -----------------------
ebreak                 # trap: debug break             ; addr=232
ecall                  # trap: environment call        ; addr=236

# -----------------------
# END OF TESTS
# -----------------------
