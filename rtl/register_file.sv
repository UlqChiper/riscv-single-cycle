// Register file module.
`timescale 1ns / 1ps

module register_file (
    input  logic        clk,
    input  logic        rst,

    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    input  logic        rd_write_enable
);

    // 32 registers, each 32 bits wide.
    logic [31:0] regs [0:31];

    // x0 is hardwired to zero.
    // Register reads are asynchronous.
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : regs[rs2_addr];

    // Register writes occur on the rising clock edge.
    // Reset clears all registers.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end
        else if (rd_write_enable && (rd_addr != 5'b0)) begin
            regs[rd_addr] <= rd_data;
        end
    end

endmodule