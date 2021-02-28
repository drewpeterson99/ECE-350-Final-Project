module DecodeExecutePipe(execute_IR, DE_IRInput, execute_PC, decode_PC, execute_A, data_readRegA, execute_B, data_readRegB, clock, reset, en);
    input clock, reset, en;
    input [31:0] DE_IRInput, decode_PC, data_readRegA, data_readRegB;
    output [31:0] execute_IR, execute_PC, execute_A, execute_B;

    register_32 DE_PCReg(execute_PC, decode_PC, clock, reset, en);
    register_32 DE_AReg(execute_A, data_readRegA, clock, reset, en);
    register_32 DE_BReg(execute_B, data_readRegB, clock, reset, en);
    
    register_32 DE_IRReg(execute_IR, DE_IRInput, clock, reset, en);

endmodule