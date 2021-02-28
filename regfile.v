module regfile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB,
    r1_in, playerReaction,
	winSignal, loseSignal, inBlueRound, inGreenRound);

	input clock, ctrl_writeEnable, ctrl_reset, playerReaction;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg, r1_in;
    output winSignal, loseSignal, inBlueRound, inGreenRound;
	output [31:0] data_readRegA, data_readRegB;

	reg[31:0] registers[31:0];
	wire[31:0] round1Win, round2Win, round3Win, round4Win, round5Win, round6Win;

	integer i;
	always @(posedge clock or posedge ctrl_reset)
	begin
		if(ctrl_reset)
			begin
				for(i = 0; i < 32; i = i + 1)
					begin
						registers[i] = 32'd0;
					end
			end
		else
		    begin
				registers[5'd1] <= r1_in; // r1_in = 1 if startSignal = 1
				registers[5'd29] <= 32'd1; // used to increment timer
                registers[5'd2] <= round1Win; // used to increment round 1 score register
				registers[5'd4] <= round2Win; // used to increment round 2 score register
				registers[5'd6] <= round3Win;
				registers[5'd8] <= round4Win;
				registers[5'd10] <= round5Win;
				registers[5'd12] <= round6Win;
                if(ctrl_writeEnable && ctrl_writeReg != 5'd0 && ctrl_writeReg != 5'd1 & ctrl_writeReg != 5'd2 && ctrl_writeReg != 5'd29)
                    registers[ctrl_writeReg] = data_writeReg;
		    end
	end
	
	assign data_readRegA = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegA) && !(ctrl_writeReg == 5'd0) ? 32'bz : registers[ctrl_readRegA];
	assign data_readRegB = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegB) && !(ctrl_writeReg == 5'd0) ? 32'bz : registers[ctrl_readRegB];

	wire [31:0] timer;
	assign timer = registers[5'd28];

	wire round1Signal, round2Signal, round3Signal, round4Signal, round5Signal, round6Signal;
	assign round1Signal = (timer > 400000000) && (timer < 500000000);
    assign round2Signal = (timer > 900000000) && (timer < 950000000);
    assign round3Signal = (timer > 1200000000) && (timer < 1225000000);
    assign round4Signal = (timer > 1600000000) && (timer < 1625000000);
	assign round5Signal = (timer > 1700000000) && (timer < 1800000000);
    assign round6Signal = (timer > 2000000000) && (timer < 2050000000);

	assign inBlueRound = round1Signal || round2Signal || round3Signal || round5Signal;
    assign inGreenRound = round4Signal || round6Signal;
	
	assign round1Win = (round1Signal && playerReaction) ? 32'd1 : 32'd0; // linked to $r2
    assign round2Win = (round2Signal && playerReaction) ? 32'd1 : 32'd0; // round2Win = 1 if player reacts during round 2
    assign round3Win = (round3Signal && playerReaction) ? 32'd1 : 32'd0; // round3Win = 1 if player reacts during round 3
    assign round4Win = (round4Signal && playerReaction) ? 32'd1 : 32'd0;
    assign round5Win = (round5Signal && playerReaction) ? 32'd1 : 32'd0;
    assign round6Win = (round6Signal && playerReaction) ? 32'd1 : 32'd0;

	wire [31:0] round1Score, round2Score, round3Score, round4Score, round5Score;
    assign round1Score = registers[5'd3]; 
	assign round2Score = registers[5'd5];
	assign round3Score = registers[5'd7];
	assign round4Score = registers[5'd9];
	assign round5Score = registers[5'd11];
	assign round6Score = registers[5'd13];

	// Rounds 1, 2, 3, 5 = Blue rounds
	// Rounds 4, 6 = Green rounds
	assign winSignal = (round1Score > 0) && (round2Score > 0) && (round3Score > 0) && (round4Score == 0) 
		&& (round5Score > 0) && (round6Score == 0) && (timer > 2050000000);
	assign loseSignal = ((round1Score == 0) && (timer > 500000000)) || ((round2Score == 0) && (timer > 950000000))
        || ((round3Score == 0) && (timer > 1225000000)) || (round4Score > 0)
        || ((round5Score == 0) && (timer > 1800000000)) || (round6Score > 0);

	/* GTKWave Test Set: */
	/* assign round1Signal = (timer > 7) && (timer < 13);
    assign round2Signal = (timer > 16) && (timer < 20);
    assign round3Signal = (timer > 23) && (timer < 30);
	assign round4Signal = (timer > 38) && (timer < 43);
	assign round5Signal = (timer > 50) && (timer < 60);
	assign winSignal = (round1Score > 0) && (round2Score > 0) && (round3Score > 0) && (round4Score > 0) && (round5Score > 0);
	assign loseSignal = ((round1Score == 0) && (timer > 13)) || ((round2Score == 0) && (timer > 20))
            || ((round3Score == 0) && (timer > 30)) || ((round4Score == 0) && (timer > 43)) 
            || ((round5Score == 0) && (timer > 60)); */

endmodule