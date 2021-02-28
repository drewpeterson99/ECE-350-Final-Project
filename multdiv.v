module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    
    // Wires:
    wire hold_DIV, hold_MULT, MULT_RDY, DIV_RDY, DIV_exception, MULT_exception, coutA, coutB, coutDiv, inputSignsDiffer;
    wire [31:0] DIV_result, DIV_out_raw, DIV_out_fixed, MULT_result, not_A, not_B, neg_A, neg_B, divInA, divInB, not_divOut, neg_divOut;

    // Logic that assigns output of multdiv circuit to output of the divider or multiplier based on control signals
    nor Rlatch(hold_DIV, ctrl_MULT, hold_MULT);
    nor Slatch(hold_MULT, ctrl_DIV, hold_DIV);

    mux_2_32bit set_result(data_result, hold_MULT, DIV_result, MULT_result);

    assign data_resultRDY = hold_MULT ? MULT_RDY : DIV_RDY;
    assign data_exception = hold_MULT ? MULT_exception : DIV_exception;

    // Multiplier
    multiplier mult(data_operandA, data_operandB, ctrl_MULT, clock, MULT_result, MULT_exception, MULT_RDY);

    // Divider
    assign not_A = ~data_operandA;
    cla_32 Aplus1(neg_A, coutA, not_A, 32'd1, 1'b0);
    assign not_B = ~data_operandB;
    cla_32 Bplus1(neg_B, coutB, not_B, 32'd1, 1'b0);
    
    // Only pass in positive numbers to the divider
    mux_2_32bit divInAMux(divInA, data_operandA[31], data_operandA, neg_A);
    mux_2_32bit divInBMux(divInB, data_operandB[31], data_operandB, neg_B);

    divider div(divInA, divInB, ctrl_DIV, clock, DIV_out_raw, DIV_exception, DIV_RDY);

    assign not_divOut = ~DIV_out_raw;
    cla_32 divOutplus1(neg_divOut, coutDiv, not_divOut, 32'd1, 1'b0);
    xor(inputSignsDiffer, data_operandA[31], data_operandB[31]);

    // If the signs of the original inputs differ, negate the output of the divider
    mux_2_32bit divResultMux(DIV_out_fixed, inputSignsDiffer, DIV_out_raw, neg_divOut);

    // If the divisor is 0, set output to 0
    mux_2_32bit divBy0Mux(DIV_result, DIV_exception, DIV_out_fixed, 32'd0);

endmodule