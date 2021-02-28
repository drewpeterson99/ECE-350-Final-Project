module mux_8_1bit(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7;
    output out;
    wire w1, w2;
    mux_4_1bit first_top(w1, select[1:0], in0, in1, in2, in3);
    mux_4_1bit first_bottom(w2, select[1:0], in4, in5, in6, in7);
    mux_2_1bit second(out, select[2], w1, w2);
endmodule