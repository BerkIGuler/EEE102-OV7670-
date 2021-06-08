library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart is
    Port ( start_sending  : in  std_logic; --triggers a send operation, send from top module
           clk            : in  std_logic; --clock 50 MHz
           pixel          : in  std_logic_vector (7 downto 0); -- byte to be sent, from the grayscale module
           ready          : out  std_logic;-- only goes high when a new byte will be sent. goes to top module
           send_pic : in std_logic;
           uart_tx        : out  std_logic); --serialized data output, goes to the computer usb port
end uart;

architecture Behavioral of uart is

type state_type is (ready_state, load_state, send_state);
signal state : state_type := ready_state;


signal bit_done   :  std_logic;
signal bit_index  :  integer;
signal tx_bit     :  std_logic := '1';
signal tx_data    :  std_logic_vector(9 downto 0);
signal bit_timer  :  std_logic_vector(13 downto 0) := (others => '0');



signal max_bit_count :  std_logic_vector(13 downto 0) := "00000001101100"; --108 = ((50000000 / 460800)) - 1 determine the baud rate
signal max_bit_index :  integer := 10;

begin
bit_done <= '1' when (bit_timer = max_bit_count) else '0'; --bit_done only goes high to trigger the transmission of next bit in a package.
uart_tx <= tx_bit;
ready <= '1' when (state = ready_state) else '0'; 

--Next state logic written according to the state diagram--
process (clk)
begin
	if (rising_edge(clk)) then
        case state is 
            when ready_state =>
                if (start_sending = '1' and send_pic = '1') then -- if start_sending does not become 1, state remains at ready_stata forever, uart sends 1 in this case.
                    state <= load_state;
                end if;
            when load_state =>
                state <= send_state;
            when send_state =>
                if (bit_done = '1') then
                    if (bit_index = max_bit_index) then
                        state <= ready_state; -- if package is completely sent, then switch to ready_state for a new package
                    else
                        state <= load_state; --if package is not completely sent, go back to load_state to keep sending
                    end if;
                end if;
            when others=> 
                state <= ready_state;
        end case;
	end if;
end process;

process(clk)--bit timer process to ensure proper baud rate
begin

    if (rising_edge(clk)) then
		if (start_sending = '1') then --when start_sending = 1, transition from ready_state to load_state occurs. So we form the package before load_state
			tx_data <= '1' & pixel & '0'; --form the bit package as stop bit, data, and start bit, LSB is sent first.
		end if;
	end if;
	
	if (rising_edge(clk)) then
		if (state = ready_state) then
			tx_bit <= '0';
		elsif (state = load_state) then
			tx_bit <= tx_data(bit_index); --select the bit to be sent among the 10 bit long bit package
		end if;
	end if;
	
	if (rising_edge(clk)) then
		if (state = ready_state) then
			bit_timer <= (others => '0'); --initialize bit_timer to 0
		else
		    if (bit_done = '1') then
			     bit_timer <= (others => '0'); --reset bit_timer when the current bit held stable for enough time.
		    else
			     bit_timer <= bit_timer + 1; --increment bit counter, so that the sent bit remains stable for a fixed period of time
		    end if;
		end if;
	end if;
	
	if (rising_edge(clk)) then
		if (state = ready_state) then
			bit_index <= 0; --set the bit index to 0, so that in load_state, transition starts at index 0.
		elsif (state = load_state) then
			bit_index <= bit_index + 1; --increment bit_index to load bits from 0 to 9 in load_state.
		end if;
	end if;
end process;

end Behavioral;
