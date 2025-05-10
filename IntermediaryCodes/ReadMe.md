# Here are all of the different codes we have made, some more successful than others.
All codes required extensive debugging.

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
- Random number generator: This is when we discovered that the uniform function does not work.
- Delay: We changed from using the clk to add a delay to manually pressing the button to change between states.

## Code 4
- Since the random number generator does not work, we decided to just display 8 predetermined numbers.
- This code was created and debugged so we could display the sequence 1-by-1 when we press the BTNU button.

## Code 5
- After successfully displaying the numbers, we created and debugged this code to test the comparator.
- This took a long time because it was always going to the fail state. We originally we thought that somehow 'operand' was being inputted incorrectly.
- To help with the debugging, we started displaying what state we were in. For instance, when in the start_op state, it would display 'dddd'. This helped us determine when we successfully moved from the clear_all state to the start_op state. 
- One change we made was adding: nx_operand <= operand; and nx_user_count <= user_count; (line 145, 146). But for some reason, this made it worse and now, it would not leave the clear_all state. We removed these lines.
- With the help of the professor, we expanded the display so that all 8 anodes turn on. The left 4 anodes (display) show the states, success, failure, etc. like before. The right 4 anodes displays user_count. This help us determine that user_count was being updated more than once and we moved user_count so that it increased in the 'if' statement.
- There were still some problems so we added lines 145 and 146 again and then it worked successfully.

## Code 6
- This was the first successful "simple" game (although it took forever to create). We combined code 4 and code 5.
- It displays 8 digits and then the user inputs 8 digits. It will show failure or success depending on whether the user correctly input the 8 digit sequence.
- At first, it was incorrectly going to the fail or success state. Additionally, pressing BTNC did not correctly go to the clear_all state. We eventually realized by looking at Lab 4 that for every 'if' statement, we need an 'else' statement (such as line 157 and 158). We also changed bt_next_edge to bt_next because if not, we were stuck at the clear_all state.
- The one exception is in the gen_num state which had the opposite behavior for some reason. Trying the use bt_next and having an else statement made the board behave unexpectedly so we kept bt_next_edge and removed the else statement.

  ## Code 7
  This is the final code (see keypad.vhd)!
