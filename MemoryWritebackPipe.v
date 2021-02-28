module MemoryWritebackPipe(writeback_IR, memory_IR, writeback_PC, memory_PC, writeback_aluOut, memory_aluOut, writeback_dataOut, q_dmem, writeback_aluoverflow, memory_aluoverflow, clock, reset, en);
    input clock, reset, memory_aluoverflow, en;
    input [31:0] memory_IR, memory_PC,memory_aluOut, q_dmem;
    output writeback_aluoverflow;
    output [31:0] writeback_IR, writeback_PC, writeback_aluOut, writeback_dataOut;

    dffe_ref flop0(writeback_aluoverflow, memory_aluoverflow, clock, en, reset);
    register_32 EM_IRReg(writeback_IR, memory_IR, clock, reset, en);
    register_32 EM_PCReg(writeback_PC, memory_PC, clock, reset, en);
    register_32 EM_aluOutReg(writeback_aluOut, memory_aluOut, clock, reset, en);
    register_32 EM_BReg(writeback_dataOut, q_dmem, clock, reset, en);

endmodule