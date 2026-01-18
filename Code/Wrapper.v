//`timescale 1ns / 1ps
module Wrapper(clock, reset, startSignal, playerReaction, hSync, vSync, VGA_R, VGA_G, VGA_B);

        // Game stuff
        input clock, reset, startSignal, playerReaction;

        // VGA stuff:
        output hSync, vSync;
	output[3:0] VGA_R, VGA_G, VGA_B;
          
        wire [31:0] r1_in;
        assign r1_in = startSignal ? 32'd1 : 32'd0; // r1_in = 1 if startSignal is asserted

        wire winSignal, loseSignal, inBlueRound, inGreenRound; // register file outputs
        VGAController vgactrl(clock, reset, startSignal, inBlueRound, inGreenRound, 
                winSignal, loseSignal, hSync, vSync, VGA_R, VGA_G, VGA_B);

/* ------------------------------------------------------- Processor: ---------------------------------------------------------- */

    wire rwe, mwe;
    wire[4:0] rd, rs1, rs2;
    wire[31:0] instAddr, instData, 
               rData, regA, regB,
               memAddr, memDataIn, memDataOut;
    
    ///// Main Processing Unit
    processor CPU(.clock(clock), .reset(reset), 
                  
		  ///// ROM
                  .address_imem(instAddr), .q_imem(instData),
                  
		  ///// Regfile
                  .ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
                  .ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
                  .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
                  
		  ///// RAM
                  .wren(mwe), .address_dmem(memAddr), 
                  .data(memDataIn), .q_dmem(memDataOut)); 
                  
    ///// Instruction Memory (ROM)
    ROM #(.MEMFILE("finalInstructionMemory.mem")) // Add your memory file here
    InstMem(.clk(clock), 
            .wEn(1'b0), 
            .addr(instAddr[11:0]), 
            .dataIn(32'b0), 
            .dataOut(instData));
    
    ///// Register File
    regfile RegisterFile(.clock(clock), 
             .ctrl_writeEnable(rwe), .ctrl_reset(reset), 
             .ctrl_writeReg(rd),
             .ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
             .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), 
             .r1_in(r1_in), .playerReaction(playerReaction),
             .winSignal(winSignal), .loseSignal(loseSignal), 
             .inBlueRound(inBlueRound), .inGreenRound(inGreenRound));
             
    ///// Processor Memory (RAM)
    RAM #(.MEMFILE("finalDataMemory.mem"))
    ProcMem(.clk(clock), 
            .wEn(mwe), 
            .addr(memAddr[11:0]), 
            .dataIn(memDataIn), 
            .dataOut(memDataOut));

/* ------------------------------------------------------------------------------------------------------------------------- */

endmodule
