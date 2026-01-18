module divBy0Tester(divisor, divBy0Marker);

    input [31:0] divisor;
    output divBy0Marker;
    
    nor(divBy0Marker, divisor[31], divisor[30], divisor[29], divisor[28], divisor[27], divisor[26], divisor[25], divisor[24], divisor[23], divisor[22], divisor[21], divisor[20], divisor[19], divisor[18], divisor[17], divisor[16], divisor[15], divisor[14], divisor[13], divisor[12], divisor[11], divisor[10], divisor[9], divisor[8], divisor[7], divisor[6], divisor[5], divisor[4], divisor[3], divisor[2], divisor[1], divisor[0]);

endmodule