LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SimonSays IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		bt_clr : IN STD_LOGIC; -- calculator "clear" button
		bt_next : in std_logic;
		KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1)); -- keypad row pins
END SimonSays;
	
ARCHITECTURE Behavioral OF SimonSays IS
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
	SIGNAL nx_operand, operand : std_logic_vector (15 DOWNTO 0); -- operand
	SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
	SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
	TYPE state IS (clear_all, start_op, op_release, comparator, fail, success, gen_num, inter_success); -- state machine states
	SIGNAL pr_state, nx_state : state; -- present and next states

------------------------------------------
	SIGNAL prev_bt_next : std_logic := '0';
	SIGNAL bt_next_edge : STD_LOGIC := '0'; -- Edge-detected pulse

	SIGNAL display2 : std_logic_vector(15 downto 0);
	SIGNAL display3 : std_logic_vector(31 downto 0);
	   
	signal gen_count : std_logic_vector (4 downto 0); -- Determine how many #'s have been generated
	signal nx_gen_count : std_logic_vector (4 downto 0);
	
	signal user_count : std_logic_vector (4 downto 0) := "00000"; -- Determine how many #'s user has inputed
	signal nx_user_count : std_logic_vector (4 downto 0);
	
	signal stage : std_logic_vector (4 downto 0):= "00000"; -- Determine what level user is on
	signal nx_stage : std_logic_vector(4 downto 0);

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
	display3 <= display & display2; -- Combine both displays
	
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
				operand <= X"0000";
				gen_count <= "00000";
				user_count <= "00000";
				stage <= "00000";
				pr_state <= clear_all;
			ELSIF rising_edge (sm_clk) THEN -- on rising clock edge
				pr_state <= nx_state; -- update present state
				operand <= nx_operand; -- update operand
				gen_count <= nx_gen_count;
				user_count <= nx_user_count;
				stage <= nx_stage;
				display2 <= X"00" & "000" & nx_gen_count; -- Display gen_count on right side
			END IF;
		END PROCESS;
		-- state maching combinatorial process
		-- determines output of state machine and next state
		
-----------------------
	fsm_process : PROCESS (operand, bt_next, pr_state, kp_hit, bt_next_edge)  
	BEGIN
	nx_operand <= operand;
	nx_user_count <= user_count;
	nx_stage <= stage;
		
		CASE pr_state IS -- depending on present state...
			WHEN clear_all =>
				display <= X"0000"; -- clear all state
				if bt_next = '1' then
					nx_state <= gen_num;
					else 
						nx_state <= clear_all;
				end if;
				WHEN gen_num =>  -- generate random number
                    			case gen_count is
                      				when "00001" =>
                           				display <= X"0008";
                       			when "00010" =>
                           				display <= X"0001";
                       			when "00011" =>
                           				display <= X"000A";
                       			when "00100" =>
                           				display <= X"0004";
                       			when "00101" =>
                           				display <= X"0005";
                       			when "00110" =>
                           				display <= X"000C";
                       			when "00111" =>
                           				display <= X"0002";
                       			when "01000"=>
                           				display <= X"0003";
                       			when others =>
                           				display(4 downto 0) <= gen_count;
                   			end case;
                   			if bt_next_edge = '1' then
                       			if gen_count > stage then
                        				nx_state <= start_op;
                      			else
                           			nx_gen_count <= gen_count + 1;
                           			nx_state <= gen_num;
                           		end if;        
                   		end if;
                     
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
                                			if stage = "00000" then
                                				nx_state <= inter_success;
                                				else
                                    					nx_state <= start_op;
                                			end if;
                           				else
                                				nx_state <= fail;
                           			end if;
                        		when "00010" => --2
                           			if operand = X"0001" then
                                			if stage = "00001" then
                                    				nx_state <= inter_success;
                                				else
                                    					nx_state <= start_op;
                                			end if;
                           				else
                                				nx_state <= fail;
                           			end if;
                        		when "00011" => --3
                           			if operand = X"000A" then
                                  			if stage = "00010" then
                                    				nx_state <= inter_success;
                                				else
                                    				nx_state <= start_op;
                                			end if;
                           			else
                                			nx_state <= fail;
                           			end if;
                        		when "00100" => --4
                           			if operand = X"0004" then
                                  			if stage = "00011" then
                                    				nx_state <= inter_success;
                               				else
                                    				nx_state <= start_op;
                                			end if;
                           			else
                                			nx_state <= fail;
                           			end if;
                        		when "00101" => --5
                           			if operand = X"0005" then
                                  			if stage = "00100" then
                                    				nx_state <= inter_success;
                                			else
                                    				nx_state <= start_op;
                                			end if;
                           			else
                                			nx_state <= fail;
                           			end if;
                        		when "00110" => --6
                           			if operand = X"000C" then
                                  			if stage = "00101" then
                                    				nx_state <= inter_success;
                                			else
                                    				nx_state <= start_op;
                                			end if;
                           			else
                                			nx_state <= fail;
                           			end if;
                        		when "00111" => -- 7
                           			if operand = X"0002" then
                                 			if stage = "00110" then
                                    				nx_state <= inter_success;
                                			else
                                    				nx_state <= start_op;
                                			end if;
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
					
                	WHEN inter_success =>
                    		display <= x"0AA0"; -- 10 = A. A for success
                    		nx_user_count <= "00000";
                    		nx_gen_count <= "00000";
                    		if bt_next = '1' then -- Adds a delay
                        		nx_state <= gen_num;
                        		nx_stage <= stage + 1;
                    		else
                        		nx_state <= inter_success;
                    		end if;
                
			WHEN success =>
                    		display <= x"AAAA"; -- 10 = A. A for success
                    		nx_user_count <= "00000";
                    		nx_gen_count <= "00000";
                    		nx_stage <= "00000";
                    		if bt_next = '1' then -- Adds a delay
                        		nx_state <= clear_all;
                    		else
                        		nx_state <= success;
                    		end if;
					
			WHEN fail =>
                    		display <=x"FFFF"; -- F
                    		nx_user_count <= "00000";
                   		nx_gen_count <= "00000";
                    		nx_stage <= "00000";
                    		if bt_next = '1' then -- Adds a delay
                        		nx_state <= clear_all;
                    		else
                        		nx_state <= fail;
                    		end if;
            	END CASE;
	END PROCESS;
END Behavioral;
