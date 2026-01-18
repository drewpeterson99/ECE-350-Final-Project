module divCounter(ctrl_DIV, clock, data_resultRDY, beginDiv);

    // "Johnson Counter" 
    // asserts data_resultRDY during the 32nd clock cycle after ctrl_Div was last asserted
    // asserts beginDIV during the whole clock cycle that beginDIV is asserted on

    input ctrl_DIV, clock;

    output data_resultRDY, beginDiv;

    wire q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16;
    wire not_q0, not_q1, not_q2, not_q3, not_q4, not_q5, not_q6, not_q7, not_q8, not_q9, not_q10, not_q11, not_q12, not_q13, not_q14, not_q15, not_q16;

    and divReadyOutput(data_resultRDY, not_q15, q16);
    and beginDivOutput(beginDiv, not_q0, not_q16);

    not(not_q0, q0);
    not(not_q1, q1);
    not(not_q2, q2);
    not(not_q3, q3);
    not(not_q4, q4);
    not(not_q5, q5);
    not(not_q6, q6);
    not(not_q7, q7);
    not(not_q8, q8);
    not(not_q9, q9);
    not(not_q10, q10);
    not(not_q11, q11);
    not(not_q12, q12);
    not(not_q13, q13);
    not(not_q14, q14);
    not(not_q15, q15);
    not(not_q16, q16);

    dffe_ref flop0(q0, not_q16, clock, 1'b1, ctrl_DIV);
    dffe_ref flop1(q1, q0, clock, 1'b1, ctrl_DIV);
    dffe_ref flop2(q2, q1, clock, 1'b1, ctrl_DIV);
    dffe_ref flop3(q3, q2, clock, 1'b1, ctrl_DIV);
    dffe_ref flop4(q4, q3, clock, 1'b1, ctrl_DIV);
    dffe_ref flop5(q5, q4, clock, 1'b1, ctrl_DIV);
    dffe_ref flop6(q6, q5, clock, 1'b1, ctrl_DIV);
    dffe_ref flop7(q7, q6, clock, 1'b1, ctrl_DIV);
    dffe_ref flop8(q8, q7, clock, 1'b1, ctrl_DIV);
    dffe_ref flop9(q9, q8, clock, 1'b1, ctrl_DIV);
    dffe_ref flop10(q10, q9, clock, 1'b1, ctrl_DIV);
    dffe_ref flop11(q11, q10, clock, 1'b1, ctrl_DIV);
    dffe_ref flop12(q12, q11, clock, 1'b1, ctrl_DIV);
    dffe_ref flop13(q13, q12, clock, 1'b1, ctrl_DIV);
    dffe_ref flop14(q14, q13, clock, 1'b1, ctrl_DIV);
    dffe_ref flop15(q15, q14, clock, 1'b1, ctrl_DIV);
    dffe_ref flop16(q16, q15, clock, 1'b1, ctrl_DIV);

endmodule