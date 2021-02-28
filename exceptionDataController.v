module exceptionDataController(exceptionData, writeback_aluop, writeback_opcode);

    input[4:0] writeback_opcode, writeback_aluop;
    output [31:0] exceptionData;

    wire writebackOpIsAddi;
    wire [31:0] tempExceptionData; 

    and(writebackOpIsAddi, ~writeback_opcode[4], ~writeback_opcode[3], writeback_opcode[2], ~writeback_opcode[1], writeback_opcode[0]);

    mux_8_32bit exceptionDataInitialMux(tempExceptionData, writeback_aluop[2:0], 32'd1, 32'd3, 32'd0, 32'd0, 32'd0, 32'd0, 32'd4, 32'd5);

    mux_2_32bit exceptionDataMux(exceptionData, writebackOpIsAddi, tempExceptionData, 32'd2);


endmodule
