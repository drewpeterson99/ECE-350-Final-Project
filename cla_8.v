module cla_8(S, Cout, A, B, Cin);

    input Cin;
    input [7:0] A, B;
    output Cout;
    output [7:0] S;

    // wires needed for sum, propogate & generate, and carry bits
    wire s0, s1, s2, s3, s4, s5, s6, s7;
    wire p0, g0, p1, g1, p2, g2, p3, g3, p4, g4, p5, g5, p6, g6, p7, g7;
    wire c1, c2, c3, c4, c5, c6, c7;

    // assign outputs
    assign S[0] = s0;
    assign S[1] = s1;
    assign S[2] = s2;
    assign S[3] = s3;
    assign S[4] = s4;
    assign S[5] = s5;
    assign S[6] = s6;
    assign S[7] = s7;

    // wires needed for carry bit calculations
    wire pre_c1_1;
    wire pre_c2_1, pre_c2_2;
    wire pre_c3_1, pre_c3_2, pre_c3_3;
    wire pre_c4_1, pre_c4_2, pre_c4_3, pre_c4_4;
    wire pre_c5_1, pre_c5_2, pre_c5_3, pre_c5_4, pre_c5_5;
    wire pre_c6_1, pre_c6_2, pre_c6_3, pre_c6_4, pre_c6_5, pre_c6_6;
    wire pre_c7_1, pre_c7_2, pre_c7_3, pre_c7_4, pre_c7_5, pre_c7_6, pre_c7_7;
    wire pre_Cout_1, pre_Cout_2, pre_Cout_3, pre_Cout_4, pre_Cout_5, pre_Cout_6, pre_Cout_7, pre_Cout_8;

    // propogate and generate function calculations
    or p0gate(p0, A[0], B[0]);
    and g0gate(g0, A[0], B[0]);
    or p1gate(p1, A[1], B[1]);
    and g1gate(g1, A[1], B[1]);
    or p2gate(p2, A[2], B[2]);
    and g2gate(g2, A[2], B[2]);
    or p3gate(p3, A[3], B[3]);
    and g3gate(g3, A[3], B[3]);
    or p4gate(p4, A[4], B[4]);
    and g4gate(g4, A[4], B[4]);
    or p5gate(p5, A[5], B[5]);
    and g5gate(g5, A[5], B[5]);
    or p6gate(p6, A[6], B[6]);
    and g6gate(g6, A[6], B[6]);
    or p7gate(p7, A[7], B[7]);
    and g7gate(g7, A[7], B[7]);

    // sum bit calculations
    xor sum0(s0, Cin, A[0], B[0]);
    xor sum1(s1, c1, A[1], B[1]);
    xor sum2(s2, c2, A[2], B[2]);
    xor sum3(s3, c3, A[3], B[3]);
    xor sum4(s4, c4, A[4], B[4]);
    xor sum5(s5, c5, A[5], B[5]);
    xor sum6(s6, c6, A[6], B[6]);
    xor sum7(s7, c7, A[7], B[7]);

    // c1 calculation
    and Cinand_1(pre_c1_1, Cin, p0);
    or c1gate(c1, pre_c1_1, g0);

    // c2 calculation
    and Cinand_2(pre_c2_1, Cin, p0, p1);
    and g0and_2(pre_c2_2, g0, p1);
    or c2gate(c2, pre_c2_1, pre_c2_2, g1);

    // c3 calculation
    and Cinand_3(pre_c3_1, Cin, p0, p1, p2);
    and g0and_3(pre_c3_2, g0, p1, p2);
    and g1and_3(pre_c3_3, g1, p2);
    or c3gate(c3, pre_c3_1, pre_c3_2, pre_c3_3, g2);

    // c4 calculation
    and Cinand_4(pre_c4_1, Cin, p0, p1, p2, p3);
    and g0and_4(pre_c4_2, g0, p1, p2, p3);
    and g1and_4(pre_c4_3, g1, p2, p3);
    and g2and_4(pre_c4_4, g2, p3);
    or c4gate(c4, pre_c4_1, pre_c4_2, pre_c4_3, pre_c4_4, g3);

    // c5 calculation
    and Cinand_5(pre_c5_1, Cin, p0, p1, p2, p3, p4);
    and g0and_5(pre_c5_2, g0, p1, p2, p3, p4);
    and g1and_5(pre_c5_3, g1, p2, p3, p4);
    and g2and_5(pre_c5_4, g2, p3, p4);
    and g3and_5(pre_c5_5, g3, p4);
    or c5gate(c5, pre_c5_1, pre_c5_2, pre_c5_3, pre_c5_4, pre_c5_5, g4);

    // c6 calculation
    and Cinand_6(pre_c6_1, Cin, p0, p1, p2, p3, p4, p5);
    and g0and_6(pre_c6_2, g0, p1, p2, p3, p4, p5);
    and g1and_6(pre_c6_3, g1, p2, p3, p4, p5);
    and g2and_6(pre_c6_4, g2, p3, p4, p5);
    and g3and_6(pre_c6_5, g3, p4, p5);
    and g4and_6(pre_c6_6, g4, p5);
    or c6gate(c6, pre_c6_1, pre_c6_2, pre_c6_3, pre_c6_4, pre_c6_5, pre_c6_6, g5);

    // c7 calculation
    and Cinand_7(pre_c7_1, Cin, p0, p1, p2, p3, p4, p5, p6);
    and g0and_7(pre_c7_2, g0, p1, p2, p3, p4, p5, p6);
    and g1and_7(pre_c7_3, g1, p2, p3, p4, p5, p6);
    and g2and_7(pre_c7_4, g2, p3, p4, p5, p6);
    and g3and_7(pre_c7_5, g3, p4, p5, p6);
    and g4and_7(pre_c7_6, g4, p5, p6);
    and g5and_7(pre_c7_7, g5, p6);
    or c7gate(c7, pre_c7_1, pre_c7_2, pre_c7_3, pre_c7_4, pre_c7_5, pre_c7_6, pre_c7_7, g6);

    // Cout calculation
    and Cinand_8(pre_Cout_1, Cin, p0, p1, p2, p3, p4, p5, p6, p7);
    and g0and_8(pre_Cout_2, g0, p1, p2, p3, p4, p5, p6, p7);
    and g1and_8(pre_Cout_3, g1, p2, p3, p4, p5, p6, p7);
    and g2and_8(pre_Cout_4, g2, p3, p4, p5, p6, p7);
    and g3and_8(pre_Cout_5, g3, p4, p5, p6, p7);
    and g4and_8(pre_Cout_6, g4, p5, p6, p7);
    and g5and_8(pre_Cout_7, g5, p6, p7);
    and g6and_8(pre_Cout_8, g6, p7);
    or Coutgate(Cout, pre_Cout_1, pre_Cout_2, pre_Cout_3, pre_Cout_4, pre_Cout_5, pre_Cout_6, pre_Cout_7, pre_Cout_8, g7);
    
endmodule