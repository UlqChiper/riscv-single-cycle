# RISC-V arithmetic test program.
# Tests R-type and I-type arithmetic

.global _start

_start:
    addi x1, x0, 15       # x1 = 15
    addi x2, x0, 25       # x2 = 25

    add  x3, x1, x2       # x3 = 40
    sub  x4, x2, x1       # x4 = 10

    and  x5, x1, x2       # x5 = 15 & 25 = 9
    or   x6, x1, x2       # x6 = 15 | 25 = 31