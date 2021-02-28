module ExecuteMemoryPipe(memory_IR, execute_IR, memory_PC, execute_PC, memory_aluOut, aluOutput, memory_B, operandBBypassMuxOut, memory_aluoverflow, alu_overflow, clock, reset, en);
    input clock, reset, alu_overflow, en;
    input [31:0] execute_IR, execute_PC,aluOutput, operandBBypassMuxOut;
    output memory_aluoverflow;
    output [31:0] memory_IR, memory_PC, memory_aluOut, memory_B;

    dffe_ref flop0(memory_aluoverflow, alu_overflow, clock, en, reset);
    register_32 EM_IRReg(memory_IR, execute_IR, clock, reset, en);
    register_32 EM_PCReg(memory_PC, execute_PC, clock, reset, en);
    register_32 EM_aluOutReg(memory_aluOut, aluOutput, clock, reset, en);
    register_32 EM_BReg(memory_B, operandBBypassMuxOut, clock, reset, en);

endmodule