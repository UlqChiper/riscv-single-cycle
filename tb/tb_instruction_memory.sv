`timescale 1ns / 1ps

module tb_instruction_memory;

    logic [31:0] addr;
    logic [31:0] instr;

    instruction_memory dut (
        .addr  (addr),
        .instr (instr)
    );

    int pass_count = 0;
    int fail_count = 0;

    task check(
        input string name,
        input logic [31:0] expected
    );
        if (instr === expected) begin
            $display("PASS: %s | Addr = %h | Instr = %h",
                     name, addr, instr);
            pass_count++;
        end
        else begin
            $display("FAIL: %s | Addr = %h | Expected = %h | Got = %h",
                     name, addr, expected, instr);
            fail_count++;
        end
    endtask

    initial begin

        $display("--- Instruction Memory Test Start ---\n");

        addr = 32'h00000000;
        #10;
        check("Address 0", 32'h00000013);

        addr = 32'h00000004;
        #10;
        check("Address 4", 32'h00000013);

        addr = 32'h00000008;
        #10;
        check("Address 8", 32'h00000013);

        addr = 32'h0000000C;
        #10;
        check("Address 12", 32'h00000013);

        addr = 32'h00000040;
        #10;
        check("Address 64", 32'h00000013);

        $display("\n--- Instruction Memory Test Summary ---");
        $display("Passed: %0d, Failed: %0d",
                 pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: Instruction memory tests");
        else
            $display("FAIL: Instruction memory tests");

        $finish;

    end

endmodule