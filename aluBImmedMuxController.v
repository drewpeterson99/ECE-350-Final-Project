module aluBImmedMuxController(opcode, inputIsImmed);

    input[4:0] opcode;
    output inputIsImmed;

    wire addi_, sw_, lw_;

    and(addi_, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
    and(sw_, ~opcode[4], ~opcode[3], opcode[2], opcode[1], opcode[0]);
    and(lw_, ~opcode[4], opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);

    or(inputIsImmed, addi_, sw_, lw_);

endmodule