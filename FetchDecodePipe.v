module FetchDecodePipe(IROut, IRIn, PCOut, PCIn, clock, reset, en);
    input clock, reset, en;
    input [31:0] IRIn, PCIn;
    output [31:0] IROut, PCOut;

    register_32 FD_PCReg(PCOut, PCIn, clock, reset, en);
    register_32 FD_IRReg(IROut, IRIn, clock, reset, en);

endmodule