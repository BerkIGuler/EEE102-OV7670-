library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity config is
    port ( clk             : in    std_logic; --50MHz clock
		   low_frame       : in    std_logic; -- overwrite data at reg address "0x11" to generate slower pclk
		   siod            : inout std_logic; --sscb interface data input to camera
		   config_finished : out   std_logic; --goes high when configuration is completed
           sioc            : out   std_logic; -- sscb interface clock input to camera
           reset           : out   std_logic; --reset signal of the camera
           pwdn            : out   std_logic; -- power up signal, when driven low, camera powers up  
		   xclk            : out   std_logic); -- system clock of camera module
end config;

architecture behavioral of config is
    
	component registers
	port(
		continue     : in std_logic;  
		clk          : in std_logic;        
		finished     : out std_logic;
		config_data  : out std_logic_vector(15 downto 0));
	end component;

	component SSCB
	port(
		clk           : in std_logic;
		not_finished  : in std_logic;
		ov_value      : in std_logic_vector(7 downto 0);
		ov_address    : in std_logic_vector(7 downto 0); 
		siod          : inout std_logic; 
		package_done  : out std_logic;
		sioc          : out std_logic);
	end component;

    signal send             : std_logic;
    signal fps_flag         : std_logic := '0';
    signal system_clock     : std_logic := '0';	
    signal finished         : std_logic := '0';
    signal package_taken    : std_logic := '0';
	signal reg_address      : std_logic_vector(7 downto 0);
	signal reg_value        : std_logic_vector(7 downto 0);
	signal config_data      : std_logic_vector(15 downto 0);
	
	
begin

    send <= not finished; --send is high until the config is done
    config_finished <= finished; --led is off until config is done
	
	instantiate_SSCB: SSCB
	port map(
		clk           => clk,
		package_done  => package_taken,
		siod          => siod,
		sioc          => sioc,
		ov_address    => reg_address,
		not_finished  => send,
		ov_value      => reg_value);

	xclk  <= system_clock;     -- clock for the timing generator of camera module (system clock - 25 MHz)
	reset <= '1'; 			   -- 1 for resetting the registers to their default values.
	pwdn  <= '0'; 			   -- Power up the camera module when low
	
	instantiate_registers: registers port map(
		config_data  => config_data,
		clk          => clk,
		continue     => package_taken,
		finished     => finished);

	process(system_clock)
	begin
	   if rising_edge(system_clock) then --slown down the pixel clock of ov7670,thus generate a video fewer frames per second
	       if low_frame = '1' then
               if fps_flag = '0' then
                   reg_address <= x"11"; --register address for internal clock setting of OV7670
                   reg_value <= "00000111";   
                   fps_flag <= '1';
               end if;
           else
               reg_address <= config_data(15 downto 8);
               reg_value <= config_data(7 downto 0);
           end if;
       end if;
   end process;
   
   --generate a clock(system_clock) with 25 MHz
	process(clk)
	begin
		if rising_edge(clk) then --implied memory --register
			system_clock <= not system_clock;
		end if;
	end process;
end behavioral;
