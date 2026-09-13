`timescale 1ns / 1ps

module tb_data_memory;

    logic        clk = 0;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] addr;
    logic [31:0] write_data;
    logic [31:0] read_data;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    data_memory dut (.*);

    int pass_count = 0;
    int fail_count = 0;

    task check(
        input string name,
        input logic [31:0] expected
    );
        if (read_data === expected) begin
            $display("PASS: %s", name);
            pass_count++;
        end
        else begin
            $display(
                "FAIL: %s | Expected: %h | Got: %h",
                name, expected, read_data
            );
            fail_count++;
        end
    endtask

    initial begin

        // Initialize inputs
        mem_read  = 0;
        mem_write = 0;
        addr      = 32'h0000_0000;
        write_data = 32'h0000_0000;

        #10;

        // 1. Store Word to address 0x00
        mem_write = 1;
        addr = 32'h0000_0000;
        write_data = 32'hDEAD_BEEF;

        #10; // Wait for clock edge
        mem_write = 0;

        // 2. Load Word from address 0x00
        mem_read = 1;
        addr = 32'h0000_0000;

        #5;
        check("sw -> lw (addr 0x00)", 32'hDEAD_BEEF);

        // 3. Store Word to address 0x04
        mem_read  = 0;
        mem_write = 1;
        addr = 32'h0000_0004;
        write_data = 32'hCAFE_BABE;

        #10;
        mem_write = 0;

        // 4. Load Word from address 0x04
        mem_read = 1;
        addr = 32'h0000_0004;

        #5;
        check("sw -> lw (addr 0x04)", 32'hCAFE_BABE);

        // 5. Verify read disabled
        mem_read = 0;

        #5;
        check("read disabled (mem_read=0)", 32'h0000_0000);

        // Summary
        $display("\n--- Data Memory Test Summary ---");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: Data Memory tests");
        else
            $display("FAIL: Data Memory tests");

        $finish;

    end

endmodule