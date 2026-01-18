module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from podecode_rt A of RegFile
    ctrl_readRegB,                  // O: Register to read from podecode_rt B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from podecode_rt A of RegFile
    data_readRegB                   // I: Data from podecode_rt B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* --------------------------------------YOUR CODE STARTS HERE----------------------------------------------- */

    wire notclock = ~clock;

    /* Fetch/PC Register Pipe: */
    wire [31:0] PCRegOut, nextPC;
    wire stallSignal; // Logic for this signal is at bottom of processor
    wire multdivStallSignal_x, multdivStallSignal_m; // Logic for these signals is at bottom of processor
    wire takeBranch; // Logic for this signal is in Execute stage

    wire combinedStallSignal;
    or(combinedStallSignal, multdivStallSignal_x, multdivStallSignal_m, stallSignal); // Stall on regular data hazard (ALU op after a lw), multdiv operations, or branch hazards
    wire noopInsertionSignal;
    or(noopInsertionSignal, combinedStallSignal, takeBranch); // Insert no-op when stalling or branch recovering
    wire enableSignal;
    or(enableSignal, !combinedStallSignal, takeBranch); // Ensures that a branch can always overwrite PC Register (even when a stall is trying to disable writing)

    register_32 PCRegister(PCRegOut, nextPC, notclock, reset, enableSignal);

    /* ---------------------------------------------- Fetch (Instruction Memory) Stage: ---------------------------------------------- */
    wire incrementerCOut;
    wire [31:0] PCPlus1;
    assign address_imem = PCRegOut;
    cla_32 PCIncrementer(PCPlus1, incrementerCOut, PCRegOut, 32'd1, 1'b0);

    wire [31:0] newPC; // Logic for this wire is in Execute stage
    mux_2_32bit PCMux(nextPC, takeBranch, PCPlus1, newPC);

    /* Fetch/Decode Pipe: */
    wire [31:0] decode_IR, decode_PC, FD_IRInput;
    mux_2_32bit FDPipeIRInputMux(FD_IRInput, takeBranch, q_imem, 32'd0); // Insert no-op ONLY when a branch is taken
    FetchDecodePipe FDPipe(decode_IR, FD_IRInput, decode_PC, PCPlus1, notclock, reset, enableSignal);

    /* ---------------------------------------------- Decode (Register File) Stage: ---------------------------------------------- */
    wire[4:0] decode_opcode, decode_rd, decode_rs, decode_rt, decode_shamt, decode_aluop;
    wire [31:0] decode_immediate;
    wire [26:0] decode_target;
    instructionSplitter decodeInstruction(decode_IR, decode_opcode, decode_rd, decode_rs, decode_rt, decode_shamt, decode_aluop, decode_immediate, decode_target);
    
    assign ctrl_readRegA = decode_rs;

    wire [1:0] regfileReadRegSelect;
    wire [4:0] regfileReadRegB;
    regfileReadRegController regfileReadRegLogic(regfileReadRegSelect, decode_opcode);
    mux_4_5bit regfileReadRegMux(regfileReadRegB, regfileReadRegSelect, decode_rt, decode_rd, 5'd30, 5'd0); // If sw, bne, jr, or blt, then read $rd. If bex, then read $r30. Otherwise, read $rt
    assign ctrl_readRegB = regfileReadRegB;

    /*  Decode/Excecute Pipe: */
    wire [31:0] execute_IR, execute_PC, execute_A, execute_B, DE_IRInput;
    mux_2_32bit DEPipeIRInputMux(DE_IRInput, noopInsertionSignal, decode_IR, 32'd0); // Inset no-op on stall logic OR multdiv logic OR branch logic
    DecodeExecutePipe DEPipe2(execute_IR, DE_IRInput, execute_PC, decode_PC, execute_A, data_readRegA, execute_B, data_readRegB, notclock, reset, !multdivStallSignal_m);
    
    /* ---------------------------------------------- Execute (ALU) Stage: ---------------------------------------------- */
    wire[4:0] execute_opcode, execute_rd, execute_rs, execute_rt, execute_shamt, execute_aluop;
    wire [31:0] execute_immediate;
    wire [26:0] execute_target;
    instructionSplitter executeInstruction(execute_IR, execute_opcode, execute_rd, execute_rs, execute_rt, execute_shamt, execute_aluop, execute_immediate, execute_target);
    
    wire [31:0] operandABypassMuxOut, operandBBypassMuxOut; // Logic for these bypassing wires is at bottom

    // Immediate Mux:
    wire inputIsImmed;
    wire [31:0] operandBImmedMuxOut;
    aluBImmedMuxController immedSignalControl(execute_opcode, inputIsImmed);
    mux_2_32bit aluBImmedMux(operandBImmedMuxOut, inputIsImmed, operandBBypassMuxOut, execute_immediate);

    // ALUOp Mux:
    wire isBranch;
    wire [4:0] aluopInput;
    aluopController aluopControl(isBranch, execute_opcode);
    mux_2_5bit aluopMux(aluopInput, isBranch, execute_aluop, 5'd1); // If blt, bne or bex, tell ALU to subtract the operands. Otherwise, use aluop from instruction

    // Arithmetic Logic Unit:
    wire alu_isNotEqual, alu_isLessThan, alu_overflow;
    wire [31:0] aluOutput;
    alu mathUnit(operandABypassMuxOut, operandBImmedMuxOut, aluopInput, execute_shamt, aluOutput, alu_isNotEqual, alu_isLessThan, alu_overflow);

    // Jump/Branch Instruction PC Control:
    wire [31:0] PCPlusN;
    wire adderCOut;
    cla_32 PCAdder(PCPlusN, adderCOut, execute_PC, execute_immediate, 1'b0);

    wire [31:0] execute_extendedTarget;
    wire [1:0] newPCSelect;
    assign execute_extendedTarget[31:27] = 5'd0;
    assign execute_extendedTarget[26:0] = execute_target;
    newPCController newPCLogic(newPCSelect, execute_opcode);
    mux_4_32bit newPCMux(newPC, newPCSelect, PCPlusN, execute_extendedTarget, execute_B, 32'd0); // Either jump to PC+1+N, T, or $rd (which will be execute_B if jr instruction)

    branchController branchControl(takeBranch, execute_opcode, execute_B, alu_isLessThan, alu_isNotEqual);

    /* Excecute/Memory Pipe: */
    wire [31:0] memory_IR, memory_PC, memory_aluOut, memory_B;
    wire memory_aluoverflow;
    ExecuteMemoryPipe EMPipe(memory_IR, execute_IR, memory_PC, execute_PC, memory_aluOut, aluOutput, memory_B, operandBBypassMuxOut, memory_aluoverflow, alu_overflow, notclock, reset, !multdivStallSignal_m);

    /* ---------------------------------------------- Memory (Data Memory) Stage: ---------------------------------------------- */
    wire [4:0] memory_opcode, memory_rd, memory_rs, memory_rt, memory_shamt, memory_aluop;
    wire [31:0] memory_immediate;
    wire [26:0] memory_target;
    instructionSplitter memoryInstruction(memory_IR, memory_opcode, memory_rd, memory_rs, memory_rt, memory_shamt, memory_aluop, memory_immediate, memory_target);

    assign address_dmem = memory_aluOut;

    wire [31:0] memoryWDBypassMuxOut; // Logic for this wire is at bottom
    assign data = memoryWDBypassMuxOut;

    and(wren, ~memory_opcode[4], ~memory_opcode[3], memory_opcode[2], memory_opcode[1], memory_opcode[0]); // write enable ONLY on a sw instruction

    /* Memory/Writeback Pipe: */
    wire [31:0] writeback_IR, writeback_PC, writeback_aluOut, writeback_dataOut;
    wire writeback_aluoverflow;
	MemoryWritebackPipe MWPipe(writeback_IR, memory_IR, writeback_PC, memory_PC, writeback_aluOut, memory_aluOut, writeback_dataOut, q_dmem, writeback_aluoverflow, memory_aluoverflow, 
        notclock, reset, !multdivStallSignal_m);

    /* ---------------------------------------------- Writeback (RegFile Control) Stage: ---------------------------------------------- */
    wire [4:0] writeback_opcode, writeback_rd, writeback_rs, writeback_rt, writeback_shamt, writeback_aluop;
    wire [31:0] writeback_immediate;
    wire [26:0] writeback_target;
    instructionSplitter writebackInstruction(writeback_IR, writeback_opcode, writeback_rd, writeback_rs, writeback_rt, writeback_shamt, writeback_aluop, writeback_immediate, writeback_target);

    wire tempWE;
    regfileWEController regfileWEControl(writeback_opcode, tempWE); // Only enable regfile writing for alu, lw, jal, or setx instructions
    and(ctrl_writeEnable, tempWE, notclock); // Ensures that regfile is only written to on the positive edge of the clock, that way we can read on the negative edge of the clock

    // Register File Write Register Control:
    wire [1:0] regfileWRSelect;
    wire [4:0] regfileWriteReg;
    regfileWRController regfileWRControl(regfileWRSelect, writeback_opcode, writeback_aluop, writeback_aluoverflow, multdivFinalException);
    mux_4_5bit regfileWriteRegMux(regfileWriteReg, regfileWRSelect, writeback_rd, 5'd31, 5'd30, 5'd0); // If jal, write to $r31. If exception or setx, write to $r30. Otherwise, write to $rd
    assign ctrl_writeReg = regfileWriteReg;

    // Register File Write Data Control:
    wire [2:0] regfileWDSelect;
    wire [31:0] regfileWriteData, multdivFinalResult, exceptionData, writeback_extendedTarget;
    assign writeback_extendedTarget[31:27] = 5'd0;
    assign writeback_extendedTarget[26:0] = writeback_target;
    exceptionDataController exceptionDataControl(exceptionData, writeback_aluop, writeback_opcode);
    regfileWDController regfileWDControl(regfileWDSelect, writeback_opcode, writeback_aluop, writeback_aluoverflow, multdivFinalException);
    /* If lw, write data from memory. If mult/div, write data from mult/div output register. If setx, write data from T. If jal, write data from PC. 
    If exception, write data from exception. Otherwise, write data from ALU */
    mux_8_32bit regfileWriteDataMux(regfileWriteData, regfileWDSelect, writeback_aluOut, writeback_dataOut, multdivFinalResult, writeback_extendedTarget, writeback_PC, 32'd30, 32'd30, exceptionData); 
    assign data_writeReg = regfileWriteData;

    /* --------------------------------------------------------------------------------------------------------------------- */

    /* Hardware Interlock (Stall) Logic: */
    wire interlockStallSignal;
    stallController stallLogic(interlockStallSignal, execute_opcode, memory_opcode, execute_rd, memory_rd, decode_rs, decode_rt, decode_rd, decode_opcode);
    assign stallSignal = interlockStallSignal;

    /* MX & WX Bypassing: */
    wire [1:0] aluInASelect, aluInBSelect;
    aluBypassMuxController aluSignalControl(aluInASelect, aluInBSelect, execute_rs, execute_rt, memory_rd, writeback_rd, isBranch); // Note that bypassing is disabled for branch instructions!
    mux_4_32bit aluABypassMux(operandABypassMuxOut, aluInASelect, memory_aluOut, regfileWriteData, execute_A, 32'd0);
    mux_4_32bit aluBBypassMux(operandBBypassMuxOut, aluInBSelect, memory_aluOut, regfileWriteData, execute_B, 32'd0);

    /* WM Bypassing: */
    wire memoryWDSelect;
    assign memoryWDSelect = (memory_rd == writeback_rd);
    mux_2_32bit memoryWriteDataBypassMux(memoryWDBypassMuxOut, memoryWDSelect, memory_B, regfileWriteData);

    /* MultDiv: */
    wire multdiv_resultRDY, ctrl_DIV, ctrl_MULT;
    multdivStallController multdivStallLogic(multdivStallSignal_x, multdivStallSignal_m, ctrl_DIV, ctrl_MULT, execute_aluop, execute_opcode, memory_aluop, memory_opcode, multdiv_resultRDY);

    wire [31:0] multdivOutput, multdivAIn, multdivBIn;
    wire multdiv_exception;
    register_32 multdivAReg(multdivAIn, operandABypassMuxOut, notclock, reset, multdivStallSignal_x);
    register_32 multdivBReg(multdivBIn, operandBBypassMuxOut, notclock, reset, multdivStallSignal_x);
    multdiv multiplierDivider(multdivAIn, multdivBIn, ctrl_MULT, ctrl_DIV, notclock, multdivOutput, multdiv_exception, multdiv_resultRDY);

    /* Product/Writeback Pipe: */
    register_32 PWRegister(multdivFinalResult, multdivOutput, notclock, reset, multdiv_resultRDY);
    dffe_ref PWException(multdivFinalException, multdiv_exception, notclock, multdiv_resultRDY, reset);

	/* --------------------------------------------END CODE------------------------------------------------------ */

endmodule