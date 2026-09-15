# RISC-V Single-Cycle Architecture
# Single-Cycle RISC-V Processor Architecture

## 1. Overview

This project implements a single-cycle RISC-V processor in SystemVerilog.

The processor implements a selected subset of the RV32I instruction set. Each instruction is fetched, decoded, executed, and completed within a single clock cycle.

The processor is designed as a simple educational implementation of a RISC-V datapath, with separate instruction memory and data memory.

### Supported Instructions

| Type | Instruction | Operation |
|---|---|---|
| R-type | `add` | Register addition |
| R-type | `sub` | Register subtraction |
| R-type | `and` | Bitwise AND |
| R-type | `or` | Bitwise OR |
| I-type | `addi` | Add immediate |
| Load | `lw` | Load 32-bit word |
| Store | `sw` | Store 32-bit word |
| Branch | `beq` | Branch if registers are equal |

The implementation uses:

- 32-bit datapath
- 32 general-purpose registers
- 32-bit program counter
- Separate instruction and data memories
- Combinational instruction decode and execution logic
- Synchronous register and data-memory writes
- Asynchronous register-file reads
- Combinational instruction and data-memory reads

---

# 2. High-Level Architecture

The processor consists of the following major components:

1. Program Counter
2. Instruction Memory
3. Instruction Decoder / Field Extraction
4. Control Unit
5. Register File
6. Immediate Generator
7. ALU
8. Data Memory
9. Write-Back Logic
10. Next-PC Logic

The overall datapath can be represented as:

```text
                         +----------------+
                         | Program Counter|
                         |      (PC)      |
                         +-------+--------+
                                 |
                                 v
                         +----------------+
                         | Instruction    |
                         | Memory         |
                         +-------+--------+
                                 |
                                 v
                         +----------------+
                         | Instruction    |
                         | Fields / Decode|
                         +---+--------+---+
                             |        |
                +------------+        +-------------+
                |                                   |
                v                                   v
        +---------------+                   +---------------+
        | Control Unit  |                   |   Immediate   |
        |               |                   |   Generator   |
        +-------+-------+                   +-------+-------+
                |                                   |
                | Control Signals                   |
                |                                   |
                v                                   v
        +-----------------------------------------------+
        |                 Register File                 |
        |                                                |
        |       rs1_data             rs2_data            |
        +----------+---------------------+---------------+
                   |                     |
                   |                     |
                   v                     v
                 +--------------------------+
                 |           ALU            |
                 |                          |
                 | A = rs1_data             |
                 | B = rs2_data / immediate |
                 +------------+-------------+
                              |
                    +---------+---------+
                    |                   |
                    v                   v
             +-------------+      +-------------+
             | Data Memory |      |  Next PC    |
             |             |      |    Logic    |
             +------+------+      +------+------+
                    |                    |
                    | load data          |
                    v                    |
             +-------------+             |
             | Write-Back  |             |
             |    MUX      |             |
             +------+------+             |
                    |                    |
                    v                    |
             Register File              |
                write                   |
                                         |
                                         +----> PC


                                        
Each instruction is 32 bits wide.

The processor extracts the standard RISC-V instruction fields:

31                    25 24       20 19       15 14    12 11        7 6       0
+-----------------------+-----------+-----------+--------+-----------+---------+
|        funct7         |    rs2    |    rs1    | funct3 |    rd     | opcode  |
+-----------------------+-----------+-----------+--------+-----------+---------+

Unsupported instructions result in safe default control signals.
