// Register file testbench.
`timescale 1ns / 1ps

module tb_register_file;

    logic        clk = 0;
    logic        rst;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rs1_data, rs2_data, rd_data;
    logic        rd_write_enable;

    always #5 clk = ~clk;

    register_file dut (.*);

    int pass_count = 0;
    int fail_count = 0;

    task check(
        input string test_name,
        input logic [31:0] exp1,
        input logic [31:0] exp2
    );
        if (rs1_data === exp1 && rs2_data === exp2) begin
            $display("PASS: %s", test_name);
            pass_count++;
        end
        else begin
            $display(
                "FAIL: %s | Exp: %h, %h | Got: %h, %h",
                test_name,
                exp1,
                exp2,
                rs1_data,
                rs2_data
            );
            fail_count++;
        end
    endtask

    initial begin

        // Reset
        rst = 1;
        rd_write_enable = 0;

        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        rd_addr  = 5'd1;
        rd_data  = 32'hDEADBEEF;

        #10;

        check("Reset state", 32'h00000000, 32'h00000000);

        rst = 0;

        // Write/read x1
        rd_addr = 5'd1;
        rd_data = 32'h12345678;
        rd_write_enable = 1;

        #10;

        rd_write_enable = 0;

        rs1_addr = 5'd1;
        rs2_addr = 5'd1;

        #1;

        check("Write/Read x1", 32'h12345678, 32'h12345678);

        // x0 must remain zero
        rd_addr = 5'd0;
        rd_data = 32'hFFFFFFFF;
        rd_write_enable = 1;

        #10;

        rd_write_enable = 0;

        rs1_addr = 5'd0;
        rs2_addr = 5'd0;

        #1;

        check("x0 hardwired zero", 32'h00000000, 32'h00000000);

        // Summary
        $display("");
        $display("--- Register File Test Summary ---");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: Register file tests");
        else
            $display("FAIL: Register file tests");

        $finish;
    end

endmodule