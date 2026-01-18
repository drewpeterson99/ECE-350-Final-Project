module cla_32(S, Cout, A, B, Cin);

    input Cin;
    input [31:0] A, B;
    output Cout;
    output [31:0] S;

    wire c8, c16, c24;
    wire [7:0] A0to7, B0to7, A8to15, B8to15, A16to23, B16to23, A24to31, B24to31;
    wire [7:0] S0to7, S8to15, S16to23, S24to31;

    assign A0to7 = A[7:0];
    assign A8to15 = A[15:8];
    assign A16to23 = A[23:16];
    assign A24to31 = A[31:24];

    assign B0to7 = B[7:0];
    assign B8to15 = B[15:8];
    assign B16to23 = B[23:16];
    assign B24to31 = B[31:24];

    assign S[7:0] = S0to7;
    assign S[15:8] = S8to15;
    assign S[23:16] = S16to23;
    assign S[31:24] = S24to31;

    cla_8 block0(S0to7, c8, A0to7, B0to7, Cin);
    cla_8 block1(S8to15, c16, A8to15, B8to15, c8);
    cla_8 block2(S16to23, c24, A16to23, B16to23, c16);
    cla_8 block3(S24to31, Cout, A24to31, B24to31, c24);
    
endmodule