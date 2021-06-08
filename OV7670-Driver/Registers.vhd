library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity registers is
    port ( clk          : in  std_logic; --50 MHz clock
           continue     : in  std_logic; -- continue is used to switch to the construction of the next register address and value generation.
           config_data  : out std_logic_vector(15 downto 0); --register address and data 
           finished     : out std_logic); --goes high when all the registers are sent, an LED lights up :)
end registers;

architecture behavioral of registers is

	signal reg         : std_logic_vector(15 downto 0);
	signal reg_counter : std_logic_vector(7 downto 0) := (others => '0');
	
begin

	config_data <= reg;
	
	with reg select
	   finished  <= '1' when x"FFFF",
	                '0' when others;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if continue = '1' then --if the previous register is sent succesfully increment counter for the next register.
				reg_counter <= reg_counter + 1;
			end if;

			case reg_counter is
			
				when x"00" => reg <= x"1280"; 
				when x"01" => reg <= x"1280"; 
				when x"02" => reg <= x"1204"; 
				when x"03" => reg <= x"1100";  
				when x"04" => reg <= x"0C00"; 
				when x"05" => reg <= x"3E00"; 
   			    when x"06" => reg <= x"8C00"; 
   			    when x"07" => reg <= x"0400"; 
 				when x"08" => reg <= x"4010"; 
				when x"09" => reg <= x"3A04"; 
				when x"0A" => reg <= x"1438"; 
				when x"0B" => reg <= x"4FB3"; 
				when x"0C" => reg <= x"50B3"; 
				when x"0D" => reg <= x"5100"; 
				when x"0E" => reg <= x"523D"; 
				when x"0F" => reg <= x"53A7"; 
				when x"10" => reg <= x"54E4"; 
				when x"11" => reg <= x"589E"; 
				when x"12" => reg <= x"3DC0"; 
				when x"13" => reg <= x"1100"; 
				when x"14" => reg <= x"1711"; 
				when x"15" => reg <= x"1861"; 
				when x"16" => reg <= x"32A4"; 
				when x"17" => reg <= x"1903"; 
				when x"18" => reg <= x"1A7B"; 
				when x"19" => reg <= x"030A"; 
                when x"1A" => reg <= x"0E61"; 
                when x"1B" => reg <= x"0F4B"; 
                when x"1C" => reg <= x"1602"; 
                when x"1D" => reg <= x"1E37"; 
                when x"1E" => reg <= x"2102";
                when x"1F" => reg <= x"2291";
                when x"20" => reg <= x"2907";
                when x"21" => reg <= x"330B";                
                when x"22" => reg <= x"350B";
                when x"23" => reg <= x"371D";                 
                when x"24" => reg <= x"3871";
                when x"25" => reg <= x"392A";                  
                when x"26" => reg <= x"3C78"; 
                when x"27" => reg <= x"4D40";                   
                when x"28" => reg <= x"4E20";
                when x"29" => reg <= x"6900";                 
                when x"2A" => reg <= x"6B4A";
                when x"2B" => reg <= x"7410";                  
                when x"2C" => reg <= x"8D4F";
                when x"2D" => reg <= x"8E00";                     
                when x"2E" => reg <= x"8F00";
                when x"2F" => reg <= x"9000";                       
                when x"30" => reg <= x"9100";
                when x"31" => reg <= x"9600";                     
                when x"32" => reg <= x"9A00";
                when x"33" => reg <= x"B084";                      
                when x"34" => reg <= x"B10C";
                when x"35" => reg <= x"B20E";                       
                when x"36" => reg <= x"B382";
                when x"37" => reg <= x"B80A";
				when others => reg <= x"FFFF";
				
			end case;
		end if;
	end process;
end behavioral;
