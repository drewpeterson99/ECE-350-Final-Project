module multCounter(ctrl_MULT, clock, data_resultRDY, beginMult);

    // "Johnson Counter" 
    // asserts data_resultRDY during the 16th clock cycle after ctrl_MULT was last asserted
    // asserts beginMult during the whole clock cycle that beginMult is asserted on

    input ctrl_MULT, clock;

    output data_resultRDY, beginMult;

    wire q0, q1, q2, q3, q4, q5, q6, q7, q8;
    wire not_q0, not_q1, not_q2, not_q3, not_q4, not_q5, not_q6, not_q7, not_q8;

    and multReadyOutput(data_resultRDY, not_q7, q8);
    and beginMultOutput(beginMult, not_q0, not_q8);

    not(not_q0, q0);
    not(not_q1, q1);
    not(not_q2, q2);
    not(not_q3, q3);
    not(not_q4, q4);
    not(not_q5, q5);
    not(not_q6, q6);
    not(not_q7, q7);
    not(not_q8, q8);

    dffe_ref flop0(q0, not_q8, clock, 1'b1, ctrl_MULT);
    dffe_ref flop1(q1, q0, clock, 1'b1, ctrl_MULT);
    dffe_ref flop2(q2, q1, clock, 1'b1, ctrl_MULT);
    dffe_ref flop3(q3, q2, clock, 1'b1, ctrl_MULT);
    dffe_ref flop4(q4, q3, clock, 1'b1, ctrl_MULT);
    dffe_ref flop5(q5, q4, clock, 1'b1, ctrl_MULT);
    dffe_ref flop6(q6, q5, clock, 1'b1, ctrl_MULT);
    dffe_ref flop7(q7, q6, clock, 1'b1, ctrl_MULT);
    dffe_ref flop8(q8, q7, clock, 1'b1, ctrl_MULT);

endmodule