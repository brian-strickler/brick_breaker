library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity brick_breaker is
	port(
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : std_logic_vector(1 downto 0); -- [0] reset and [1] next
		LEDR : out std_logic_vector(9 downto 0);
		SW : in std_logic_vector(9 downto 0);
		VGA_R 	: out std_logic_vector(3 downto 0);
		VGA_G 	: out std_logic_vector(3 downto 0);
		VGA_B 	: out std_logic_vector(3 downto 0);
		VGA_HS 	: out std_logic;
		VGA_VS 	: out std_logic;		
		ARDUINO_IO : out std_logic_vector(15 downto 0);
		ARDUINO_RESET_N : inout std_logic
	);
end entity brick_breaker;

architecture behavioral of brick_breaker is

signal paddle_pos : std_logic_vector(11 downto 0) := X"000";
signal level : std_logic_vector(11 downto 0) := X"000";
signal rst_l : std_logic;
signal sound_fx : std_logic_vector(2 downto 0); -- b"000"/no sound, b"001"/ball paddle, b"010"/walls+ceiling, b"011"/dead ball, b"100"/brick break

	component sound_board is
		port (
			CLK : in std_logic := 'X';
			SOUND_EFFECT : in std_logic_vector (2 downto 0);
			SOUND_OUT : out std_logic
		);
	end component sound_board;
	
	component my_adc is 										-- creates digital value from potentiometer
		port (
			CLOCK : in  std_logic                     := 'X'; 	-- clk
			RESET : in  std_logic                     := 'X'; 	-- reset
			CH0   : out std_logic_vector(11 downto 0)        	-- CH0
		);
	end component my_adc;

begin
	
	u0 : component sound_board
	port map (
		CLK => MAX10_CLK1_50,
		SOUND_EFFECT => sound_fx,
		SOUND_OUT => ARDUINO_IO(7)
	);
	
	u1 : component my_adc
	port map (
		CLOCK => MAX10_CLK1_50, --      clk.clk
		RESET => rst_l, --    reset.reset
		CH0   => level   --         .CH1
	);
	
	process(SW) begin
		sound_fx <= SW(2 downto 0);
	end process;
	
end architecture behavioral;