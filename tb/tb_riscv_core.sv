module tb_riscv_core;

    logic clk = 0;
    logic rst;

    always #5 clk = ~clk;

    // DUT
    riscv_core #(
        .PROGRAM_FILE(
            "C:/Users/thRin/Documents/riscv-single-cycle/hex/test_branch.hex"
        )
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    int pass_count = 0;
    int fail_count = 0;

    // check_reg task stays here, OUTSIDE initial begin
    task check_reg(
        input string name,
        input int reg_num,
        input logic [31:0] expected
    );
        if (dut.registers.regs[reg_num] === expected) begin
            $display(
                "PASS: %s | x%0d = %h",
                name,
                reg_num,
                dut.registers.regs[reg_num]
            );
            pass_count++;
        end
        else begin
            $display(
                "FAIL: %s | x%0d | Expected = %h | Got = %h",
                name,
                reg_num,
                expected,
                dut.registers.regs[reg_num]
            );
            fail_count++;
        end
    endtask


    // Test sequence
    initial begin

        $display("");
        $display("========================================");
        $display("     RISC-V BRANCH TESTBENCH");
        $display("========================================");
        $display("");

        // Reset
        rst = 1;
        #12;
        rst = 0;

        // Allow program to execute
        #60;

        // Checks
        check_reg("ADDI x1 = 5",          1, 32'd5);
        check_reg("ADDI x2 = 5",          2, 32'd5);
        check_reg("BEQ skipped x3",       3, 32'd0);
        check_reg("Branch target x4 = 4",  4, 32'd4);
        check_reg("x0 remains zero",       0, 32'd0);

        // Summary
        $display("");
        $display("========================================");
        $display("        BRANCH PROGRAM SUMMARY");
        $display("========================================");

        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0)
            $display("PASS: RISC-V branch program executed correctly");
        else
            $display("FAIL: RISC-V branch program execution");

        $display("========================================");
        $display("");

        $finish;

    end

endmodule