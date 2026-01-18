module overflowTester(overflowBits, lowerOverflowBits, multiplicandMSB, multiplierMSB, overflowMarker);

    input [32:0] overflowBits;
    input [31:0] lowerOverflowBits;
    input multiplicandMSB, multiplierMSB;
    output overflowMarker;

    wire allones1, allones2, allzeros;
    
    and(allones1, multiplicandMSB, ~multiplierMSB, overflowBits[32], overflowBits[31], overflowBits[30], overflowBits[29], overflowBits[28], overflowBits[27], overflowBits[26], overflowBits[25], overflowBits[24], overflowBits[23], overflowBits[22], overflowBits[21], overflowBits[20], overflowBits[19], overflowBits[18], overflowBits[17], overflowBits[16], overflowBits[15], overflowBits[14], overflowBits[13], overflowBits[12], overflowBits[11], overflowBits[10], overflowBits[9], overflowBits[8], overflowBits[7], overflowBits[6], overflowBits[5], overflowBits[4], overflowBits[3], overflowBits[2], overflowBits[1], overflowBits[0]);
    and(allones2, ~multiplicandMSB, multiplierMSB, overflowBits[32], overflowBits[31], overflowBits[30], overflowBits[29], overflowBits[28], overflowBits[27], overflowBits[26], overflowBits[25], overflowBits[24], overflowBits[23], overflowBits[22], overflowBits[21], overflowBits[20], overflowBits[19], overflowBits[18], overflowBits[17], overflowBits[16], overflowBits[15], overflowBits[14], overflowBits[13], overflowBits[12], overflowBits[11], overflowBits[10], overflowBits[9], overflowBits[8], overflowBits[7], overflowBits[6], overflowBits[5], overflowBits[4], overflowBits[3], overflowBits[2], overflowBits[1], overflowBits[0]);
    nor(allzeros, overflowBits[32], overflowBits[31], overflowBits[30], overflowBits[29], overflowBits[28], overflowBits[27], overflowBits[26], overflowBits[25], overflowBits[24], overflowBits[23], overflowBits[22], overflowBits[21], overflowBits[20], overflowBits[19], overflowBits[18], overflowBits[17], overflowBits[16], overflowBits[15], overflowBits[14], overflowBits[13], overflowBits[12], overflowBits[11], overflowBits[10], overflowBits[9], overflowBits[8], overflowBits[7], overflowBits[6], overflowBits[5], overflowBits[4], overflowBits[3], overflowBits[2], overflowBits[1], overflowBits[0]);
    nor(overflowMarker, allones1, allones2, allzeros);

endmodule