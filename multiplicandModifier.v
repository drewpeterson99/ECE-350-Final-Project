module multiplicandModifier(multiplicand, encoding, modifiedMultiplicand);

    input [2:0] encoding;
    input signed [31:0] multiplicand;

    output signed [31:0] modifiedMultiplicand;

    wire [31:0] not_multiplicand, neg_multiplicand;
    wire cout;
    assign not_multiplicand = ~multiplicand;
    cla_32 plus1(neg_multiplicand, cout, not_multiplicand, 32'd1, 1'b0);

    mux_8_32bit multiplicandMux(modifiedMultiplicand, encoding, 32'b0, multiplicand, multiplicand, multiplicand <<< 1, neg_multiplicand <<< 1, neg_multiplicand, neg_multiplicand, 32'b0);

endmodule