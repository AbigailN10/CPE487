# Here are all of the different codes we have made, some more successful than others.

## Code 1
- Our very first attempt. It successfully synthesizes and implements but the board does not behave correctly.
- Loops: "for i in 1 to stage loop" did not work because stage was a signal, not a constant. We changed it to "for i in 1 to 8 loop" and then added an exit statement. The professor says the loops may be messing with the board behavior so we abandoned the loop in future codes.
- Delay: We wanted to add a delay between the states for the user to be able to read the numbers correctly, so we added 'wait for' statements. Apparently this is only for simulations, not synthesis.

## Code 2
- Loops: We abandoned the loops and instead, added if statements to loop through the states.
- Delay: We abandoned the 'wait for' and added a signal, delay_clk. The state would only change when the delay_clk was 1, hopefully adding a delay. When this did not work, we added a process to synchronize the delay_clk and clk_50Mhz.

-   Random number generator: Using math library and uniform function, but apparently it always generates the same number and only works for simulations, not synthesis.

