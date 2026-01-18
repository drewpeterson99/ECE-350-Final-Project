module mux_4_1bit(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input in0, in1, in2, in3;
    output out;
    wire w1, w2;
    mux_2_1bit first_top(w1, select[0], in0, in1);
    mux_2_1bit first_bottom(w2, select[0], in2, in3);
    mux_2_1bit second(out, select[1], w1, w2);
endmodule