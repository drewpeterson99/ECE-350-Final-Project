module multdivStallController(multdivStallSignal_x, multdivStallSignal_m, ctrl_DIV, ctrl_MULT, execute_aluop, execute_opcode, memory_aluop, memory_opcode, multdiv_resultRDY);

    input[4:0] execute_opcode, execute_aluop, memory_aluop, memory_opcode;
    input multdiv_resultRDY;
    output multdivStallSignal_x, multdivStallSignal_m, ctrl_DIV, ctrl_MULT;

    wire executeOpIs0, executeALUIsMult, executeALUIsDiv;
    wire memoryOpIs0, memoryALUIsMult, memoryALUIsDiv;

    assign executeOpIs0 = (execute_opcode == 5'b00000);
    assign memoryOpIs0 = (memory_opcode == 5'b00000);

    and(executeALUIsMult, ~execute_aluop[4], ~execute_aluop[3], execute_aluop[2], execute_aluop[1], ~execute_aluop[0]);
    and(executeALUIsDiv, ~execute_aluop[4], ~execute_aluop[3], execute_aluop[2], execute_aluop[1], execute_aluop[0]);
    and(memoryALUIsMult, ~memory_aluop[4], ~memory_aluop[3], memory_aluop[2], memory_aluop[1], ~memory_aluop[0]);
    and(memoryALUIsDiv, ~memory_aluop[4], ~memory_aluop[3], memory_aluop[2], memory_aluop[1], memory_aluop[0]);

    wire cond1;
    or(cond1, executeALUIsDiv, executeALUIsMult);
    wire cond2;
    or(cond2, memoryALUIsDiv, memoryALUIsMult);

    and(ctrl_MULT, executeALUIsMult, executeOpIs0);
    and(ctrl_DIV, executeALUIsDiv, executeOpIs0);
    and(multdivStallSignal_x, cond1, executeOpIs0);
    and(multdivStallSignal_m, cond2, memoryOpIs0, !multdiv_resultRDY);

endmodule