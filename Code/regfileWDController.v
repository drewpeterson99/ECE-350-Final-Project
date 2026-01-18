module regfileWDController(regfileWDSelect, writeback_opcode, writeback_aluop, writeback_aluoverflow, multdivFinalException);

    input[4:0] writeback_opcode, writeback_aluop;
    input writeback_aluoverflow, multdivFinalException;
    output [2:0] regfileWDSelect;

    wire writebackOpIsLw, writebackALUIsMult, writebackALUIsDiv, writebackOpIs0, writebackOpIsSetx, writebackOpIsJal;

    and(writebackOpIsLw, ~writeback_opcode[4], writeback_opcode[3], ~writeback_opcode[2], ~writeback_opcode[1], ~writeback_opcode[0]);
    and(writebackOpIsSetx, writeback_opcode[4], ~writeback_opcode[3], writeback_opcode[2], ~writeback_opcode[1], writeback_opcode[0]);
    and(writebackOpIsJal, ~writeback_opcode[4], ~writeback_opcode[3], ~writeback_opcode[2], writeback_opcode[1], writeback_opcode[0]);

    assign writebackOpIs0 = (writeback_opcode == 5'b00000);
    and(writebackALUIsMult, ~writeback_aluop[4], ~writeback_aluop[3], writeback_aluop[2], writeback_aluop[1], ~writeback_aluop[0]);
    and(writebackALUIsDiv, ~writeback_aluop[4], ~writeback_aluop[3], writeback_aluop[2], writeback_aluop[1], writeback_aluop[0]);

    wire writebackALUIsMultDiv;
    or(writebackALUIsMultDiv, writebackALUIsMult, writebackALUIsDiv);

    wire writebackIRIsMultDiv;
    and(writebackIRIsMultDiv, writebackALUIsMultDiv, writebackOpIs0);

    wire multdivActualException;
    and(multdivActualException, writebackIRIsMultDiv, multdivFinalException);

    wire aluActualException;
    and(aluActualException, writeback_aluoverflow, writebackOpIs0);

    wire exceptionDetected;
    or(exceptionDetected, aluActualException, multdivActualException);

    // Default is select = 000. If lw, select = 001. If multdiv, select = 010. If setx, select = 011. If jal, select = 100. If exception, select = 111.

    or(regfileWDSelect[0], writebackOpIsLw, writebackOpIsSetx, exceptionDetected);
    or(regfileWDSelect[1], writebackIRIsMultDiv, writebackOpIsSetx, exceptionDetected);
    or(regfileWDSelect[2], writebackOpIsJal, exceptionDetected);

endmodule