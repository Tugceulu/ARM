    .section .data
    .align 4
i_vec:  .space 64        # 16 * 4 bytes
w_vec:  .space 64
b_val:  .float 171.0
y_out:  .space 4

    .section .text
    .globl _start
_start:
    # pointers
    la    t0, i_vec       # t0 -> i_vec
    la    t1, w_vec       # t1 -> w_vec
    la    t2, b_val
    la    t3, y_out

    # acc = 0.0
    li    a0, 0
    fmv.w.x fa0, a0      # fa0 = 0.0

    li    t4, 16         # loop count K

loop_base:
    beqz  t4, done_base

    flw   fa1, 0(t0)     # fa1 = i[j]
    flw   fa2, 0(t1)     # fa2 = w[j]
    addi  t0, t0, 4
    addi  t1, t1, 4

    fmul.s ft0, fa1, fa2
    fadd.s fa0, fa0, ft0

    addi  t4, t4, -1
    bnez  t4, loop_base

done_base:
    # acc += b
    flw   ft1, 0(t2)
    fadd.s fa0, fa0, ft1

    # check exponent: move float bits to integer and extract exponent
    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, store_zero

    # store fa0 to y_out
    fsw    fa0, 0(t3)
    j      exit_prog

store_zero:
    li     t8, 0
    fmv.w.x ft2, t8      # ft2 = 0.0f
    fsw    ft2, 0(t3)

exit_prog:
    li a0, 0
    li a7, 93
    ecall

#####################################################################################################

.section .data
.align 4
i_vec:  .space 64
w_vec:  .space 64
b_val:  .float 171.0
y_out:  .space 4

.section .text
.globl _start
_start:
    la    t0, i_vec
    la    t1, w_vec
    la    t2, b_val
    la    t3, y_out

    li    a0, 0
    fmv.w.x fa0, a0

    li    t4, 16

loop_base:
    beqz  t4, done_base

    flw   fa1, 0(t0)
    flw   fa2, 0(t1)
    addi  t0, t0, 4
    addi  t1, t1, 4

    fmul.s ft0, fa1, fa2
    fadd.s fa0, fa0, ft0

    addi  t4, t4, -1
    bnez  t4, loop_base

done_base:
    flw   ft1, 0(t2)
    fadd.s fa0, fa0, ft1

    fmv.x.w t5, fa0
    srli   t6, t5, 23
    andi   t6, t6, 0xff
    li     t7, 0xff
    beq    t6, t7, store_zero

    fsw    fa0, 0(t3)
    j      exit_prog

store_zero:
    li     t8, 0
    fmv.w.x ft2, t8
    fsw    ft2, 0(t3)

exit_prog:
    li a0, 0
    li a7, 93
    ecall


