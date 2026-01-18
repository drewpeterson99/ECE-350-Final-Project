module multCounter_tb;
    reg clock, ctrl_MULT;
    wire data_resultRDY;

    multCounter maingate(ctrl_MULT, clock, data_resultRDY);

    initial begin

        // assign in = 32'b1;
        clock = 0;
        ctrl_MULT = 0;

        #1000;

        $finish;
    end

    always
        #10 clock = ~clock;
   
    always
        #140 ctrl_MULT = ~ctrl_MULT;

    always @(clock) begin

        #1;
        $display("out:%d", data_resultRDY);
    end

    // Define output waveform properties
    initial begin
        // Output file name
        $dumpfile("multCounter_wave.vcd");
        // Module to capture and what level, 0 means all wires
        $dumpvars(0, multCounter_tb);
    end

endmodule