    .section .data
v1: .space 128        # 32 floats × 4 bytes = 128
v2: .space 128
v3: .space 128
v4: .space 128
v5: .space 128
v6: .space 128

    .section .text
    .globl _start
_start:
    # --- initialize pointers to last element (index 31) ---
    la   s0, v1
    la   s1, v2
    la   s2, v3
    la   s3, v4
    la   s4, v5
    la   s5, v6

    li   t0, 31           # loop counter i = 31
    slli t1, t0, 2        # t1 = 31 * 4
    add  s0, s0, t1
    add  s1, s1, t1
    add  s2, s2, t1
    add  s3, s3, t1
    add  s4, s4, t1
    add  s5, s5, t1

loop:
    flw  fa0, 0(s0)       # v1[i]
    flw  fa1, 0(s1)       # v2[i]
    flw  fa2, 0(s2)       # v3[i]

    fmul.s ft0, fa0, fa0  # v1*v1
    fsub.s ft1, ft0, fa1  # v1*v1 - v2 = v4
    fsw   ft1, 0(s3)

    fdiv.s ft2, ft1, fa2  # v4 / v3
    fsub.s ft3, ft2, fa1  # - v2 = v5
    fsw   ft3, 0(s4)

    fsub.s ft4, ft1, fa0  # v4 - v1
    fmul.s ft5, ft4, ft3  # * v5 = v6
    fsw   ft5, 0(s5)

    addi s0, s0, -4
    addi s1, s1, -4
    addi s2, s2, -4
    addi s3, s3, -4
    addi s4, s4, -4
    addi s5, s5, -4

    addi t0, t0, -1
    bgez t0, loop

    li   a0, 0
    li   a7, 93
    ecall
