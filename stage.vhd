LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY stage1 IS
    port (
        STAGE : IN std_logic_vector (4 downto 0);
        LED : OUT Std_logic_vector (7 downto 0));
end stage1;

architecture Behavioral of stage1 is

begin
	LED <= "00000001" WHEN stage = "00000" ELSE -- 0
	       "00000010" WHEN stage = "00001" ELSE -- 1
	       "00000100" WHEN stage = "00010" ELSE -- 2
	       "00001000" WHEN stage = "00011" ELSE -- 3
	       "00010000" WHEN stage = "00100" ELSE -- 4
	       "00100000" WHEN stage = "00101" ELSE -- 5 
	       "01000000" WHEN stage = "00110" ELSE -- 6
	       "10000000" WHEN stage = "00111" ELSE -- 7
	       "00000000";
end Behavioral;
