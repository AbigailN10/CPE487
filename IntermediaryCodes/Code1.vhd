LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.all;

use ieee.math_real.all; -- Library for generating random number 

ENTITY hexcalc IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		bt_clr : IN STD_LOGIC; -- calculator "clear" button
		bt_plus : IN STD_LOGIC; -- calculator "+" button
		bt_eq : IN STD_LOGIC; -- calculator "=" button
		KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1)); -- keypad row pins
END hexcalc;

ARCHITECTURE Behavioral OF hexcalc IS
	COMPONENT keypad IS
		PORT (
			samp_ck : IN STD_LOGIC;
			col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
			row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
			value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hit : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL cnt : std_logic_vector(20 DOWNTO 0); -- counter to generate timing signals
	SIGNAL kp_clk, kp_hit, sm_clk : std_logic;
	SIGNAL kp_value : std_logic_vector (3 DOWNTO 0);
	-- SIGNAL nx_acc, acc : std_logic_vector (15 DOWNTO 0); -- accumulated sum
	SIGNAL nx_operand, operand : std_logic_vector (15 DOWNTO 0); -- operand
	SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
	SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
	TYPE state IS (clear_all, gen_num,show_acc, fail, success, op_release, enter_op, comparator); -- state machine states
	SIGNAL pr_state, nx_state : state; -- present and next states
	
------------------------------------------
----- To create random number
	signal rand_num : integer := 0;
	type t_vector is array (1 to 8) of integer; --vector 8 integer
	signal gen_vector : t_vector; -- Generated vector
	signal stage : integer; --Determine which stage of game we are on
	signal count : integer;
	
	type input_vector is array (1 to 8) of integer; --vector 8 integer
	signal in_vector : input_vector;

BEGIN
	ck_proc : PROCESS (clk_50MHz)
	BEGIN
		IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
		END IF;
	END PROCESS;
	kp_clk <= cnt(15); -- keypad interrogation clock
	sm_clk <= cnt(20); -- state machine clock
	led_mpx <= cnt(19 DOWNTO 17); -- 7-seg multiplexing clock
	kp1 : keypad
	PORT MAP(
		samp_ck => kp_clk, col => KB_col, 
		row => KB_row, value => kp_value, hit => kp_hit
		);
		led1 : leddec16
		PORT MAP(
			dig => led_mpx, data => display, 
			anode => SEG7_anode, seg => SEG7_seg
		);
		
		clock_process : PROCESS (bt_clr, sm_clk) -- state machine clock process
		BEGIN
			IF bt_clr = '1' THEN -- reset to known state
				--acc <= X"0000";
				operand <= X"0000";
				pr_state <= clear_all;
			ELSIF rising_edge (sm_clk) THEN -- on rising clock edge
				pr_state <= nx_state; -- update present state
			--	acc <= nx_acc; -- update accumulator
				operand <= nx_operand; -- update operand
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		
-----------------------
		fsm_process : PROCESS 

--------------  For generating random number:
		       variable seed1, seed2: positive;               -- seed values for random generator
               variable x: real;   -- random real-number value in range 0 to 1.0  
               variable rand_num : integer;
               --variable range_of_rand : integer := 10;    -- the range of random values created will be 0 to +10.
-------------------------------------		
		BEGIN
			--nx_acc <= acc; -- default values of nx_acc, nx_operand & display
			nx_operand <= operand;
		--	display <= acc;
			
			CASE pr_state IS -- depending on present state...
			     when clear_all =>
			          stage <= 0;
			        for i in 1 to 8 loop
                        in_vector(i) <= 0;
                        gen_vector(i) <= 0;
                    end loop;
			        nx_state <= gen_num;
			          
			     when gen_num =>  -- generate random number
                       seed1 := 1;
                       seed2 := 1;
                      -- for n in 1 to 10 loop
                            uniform(seed1, seed2, x);   -- generate random number
                            rand_num := integer( floor(x * 11.0));
                     --   end loop;
                       stage <= stage +1;
                       nx_state <= show_acc;
                 when show_acc =>
                        --constant stage_constant: integer := stage;
                        for i in 1 to 8 loop
                            gen_vector(stage) <= rand_num;  -- random number generated in gen_num is added to array
                            display <= std_logic_vector( to_unsigned(gen_vector(i), 16)); -- Show the random number 1 at a time
                            wait for 2000000000 ns; -- 2 seconds
                            if i = stage then
                               exit;
                               end if;
                         end loop;
                         nx_state <= enter_op;	
				  WHEN enter_op => -- waiting for next digit in 2nd operand
					display <= operand;
					IF kp_hit = '1' then 
					   nx_state <= op_release;
					end if;
					if count = stage then
					   nx_state <= comparator;
					end if;
				 WHEN op_release => -- waiting for next digit in 2nd operand
					in_vector(count) <= to_integer( unsigned(operand)); 
					count <= count+1;
					IF kp_hit = '0' then 
					   nx_state <= enter_op;
					end if;
					
				when comparator =>
				    for i in 1 to 8 loop
                        if in_vector(i) /= gen_vector(i) then
                              nx_state <= fail;
                        end if;
                          if i = stage then
                               exit;
                               end if;
                    end loop;
				    nx_state <= success;
                when success =>
                    display <= "0000000000001010"; -- 10 = A. A for success
                    wait for 2000000000 ns;
                    nx_state <= gen_num;
                when fail =>
                    display <= "0000000000001111"; -- F
                    wait for 2000000000 ns;
                    nx_state <= clear_all;
			END CASE;
		END PROCESS;
END Behavioral;
