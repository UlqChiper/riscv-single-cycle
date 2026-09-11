// Control unit module.
`timescale 1ns / 1ps

import alu_pkg::*;
import opcode_pkg::*;

module control_unit (
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,

    output logic        reg_write,
    output logic        alu_src,
    output logic        mem_read,
    output logic        mem_write,
    output logic        mem_to_reg,
    output logic        branch,
    output alu_op_t     alu_op
);

    always_comb begin

       //
        // Safe default values
       //
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        alu_op     = ALU_ADD;

        case (opcode)

            //
            // R-TYPE: ADD, SUB, AND, OR
            //
            OP_REG: begin

                case (funct3)

                    // ADD / SUB
                    3'b000: begin
                        if (funct7 == 7'b0100000) begin
                            alu_op = ALU_SUB;
                            reg_write = 1'b1;
                        end
                        else if (funct7 == 7'b0000000) begin
                            alu_op = ALU_ADD;
                            reg_write = 1'b1;
                        end
                        else begin
                            // Unsupported funct7
                            reg_write = 1'b0;
                            alu_op = ALU_ADD;
                        end
                    end

                    // AND
                    3'b111: begin
                        if (funct7 == 7'b0000000) begin
                            alu_op = ALU_AND;
                            reg_write = 1'b1;
                        end
                    end

                    // OR
                    3'b110: begin
                        if (funct7 == 7'b0000000) begin
                            alu_op = ALU_OR;
                            reg_write = 1'b1;
                        end
                    end

                    // Unsupported funct3
                    default: begin
                        reg_write = 1'b0;
                        alu_op = ALU_ADD;
                    end

                endcase
            end


            //
            // I-TYPE: ADDI
            //
            OP_IMM: begin

                // Only ADDI is supported in this project.
                if (funct3 == 3'b000) begin
                    reg_write = 1'b1;
                    alu_src   = 1'b1;
                    alu_op    = ALU_ADD;
                end

            end


            //
            // LOAD: LW
            //
            OP_LOAD: begin

                // Only LW is supported.
                if (funct3 == 3'b010) begin
                    reg_write  = 1'b1;
                    alu_src    = 1'b1;
                    mem_read   = 1'b1;
                    mem_to_reg = 1'b1;
                    alu_op     = ALU_ADD;
                end

            end


            //
            // STORE: SW
            //
            OP_STORE: begin

                // Only SW is supported.
                if (funct3 == 3'b010) begin
                    alu_src   = 1'b1;
                    mem_write = 1'b1;
                    alu_op    = ALU_ADD;
                end

            end


            //
            // BRANCH: BEQ
            //
            OP_BRANCH: begin

                // Only BEQ is supported.
                if (funct3 == 3'b000) begin
                    branch = 1'b1;
                    alu_op = ALU_SUB;
                end

            end


            //
            // Unsupported opcode
            //
            default: begin
                // Keep all control signals at safe defaults.
            end

        endcase
    end

endmodule