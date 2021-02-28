module regfileReadRegController(regfileReadRegSelect, decode_opcode);

    input [4:0] decode_opcode;
    output [1:0] regfileReadRegSelect;

    wire sw_, bne_, jr_, blt_, bex_;

    and(sw_, ~decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], decode_opcode[0]);
    and(bne_, ~decode_opcode[4], ~decode_opcode[3], ~decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);
    and(jr_, ~decode_opcode[4], ~decode_opcode[3], decode_opcode[2], ~decode_opcode[1], ~decode_opcode[0]);
    and(blt_, ~decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);
    and(bex_, decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);

    or(regfileReadRegSelect[0], sw_, bne_, jr_, blt_);
    assign regfileReadRegSelect[1] = bex_;

endmodule