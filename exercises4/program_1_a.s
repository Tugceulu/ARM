    .section .data
    .align 4
i_vec:  .space 64
w_vec:  .space 64
b_val:  .float 171.0
y_out:  .space 4

    .section .text
    .globl _start
_start:
    la   t0, i_vec
    la   t1, w_vec
    la   t2, b_val
    la   t3, y_out

    # acc = 0.0
    li   a0, 0
    fmv.w.x fa0, a0

    li   t4, 16

    # Preload first pair
    flw  fa1, 0(t0)
    flw  fa2, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4

loop_resched:
    beqz t4, done_resched

    fmul.s ft0, fa1, fa2      # multiply j

    # preload next pair while fmul is executing
    flw   fa3, 0(t0)
    flw   fa4, 0(t1)
    addi  t0, t0, 4
    addi  t1, t1, 4

    # update accumulator (must wait for ft0)
    fadd.s fa0, fa0, ft0

    # move preloaded into working regs
    fmv.s fa1, fa3
    fmv.s fa2, fa4

    addi  t4, t4, -1
    bnez  t4, loop_resched

done_resched:
    flw  ft1, 0(t2)
    fadd.s fa0, fa0, ft1

    # exponent test & store (same as before)
    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, rz_zero
    fsw    fa0, 0(t3)
    j      rz_exit

rz_zero:
    li    t8, 0
    fmv.w.x ft2, t8
    fsw   ft2, 0(t3)

rz_exit:
    li a0,0
    li a7,93
    ecall

##########################################################################################

.section .data
.align 4
i_vec:  .space 64
w_vec:  .space 64
b_val:  .float 171.0
y_out:  .space 4

.section .text
.globl _start
_start:
    la   t0, i_vec
    la   t1, w_vec
    la   t2, b_val
    la   t3, y_out

    li   a0, 0
    fmv.w.x fa0, a0

    li   t4, 16

    flw  fa1, 0(t0)
    flw  fa2, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4

loop_resched:
    beqz t4, done_resched

    fmul.s ft0, fa1, fa2

    flw   fa3, 0(t0)
    flw   fa4, 0(t1)
    addi  t0, t0, 4
    addi  t1, t1, 4

    fadd.s fa0, fa0, ft0

    fmv.s fa1, fa3
    fmv.s fa2, fa4

    addi  t4, t4, -1
    bnez  t4, loop_resched

done_resched:
    flw  ft1, 0(t2)
    fadd.s fa0, fa0, ft1

    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, rz_zero
    fsw    fa0, 0(t3)
    j      rz_exit

rz_zero:
    li    t8, 0
    fmv.w.x ft2, t8
    fsw   ft2, 0(t3)

rz_exit:
    li a0,0
    li a7,93
    ecall

