library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity capture is
    Port ( pclk         : in   std_logic; --pixel clock
           take_pic     : out  std_logic;
           vsync        : in   std_logic; --vertical synchronization 
           href         : in   std_logic; --horizontal reference 
           stop         : in   std_logic; --stop signal from a switch
           write_enable : out  std_logic; --write enable of frame buffer
           image_data   : in   std_logic_vector (7 downto 0); --parallel image data 16 bit RGB / 2 = 8
           wr_addr      : out  std_logic_vector (18 downto 0); --write address for the frame buffer
           data_output  : out  std_logic_vector (11 downto 0)); --data to be be written at wr_addr on frame buffer        
end capture;

architecture behavioral of capture is
   signal latched_vsync          : std_logic := '0';
   signal href_store             : std_logic := '0';
   signal latched_href           : std_logic := '0';
   signal stop_signal            : std_logic := '0';
   signal we_reg                 : std_logic := '0';
   signal data_latch             : std_logic_vector(15 downto 0) := (others => '0');
   signal write_address          : std_logic_vector(18 downto 0) := (others => '0');
   signal latched_image_data     : std_logic_vector (7 downto 0) := (others => '0');
   
   
begin

   data_output <= data_latch(15 downto 12) & data_latch(10 downto 7) & data_latch(4 downto 1); -- RGB444 format from RGB565 format
   wr_addr <= write_address;
   write_enable <= we_reg and not stop_signal;
   take_pic <= stop_signal;
   
process(pclk)
   begin
      if falling_edge(pclk) then --negative edge triggered registers, load at negative; use at positive
         latched_vsync <= vsync;
         latched_href  <= href;
         latched_image_data <= image_data;
      end if;
      
      if rising_edge(pclk) then
         if we_reg = '1' then
            write_address <= write_address + 1 ;
         end if;
         we_reg  <= '0';
         if latched_href = '1' then
            data_latch <= data_latch(7 downto 0) & latched_image_data;-- it takes 2 cycle to construct 1 pixel data due to rgb565
         end if;
         -- if we have new frame, control the stop switch, also reset address and href
         if latched_vsync = '1' then 
            if stop = '1' then
                stop_signal <= '1';
            else
                stop_signal <= '0';
            end if;
            write_address      <= (others => '0'); -- if new frame reset the addresses
            href_store    <=  '0';
         else
            -- if not, set the write enable whenever capturing a new pixel
            if (href_store = '1') then
               we_reg <= '1';
               href_store <= '0';
            else
               href_store <= latched_href;
            end if;
         end if;
     end if;
   end process;
end behavioral;
