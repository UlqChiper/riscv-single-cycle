// Arithmetic logic unit module.
`timescale 1ns / 1ps

import alu_pkg::*;

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  alu_op_t     alu_op,
    output logic [31:0] result,
    output logic        eq
);

    always_comb begin
        case (alu_op)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            default: result = 32'b0;
        endcase

        eq = (a == b);
    end

endmodule