library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_module is
    Port ( bin             : in std_logic_vector (7 downto 0);
           bin_en          : in std_logic;
           clk100          : in  std_logic;
           low_frame       : in  std_logic; 
           ov_pclk         : in  std_logic;
           ov_vsync        : in  std_logic;
           pause_switch    : in  std_logic;
           ov_href         : in  std_logic;
           ov_image_data   : in  std_logic_vector(7 downto 0);           
           ov_siod         : inout std_logic;
           ov_pwdn         : out std_logic;
           ov_xclk         : out std_logic;
           ov_sioc         : out std_logic;
           uart_tx         : out std_logic;
           config_done     : out std_logic;
           ov_reset        : out std_logic);
end top_module;

architecture Behavioral of top_module is

	component config
	port( clk             : in std_logic;     
		  low_frame       : in std_logic;
		  siod            : inout std_logic;
		  config_finished : out std_logic;
		  pwdn            : out std_logic;
		  sioc            : out std_logic;
		  reset           : out std_logic;
		  xclk            : out std_logic);
	end component;

	

	component frame_buffer
    port ( clkb           : in std_logic;
           clka           : in std_logic;
           wea            : in std_logic_vector(0 downto 0);
           addrb          : in std_logic_vector(16 downto 0);
           dina           : in std_logic_vector(11 downto 0);            
           addra          : in std_logic_vector(16 downto 0);
           doutb          : out std_logic_vector(11 downto 0));
	end component;

    
	component capture
	port ( href             : in   std_logic;
           pclk             : in   std_logic;
           stop             : in   std_logic;
           take_pic         : out   std_logic;
           vsync            : in   std_logic;
           image_data       : in   std_logic_vector (7 downto 0);
           wr_addr          : out  std_logic_vector (18 downto 0);
           data_output      : out  std_logic_vector (11 downto 0);
           write_enable     : out  std_logic);
       
	end component;
	
	component grayscale
        port ( R            : in std_logic_vector (7 downto 0);
               G            : in std_logic_vector (7 downto 0);
               B            : in std_logic_vector (7 downto 0);
               threshold    : in std_logic_vector (7 downto 0);
               binarize_enable       : in std_logic;
               gray_out     : out std_logic_vector (7 downto 0));
    end component;
          
	component clocking
	port ( CLK_100         : in  std_logic;
           CLK_50          : out std_logic);
	end component;
	
    component uart is
        port ( start_sending    : in  std_logic;
               clk              : in  std_logic;
               pixel            : in  std_logic_vector (7 downto 0);
               ready            : out  std_logic;
               send_pic : in std_logic;
               uart_tx          : out  std_logic);
    end component;
    
    
    signal uart_signal           : std_logic;
	signal send                  : std_logic;
	signal ready                 : std_logic;
	signal raw_clock             : std_logic;
	signal clk_cam               : std_logic;
	signal pause_switch_signal   : std_logic;
    signal wr_enable             : std_logic_vector(0 downto 0);
    signal write_address         : std_logic_vector(18 downto 0);
    signal write_data            : std_logic_vector(11 downto 0);
    signal read_address          : std_logic_vector(18 downto 0);
    signal read_data             : std_logic_vector(11 downto 0);
    signal actual_write_address  : std_logic_vector(16 downto 0);
    signal actual_read_address   : std_logic_vector(16 downto 0);
    signal grayed_output         : std_logic_vector(7 downto 0);
    signal red                   : std_logic_vector (7 downto 0);
    signal blue                  : std_logic_vector (7 downto 0);
    signal green                 : std_logic_vector (7 downto 0);
	signal uart_data             : std_logic_vector(7 downto 0);
	signal max_write_address     : std_logic_vector (18 downto 0);
	signal threshold             : std_logic_vector(7 downto 0);
	signal take_p : std_logic;
	signal send_pic : std_logic := '0';
	

begin
    
   raw_clock <= CLK100;
   uart_data <= grayed_output;
   uart_tx <= uart_signal;
   pause_switch_signal <= pause_switch;
   actual_read_address <= read_address(18 downto 2);
   actual_write_address <= write_address(18 downto 2);
   red <= read_data(11 downto 8) & read_data(11 downto 8);
   green <= read_data(7 downto 4)  & read_data(7 downto 4);
   blue <= read_data(3 downto 0)  & read_data(3 downto 0);
   threshold <= bin;   

process(ov_pclk)
begin
    if write_address > max_write_address AND wr_enable(0) = '1' then
        max_write_address <= write_address;
    end if;
end process;
   
process(clk_cam)
begin
    if rising_edge(clk_cam) then
        if (ready = '1' and take_p = '1') then --comes from the UART
              send <= '1'; 
              if read_address(18 downto 2) < max_write_address(18 downto 2) then                                          
                 read_address <= read_address + 1 ;
              else
                 read_address <= (others => '0');
                 send_pic <= not send_pic;
              end if;
        else
            send <= '0';    
        end if;
    end if;
end process;  

   instantiate_clocking : clocking
     port map
       (CLK_100 => CLK100,
        CLK_50 => clk_cam);
        
	instantiate_config: config 
	port map(	
		reset           => ov_reset,
		clk             => clk_cam,
		pwdn            => ov_pwdn,
		low_frame       => low_frame,
		config_finished => config_done,
		sioc            => ov_sioc,
		siod            => ov_siod,
		xclk            => ov_xclk);
		 
	instantiate_frame_buffer: frame_buffer 
	port map(
		addrb => actual_read_address,
		dina  => write_data,	
		addra => actual_write_address,
		doutb => read_data,
		clka  => ov_pclk,
		clkb  => clk_cam, 
		wea   => wr_enable);
	
	instantiate_capture: capture
	 port map(
	    write_enable  => wr_enable(0),
		pclk          => ov_pclk,
		vsync         => ov_vsync,
		take_pic => take_p,
		wr_addr       => write_address,
		data_output   => write_data,
		href          => ov_href,
		image_data    => ov_image_data,
		stop          => pause_switch);
	
	instantiate_grayscale: grayscale 
	port map(
	   R         => red,
	   G         => green,
	   B         => blue,
	   threshold => threshold,
	   binarize_enable => bin_en,
	   gray_out  => grayed_output);
	 	
	instantiate_uart: uart 
	port map(
	   start_sending => send, 
	   ready         => ready,
	   pixel         => uart_data,
	   clk           => clk_cam,
	   send_pic => send_pic,
	   uart_tx       => uart_signal);

end Behavioral;
