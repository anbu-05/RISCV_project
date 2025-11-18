    .section .text
    .globl _start
_start:
    # base = 0x18000
    lui   x5, 0x18        # x5 = 0x18_000 = 0x18000

    # write CLKDIV = 1  -> store word at 0x18004
    addi  x6, x0, 1       # x6 = 1
    sw    x6, 4(x5)       # write CLKDIV

    # write 'H' (0x48) to DATA (0x18008)
    addi  x7, x0, 72      # x7 = 'H'
    sb    x7, 8(x5)       # store byte to DATA register

    # small busy delay = 20000
    # 20000 = (5 << 12) + (-480)  => 5*4096 = 20480; 20480 - 480 = 20000
    lui   x8, 5
    addi  x8, x8, -480
1:  addi  x8, x8, -1
    bne   x8, x0, 1b

    # write 'i' (0x69)
    addi  x7, x0, 105     # x7 = 'i'
    sb    x7, 8(x5)

    # delay again = 20000 (same loading)
    lui   x8, 5
    addi  x8, x8, -480
2:  addi  x8, x8, -1
    bne   x8, x0, 2b

    # write newline '\n' (0x0A)
    addi  x7, x0, 10
    sb    x7, 8(x5)

    # final tiny delay = 50000
    # 50000 = (12 << 12) + 848  => 12*4096 = 49152; 49152 + 848 = 50000
    lui   x8, 12
    addi  x8, x8, 848
3:  addi  x8, x8, -1
    bne   x8, x0, 3b

hang:
    jal   x0, hang        # infinite loop

    .size _start, .-_start
