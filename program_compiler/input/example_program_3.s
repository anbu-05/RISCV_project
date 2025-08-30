addi x1, x0, 10       # x1 <- 10
addi x2, x1, 5        # x2 <- x1 + 5 = 15 (immediate data hazard)
add  x3, x1, x2       # x3 <- x1 + x2 = 25 (register-register hazard)
sub  x4, x3, x1       # x4 <- x3 - x1 = 15 (another hazard)
sll  x5, x4, x1       # x5 <- x4 << x1 = 15 << 10 = 15360
srl  x6, x5, x1       # x6 <- x5 >> x1 = 15360 >> 10 = 15
beq  x6, x4, success        # if x6 == x4 (should be true), jump to 32
addi x31, x0, 99      # ERROR: should not reach here
success: 
add  x31, x6, x4      # x31 <- 15 + 15 = 30 (success indicator)