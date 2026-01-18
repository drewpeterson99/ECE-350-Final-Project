## Final Project Report
### Overall Project Description:
This Final Project is a reaction-time based game that was implemented using the capabilities of a 5-stage pipelined processor and the Nexys A7 FPGA board. The specifications of this game are below:
-	Game screen defaults to the color white in between rounds
-	During each round, screen will change color to either blue or green
    -	If blue: to pass this round, player must react by hitting button on board before time runs out and screen changes back to white
    -	If green: to pass this round, player must NOT react and leave button unpressed until time runs out and screen changes back to white
-	Player wins and WIN screen appears if player successfully passes every round
-	Player loses and red LOSE screen appears as soon as a player fails to react during a “blue” round or improperly reacts during a “green round”

### Input/Output:
Input to this module is relatively simple. The first input is startSignal, which is routed to one of the switches on the FPGA board. This signal controls the progression of the game: if it is high, the timer is allowed to increment and the game’s assembly code is continuously looped through. If it is low however, the timer is paused at its current value and the game enters an idle loop. The second input is playerReaction, which is routed to one of the buttons on the FPGA board. This signal can be considered the “primary” game input and is used to determine whether a player reacts in time during a “blue” round or improperly reacts during a “green” round. The third input is reset, which is also routed to one of the buttons on the FPGA board. The assertion of this signal triggers the resetting of all the memory elements in the processor as well as the VGA modules, which effectively restarts the game. The final input is the clock, which is routed directly to the Nexys A7’s built-in 100 MHz clock on pin E3 and of course dictates the flow of information through memory elements.  
  
The output of the main Wrapper module consists solely of VGA signals. The VGAController module from Lab 5 was modified with additional inputs and a series of multiplexers used to select the proper colorOut based on what state the game is currently in. The following four inputs were added:
-	inBlueRound: This signal is asserted when the game is in the middle of a “blue” round. It is used as a selector to a multiplexer such that if the signal is high, colorOut is set to blue (12’h00f)
-	inGreenRound -  This signal is asserted when the game is in the middle of a “green” round. It is used as a selector to a multiplexer such that if the signal is high, colorOut is set to green (12’h0f0)
-	winSignal - This signal indicates whether the player has "won" the game and is detailed in the next section of this report. It is used as a selector to a multiplexor such that if the signal is high, colorOut is set to the colorData of the custom winImage.
-	loseSignal - This signal indicates that the player has “lost” the game and is detailed in the next section of this report. It is used as a selector to a multiplexer such that if the signal is high, colorOut is set to red (12’hf00).
-	startSignal: This signal is used as a selector to a multiplexor such that if it is low, colorOut is set to black (12’h000).

If winSignal, loseSignal, inGreenRound, and inBlueRound are all low while startSignal is high, the default colorOut is white (12’hfff). The implementation of this logic is shown below:
 
The output of this VGAController module is routed directly to the output of the main Wrapper module, which contains the processor, memory elements (regfile, ROM, RAM), VGA modules, and the game’s behavioral code.

### Processor/Assembly Code:
The 5-stage pipelined processor created during class was in this project/game as both a timer and a score keeper. It was left largely unmodified except for the register file. Wires were routed directly into and out of certain registers in order to modify or read their values without using the processor’s assembly instructions. The purposes/uses of each of these registers are detailed below:
-	$r1: this register is wired directly by the behavioral verilog code to 32’d1 if startSignal = high, 32’d0 otherwise. Its value is used in the assembly code to determine which loop (game or idle) the processor should be executing
-	$r29: this register is always wired directly by the behavioral verilog code to 32’d1. It is used in the assembly code to increment $r28 
-	$r28: this register acts as the timer. It is incremented by the processor according to the game’s assembly code, and a wire is used by the behavioral verilog code to directly read its value 
-	$r2: this register is wired directly by the behavioral verilog code to 32’d1 if playerReaction = high and it is currently Round 1, 32’d0 otherwise. Its value is used in the assembly code to increment $r3
-	$r3: this register acts as the Round 1 score register and is incremented by the processor according to the game’s assembly code. A wire is used by the behavioral verilog code to directly read its value and determine whether the player won or lost. If its value is greater than 0, the player must have reacted during Round 1
-	$r(4, 6, 8, 10, 12): this register is wired directly by the behavioral verilog code to 32’d1 if playerReaction = high and it is currently Round (2, 3, 4, 5, 6), 32’d0 otherwise. Its value is used in the assembly code to increment $r(5, 7, 9, 11, 13)
-	$r(5, 7, 9, 11, 13): this register acts as the Round (2, 3, 4, 5, 6) score register and is incremented by the processor according to the game’s assembly code. A wire is used by the behavioral verilog code to directly read its value and determine whether the player won or lost. If its value is greater than 0, the player must have reacted during Round (2, 3, 4, 5, 6)

The full assembly program that is loaded into the processor’s instruction memory is below:

```
# $r1 = 1 if startSignal, 0 otherwise

# $r29 = 1
# $r28 = "timer"

# $r2 = 1 if round1Win
# $r3 = round1Score
# $r4 = 1 if round2Win
# $r5 = round2Score
# ...

idle:
    bne     $r0, $r1, loop
    j       idle

loop:
    add     $r28, $r28, $r29

    add     $r3, $r3, $r2
    add     $r5, $r5, $r4
    add     $r7, $r7, $r6
    add     $r9, $r9, $r8
    add     $r11, $r11, $r10
    add     $r13, $r13, $r12

    bne     $r0, $r1, loop
    j       idle
```
	
For each of the 6 rounds, simple behavioral verilog code is used to determine when that round is active and whether the player successfully passed it or not. For example, the round1Signal is asserted whenever the value of the timer register ($r28) is greater than 400000000 and less than 500000000. These upper and lower bounds were calculated using the fact that the period of a 100 MHz clock is 10 nanoseconds and 1 second is 109 nanoseconds. From here a mux is used to assign the value of $r2 to 32’d1 if playerReaction is asserted while round1Signal is high, and 32’d0 otherwise. If $r2 = 32’d1, then the value of $r3 will be incremented as detailed in the description of the assembly program above. This process can be repeated for every round, resulting in registers 3, 5, 7, 9, 11, and 13 holding the scores for each round at the end.  
  
Finally, these scores can be used to determine whether the player won or lost the game. The loseSignal can be asserted in the middle of the game if a player fails to react to a “blue” round or improperly reacts to a “green” round, but the win signal can only be asserted once the final round is over since the player must pass all of them. In order to win, a player’s score for “blue” rounds must be greater than 0 and a player’s score for “green” rounds must be exactly 0. A player loses if their score for a “blue” round is 0 and that round has ended or if their score for a “green” round is greater than 0 at any point. The implementation of this logic is shown below:
 

As detailed in the Input/Output section of this report, the round signals, winSignal, and loseSignal are then used to determine what should be output onto the VGA screen. 

## Testing:
The project was tested with a combination of GTKWave and Vivado. Vivado is useful for testing practical functioning and final output features such as VGA, but it gives no information about actual register values or internal wires. Therefore, especially early on, having a functioning Wrapper testbench that output a wave file was crucial. The Wrapper testbench used during this project is relatively simple. It was set to a nanosecond timescale, and the clock was manually inverted every 5 seconds to simulate a 100 MHz clock. Examining the output wave file allowed for confirmation that registers were being properly set by the behavioral code and that the assembly program was properly executing jumps between the two loops as well as incrementing the timer and scoring registers. Most of functional debugging was done using GTKWave. Once the game’s logic was perfected, Vivado was used to test the hardware integration and final product.

### Challenges:
The vast majority of challenges with this project came as a result of Vivado. Initially, there were some major issues with Vivado finding “timing loops” upon synthesis that prevented the generation of bitstreams. These timing loops appeared in parts of the design that seemed to be completely unrelated to what was actually causing them, and this resulted in a lot of confusion. Finally, the introduction of some new timing constraints and slight modifications to the design cleared these errors up. Another big issue came as a result of multiple image files being loaded into RAM. Ideally, text would have been on the screen at every state of the game but the FPGA board simply does not have enough memory to support this feature. Vivado rightly flagged this as a BRAM overutilization error which could only be solved by reverting to a single image. The “winImage” is simply a giant black “W” on a white background and is displayed when the winSignal is asserted. Assigning a single color to colorOut does not require any RAM, so the other stages of the game are shown with either a solid green, blue, red, or white background.

### Future Work/Improvements:
With more time there is certainly a bevy of improvements and features that could be added to this project. An obvious spot to start at would be the randomization of gameplay. Currently, the start time, duration, and color of each round is hardcoded into the game. Theoretically this is not an issue, but in reality it results in a game that has little replay value due to the fact that its sequence can be memorized and easily mastered. A very useful tool to implement this feature would be Linear Feedback Shift Registers, which are capable of producing puedo-random numbers that could then be used to generate things such as round start time, duration, and color.  
Another great feature that could be added to this project is a more competitive scoring system. Currently, success in this game is binary: either the player passes every round or the player does not. Being able to judge competency with a variable score at the end of the game would certainly be an improvement. This could be done with additional memory elements and logic that records the value of the timer register as soon as playerReaction is asserted. This value could then be compared to the timer’s value at the start of the round. Obviously a smaller  difference between these two timer values should indicate a higher score, and this score could be displayed using the LED on the FPGA board.  


