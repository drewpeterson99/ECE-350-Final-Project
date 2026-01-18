module stallController(stallSignal, execute_opcode, memory_opcode, execute_rd, memory_rd, decode_rs, decode_rt, decode_rd, decode_opcode);

    input[4:0] execute_opcode, memory_opcode, execute_rd, memory_rd, decode_rs, decode_rt, decode_rd, decode_opcode;
    output stallSignal;

    /* Regular hardware interlock stall logic (lw immediately followed by an ALU operation): */

    wire executeOpIsLoad, decodeRsIsExecuteRd, decodeRtIsExecuteRd, decodeOpIsStore;
    
    wire executeDestinationNotR0;
    assign executeDestinationNotR0 = !(execute_rd == 5'b00000);

    and(executeOpIsLoad, ~execute_opcode[4], execute_opcode[3], ~execute_opcode[2], ~execute_opcode[1], ~execute_opcode[0]);
    assign decodeRsIsExecuteRd = (decode_rs == execute_rd) & executeDestinationNotR0;
    assign decodeRtIsExecuteRd = (decode_rt == execute_rd) & executeDestinationNotR0;
    and(decodeOpIsStore, ~decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], decode_opcode[0]);

    wire sourceDestinationHazard;
    or(sourceDestinationHazard, decodeRsIsExecuteRd, decodeRtIsExecuteRd);

    wire regularStallSignal;
    and(regularStallSignal, sourceDestinationHazard, executeOpIsLoad, !decodeOpIsStore);

    /* Branch stall logic (if preceeding instructions are going to write to rd, rs, or rstatus of branch instruction in decode stage): */

    wire decodeOpIsBex, decodeOpIsBne, decodeOpIsBlt;
    and(decodeOpIsBex, decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);
    and(decodeOpIsBne, ~decode_opcode[4], ~decode_opcode[3], ~decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);
    and(decodeOpIsBlt, ~decode_opcode[4], ~decode_opcode[3], decode_opcode[2], decode_opcode[1], ~decode_opcode[0]);

    wire memoryDestinationNotR0;
    assign memoryDestinationNotR0 = !(memory_rd == 5'b00000);

    wire decodeRdIsExecuteRd, decodeRsIsMemoryRd, decodeRdIsMemoryRd;
    assign decodeRdIsExecuteRd = (decode_rd == execute_rd) & executeDestinationNotR0;
    assign decodeRsIsMemoryRd = (decode_rs == memory_rd) & memoryDestinationNotR0;
    assign decodeRdIsMemoryRd = (decode_rd == memory_rd) & memoryDestinationNotR0;

    wire executeOpIsAlu, executeOpIs0, executeOpIsAddi, executeOpIsSetx, executeOpIsLw;
    and(executeOpIs0, ~execute_opcode[4], ~execute_opcode[3], ~execute_opcode[2], ~execute_opcode[1], ~execute_opcode[0]);
    and(executeOpIsAddi, ~execute_opcode[4], ~execute_opcode[3], execute_opcode[2], ~execute_opcode[1], execute_opcode[0]);
    or(executeOpIsAlu, executeOpIs0, executeOpIsAddi);
    and(executeOpIsSetx, execute_opcode[4], ~execute_opcode[3], execute_opcode[2], ~execute_opcode[1], execute_opcode[0]);
    and(executeOpIsLw, ~execute_opcode[4], execute_opcode[3], ~execute_opcode[2], ~execute_opcode[1], ~execute_opcode[0]);

    wire memoryOpIsAlu, memoryOpIs0, memoryOpIsAddi, memoryOpIsSetx, memoryOpIsLw; 
    and(memoryOpIs0, ~memory_opcode[4], ~memory_opcode[3], ~memory_opcode[2], ~memory_opcode[1], ~memory_opcode[0]);
    and(memoryOpIsAddi, ~memory_opcode[4], ~memory_opcode[3], memory_opcode[2], ~memory_opcode[1], memory_opcode[0]);
    or(memoryOpIsAlu, memoryOpIs0, memoryOpIsAddi);
    and(memoryOpIsSetx, memory_opcode[4], ~memory_opcode[3], memory_opcode[2], ~memory_opcode[1], memory_opcode[0]);
    and(memoryOpIsLw, ~memory_opcode[4], memory_opcode[3], ~memory_opcode[2], ~memory_opcode[1], ~memory_opcode[0]);

    wire memoryOpPotentialException, executeOpPotentialException;
    and(executeOpPotentialException, executeOpIsAlu, executeDestinationNotR0);
    and(memoryOpPotentialException, memoryOpIsAlu, memoryDestinationNotR0);

    wire potentialExceptionRegWrite;
    or(potentialExceptionAhead, memoryOpPotentialException, executeOpPotentialException, memoryOpIsSetx, executeOpIsSetx);

    wire executeOpWritesToRegfile, memoryOpWritesToRegfile;
    or(executeOpWritesToRegfile, executeOpIsAlu, executeOpIsSetx, executeOpIsLw);
    or(memoryOpWritesToRegfile, memoryOpIsAlu, memoryOpIsSetx, memoryOpIsLw);

    wire decodeExecuteHazard_temp, decodeMemoryHazard_temp, decodeExecuteHazard, decodeMemoryHazard;
    or(decodeExecuteHazard_temp, decodeRsIsExecuteRd, decodeRdIsExecuteRd);
    or(decodeMemoryHazard_temp, decodeRsIsMemoryRd, decodeRdIsMemoryRd);
    and(decodeExecuteHazard, decodeExecuteHazard_temp, executeDestinationNotR0, executeOpWritesToRegfile);
    and(decodeMemoryHazard, decodeMemoryHazard_temp, memoryDestinationNotR0, memoryOpWritesToRegfile);

    wire branchHazard;
    or(branchHazard, decodeExecuteHazard, decodeMemoryHazard);

    wire bexStall, bneStall, bltStall;
    and(bexStall, decodeOpIsBex, potentialExceptionAhead);
    and(bneStall, decodeOpIsBne, branchHazard);
    and(bltStall, decodeOpIsBlt, branchHazard);

    wire branchStallSignal;
    or(branchStallSignal, bexStall, bneStall, bltStall);

    /* Final Signal: */
    or(stallSignal, regularStallSignal, branchStallSignal);

endmodule