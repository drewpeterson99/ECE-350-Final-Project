module aluBypassMuxController(aluInASelect, aluInBSelect, execute_rs, execute_rt, memory_rd, writeback_rd, isBranch);

    input[4:0] execute_rt, execute_rs, memory_rd, writeback_rd;
    input isBranch; // Do NOT bypass if current instruction is a branch (we would have stalled if there was a potantial hazard)
    output [1:0] aluInASelect, aluInBSelect;

    wire ACond1, ACond2, BCond1, BCond2;

    wire memoryDestinationIsNotR0, writebackDestinationIsNotR0;
    assign memoryDestinationIsNotR0 = !(memory_rd == 5'b00000);
    assign writebackDestinationIsNotR0 = !(writeback_rd == 5'b00000);

    assign ACond1 = ((execute_rs == memory_rd) & memoryDestinationIsNotR0 & !isBranch);
    assign ACond2 = ((execute_rs == writeback_rd) & writebackDestinationIsNotR0 & !isBranch);
    assign BCond1 = ((execute_rt == memory_rd) & memoryDestinationIsNotR0 & !isBranch);
    assign BCond2 = ((execute_rt == writeback_rd) & writebackDestinationIsNotR0 & !isBranch);

    and(aluInASelect[0], !ACond1, ACond2);
    and(aluInASelect[1], !ACond1, !ACond2);

    and(aluInBSelect[0], !BCond1, BCond2);
    and(aluInBSelect[1], !BCond1, !BCond2);

endmodule