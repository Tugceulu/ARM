    .section .data
v1: .space 32*4
v2: .space 32*4
v3: .space 32*4
v4: .space 32*4
v5: .space 32*4
v6: .space 32*4

    .section .text
    .globl _start
_start:
    # set pointers to last element: base + 31*4
    la  s0, v1
    la  s1, v2
    la  s2, v3
    la  s3, v4
    la  s4, v5
    la  s5, v6

    li  t0, 31            # index = 31

    slli t1, t0, 2        # t1 = 31*4
    add  s0, s0, t1       # s0 = &v1[31]
    add  s1, s1, t1       # s1 = &v2[31]
    add  s2, s2, t1       # s2 = &v3[31]
    add  s3, s3, t1       # s3 = &v4[31]
    add  s4, s4, t1       # s4 = &v5[31]
    add  s5, s5, t1       # s5 = &v6[31]

loop:
    # load v1[i], v2[i], v3[i]
    flw fa0, 0(s0)        # fa0 = v1[i]
    flw fa1, 0(s1)        # fa1 = v2[i]
    flw fa2, 0(s2)        # fa2 = v3[i]

    # v4[i] = v1[i]*v1[i] - v2[i]
    fmul.s ft0, fa0, fa0  # ft0 = v1*v1
    fsub.s ft1, ft0, fa1  # ft1 = ft0 - v2
    fsw  ft1, 0(s3)       # store v4[i]

    # v5[i] = v4[i] / v3[i] - v2[i]
    # ft1 currently = v4[i]
    fdiv.s ft2, ft1, fa2  # ft2 = v4 / v3
    fsub.s ft3, ft2, fa1  # ft3 = ft2 - v2
    fsw  ft3, 0(s4)       # store v5[i]

    # v6[i] = (v4[i] - v1[i]) * v5[i]
    fsub.s ft4, ft1, fa0  # ft4 = v4 - v1
    fmul.s ft5, ft4, ft3  # ft5 = ft4 * v5
    fsw  ft5, 0(s5)       # store v6[i]

    # decrement pointers by 4 (previous element)
    addi s0, s0, -4
    addi s1, s1, -4
    addi s2, s2, -4
    addi s3, s3, -4
    addi s4, s4, -4
    addi s5, s5, -4

    addi t0, t0, -1
    bgez t0, loop

    # exit syscall
    li a0, 0
    li a7, 93
    ecall
