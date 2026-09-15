#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path


def elf_to_hex(elf_file, hex_file):
    elf_file = Path(elf_file)
    hex_file = Path(hex_file)

    # Extract the .text section as raw binary.
    binary_file = hex_file.with_suffix(".bin")

    subprocess.run(
        [
            "riscv32-none-elf-objcopy",
            "-O", "binary",
            "-j", ".text",
            str(elf_file),
            str(binary_file),
        ],
        check=True,
    )

    data = binary_file.read_bytes()

    # Instructions are 32-bit / 4 bytes.
    if len(data) % 4 != 0:
        raise ValueError(".text section is not aligned to 4 bytes.")

    with hex_file.open("w") as f:
        for i in range(0, len(data), 4):
            word = int.from_bytes(data[i:i + 4], byteorder="little")
            f.write(f"{word:08x}\n")

    binary_file.unlink()

    print(f"Generated: {hex_file}")
    print(f"Instructions: {len(data) // 4}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: elf_to_hex.py <input.elf> <output.hex>")
        sys.exit(1)

    elf_to_hex(sys.argv[1], sys.argv[2])
