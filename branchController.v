module branchController(takeBranch, execute_opcode, execute_B, alu_isLessThan, alu_isNotEqual);

    input [4:0] execute_opcode;
    input [31:0] execute_B;
    input alu_isLessThan, alu_isNotEqual;
    output takeBranch;

    wire bne_, blt_, jr_, j_, jal_, bex_;

    and(jr_, ~execute_opcode[4], ~execute_opcode[3], execute_opcode[2], ~execute_opcode[1], ~execute_opcode[0]);
    and(j_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], ~execute_opcode[1], execute_opcode[0]);
    and(jal_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], execute_opcode[1], execute_opcode[0]);
    and(bex_, execute_opcode[4], ~execute_opcode[3], execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);
    and(bne_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);
    and(blt_, ~execute_opcode[4], ~execute_opcode[3], execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);

    wire bneAndNotEqual, bltAndLessThan, bexAndNotZero, rstatusIsNot0;

    assign rstatusIsNot0 = !(execute_B == 32'd0);

    and(bneAndNotEqual, bne_, alu_isNotEqual);
    and(bltAndLessThan, blt_, !alu_isLessThan, alu_isNotEqual);
    and(bexAndNotZero, bex_, rstatusIsNot0);

    or(takeBranch, j_, jal_, jr_, bneAndNotEqual, bltAndLessThan, bexAndNotZero);

endmodule