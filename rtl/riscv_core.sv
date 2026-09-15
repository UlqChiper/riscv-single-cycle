// RISC-V single-cycle core.
// Single-cycle RISC-V core.
`timescale 1ns / 1ps

import alu_pkg::*;
import opcode_pkg::*;
import immediate_pkg::*;

module riscv_core (
    input logic        clk,
    input logic        rst
);

    //
    // Program Counter
    //

    logic [31:0] pc;
    logic [31:0] next_pc;

    program_counter pc_unit (
        .clk     (clk),
        .rst     (rst),
        .next_pc (next_pc),
        .pc      (pc)
    );


    //
    // Instruction Memory
    //

    logic [31:0] instruction;

    instruction_memory instr_mem (
        .addr  (pc),
        .instr (instruction)
    );


    //
    // Instruction Fields
    //

    logic [6:0] opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode  = instruction[6:0];
    assign rd_addr = instruction[11:7];
    assign funct3  = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7  = instruction[31:25];


    //
    // Control Unit
    //

    logic    reg_write;
    logic    alu_src;
    logic    mem_read;
    logic    mem_write;
    logic    mem_to_reg;
    logic    branch;
    alu_op_t alu_op;

    control_unit control (
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_to_reg(mem_to_reg),
        .branch    (branch),
        .alu_op    (alu_op)
    );


    //
    // Register File
    //

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] write_back_data;

    register_file registers (
        .clk             (clk),
        .rst             (rst),
        .rs1_addr        (rs1_addr),
        .rs2_addr        (rs2_addr),
        .rs1_data        (rs1_data),
        .rs2_data        (rs2_data),
        .rd_addr         (rd_addr),
        .rd_data         (write_back_data),
        .rd_write_enable (reg_write)
    );


    //
    // Immediate Generator
    //

    imm_type_t imm_type;
    logic [31:0] immediate;

    always_comb begin
        case (opcode)

            OP_IMM,
            OP_LOAD:
                imm_type = IMM_I;

            OP_STORE:
                imm_type = IMM_S;

            OP_BRANCH:
                imm_type = IMM_B;

            default:
                imm_type = IMM_I;

        endcase
    end

    immediate_generator imm_gen (
        .instruction (instruction),
        .imm_type    (imm_type),
        .immediate   (immediate)
    );


    //
    // ALU
    //

    logic [31:0] alu_b;
    logic [31:0] alu_result;
    logic        alu_eq;

    assign alu_b = alu_src ? immediate : rs2_data;

    alu arithmetic_logic_unit (
        .a      (rs1_data),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result),
        .eq     (alu_eq)
    );


    //
    // Data Memory
    //

    logic [31:0] memory_read_data;

    data_memory data_mem (
        .clk       (clk),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .addr      (alu_result),
        .write_data(rs2_data),
        .read_data (memory_read_data)
    );


    //
    // Write-Back
    //

    always_comb begin
        if (mem_to_reg)
            write_back_data = memory_read_data;
        else
            write_back_data = alu_result;
    end


    //
    // Next PC Logic
    //

    always_comb begin

        // Default: execute next instruction
        next_pc = pc + 32'd4;

        // Taken BEQ
        if (branch && alu_eq)
            next_pc = pc + immediate;

    end

endmodule