`timescale 1ns / 1ps

import alu_pkg::*;

module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] result;
    alu_op_t     alu_op;
    logic        eq;

    // Device under test
    alu dut (
        .a      (a),
        .b      (b),
        .alu_op (alu_op),
        .result (result),
        .eq     (eq)
    );

    int pass_count = 0;
    int fail_count = 0;

    // ------------------------------------------------------------
    // Test/check task
    // ------------------------------------------------------------
    task automatic check(
        input string      test_name,
        input logic [31:0] expected_result,
        input logic        expected_eq
    );
        if ((result === expected_result) && (eq === expected_eq)) begin
            $display(
                "PASS: %-24s | result=%h eq=%b",
                test_name,
                result,
                eq
            );
            pass_count++;
        end
        else begin
            $display(
                "FAIL: %-24s | Expected: result=%h eq=%b | Got: result=%h eq=%b",
                test_name,
                expected_result,
                expected_eq,
                result,
                eq
            );
            fail_count++;
        end
    endtask

    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        $display("");
        $display("========================================");
        $display("        RISC-V ALU TESTBENCH");
        $display("========================================");
        $display("");

        // --------------------------------------------------------
        // ADD
        // --------------------------------------------------------
        alu_op = ALU_ADD;
        a = 32'd10;
        b = 32'd20;
        #10;

        check(
            "ADD positive",
            32'd30,
            1'b0
        );

        // 0xFFFFFFF0 + 0x00000010 = 0x00000000
        // Demonstrates normal 32-bit wraparound.
        a = 32'hFFFFFFF0;
        b = 32'h00000010;
        #10;

        check(
            "ADD wraparound",
            32'h00000000,
            1'b0
        );

        // Equal operands should still assert eq.
        a = 32'h12345678;
        b = 32'h12345678;
        #10;

        check(
            "ADD equal operands",
            32'h2468ACF0,
            1'b1
        );

        // --------------------------------------------------------
        // SUB
        // --------------------------------------------------------
        alu_op = ALU_SUB;
        a = 32'd30;
        b = 32'd10;
        #10;

        check(
            "SUB positive",
            32'd20,
            1'b0
        );

        // 10 - 20 = -10 = 0xFFFFFFF6
        a = 32'd10;
        b = 32'd20;
        #10;

        check(
            "SUB negative result",
            32'hFFFFFFF6,
            1'b0
        );

        // -10 - (-10) = 0
        a = -32'sd10;
        b = -32'sd10;
        #10;

        check(
            "SUB negative equal",
            32'h00000000,
            1'b1
        );

        // --------------------------------------------------------
        // AND
        // --------------------------------------------------------
        alu_op = ALU_AND;
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        #10;

        check(
            "AND logic",
            32'h0F000F00,
            1'b0
        );

        // --------------------------------------------------------
        // OR
        // --------------------------------------------------------
        alu_op = ALU_OR;
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        #10;

        check(
            "OR logic",
            32'hFF0FFF0F,
            1'b0
        );

        // --------------------------------------------------------
        // Equality comparison
        // --------------------------------------------------------
        // ALU operation is irrelevant to eq.
        // Both operands are equal, so eq must be 1.
        alu_op = ALU_ADD;
        a = 32'hDEADBEEF;
        b = 32'hDEADBEEF;
        #10;

        check(
            "EQ large hex",
            32'hBD5B7DDE,
            1'b1
        );

        // Equal operands with a different ALU operation.
        // This verifies that eq is independent of alu_op.
        alu_op = ALU_AND;
        a = 32'hAAAAAAAA;
        b = 32'hAAAAAAAA;
        #10;

        check(
            "EQ independent of ALU op",
            32'hAAAAAAAA,
            1'b1
        );

        // --------------------------------------------------------
        // Final summary
        // --------------------------------------------------------
        $display("");
        $display("========================================");
        $display("           ALU TEST SUMMARY");
        $display("========================================");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("========================================");

        if (fail_count == 0) begin
            $display("PASS: All ALU tests passed.");
        end
        else begin
            $display("FAIL: One or more ALU tests failed.");
        end

        $display("");

        $finish;
    end

endmodule