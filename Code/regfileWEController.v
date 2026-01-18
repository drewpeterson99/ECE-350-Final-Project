module regfileWEController(opcode, ctrl_writeEnable);

    input[4:0] opcode;
    output ctrl_writeEnable;

    wire alu_, addi_, lw_, jal_, setx_;

    and(alu_, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
    and(addi_, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
    and(lw_, ~opcode[4], opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
    and(jal_, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], opcode[0]);
    and(setx_, opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);

    or(ctrl_writeEnable, alu_, addi_, lw_, jal_, setx_);

endmodule