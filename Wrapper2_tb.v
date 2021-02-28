`timescale 1ns/10ps
module Wrapper2_tb;
    reg clock, reset, playerReaction;
    wire getReadyLED, reactLED, winLED;

    Wrapper2 maingate(clock, reset, playerReaction, getReadyLED, reactLED, winLED);

    initial begin
        clock = 0;
        reset = 1;
        playerReaction = 0;
        #40
        reset = 0;
        #10000;

        $finish;
    end

    always
        #5 clock = ~clock;

    always
        #100 playerReaction = ~playerReaction;

    // Define output waveform properties
    initial begin
        // Output file name
        $dumpfile("Wrapper_wave.vcd");
        // Module to capture and what level, 0 means all wires
        $dumpvars(0, Wrapper2_tb);
    end

endmodule