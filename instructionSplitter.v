module instructionSplitter(instruction, opcode, rd, rs, rt, shamt, aluOp, immediate, target);

    input[31:0] instruction;
    output[4:0] opcode, rd, rs, rt, shamt, aluOp;
    output [31:0] immediate;
    output [26:0] target;

    assign opcode = instruction[31:27];
    assign rd = instruction[26:22];
    assign rs = instruction[21:17];
    assign rt = instruction[16:12];
    assign shamt = instruction[11:7];
    assign aluOp = instruction[6:2];
    assign target = instruction[26:0];

    assign immediate[31] = instruction[16];
    assign immediate[30] = instruction[16];
    assign immediate[29] = instruction[16];
    assign immediate[28] = instruction[16];
    assign immediate[27] = instruction[16];
    assign immediate[26] = instruction[16];
    assign immediate[25] = instruction[16];
    assign immediate[24] = instruction[16];
    assign immediate[23] = instruction[16];
    assign immediate[22] = instruction[16];
    assign immediate[21] = instruction[16];
    assign immediate[20] = instruction[16];
    assign immediate[19] = instruction[16];
    assign immediate[18] = instruction[16];
    assign immediate[17] = instruction[16];
    assign immediate[16:0] = instruction[16:0];

endmodule