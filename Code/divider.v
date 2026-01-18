module divider(
	dividendIn, divisorIn, 
	ctrl_DIV, clock, 
	data_result, data_exception, data_resultRDY);

    // DataOperandA is the dividend, DataOperandB is the divisor
    // Remember: dividend / divisor = quotient
    input [31:0] dividendIn, divisorIn;
    input ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // Wires:
    wire signed [63:0] quotientRegIn, quotientRegOut, initialQuotientRegIn, shiftedQuotientRegOut, modifiedQuotientRegOut;
    wire signed [31:0] dividendRegOut, divisorRegOut, not_divisorRegOut, divAdderOut, partialRemainder, divAdderIn;
    wire beginDiv, shiftedQuotientMSB, cout, divAdderCarryOut, divAdderCarryIn, quotientLSB, divAdderOutMSB, divNotReady;

    // Set output (quotient) of this divider circuit to the first 32 bits of the quotient register
    assign data_result = quotientRegOut[31:0];


    // Hardware:

    divCounter divControlCircuit(ctrl_DIV, clock, data_resultRDY, beginDiv);

    register_32 dividendReg(dividendRegOut, dividendIn, clock, 1'b0, beginDiv);

    register_32 divisorReg(divisorRegOut, divisorIn, clock, 1'b0, beginDiv);

    // Initializes 64-bit quotient register
    assign initialQuotientRegIn[31:0] = dividendIn;
    assign initialQuotientRegIn[63:32] = 32'b0;

    mux_2_64bit quotientInMux(quotientRegIn, beginDiv, modifiedQuotientRegOut, initialQuotientRegIn);

    /* This signal is used to disable writing to the product register while data_resultRDY is asserted (necessary because
    AG350 checks the result on the NEXT clock cycle) */
    assign divNotReady = ~data_resultRDY;
    //

    register_64 quotientReg(quotientRegOut, quotientRegIn, clock, 1'b0, divNotReady);

    assign shiftedQuotientRegOut = quotientRegOut <<< 1;

    assign shiftedQuotientMSB = shiftedQuotientRegOut[63];

    // Isolate the different components of the quotient register
    assign partialRemainder = shiftedQuotientRegOut[63:32];
    //

    // Gives us access to the negative of the divisor to potentially pass into our adder
    assign not_divisorRegOut = ~divisorRegOut;
    // cla_32 plus1div(neg_divisor, cout, not_divisorRegOut, 32'd1, 1'b0);
    //

    mux_2_32bit divAdderInMux(divAdderIn, shiftedQuotientMSB, not_divisorRegOut, divisorRegOut);
    mux_2_1bit divCarryInMux(divAdderCarryIn, shiftedQuotientMSB, 1'b1, 1'b0);

    cla_32 divAdder1(divAdderOut, divAdderCarryOut, partialRemainder, divAdderIn, divAdderCarryIn);

    assign divAdderOutMSB = divAdderOut[31];

    mux_2_1bit q0Mux(quotientLSB, divAdderOutMSB, 1'b1, 1'b0);

    /* Combine the 32 bits from the adder, bits 31-1 of the shifted quotient register output, and the explicitly assigned
    LSB to form the 64 bits that should be fed back quotient register's input */
    assign modifiedQuotientRegOut[0] = quotientLSB;
    assign modifiedQuotientRegOut[31:1] = shiftedQuotientRegOut[31:1];
    assign modifiedQuotientRegOut[63:32] = divAdderOut;
    //

    // Checks to see if the divisor is 0
    divBy0Tester divExceptionLogic(divisorRegOut, data_exception);

endmodule