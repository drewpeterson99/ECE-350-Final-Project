module mux_2_1bit(out, select, in0, in1);
    // passes in1 if select = 1, passes in0 if select = 0
    input select;
    input in0, in1;
    output out;
    assign out = select ? in1 : in0;
endmodule

