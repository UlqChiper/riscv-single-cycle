`timescale 1ns / 1ps

import immediate_pkg::*;

module tb_immediate_generator;

    logic [31:0] instruction;
    imm_type_t   imm_type;
    logic [31:0] immediate;

    immediate_generator dut (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    int pass_count = 0;
    int fail_count = 0;


    //
    // Check task
    //

    task check(
        input string test_name,
        input logic [31:0] expected
    );

        if (immediate === expected) begin
            $display("PASS: %s | Immediate = %h", test_name, immediate);
            pass_count++;
        end
        else begin
            $display(
                "FAIL: %s | Expected = %h | Got = %h",
                test_name,
                expected,
                immediate
            );
            fail_count++;
        end

    endtask


    //
    // Test sequence
    //

    initial begin

         
        // I-TYPE TESTS
         

        // Positive immediate: +10
        // Immediate field = 000000001010
        imm_type = IMM_I;

        instruction = 32'b0;
        instruction[31:20] = 12'b000000001010;

        #1;

        check(
            "I-type positive (+10)",
            32'h0000000A
        );


        // Negative immediate: -10
        // 12-bit two's complement representation = F F 6
        imm_type = IMM_I;

        instruction = 32'b0;
        instruction[31:20] = 12'b111111110110;

        #1;

        check(
            "I-type negative (-10)",
            32'hFFFFFFF6
        );


         
        // S-TYPE TESTS
         

        // Positive immediate: +20
        // 12-bit representation = 000000010100
        imm_type = IMM_S;

        instruction = 32'b0;
        instruction[31:25] = 7'b0000000;
        instruction[11:7]  = 5'b10100;

        #1;

        check(
            "S-type positive (+20)",
            32'h00000014
        );


        // Negative immediate: -20
        // 12-bit two's complement = FFFFFEC
        // 12-bit representation = 111111101100
        imm_type = IMM_S;

        instruction = 32'b0;
        instruction[31:25] = 7'b1111111;
        instruction[11:7]  = 5'b01100;

        #1;

        check(
            "S-type negative (-20)",
            32'hFFFFFFEC
        );


         
        // B-TYPE TESTS
         

        // Positive branch offset: +16
        //
        // B-type immediate layout:
        // [12]   [11]   [10:5]   [4:1]   [0]
        //   0      0      000000    1000    0
        //
        // Result = 0000000000010000 = 16
        imm_type = IMM_B;

        instruction = 32'b0;

        instruction[31]    = 1'b0;      // imm[12]
        instruction[7]     = 1'b0;      // imm[11]
        instruction[30:25] = 6'b000000; // imm[10:5]
        instruction[11:8]  = 4'b1000;   // imm[4:1]

        #1;

        check(
            "B-type positive (+16)",
            32'h00000010
        );


        // Negative branch offset: -16
        //
        // 13-bit two's complement representation:
        // 1 1 111111 1000 0
        //
        imm_type = IMM_B;

        instruction = 32'b0;

        instruction[31]    = 1'b1;      // imm[12]
        instruction[7]     = 1'b1;      // imm[11]
        instruction[30:25] = 6'b111111; // imm[10:5]
        instruction[11:8]  = 4'b1000;   // imm[4:1]

        #1;

        check(
            "B-type negative (-16)",
            32'hFFFFFFF0
        );


         
        // SUMMARY
         

        $display("");
        $display("--- Immediate Generator Test Summary ---");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: Immediate generator tests");
        else
            $display("FAIL: Immediate generator tests");

        $finish;

    end

endmodule