// Instruction memory module.
`timescale 1ns / 1ps

module instruction_memory #(
    parameter string PROGRAM_FILE = ""
) (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    // 256 words × 32 bits = 1 KB
    logic [31:0] mem [0:255];

    // Convert byte address to word address.
    // Each instruction is 4 bytes.
    logic [7:0] word_addr;
    assign word_addr = addr[9:2];

    // Initialize instruction memory.
    initial begin
        // Default unused locations to NOP.
        for (int i = 0; i < 256; i++) begin
            mem[i] = 32'h00000013;
        end

        // Load assembled program when a file is provided.
        if (PROGRAM_FILE != "") begin
            $display("Loading program: %s", PROGRAM_FILE);
            $readmemh(PROGRAM_FILE, mem);
        end
    end

    // Combinational instruction read.
    assign instr = mem[word_addr];

endmodule