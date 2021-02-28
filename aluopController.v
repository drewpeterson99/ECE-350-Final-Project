module aluopController(isBranch, execute_opcode);

    input [4:0] execute_opcode;
    output isBranch;

    wire bne_, blt_;

    and(bne_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);
    and(blt_, ~execute_opcode[4], ~execute_opcode[3], execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);
    and(bex_, execute_opcode[4], ~execute_opcode[3], execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);

    or(isBranch, bne_, blt_);

endmodule