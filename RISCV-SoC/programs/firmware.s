    .section .text
    .globl _start
_start:
    /* set up stack from linker script (provided by your LD script) */
    la   sp, _sstack

    /* ---- Test 1: ADD / SUB (smoke) ----
       Expect: a2 = 12, a0 (after add3 later) will be changed by call test; here just add/sub checks */
    li   a0, 5
    li   a1, 7
    add  a2, a0, a1        /* a2 = 12 */
    li   t0, 12
    bne  a2, t0, fail

    li   a3, 12
    li   a4, 20
    sub  a5, a3, a4        /* a5 = -8 */
    li   t0, -8
    bne  a5, t0, fail

    /* ---- Test 2: Logic & Shifts ----
       Expect after block:
         t2 = 0x000F000F (AND)
         t2 = 0x0FFF0FFF (OR)
         t2 = 0x0FF00FF0 (XOR)
         t5 = 0xFFFFFFFF (SRA of 0x80000000 by 31)
         t5 = 32 (SLL 1 << 5)
         t5 = 0xF (SRL 0xF0 >> 4)
    */
    li   t0, 0x0F0F0F0F
    li   t1, 0x00FF00FF
    and  t2, t0, t1
    li   t3, 0x000F000F
    bne  t2, t3, fail

    or   t2, t0, t1
    li   t3, 0x0FFF0FFF
    bne  t2, t3, fail

    xor  t2, t0, t1
    li   t3, 0x0FF00FF0
    bne  t2, t3, fail

    li   t4, 0x80000000
    srai t5, t4, 31
    li   t6, -1
    bne  t5, t6, fail

    li   t4, 1
    sll  t5, t4, 5
    li   t6, 32
    bne  t5, t6, fail

    li   t4, 0xF0
    srl  t5, t4, 4
    li   t6, 0xF
    bne  t5, t6, fail

    /* ---- Test 3: Branches (taken / not-taken) ----
       Checks basic branch behavior */
    li   t0, 10
    li   t1, 10
    bne  t0, t1, fail     /* not taken */

    li   t2, 5
    beq  t2, zero, fail   /* not taken */

    blt  zero, t2, L_ok   /* should be taken (0 < 5) */
    j    fail
L_ok:
    bge  t2, t0, fail     /* 5 >= 10? should NOT be taken */

    /* ---- Test 4: Loads/Stores word/half/byte sign/zero ----
       Memory expectations:
         buf (word) initially 0xA1B2C3D4
         lb (byte 0) => signed -44
         lbu (byte 0) => 212
         lh (half) => signed -15404
         lhu (half) => 50132
         after sb 0x55 at offset 1, lbu 1 => 0x55
    */
    la   t0, buf
    lw   t2, 0(t0)
    li   t1, 0xA1B2C3D4
    bne  t2, t1, fail

    lb   t3, 0(t0)
    li   t4, -44
    bne  t3, t4, fail

    lbu  t3, 0(t0)
    li   t4, 212
    bne  t3, t4, fail

    lh   t3, 0(t0)
    li   t4, -15404
    bne  t3, t4, fail

    lhu  t3, 0(t0)
    li   t4, 50132
    bne  t3, t4, fail

    li   t5, 0x55
    sb   t5, 1(t0)            /* write at byte offset 1 */
    lbu  t6, 1(t0)
    li   s0, 0x55             /* use s0 (x8) because RV32I has t0..t6 only */
    bne  t6, s0, fail

    /* ---- Test 5: JAL / JALR + stack (call test) ----
       Call add3(2,3,4) -> returns 9 in a0 after function returns.
       Expect: a0 = 9 after jal to add3
    */
    li   a0, 2
    li   a1, 3
    li   a2, 4
    jal  ra, add3         /* call */
    li   t0, 9
    bne  a0, t0, fail

    /* JALR test: jump by register to label L_done (should land there) */
    la   t1, L_done
    jalr ra, 0(t1)
    j    fail             /* If jalr failed, we'd fall here */

L_done:
    /* ---- Test 6: Register poke (small subset) ----
       We write values to x1..x5 and verify them.
       Expect: x1=1, x2=2, x3=3, x4=4, x5=5
    */
    li   x1, 1
    li   x2, 2
    li   x3, 3
    li   x4, 4
    li   x5, 5

    li   t3, 1
    bne  x1, t3, fail
    li   t3, 2
    bne  x2, t3, fail
    li   t3, 3
    bne  x3, t3, fail
    li   t3, 4
    bne  x4, t3, fail
    li   t3, 5
    bne  x5, t3, fail

    /* All tests passed -> write PASS (1) to test_result and hang */
    li   t0, 1
    la   t1, test_result
    sw   t0, 0(t1)

done:
    j done

/* Failure: write 0 to test_result and hang */
fail:
    li   t0, 0
    la   t1, test_result
    sw   t0, 0(t1)
hang_fail:
    j hang_fail

/* small helper function:
   add3: a0= x, a1= y, a2= z -> return a0 + a1 + a2 in a0
*/
add3:
    add  t0, a0, a1
    add  a0, t0, a2
    jr   ra

    .section .data
    .align 4
test_result:
    .word 0            /* 0 = fail (default), 1 = all tests passed */

    .align 4
buf:
    .word 0xA1B2C3D4   /* initial memory word used by mem tests */
