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

    # acc0 = acc1 = 0.0
    li   a0,0
    fmv.w.x fa0, a0    # acc0
    fmv.w.x fa1, a0    # acc1

    li   t4, 8         # 16 elements => 8 unrolled iterations

loop_un2:
    beqz t4, done_un2

    # load i0,w0,i1,w1
    flw  ft0, 0(t0)
    flw  ft1, 0(t1)
    flw  ft2, 4(t0)
    flw  ft3, 4(t1)
    addi t0, t0, 8
    addi t1, t1, 8

    # two independent multiplies
    fmul.s ft4, ft0, ft1  # prod0
    fmul.s ft5, ft2, ft3  # prod1

    # independent accumulations
    fadd.s fa0, fa0, ft4  # acc0 += prod0
    fadd.s fa1, fa1, ft5  # acc1 += prod1

    addi t4, t4, -1
    bnez t4, loop_un2

done_un2:
    # combine accumulators and add bias
    fadd.s fa0, fa0, fa1
    flw    ft0, 0(t2)
    fadd.s fa0, fa0, ft0

    # exponent test & store
    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, ub_zero
    fsw    fa0, 0(t3)
    j      ub_exit

ub_zero:
    li    t8, 0
    fmv.w.x ft2, t8
    fsw   ft2, 0(t3)

ub_exit:
    li a0,0
    li a7,93
    ecall

############################################################
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

    li   a0,0
    fmv.w.x fa0, a0
    fmv.w.x fa1, a0

    li   t4, 8

loop_un2:
    beqz t4, done_un2

    flw  ft0, 0(t0)
    flw  ft1, 0(t1)
    flw  ft2, 4(t0)
    flw  ft3, 4(t1)
    addi t0, t0, 8
    addi t1, t1, 8

    fmul.s ft4, ft0, ft1
    fmul.s ft5, ft2, ft3

    fadd.s fa0, fa0, ft4
    fadd.s fa1, fa1, ft5

    addi t4, t4, -1
    bnez t4, loop_un2

done_un2:
    fadd.s fa0, fa0, fa1
    flw    ft0, 0(t2)
    fadd.s fa0, fa0, ft0

    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, ub_zero
    fsw    fa0, 0(t3)
    j      ub_exit

ub_zero:
    li    t8, 0
    fmv.w.x ft2, t8
    fsw   ft2, 0(t3)

ub_exit:
    li a0,0
    li a7,93
    ecall

