// Immediate generator module.
`timescale 1ns / 1ps

import immediate_pkg::*;

module immediate_generator (
    input  logic [31:0] instruction,
    input  imm_type_t   imm_type,
    output logic [31:0] immediate
);

    always_comb begin
        case (imm_type)

            // I-type: addi, lw
            IMM_I: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:20]
                };
            end

            // S-type: sw
            IMM_S: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:25],
                    instruction[11:7]
                };
            end

            // B-type: beq
            IMM_B: begin
                immediate = {
                    {19{instruction[31]}},
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8],
                    1'b0
                };
            end

            default: begin
                immediate = 32'b0;
            end

        endcase
    end

endmodule