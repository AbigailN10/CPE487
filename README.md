# CPE487 - Simon Says

## Expected behavior of code
* Program the FPGA on the Nexys A7-100T board to function as a [Simon Says game](https://www.youtube.com/watch?v=vLi1qnRmpe4) using a 16-button keypad module ([Pmod KYPD](https://store.digilentinc.com/pmod-kypd-16-button-keypad/)) connected to the Pmod port JA (See Section 10 of the [Reference Manual](https://reference.digilentinc.com/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf)) directly or via an optional [2x6-pin cable](https://digilent.com/shop/2x6-pin-pmod-cable/) with three dots (or VDD/GND) facing up on both ends. In the game, the board displays the 1st number of a sequence and the user has to correctly input that number. Then, the board displays the first 2 numbers of the sequence and the user has to input those two numbers. This game continues until either the user loses, by inputting the wrong number, or wins, by inputting the entire 8-digit sequence.

### Necessary Hardware
* Nexys A7-100T FPGA Board
* Computer with Vivado installed
* Micro-USB cable
* 4x4 Keypad
* Optional 2x6 pin cable

<img src="https://upload.wikimedia.org/wikipedia/commons/c/cd/Simon_Electronic_Game.jpg" width=300>

![keypad](kypd.png)


* The top level source module is called **_SimonSays_** that
  * Creates an instance of the keypad interface, 7-segment decoder interface, and LEDs instance modules
  * Make connection to the display, buttons, and external keypad
  * Has a timing process to generate [clock signals](https://en.wikipedia.org/wiki/Clock_signal) for the keypad, display multiplexer, and [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine)
  * Implements a finite-state machine for the operations of the game in response to button pushes
![FSM](FSM.png)

* The finite-state machine uses a number of variables to keep track of which numbers to display whether the user succeeds or fails at the game.
  * The variable _gen_num_ holds the amount of numbers that have been generated for the specific stage.
  * The variable _user_count_ holds the amount of numbers the user has inputted (pressed on the keypad) for the specific stage.
  * The variable _stage_ holds the current stage/level of the game.
  * The variable _display_ holds the value currently being displayed on the 7-segment displays.
  * The variable _pr_state_ is the current state of the finite-state machine.

Depending on the current state, the machine will react to pushed keypad buttons or operation buttons to update variables, change the output, and select the next state.
* Generally, the "bt_next" (BTNU) is used to progress through the states.
* When the clear button is pushed, the machine enters the CLEAR_ALL state.
* In GEN_NUM
  * The sequence of numbers is displayed.
  * This state will loop until it reaches the stage.
  * i.e. First, the stage is 1, so it loops through GEN_NUM once and displays the first number. When the stage is 8, it loops through GEN_NUM 8 times and displays the entire 8-digit sequence.
  * It uses _gen_count_ to know which number to display on the loop. _gen_count_ increases with each loop to allow _Gen_count_ (using the case statement) to display the next number in the sequence.
 * In START_OP
   * This state is copied from lab 4.
   * The machine waits for a keypad button to be pushed.
   * The board displays 'dddd' to signify to the user to press the keypad.
* In OP_RELEASE
  * This state is very similar to the one from lab 4.
  * The board displays the button currently pressed on the keypad and waits for the button to release to go to the comparator state.
* In COMPARATOR
  * This state determines whether it is a success for the stage, a failure, or more numbers need to be pressed.
  * When the correct number is pressed, the machine checks if user_count  = stage+1 to determine if it is at the end of the sequence for the current stage. This is because _user_count_ is incremented in START_OP but _stage_ is incremented in INTER_SUCCESS, so _user_count_ needs to be one more than _stage_.
  * If the wrong number is pressed, it is a failure and the next state is FAIL.
* In INTER_SUCCESS
  * The board displays '0AA0' to signify a success.
  * The game then continues (after BTNU is pressed) and the next sequence is shown.
* In SUCCESS
  * This state is the end of the game. The board displays 'AAAA' to signify to the user that they received an A+ for the game :)
  * The user can restart the game by pressing "bt_next" (BTNU) or clear (BTNC).
* In FAIL
  * This state is the end of the game when the user fails. The board displays 'FFFF' to signal to the user that they received an F grade :(
  * The user can restart the game by pressing BTNU or BTNC.


## Steps to get project to work

### 1. Create a new RTL project _SimonSays_ in Vivado Quick Start

* Create three new source files of file type VHDL called **_keypad_**, **_leddec16_**, **_stage_**, and **_SimonSays_**

* Create a new constraint file of file type XDC called **_SimonSays_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from keypad.vhd, leddec16.vhd, and SimonSays.vhd

* Click constraints and copy the code from SimonSays.xdc

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download SimonSays.bit to the Nexys A7-100T board

### 5. Use keypad and buttons
* Press BTNU to continuously advance through the game.
* Watch the Nexys A7-100T board which will display a sequence of numbers.
* When the left side of the board displays ‘dddd’, it is time for you to use the keypad.
* Use the keypad to press the number(s) that was just displayed in order. If you correctly do so, then the Nexys A7-100T board will display ‘0AA0’ meaning success. Press "bt_next" (BTNU) to continue playing the game and have the board continue displaying numbers that you will need to input on the keypad.
* When the board displays ‘AAAA’, you have reached the end of the game and won.
* If the board displays ‘FFFF’, you have reached the end of the game and lost.
* Press "clear" (BTNC) to restart the game.
* Check which level you are on by looking at the LEDs. The first LED (LED0) will light up when you are on the first level, and the last LED (LED7) will light up when you are on the last level (level 8).


## Inputs and Outputs
- Connected our code - SimonSays to Lab 4's leddec and keypad code along with using most of the constraints file
- Outputs displayed on the LED
- Gathering inputs from the keypad

Inputs from the board (see SimonSays.xdc)
* PIN E3: The clock on the board, renamed as “clk_50MHz”.
  * Used to control the timing of the game.
* PIN N17: The BTNC button on the board, renamed as “bt_clear”.
  * Used to reset the game when pressed and go to the CLEAR_ALL state.
* PIN M18: The BTNU button on the board, renamed as “bt_next”.
  * Used to advance through the game (from CLEAR_ALL state to GEN_NUM to START_OP, and from SUCCESS/FAIL/INTER_SUCCESS to CLEAR_ALL state).

Outputs (see SimonSays.xdc)
* 8 pins for Pmod Header JA which are connected to the keypad
  * Keypad is used to input numbers based on the sequence shown on the board.
* 7 pins for the segments and 8 pins for the anodes on the board
  * Anodes are used to tell the user the sequence that the user must input and whether they succeeded or failed.
* 8 pins for the LEDs
  * LEDs are used to tell the user what state/level they are on.

How we expanded the display to light up all 8 anodes (instead of 4):
  * In leddec16.vhd
     * Uncommented lines 47-50 as we now want to use all 8 anodes (instead of just 4).
  * In SimonSays.vhd
     * Created new signals called _display2_ and _display3_
     * Combine _display_ and _display2_ into _display3_. This allowed us to modify _display_ (the 4 left anodes) and _display2_ (the 4 right anodes) independently.
     * Connect _display3_ to _data_ from leddec16.vhd.
     * Change_data_ to be from (15 downto 0) to (31 downto 0). _data_ needs to be twice as big because it holds twice the amount of information: information from _display_ and now information from _display2_ too.

How we added the LEDs:
- We added 8 LEDs in the constraints file.
- We created a new source file called _stage_.
   * This source file was written similarly to _leddec_. It has an 'in port' to take in the stage and an 'out port' to output the stage to the LEDs.
   * The LEDs light up based on the stage/level the user is at.
- In SimonSays.vhd
   * In the entity, LED was added as an output port. LED is an 8-bit array because 8 LEDs are used
   * The component stage1 was added.
   * In the port mapping, stage connects to stage and LED connects to LED.

## Video
See SuccessfulGame1.mov for video of the board working in action.

See SuccessfulGameWithLEDS.mov for video of the board working with the LEDs.

See Reset.mov for video of the board properly resetting after pressing BTNC.

Note: GitHub only allows files up to 25MB so the demonstration is broken up into 3 seperate videos.

## Modifications
See IntermediaryCodes for detailed steps on how we created the code.

## Process

Timeline:
* April 22 - 23: (All) Brainstorming, creating FSM
* April 24 - April 30: (All) Writing Code 1
* May 1 - 5: (All) Writing code 2
* May 6: (All) Writing code 3
* May 7 - 8: (All) Writing code 4 and 5, (Abigail) writing code 6
* May 9: (Chris) Writing code 7
* May 10 - 11: (All) Writing presentation and updating GitHub
* May 12: (All) Presentation
* May 13: (ALL) Writing code 8 and final editing of GitHub

Chris specifically laid the groundwork for state GEN_NUM, wrote all of code 7 which added complexity to the game by having multiple levels, and created the additional INTER_SUCCESS state to specify that the user reached the end of the level and not the end of the game.

Abigail specifically discovered the need for ‘else’ statements, finished troubleshooting code 5, and integrated code 4 and code 5 into a single simple game seen in code 6.

Everything else was written collaboratively.

See extra coding process through IntermediaryCodes ReadME.
