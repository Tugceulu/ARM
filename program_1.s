{\rtf1\ansi\ansicpg1252\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww14380\viewh17840\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0     .section .data\
v1: .space 128        # 32 floats \'d7 4 bytes = 128\
v2: .space 128\
v3: .space 128\
v4: .space 128\
v5: .space 128\
v6: .space 128\
\
v7: .word 1           # m = 1 (integer)\
v8: .space 4          # a (float)\
v9: .space 4          # b (float)\
\
    .section .text\
    .globl _start\
_start:\
    # --- Initialize base addresses ---\
    la   s0, v1\
    la   s1, v2\
    la   s2, v3\
    la   s3, v4\
    la   s4, v5\
    la   s5, v6\
    la   s7, v7       # m\
    la   s8, v8       # a\
    la   s9, v9       # b\
\
    # --- Point to last element (index 31) ---\
    li   t0, 31\
    slli t1, t0, 2    # offset = 31 * 4\
    add  s0, s0, t1\
    add  s1, s1, t1\
    add  s2, s2, t1\
    add  s3, s3, t1\
    add  s4, s4, t1\
    add  s5, s5, t1\
\
loop:\
    # Load vectors\
    flw  fa0, 0(s0)      # v1[i]\
    flw  fa1, 0(s1)      # v2[i]\
    flw  fa2, 0(s2)      # v3[i]\
    flw  fa5, 0(s9)      # b\
\
    # Load m (integer)\
    lw   t2, 0(s7)       # m\
\
    # Check if (i % 3 == 0)\
    li   t3, 3\
    rem  t4, t0, t3\
    beqz t4, MULT3       # if (i % 3 == 0)\
\
    # ----- else branch -----\
    fcvt.s.w fa3, t2     # fa3 = (float)m\
    fcvt.s.w ft6, t0     # ft6 = (float)i\
    fmul.s ft7, fa3, ft6 # ft7 = (float)m * (float)i\
    fmul.s fa4, fa0, ft7 # a = v1[i] * (m * i)\
    fcvt.w.s t2, fa4     # m = (int)a\
    sw   t2, 0(s7)       # store new m\
    j AFTER_IF\
\
MULT3:\
    # ----- if (i % 3 == 0) -----\
    sll  t4, t2, t0      # t4 = m << i\
    fcvt.s.w ft8, t4     # ft8 = (float)(m << i)\
    fdiv.s fa4, fa0, ft8 # a = v1[i] / ((float)m << i)\
    fcvt.w.s t2, fa4     # m = (int)a\
    sw   t2, 0(s7)\
\
AFTER_IF:\
    # v4[i] = a * v1[i] - v2[i]\
    fmul.s ft0, fa4, fa0\
    fsub.s ft1, ft0, fa1\
    fsw   ft1, 0(s3)\
\
    # v5[i] = v4[i]/v3[i] - b\
    fdiv.s ft2, ft1, fa2\
    fsub.s ft3, ft2, fa5\
    fsw   ft3, 0(s4)\
    fsw   ft3, 0(s9)     # update b\
\
    # v6[i] = (v4[i]-v1[i]) * v5[i]\
    fsub.s ft4, ft1, fa0\
    fmul.s ft5, ft4, ft3\
    fsw   ft5, 0(s5)\
\
    # Move to previous elements\
    addi s0, s0, -4\
    addi s1, s1, -4\
    addi s2, s2, -4\
    addi s3, s3, -4\
    addi s4, s4, -4\
    addi s5, s5, -4\
\
    addi t0, t0, -1\
    bgez t0, loop\
\
    # --- Exit ---\
    li   a0, 0\
    li   a7, 93\
    ecall\
}