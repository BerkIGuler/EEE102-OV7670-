library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity button_debouncer is
    Port ( clk              : in  STD_LOGIC;   --50 MHz clock
           button_input     : in  STD_LOGIC;   -- input taken from the center button
           debounced_output : out  STD_LOGIC); -- output that goes to controller, when 1 restart camera configuration.
end button_debouncer;

architecture behavioral of button_debouncer is

signal counter : std_logic_vector (24 downto 0);
begin

process(clk)
begin
	if rising_edge(clk) then
	    if button_input = '1' then
	        counter <= counter + 1;
		    if counter= x"ffffff" then --when max, output '1'
			    debounced_output <= '1';
			else
				debounced_output<= '0';
			end if;
		else
			counter <= (others => '0');
			debounced_output <= '0';
		end if;
	end if;
end process;
	
end behavioral;
