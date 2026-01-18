module overflowTester_tb;
    reg [32:0] overflowBits;
    wire overflowMarker;

    overflowTester maingate(overflowBits, overflowMarker);

    initial begin

        // assign in = 32'b1;
        overflowBits = 33'b000000000000000000000000000000000;

        #20;

        $finish;
    end

    always
        #10 overflowBits = ~overflowBits;

    always @(overflowBits) begin
        #1;
        $display("overflowBits: %d ===> overflowMarker: %b", overflowBits, overflowMarker);
    end

endmodule