# Here are all of the different codes we have made, some more successful than others.

## Code 1
- Our very first attempt. It successfully synthesizes and implements but the board does not behave correctly.
- Loops: "for i in 1 to stage loop" did not work because stage was a signal, not a constant. We changed it to "for i in 1 to 8 loop" and then added an exit statement. The professor says the loops may be messing with the board behavior so we abandoned the loop in future codes.
- Delay: We wanted to add a delay between the states for the user to be able to read the numbers correctly, so we added 'wait for' statements. Apparently this is only for simulations, not synthesis.
- Random number generator: Using math library and uniform function. We later found out it always generates the same number and only works for simulations, not synthesis.
- Vectors: To minimize the number of 'if' statements, we were using vectors to store the generated values and inputed values. We later abondaned this because we have no used vectors before and wanted to use something more familiar to us.

## Code 2
- Loops: We abandoned the loops and instead, added if statements to loop through the states.
- Delay: We abandoned the 'wait for' and added a signal, delay_clk. The state would only change when the delay_clk was 1, hopefully adding a delay. When this did not work, we added a process to synchronize the delay_clk and clk_50Mhz.

## Code 3
- We basically scrapped our previous codes and started building from the bottom up.
-Random number generator: This is when we discovered that the uniform function does not work.
- Delay: We changed from using the clk to add a delay to manually pressing the button to change between states.

## Code 4

