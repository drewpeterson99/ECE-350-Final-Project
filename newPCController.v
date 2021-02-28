module newPCController(newPCSelect, execute_opcode);

    input[4:0] execute_opcode;
    output [1:0] newPCSelect;

    wire jr_, j_, jal_, bex_;

    and(jr_, ~execute_opcode[4], ~execute_opcode[3], execute_opcode[2], ~execute_opcode[1], ~execute_opcode[0]);
    and(j_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], ~execute_opcode[1], execute_opcode[0]);
    and(jal_, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], execute_opcode[1], execute_opcode[0]);
    and(bex_, execute_opcode[4], ~execute_opcode[3], execute_opcode[2], execute_opcode[1], ~execute_opcode[0]);

    assign newPCSelect[1] = jr_;
    or(newPCSelect[0], j_, jal_, bex_);

endmodule