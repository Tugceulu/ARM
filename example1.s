# ============================================================
# Compare two 8-bit integer arrays and find common elements.
# Then set 3 condition flags based on the result.
# ============================================================

.section .data
v1:     .byte 2, 6, -3, 11, 9, 18, -13, 16, 5, 1
v2:     .byte 4, 2, -13, 3, 9, 9, 7, 16, 4, 7
v3:     .space 10              # result vector (common values)
flag1:  .byte 0                # =1 if v3 empty
flag2:  .byte 0                # =1 if v3 strictly increasing
flag3:  .byte 0                # =1 if v3 strictly decreasing

.section .text
.globl _start
_start:

    # Initialize base addresses
    la x10, v1           # x10 = &v1
    la x11, v2           # x11 = &v2
    la x12, v3           # x12 = &v3
    li x13, 10           # length = 10
    li x14, 0            # v3_count = 0

# ------------------------------------------------------------
# Outer loop: iterate over v1 elements
# ------------------------------------------------------------
outer_loop:
    beqz x13, check_flags      # if all 10 elements done, go check flags

    lb x5, 0(x10)              # load v1[i]
    addi x10, x10, 1           # move to next v1 element
    addi x13, x13, -1          # decrement counter

    # Inner loop setup
    la x11, v2                 # reset v2 pointer
    li x6, 10                  # inner counter = 10

inner_loop:
    beqz x6, outer_loop        # if v2 done, go to next v1 element
    lb x7, 0(x11)              # load v2[j]
    addi x11, x11, 1
    addi x6, x6, -1

    bne x5, x7, inner_loop     # compare v1[i] != v2[j]? continue
    # Match found:
    sb x5, 0(x12)              # store into v3
    addi x12, x12, 1           # advance v3 pointer
    addi x14, x14, 1           # v3_count++
    j outer_loop               # move to next v1 element

# ------------------------------------------------------------
# After loops: check and set flags
# ------------------------------------------------------------
check_flags:
    la x12, v3                 # reset pointer to v3
    la x15, flag1
    la x16, flag2
    la x17, flag3

    beqz x14, v3_empty         # if v3_count == 0 → empty

# ---- v3 not empty ----
    sb x0, 0(x15)              # flag1 = 0 (not empty)
    li x18, 0                  # index = 0
    li x19, 1                  # increasing = 1 (assume true)
    li x20, 1                  # decreasing = 1 (assume true)

check_order_loop:
    add x21, x12, x18          # addr of v3[i]
    lb x5, 0(x21)              # v3[i]
    addi x21, x21, 1
    lb x6, 0(x21)              # v3[i+1]
    addi x18, x18, 1
    blt x14, x18, set_flags    # stop if i >= count-1

    ble x6, x5, not_increasing # if next <= current → not strictly inc
    j cont_dec_check
not_increasing:
    li x19, 0
cont_dec_check:
    bge x6, x5, not_decreasing # if next >= current → not strictly dec
    j cont_order
not_decreasing:
    li x20, 0
cont_order:
    j check_order_loop

set_flags:
    sb x19, 0(x16)             # flag2 = increasing
    sb x20, 0(x17)             # flag3 = decreasing
    j end_program

v3_empty:
    li x5, 1
    sb x5, 0(x15)              # flag1 = 1 (empty)
    sb x0, 0(x16)              # flag2 = 0
    sb x0, 0(x17)              # flag3 = 0

end_program:
    li a0, 0                   # exit(0)
    li a7, 93
    ecall
