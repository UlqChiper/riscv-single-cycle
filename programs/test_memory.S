# RISC-V memory test program.
# Tests Load and Store
.global _start

_start:
    addi x1, x0, 100     # x1 = 100

    sw   x1, 0(x0)       # MEM[0] = 100
    lw   x2, 0(x0)       # x2 = MEM[0] = 100

    sw   x2, 4(x0)       # MEM[1] = 100
    lw   x4, 4(x0)       # x4 = MEM[1] = 100