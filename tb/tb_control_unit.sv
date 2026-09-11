`timescale 1ns / 1ps

import alu_pkg::*;
import opcode_pkg::*;

module tb_control_unit;

    //
    // Inputs
    //
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    //
    // Outputs
    //
    logic    reg_write;
    logic    alu_src;
    logic    mem_read;
    logic    mem_write;
    logic    mem_to_reg;
    logic    branch;
    alu_op_t alu_op;

    //
    // DUT
    //
    control_unit dut (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .alu_op     (alu_op)
    );

    //
    // Test counters
    //
    int pass_count = 0;
    int fail_count = 0;

    //
    // Check task
    //
    task check(
        input string name,
        input logic exp_rw,
        input logic exp_asrc,
        input logic exp_mr,
        input logic exp_mw,
        input logic exp_m2r,
        input logic exp_br,
        input alu_op_t exp_alu_op
    );

        if (reg_write === exp_rw &&
            alu_src === exp_asrc &&
            mem_read === exp_mr &&
            mem_write === exp_mw &&
            mem_to_reg === exp_m2r &&
            branch === exp_br &&
            alu_op === exp_alu_op) begin

            $display("PASS: %s", name);
            pass_count++;

        end else begin

            $display(
                "FAIL: %s | Expected: RW=%b AS=%b MR=%b MW=%b M2R=%b BR=%b ALU=%0d",
                name,
                exp_rw,
                exp_asrc,
                exp_mr,
                exp_mw,
                exp_m2r,
                exp_br,
                exp_alu_op
            );

            $display(
                "                 Got: RW=%b AS=%b MR=%b MW=%b M2R=%b BR=%b ALU=%0d",
                reg_write,
                alu_src,
                mem_read,
                mem_write,
                mem_to_reg,
                branch,
                alu_op
            );

            fail_count++;

        end
    endtask

    //
    // Tests
    //
    initial begin

        $display("--- Control Unit Test Start ---\n");

        //
        // 1. ADD
        //
        opcode = OP_REG;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        check("ADD",
              1'b1, 1'b0, 1'b0, 1'b0,
              1'b0, 1'b0, ALU_ADD);


        //
        // 2. SUB
        //
        opcode = OP_REG;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;

        check("SUB",
              1'b1, 1'b0, 1'b0, 1'b0,
              1'b0, 1'b0, ALU_SUB);


        //
        // 3. AND
        //
        opcode = OP_REG;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #10;

        check("AND",
              1'b1, 1'b0, 1'b0, 1'b0,
              1'b0, 1'b0, ALU_AND);


        //
        // 4. OR
        //
        opcode = OP_REG;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #10;

        check("OR",
              1'b1, 1'b0, 1'b0, 1'b0,
              1'b0, 1'b0, ALU_OR);


        //
        // 5. ADDI
        //
        opcode = OP_IMM;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        check("ADDI",
              1'b1, 1'b1, 1'b0, 1'b0,
              1'b0, 1'b0, ALU_ADD);


        //
        // 6. LW
        //
        opcode = OP_LOAD;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;

        check("LW",
              1'b1, 1'b1, 1'b1, 1'b0,
              1'b1, 1'b0, ALU_ADD);


        //
        // 7. SW
        //
        opcode = OP_STORE;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;

        check("SW",
              1'b0, 1'b1, 1'b0, 1'b1,
              1'b0, 1'b0, ALU_ADD);


        //
        // 8. BEQ
        //
        opcode = OP_BRANCH;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        check("BEQ",
              1'b0, 1'b0, 1'b0, 1'b0,
              1'b0, 1'b1, ALU_SUB);


        //
        // Summary
        //
        $display("\n--- Control Unit Test Summary ---");
        $display("Passed: %0d, Failed: %0d",
                 pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: Control Unit tests");
        else
            $display("FAIL: Control Unit tests");

        $finish;

    end

endmodule