# CPE487 - Simon Says

## Expected behavior of code
* Program the FPGA on the Nexys A7-100T board to function as a Simon Says game using a 16-button keypad module ([Pmod KYPD](https://store.digilentinc.com/pmod-kypd-16-button-keypad/)) connected to the Pmod port JA (See Section 10 of the [Reference Manual](https://reference.digilentinc.com/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf)) directly or via an optional [2x6-pin cable](https://digilent.com/shop/2x6-pin-pmod-cable/) with three dots (or VDD/GND) facing up on both ends. In the game, the board displays the 1st number of a sequence and the user has to correctly input that number. Then, the board displays the first 2 numbers of the sequence and the user has to input those two numbers. This game continues until either the user loses, by inputting the wrong number, or wins, by inputting the entire 8-digit sequence.

![keypad](kypd.png)

* The top level source module is called **_SimonSays_** that
  * Creates an instance of the keypad interface and 7-segment decoder interface modules
  * Make connection to the display, buttons, and external keypad
  * Has a timing process to generate [clock signals](https://en.wikipedia.org/wiki/Clock_signal) for the keypad, display multiplexer, and [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine)
  * Implements a finite-state machine for the operations of the calculator in response to button pushes

![FSM](FSM.png)

* The finite-state machine uses a number of variables to keep track of the addition operation


## Steps to get project to work

### 1. Create a new RTL project _hexcalc_ in Vivado Quick Start

* Create three new source files of file type VHDL called **_keypad_**, **_leddec16_**, and **_SimonSays_**

* Create a new constraint file of file type XDC called **_SimonSays_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from keypad.vhd, leddec16.vhd, and hexcalc.vhd

* Click constraints and copy the code from hexcalc.xdc

* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.

### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download hexcalc.bit to the Nexys A7-100T board

### 5. Use keypad and buttons
* Press BTNU to continuously advance through the game.
* Watch the Nexys A7-100T board which will display a sequence of numbers.
* When the left side of the board displays ‘dddd’, it is time for you to use the keypad.
* Use the keypad to press the number(s) that was just displayed in order. If you correctly do so, then the Nexys A7-100T board will display ‘0AA0’ meaning success. Press * BTNU to continue playing the game and have the board continue displaying numbers that you will need to input on the keypad.
* When the board displays ‘AAAA’, you have reached the end of the game and won.
* If the board displays ‘FFFF’, you have reached the end of the game and lost.
* Press BTNC to restart the game.


## Inputs and Outputs

## Modifications
See IntermediaryCodes for detailed steps on how we created the code

## Process

