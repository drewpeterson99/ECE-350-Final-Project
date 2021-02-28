//`timescale 1ns / 1ps
module Wrapper2(clock, reset, startSignal, playerReaction, hSync, vSync, VGA_R, VGA_G, VGA_B);

    // VGA stuff:
    output hSync, vSync;
	output[3:0] VGA_R, VGA_G, VGA_B;

    // Game stuff:
    input clock, reset, startSignal, playerReaction;

        time timer;
        initial begin
                timer <= 0;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        timer <= 0;
                else
                        if(startSignal)
                                timer <= timer + 1;
                        else
                                timer <= timer;
        end

        wire round1Signal, round2Signal, round3Signal, round4Signal, round5Signal, round6Signal;
        assign round1Signal = (timer > 400000000) && (timer < 500000000);
        assign round2Signal = (timer > 900000000) && (timer < 950000000);
        assign round3Signal = (timer > 1200000000) && (timer < 1225000000);
        assign round4Signal = (timer > 1600000000) && (timer < 1625000000);
	    assign round5Signal = (timer > 1700000000) && (timer < 1800000000);
        assign round6Signal = (timer > 2000000000) && (timer < 2050000000);

        integer round1Score, round2Score, round3Score, round4Score, round5Score, round6Score;
        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round1Score <= 0;
                else
                        if(round1Signal & playerReaction)
                                round1Score <= round1Score + 1;
                        else
                                round1Score <= round1Score;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round2Score <= 0;
                else
                        if(round2Signal & playerReaction)
                                round2Score <= round2Score + 1;
                        else
                                round2Score <= round2Score;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round3Score <= 0;
                else
                        if(round3Signal & playerReaction)
                                round3Score <= round3Score + 1;
                        else
                                round3Score <= round3Score;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round4Score <= 0;
                else
                        if(round4Signal & playerReaction)
                                round4Score <= round4Score + 1;
                        else
                                round4Score <= round4Score;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round5Score <= 0;
                else
                        if(round5Signal & playerReaction)
                                round5Score <= round5Score + 1;
                        else
                                round5Score <= round5Score;
        end

        always @(posedge clock or posedge reset)
        begin
                if(reset)
                        round6Score <= 0;
                else
                        if(round6Signal & playerReaction)
                                round6Score <= round6Score + 1;
                        else
                                round6Score <= round6Score;
        end

        wire winSignal, loseSignal;
        assign winSignal = (round1Score > 0) && (round2Score > 0) && (round3Score > 0) && (round4Score == 0) 
            && (round5Score > 0) && (round6Score == 0) && (timer > 2050000000);
	    assign loseSignal = ((round1Score == 0) && (timer > 500000000)) || ((round2Score == 0) && (timer > 950000000))
            || ((round3Score == 0) && (timer > 1225000000)) || (round4Score > 0)
            || ((round5Score == 0) && (timer > 1800000000)) || (round6Score > 0);

        wire inBlueRound = round1Signal || round2Signal || round3Signal || round5Signal;
        wire inGreenRound = round4Signal || round6Signal;
        VGAController vgactrl(clock, reset, startSignal, inBlueRound, inGreenRound, winSignal, loseSignal, hSync, vSync, VGA_R, VGA_G, VGA_B);

endmodule
