library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity grayscale is  
    Port ( binarize_enable  : in std_logic;
           R                : in std_logic_vector (7 downto 0);
           G                : in std_logic_vector (7 downto 0);
           B                : in std_logic_vector (7 downto 0);
           threshold        : in std_logic_vector (7 downto 0); 
           gray_out         : out std_logic_vector (7 downto 0));
end grayscale;

architecture Behavioral of grayscale is

signal gray_temp : std_logic_vector(15 downto 0);
signal grayed    : std_logic_vector(7 downto 0);


begin

    gray_temp <= (x"4C" * R) + (x"97" * G) + (x"1C" * B); --luminosity method constants equal to 76, 151, 28
    grayed <= gray_temp (15 downto 8); --division by 256, since right shift is equivalent to division by two.
    
    
    process(gray_temp)
    begin 
        if (binarize_enable = '1') then --binarize the image if enable, else send grayscale
            if (grayed > threshold) then
                gray_out <= "11111110";
            else
                gray_out <= (others => '0');    
            end if;
        else
            gray_out <= grayed;    
        end if;    
    end process;
 
end Behavioral;
