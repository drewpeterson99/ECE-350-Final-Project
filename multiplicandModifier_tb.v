module multiplicandModifier_tb;
    wire [2:0] encoding;
    wire signed [31:0] multiplicand, not_multiplicand;

    wire [31:0] modifiedMultiplicand;
    wire adderCarryIn;

    multiplicandModifier decoder(multiplicand, not_multiplicand, encoding, modifiedMultiplicand, adderCarryIn);

    assign multiplicand = 32'b00000000000000000000000000101010;
    assign not_multiplicand = ~multiplicand;

    integer i;
    assign encoding = i[2:0];

    initial begin
        for(i = 0; i < 8; i = i + 1) begin
            #20
            $display("encoding: %d, multiplicand: %d ===> modifiedMult: %d, adderCarryIn: %b", encoding, multiplicand, modifiedMultiplicand, adderCarryIn);
        end
        $finish;
    end

    // Define output waveform properties
    initial begin
        // Output file name
        $dumpfile("multiplicandModifier_wave.vcd");
        // Module to capture and what level, 0 means all wires
        $dumpvars(0, multiplicandModifier_tb);
    end
endmodule