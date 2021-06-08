library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clocking is
    Port ( CLK_100  : in STD_LOGIC;
           CLK_50   : out STD_LOGIC);
end clocking;

architecture Behavioral of clocking is

signal clk_temp: std_logic := '0';

begin

clk_50 <= clk_temp;

process(CLK_100)
begin

if rising_edge(CLK_100) then
    clk_temp <= not clk_temp;
end if;

end process;
end Behavioral;
