# RISC-V branch test program.
# Tests Branch (beq)
.global _start

_start:
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 5      # x2 = 5

    beq  x1, x2, taken  # Branch taken

    addi x3, x0, 99     # Must be skipped

taken:
    addi x4, x0, 4      # Must execute