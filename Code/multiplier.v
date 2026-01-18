module multiplier(
	multiplicandIn, multiplierIn, 
	ctrl_MULT, clock, 
	data_result, data_exception, data_resultRDY);

    // DataOperandA is the multiplicand, DataOperandB is the multiplier
    // Remember: multiplicand * multiplier = product
    input [31:0] multiplicandIn, multiplierIn;
    input ctrl_MULT, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // Wires:
    wire signed [64:0] productRegIn, productRegOut, modifiedProductRegOut, initialProductRegIn, preshift_modifiedProductRegOut;
    wire signed [31:0] multiplicandRegOut, multiplierRegOut, modifiedMultiplicand, multAdderOut, partialProduct, lowerOverflowBits;
    wire [32:0] overflowBits;
    wire [2:0] encoding;
    wire multAdderCarryOut, beginMult, multNotReady, oppositeOperandSigns;

    // Set output (product) of this multiplier circuit to the first 32 bits after the extra Booth bit
    assign data_result = productRegOut[32:1];

    // Hardware:

    multCounter multControlCircuit(ctrl_MULT, clock, data_resultRDY, beginMult);

    register_32 multiplicandReg(multiplicandRegOut, multiplicandIn, clock, 1'b0, beginMult);

    register_32 multiplierReg(multiplierRegOut, multiplierIn, clock, 1'b0, beginMult);

    // Initializes 65-bit product register
    assign initialProductRegIn[0] = 1'b0;
    assign initialProductRegIn[32:1] = multiplierIn;
    assign initialProductRegIn[64:33] = 32'b0;
    //

    mux_2_65bit productInMux(productRegIn, beginMult, modifiedProductRegOut, initialProductRegIn);

    /* This signal is used to disable writing to the product register while data_resultRDY is asserted (necessary because
    AG350 checks the result on the NEXT clock cycle) */
    assign multNotReady = ~data_resultRDY;
    //

    register_65 productReg(productRegOut, productRegIn, clock, 1'b0, multNotReady);

    // Isolate the different components of the product register
    assign encoding = productRegOut[2:0];
    assign partialProduct = productRegOut[64:33];
    //

    multiplicandModifier multiplicandDecoder(multiplicandRegOut, encoding, modifiedMultiplicand);

    cla_32 adder(multAdderOut, multAdderCarryOut, modifiedMultiplicand, partialProduct, 1'b0);

    /* Combine the lower 33 bits of the previous cycle's product register with the new 32 bits from the adder to form the pre-shifted
    65 bits that should be fed into the product register's input */
    assign preshift_modifiedProductRegOut[32:0] = productRegOut[32:0];
    assign preshift_modifiedProductRegOut[64:33] = multAdderOut;
    //

    // Arithmetic right shift by 2 the 65 bits that were synthesized above
    // These shifted bits will be fed back into the product register
    assign modifiedProductRegOut = preshift_modifiedProductRegOut >>> 2;
    //

    // Bits we will analyze to determine overflow
    assign overflowBits = productRegOut[64:32];
    assign lowerOverflowBits = productRegOut[32:1];
    //

    // Checks to see if there if the product is fully contained in the lower 32 bits of the product register
    overflowTester multExceptionLogic(overflowBits, lowerOverflowBits, multiplicandRegOut[31], multiplierRegOut[31], data_exception);


endmodule