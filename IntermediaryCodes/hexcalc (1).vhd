LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.numeric_std.all;

--use ieee.math_real.all; -- Library for generating random number 

ENTITY hexcalc IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		bt_clr : IN STD_LOGIC; -- calculator "clear" button
		-- bt_plus : IN STD_LOGIC; -- calculator "+" button
		-- bt_eq : IN STD_LOGIC; -- calculator "=" button
		bt_next : in std_logic;
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
			data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL cnt : std_logic_vector(100 DOWNTO 0); -- counter to generate timing signals. Changed from 20 to 32 to make a slower clock
	SIGNAL kp_clk, kp_hit, sm_clk : std_logic;
	SIGNAL kp_value : std_logic_vector (3 DOWNTO 0);
	-- SIGNAL nx_acc, acc : std_logic_vector (15 DOWNTO 0); -- accumulated sum
	SIGNAL nx_operand, operand : std_logic_vector (15 DOWNTO 0); -- operand
	SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
	signal display_left : std_logic_vector (15 DOWNTO 0); -- value to be displayed on left side
	SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
	TYPE state IS (clear_all, start_op, op_release, comparator, fail, success); -- state machine states
	SIGNAL pr_state, nx_state : state; -- present and next states
    
    SIGNAL prev_bt_next : std_logic := '0';
	SIGNAL bt_next_edge : STD_LOGIC := '0'; -- Edge-detected pulse
    SIGNAL display2 : std_logic_vector(15 downto 0);
    SIGNAL display3 : std_logic_vector(31 downto 0);
    SIGNAL display_buf : std_logic_vector(15 downto 0);
------------------------------------------
----- To create random number
	signal rand_num : std_logic_vector(0 to 2); --3 bits
	type t_vector is array (1 to 8) of integer; --vector 8 integer
	signal gen_vector : t_vector; -- Generated vector
	--   signal gen_vector : std_logic_vector (1 to 8);
	   
	signal stage : integer; --Determine which stage of game we are on
	signal gen_count : std_logic_vector (4 downto 0); -- Determine how many #'s have been generated
	signal nx_gen_count : std_logic_vector (4 downto 0);
	
	signal user_count : std_logic_vector (4 downto 0) := "00000"; -- Determine how many #'s user has inputed
	signal nx_user_count : std_logic_vector (4 downto 0);
	
	signal compare_count : integer; -- Determine how many comparisons we have made
	
	type input_vector is array (1 to 8) of integer; --vector 8 integer
	signal in_vector : input_vector;
	   --signal in_vector : std_logic_vector(1 to 8);
	signal delay_clk : std_logic; -- New clock signal to add delay in process
	-- signal nx_delay_clk : std_logic; -- New clock signal to add delay in process

-- variable seed1, seed2: positive;               -- seed values for random generator


BEGIN
	ck_proc : PROCESS (clk_50MHz)
	BEGIN
		IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
			
			IF prev_bt_next = '0' AND bt_next = '1' THEN
                bt_next_edge <= '1';
            ELSE
                bt_next_edge <= '0';
            END IF;
        
            -- Store previous state
            prev_bt_next <= bt_next;
		END IF;
	END PROCESS;
	kp_clk <= cnt(15); -- keypad interrogation clock
	sm_clk <= cnt(20); -- state machine clock
	led_mpx <= cnt(19 DOWNTO 17); -- 7-seg multiplexing clock
	display3 <= display & display2;
	delay_clk <= cnt(50); -- Clock to add a delay
	
	kp1 : keypad
	PORT MAP(
		samp_ck => kp_clk, col => KB_col, 
		row => KB_row, value => kp_value, hit => kp_hit
		);
		led1 : leddec16
		PORT MAP(
			dig => led_mpx, data => display3, 
			anode => SEG7_anode, seg => SEG7_seg
		);
		
		clock_process : PROCESS (bt_clr, sm_clk) -- state machine clock process
		BEGIN
			IF bt_clr = '1' THEN -- reset to known state
				--acc <= X"0000";
				operand <= X"0000";
				gen_count <= "00000";
				user_count <= "00000";
				pr_state <= clear_all;
			ELSIF rising_edge (sm_clk) THEN -- on rising clock edge
				pr_state <= nx_state; -- update present state
			--	acc <= nx_acc; -- update accumulator
				operand <= nx_operand; -- update operand
				gen_count <= nx_gen_count;
				user_count <= nx_user_count;
				display2 <= X"00" & "000" & nx_user_count;
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		
-----------------------
-----------------------
		fsm_process : PROCESS (operand, bt_next_edge, pr_state, kp_hit)  
		--kp_hit, kp_value, operand, bt_next, pr_state, gen_count, gen_vector, delay_clk, stage, count, compare_count, in_vector)
--------------  For generating random number:
		       variable seed1, seed2: positive;               -- seed values for random generator
               variable x: real;   -- random real-number value in range 0 to 1.0  
              -- variable rand_num : integer;
               --variable range_of_rand : integer := 10;    -- the range of random values created will be 0 to +10.
-------------------------------------		
		BEGIN
			--nx_acc <= acc; -- default values of nx_acc, nx_operand & display
		nx_operand <= operand;
		nx_user_count <= user_count;
		--nx_state <= pr_state;
			--nx_gen_count <= gen_count;
		--	display <= acc;
			
			CASE pr_state IS -- depending on present state...
			     when clear_all =>
			          display <= X"0000"; -- clear all state
			   --       nx_gen_count <= "00000";
			          if bt_next_edge = '1' then
			             nx_state <= start_op;
			          end if;
			          
          -- copied from lab 4
                WHEN START_OP => -- ready to start entering operand
					display <= X"DDDD";
					
					IF kp_hit = '1' THEN
						nx_operand <= X"000" & kp_value; -- display number we pressed
						nx_state <= OP_RELEASE;
						display(4 downto 0) <= user_count;
					    ELSE nx_state <= START_OP;
					END IF;
				WHEN OP_RELEASE => -- waiting for button ot be released
					display <= operand;
					
					IF kp_hit = '0' THEN
					   nx_user_count <= user_count + 1;
					   nx_state <= comparator;
					ELSE nx_state <= op_release;
					END IF;
               WHEN comparator => -- 81a45c23
                    display <= X"CCCC";
                     case user_count is
                        when "00001" => --1
                           if operand = X"0008" then
                                nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00010" => --2
                           if operand = X"0001" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00011" => --3
                           if operand = X"000A" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00100" => --4
                           if operand = X"0004" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00101" => --5
                           if operand = X"0005" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00110" => --6
                           if operand = X"000C" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "00111" => -- 7
                           if operand = X"0002" then
                                  nx_state <= start_op;
                           else
                                nx_state <= fail;
                           end if;
                        when "01000"=> --15
                           if operand = X"0003" then
                                  nx_state <= success;
                           else
                                nx_state <= fail;
                           end if;
                        when others =>
                            display(4 downto 0) <= user_count;
                        end case;
                            
                WHEN success =>
                    display <= x"AAAA"; -- 10 = A. A for success
                    nx_user_count <= "00000";
                    if bt_next_edge = '1' then -- Adds a delay
                        nx_state <= clear_all;
                    end if;
                WHEN fail =>
                    display <=x"FFFF"; -- F
                    nx_user_count <= "00000";
                    if bt_next_edge = '1' then -- Adds a delay
                        nx_state <= clear_all;
                    end if;
            END CASE;
		END PROCESS;
END Behavioral;
