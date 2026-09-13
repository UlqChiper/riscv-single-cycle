`timescale 1ns / 1ps

module tb_program_counter;

    logic        clk = 0;
    logic        rst;
    logic [31:0] next_pc;
    logic [31:0] pc;

    always #5 clk = ~clk;

    program_counter dut (.*);

    initial begin
        // Reset
        rst = 1;
        next_pc = 32'h0000_0000;
        #10;

        if (pc == 32'h0000_0000)
            $display("PASS: Reset");
        else
            $display("FAIL: Reset");

        // Normal PC update
        rst = 0;
        next_pc = 32'h0000_0004;
        #10;

        if (pc == 32'h0000_0004)
            $display("PASS: PC = 0x04");
        else
            $display("FAIL: PC = 0x04");

        // Another update
        next_pc = 32'h0000_0008;
        #10;

        if (pc == 32'h0000_0008)
            $display("PASS: PC = 0x08");
        else
            $display("FAIL: PC = 0x08");

        $finish;
    end

endmodule