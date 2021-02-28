`timescale 1ns/10ps
module Wrapper_tb;
    reg clock, reset, playerReaction, startSignal;
    wire hSync, vSync;
	wire[3:0] VGA_R, VGA_G, VGA_B;

    Wrapper maingate(clock, reset, startSignal, playerReaction, hSync, vSync, VGA_R, VGA_G, VGA_B);

    initial begin
        clock = 0;
        reset = 1;
        startSignal = 0;
        playerReaction = 0;
        #40
        startSignal = 1;
        reset = 0;
        #40
        startSignal = 0;
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
        $dumpvars(0, Wrapper_tb);
    end

endmodule