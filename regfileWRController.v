module regfileWRController(regfileWRSelect, writeback_opcode, writeback_aluop, writeback_aluoverflow, multdivFinalException);

    input[4:0] writeback_opcode, writeback_aluop;
    input writeback_aluoverflow, multdivFinalException;
    output [1:0] regfileWRSelect;

    wire writebackALUIsMult, writebackALUIsDiv, writebackOpIs0, writebackOpIsJal, writebackOpIsSetx;

    assign writebackOpIs0 = (writeback_opcode == 5'b00000);
    and(writebackALUIsMult, ~writeback_aluop[4], ~writeback_aluop[3], writeback_aluop[2], writeback_aluop[1], ~writeback_aluop[0]);
    and(writebackALUIsDiv, ~writeback_aluop[4], ~writeback_aluop[3], writeback_aluop[2], writeback_aluop[1], writeback_aluop[0]);
    and(writebackOpIsJal, ~writeback_opcode[4], ~writeback_opcode[3], ~writeback_opcode[2], writeback_opcode[1], writeback_opcode[0]);
    and(writebackOpIsSetx, writeback_opcode[4], ~writeback_opcode[3], writeback_opcode[2], ~writeback_opcode[1], writeback_opcode[0]);

    wire writebackALUIsMultDiv;
    or(writebackALUIsMultDiv, writebackALUIsMult, writebackALUIsDiv);

    wire writebackIRIsMultDiv;
    and(writebackIRIsMultDiv, writebackALUIsMultDiv, writebackOpIs0);

    wire multdivActualException;
    and(multdivActualException, writebackIRIsMultDiv, multdivFinalException);

    wire aluActualException;
    and(aluActualException, writeback_aluoverflow, writebackOpIs0);    

    or(regfileWRSelect[0], writebackOpIsJal);
    or(regfileWRSelect[1], aluActualException, multdivActualException, writebackOpIsSetx);

endmodule