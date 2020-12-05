library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ball_movement is
	port (
		clk				: in std_logic; 
		reset				: in std_logic; -- KEY(0)
		new_ball			: in std_logic; -- KEY(1)
		collision		: in std_logic_vector(3 downto 0); -- from detector process
		ball_x			: out integer;
		ball_y 			: out integer;
		brick_reset		: out std_logic
	);
end entity ball_movement;

architecture behavioral of ball_movement is

-- signals for ball movement
	signal next_ball_y : integer := 250;
	signal next_ball_x : integer := 316;
	signal ball_y_holder : integer := 250;
	signal ball_x_holder : integer := 316;
	signal ball_counter : integer := 0;
	signal next_ball_counter : integer := 0;
	signal x_move : integer := 0;
	signal y_move : integer := 1;
	signal next_x_move : integer := 0;
	signal next_y_move : integer := 1;
	
	signal count : natural := 0;
	
	type ball_states is (IDLE, DIE, INITIAL, NO_COLLISION, RIG, LEF, TOP, PAD_C, PAD_R1, PAD_R2, PAD_L1, PAD_L2);
	signal current_ball_state, next_ball_state : ball_states;

begin	
	-- synchronous process
	process(clk, reset, new_ball, ball_y_holder, ball_x_holder, next_ball_x, next_ball_y, next_ball_state) is
	begin
		if rising_edge(clk) then
			ball_y <= ball_y_holder;
			ball_x <= ball_x_holder;
			ball_counter <= next_ball_counter;
			if reset = '0' then
				current_ball_state <= IDLE;
			elsif new_ball = '0' then
				current_ball_state <= INITIAL;
			else
				if count >= 419999 then
					count <= 0;
					ball_x_holder <= next_ball_x;
					ball_y_holder <= next_ball_y;
					x_move <= next_x_move;
					y_move <= next_y_move;
					current_ball_state <= next_ball_state;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;

	-- FSM (IDLE, INITIAL, TOP, RIG, LEF, DIE, PAD_C, PAD_L1, PAD_L2, PAD_R1, PAD_R2)
	process(collision, ball_x_holder, ball_y_holder, x_move, y_move, new_ball, reset, current_ball_state, ball_counter) is
	begin
		case current_ball_state is
			when IDLE =>
				next_ball_counter <= ball_counter;
				if reset = '1' then
					next_ball_state <= current_ball_state;
					next_y_move <= 0;
					next_x_move <= 0;
					next_ball_y <= 250;
					next_ball_x <= 316;
				else
					next_ball_state <= IDLE;
					next_y_move <= y_move;
					next_x_move <= x_move;
					next_ball_y <= 250;
					next_ball_x <= 316;
				end if;
				
			when INITIAL =>
				next_ball_counter <= ball_counter;
				if new_ball = '1' then
					next_y_move <= 1;
					next_x_move <= 0;
					next_ball_y <= ball_y_holder + y_move;
					next_ball_x <= ball_x_holder + x_move;
					next_ball_state <= NO_COLLISION;
				else
					next_ball_state <= INITIAL;
					next_y_move <= y_move;
					next_x_move <= x_move;
					next_ball_y <= ball_y_holder;
					next_ball_x <= ball_x_holder;
				end if;
				
			when NO_COLLISION =>
				next_y_move <= y_move;
				next_x_move <= x_move;
				next_ball_y <= ball_y_holder + y_move;
				next_ball_x <= ball_x_holder + x_move;
				next_ball_counter <= ball_counter;
				case collision is
					when "0000" => -- PAD_C
						next_ball_state <= PAD_C;
					when "0001" => -- PAD_R1
						next_ball_state <= PAD_R1;
					when "0010" => -- PAD_R2
						next_ball_state <= PAD_R2;
					when "0011" => -- PAD_L1
						next_ball_state <= PAD_L1;
					when "0100" => -- PAD_L2
						next_ball_state <= PAD_L2;
					when "0101" => -- RIG
						next_ball_state <= RIG;
					when "0110" => -- LEF
						next_ball_state <= LEF;
					when "0111" => -- TOP
						next_ball_state <= TOP;
					when "1000" => -- DIE
						next_ball_state <= DIE;
					when "1010" => -- NO_COLLISION
						next_ball_state <= NO_COLLISION;
					when others => 
						next_ball_state <= NO_COLLISION;
				end case;
				
			when PAD_C =>
				next_y_move <= -y_move;
				next_x_move <= x_move;
				next_ball_y <= ball_y_holder - 4;
				next_ball_x <= ball_x_holder;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when PAD_R1 =>
				next_y_move <= -1;
				next_x_move <= 1;
				next_ball_y <= ball_y_holder - 4;
				next_ball_x <= ball_x_holder + 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when PAD_R2 =>
				next_y_move <= -1;
				next_x_move <= 2;
				next_ball_y <= ball_y_holder - 4;
				next_ball_x <= ball_x_holder + 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when PAD_L1 =>
				next_y_move <= -1;
				next_x_move <= -1;
				next_ball_y <= ball_y_holder - 4;
				next_ball_x <= ball_x_holder - 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
			
			when PAD_L2=>
				next_y_move <= -1;
				next_x_move <= -2;
				next_ball_y <= ball_y_holder - 4;
				next_ball_x <= ball_x_holder - 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when RIG =>
				next_y_move <= y_move;
				next_x_move <= -x_move;
				next_ball_y <= ball_y_holder;
				next_ball_x <= ball_x_holder - 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when LEF =>
				next_y_move <= y_move;
				next_x_move <= -x_move;
				next_ball_y <= ball_y_holder;
				next_ball_x <= ball_x_holder + 4;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
			
			when TOP => 
				next_y_move <= -y_move;
				next_x_move <= x_move;
				next_ball_y <= ball_y_holder + 4;
				next_ball_x <= ball_x_holder;
				next_ball_state <= NO_COLLISION;
				next_ball_counter <= ball_counter;
				
			when DIE =>
				next_y_move <= 0;
				next_x_move <= 0;
				next_ball_y <= ball_y_holder + y_move;
				next_ball_x <= ball_x_holder + x_move;
				next_ball_state <= IDLE;	
				if ball_counter < 4 then
					next_ball_counter <= ball_counter + 1;
				else
					next_ball_counter <= 0;
				end if;
		end case;
	end process;
end architecture behavioral;	