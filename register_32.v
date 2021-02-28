module register_32(out, in, clk, clr, en);
    input clk, clr, en;
    input [31:0] in;
    output [31:0] out;

    dffe_ref flop0(out[0], in[0], clk, en, clr);
    dffe_ref flop1(out[1], in[1], clk, en, clr);
    dffe_ref flop2(out[2], in[2], clk, en, clr);
    dffe_ref flop3(out[3], in[3], clk, en, clr);
    dffe_ref flop4(out[4], in[4], clk, en, clr);
    dffe_ref flop5(out[5], in[5], clk, en, clr);
    dffe_ref flop6(out[6], in[6], clk, en, clr);
    dffe_ref flop7(out[7], in[7], clk, en, clr);
    dffe_ref flop8(out[8], in[8], clk, en, clr);
    dffe_ref flop9(out[9], in[9], clk, en, clr);
    dffe_ref flop10(out[10], in[10], clk, en, clr);
    dffe_ref flop11(out[11], in[11], clk, en, clr);
    dffe_ref flop12(out[12], in[12], clk, en, clr);
    dffe_ref flop13(out[13], in[13], clk, en, clr);
    dffe_ref flop14(out[14], in[14], clk, en, clr);
    dffe_ref flop15(out[15], in[15], clk, en, clr);
    dffe_ref flop16(out[16], in[16], clk, en, clr);
    dffe_ref flop17(out[17], in[17], clk, en, clr);
    dffe_ref flop18(out[18], in[18], clk, en, clr);
    dffe_ref flop19(out[19], in[19], clk, en, clr);
    dffe_ref flop20(out[20], in[20], clk, en, clr);
    dffe_ref flop21(out[21], in[21], clk, en, clr);
    dffe_ref flop22(out[22], in[22], clk, en, clr);
    dffe_ref flop23(out[23], in[23], clk, en, clr);
    dffe_ref flop24(out[24], in[24], clk, en, clr);
    dffe_ref flop25(out[25], in[25], clk, en, clr);
    dffe_ref flop26(out[26], in[26], clk, en, clr);
    dffe_ref flop27(out[27], in[27], clk, en, clr);
    dffe_ref flop28(out[28], in[28], clk, en, clr);
    dffe_ref flop29(out[29], in[29], clk, en, clr);
    dffe_ref flop30(out[30], in[30], clk, en, clr);
    dffe_ref flop31(out[31], in[31], clk, en, clr);

endmodule