// Data memory module.
`timescale 1ns / 1ps

module data_memory (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    // 256 words of memory (1KB)
    logic [31:0] mem [0:255];

    logic [7:0] word_addr;
    assign word_addr = addr[9:2];

    always_ff @(posedge clk) begin
        if (mem_write) begin
            mem[word_addr] <= write_data;
        end
    end

    assign read_data = mem_read ? mem[word_addr] : 32'b0;

endmodule