`timescale 1ns / 1ps

package immediate_pkg;

    typedef enum logic [1:0] {
        IMM_I = 2'b00,
        IMM_S = 2'b01,
        IMM_B = 2'b10
    } imm_type_t;

endpackage