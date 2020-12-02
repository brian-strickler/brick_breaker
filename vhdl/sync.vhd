library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	port (
		clk 				: in std_logic;
		reset				: in std_logic;
		vs_sig 			: out std_logic;
		hs_sig 			: out std_logic;
		pixel_data 	: out std_logic_vector(11 downto 0);
		pot : in std_logic_vector(11 downto 0)
	);
end entity sync;

architecture behavioral of sync is

	-- Note / R: bits 11:8 / G: bits 7:4 / B: bits 3:0 /  MSB:LSB ->
	constant red : std_logic_vector(11 downto 0) := X"B00";
	constant black : std_logic_vector(11 downto 0) := X"000";
	constant brown : std_logic_vector(11 downto 0) := X"722";
	constant grey : std_logic_vector(11 downto 0) := X"FFF";
	constant blue : std_logic_vector(11 downto 0) := X"00A";
	
	type BRICK_STATE is array (0 to 1199) of std_logic;
	signal brick : BRICK_STATE	:= (others => '1');
	
	signal cur_brick : integer range 0 to 1199 := 0;
	
	type MY_MEM is array (0 to 639) of std_logic_vector(11 downto 0);
	constant full_bricks : MY_MEM := (red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey);
	constant staggered : MY_MEM := (red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red);
	
	type vs_states is (V_FRONT_PORCH, V_SYNC, V_BACK_PORCH, DATA);
	signal current_vs_state, next_vs_state : vs_states;
	
	type hs_states is (H_FRONT_PORCH, H_SYNC, H_BACK_PORCH, P_DATA);
	signal current_hs_state, next_hs_state : hs_states;
	
	type my_horiz is range 0 to 799;
	
	signal row_counter : integer := 0; -- to keep track of brick rows
	signal next_row_counter : integer := 0; 
	signal x_pos : integer := 0;
	signal y_pos : integer := 0;
	signal layer : integer := 0;
	signal next_x_pos : integer := 0;
	signal next_y_pos : integer := 0;
	signal count1 : integer := 0;
	signal count2 : integer := 0;
	signal count1_mod : integer := 0;
	signal count2_mod : integer := 0;
	signal m : std_logic := '0';
	signal pad_pos : integer := 0;
	signal pot_sig : integer := 0;
	signal ball_x : integer := 316;
	signal ball_y : integer := 250;
	signal brick_x : integer := 0;
	signal ball_counter : integer := 0;
	signal ball_move_enable : std_logic := '0';
	signal x_move : integer := 1;
	signal y_move : integer := 2;
	
begin
	process(clk, reset, current_vs_state, count1, count2, current_hs_state, x_pos, y_pos) 
	begin
		if rising_edge(clk) then
			if reset = '0' then	
				current_vs_state <= V_FRONT_PORCH;
				current_hs_state <= H_FRONT_PORCH;
				count1 <= 0;
				count2 <= 0;
				x_pos <= 0;
				y_pos <= 0;
				row_counter <= 0;
			else
				x_pos <= next_x_pos;
				y_pos <= next_y_pos;
				row_counter <= next_row_counter;
				if m = '0' then
					count1 <= count1 + 1;
					count2 <= count2 + 1;
				else
					count1 <= 0;
					count2 <= 0;
				end if;
				current_vs_state <= next_vs_state;
				current_hs_state <= next_hs_state;
			end if;
		end if;
	end process;
	
	process(count1, current_vs_state, count1_mod)
	begin
		count1_mod <= count1 mod 420000;
		case current_vs_state is
			when V_FRONT_PORCH =>
				m <= '0';
				vs_sig <= '1';
				if count1_mod < 8000 then
					next_vs_state <= V_FRONT_PORCH;
				else
					next_vs_state <= V_SYNC;
				end if;
				
			when V_SYNC =>
				m <= '0';
				vs_sig <= '0';
				if count1_mod < 9600 then
					next_vs_state <= V_SYNC;
				else	
					next_vs_state <= V_BACK_PORCH;
				end if;
				
			when V_BACK_PORCH =>
				m <= '0';
				vs_sig <= '1';
				if count1_mod < 36000 then
					next_vs_state <= V_BACK_PORCH;
				else
					next_vs_state <= DATA;
				end if;
				
			when DATA =>
				vs_sig <= '1';
				if count1_mod < 420000 and count1_mod >= 36000 then
					next_vs_state <= DATA;
					m <= '0';
				else
					next_vs_state <= V_FRONT_PORCH;
					m <= '1';
				end if;
		end case;	
	end process;
	
	process(count2,count2_mod, x_pos, y_pos, current_hs_state, current_vs_state, row_counter, pad_pos)
	begin
		count2_mod <= count2 mod 800;
		case current_hs_state is
			when H_FRONT_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
				next_y_pos <= y_pos; 
				next_row_counter <= row_counter;
				if count2_mod < 16 then
					next_hs_state <= H_FRONT_PORCH;
				else	
					next_hs_state <= H_SYNC;
				end if;
				
			when H_SYNC =>
				hs_sig <= '0';
				pixel_data <= black;
				next_x_pos <= 0;
				next_y_pos <= y_pos;
				next_row_counter <= row_counter;
				if count2_mod < 112 then 
					next_hs_state <= H_SYNC;
				else	
					next_hs_state <= H_BACK_PORCH;
				end if;
				
			when H_BACK_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
				next_row_counter <= row_counter;
				if count2_mod < 160 then 
					next_hs_state <= H_BACK_PORCH;
					next_y_pos <= y_pos;
				else	
					next_hs_state <= P_DATA;
					next_y_pos <= y_pos + 1;
				end if;
				
			when P_DATA =>
				hs_sig <= '1';
				if count2_mod < 800 and count2_mod >= 160 then 
					next_hs_state <= P_DATA;
					next_y_pos <= y_pos;
					next_x_pos <= x_pos + 1;
					next_row_counter <= row_counter;
				else	
					next_hs_state <= H_FRONT_PORCH;
					next_y_pos <= y_pos;
					next_x_pos <= x_pos;
					next_row_counter <= row_counter;
				end if;
				if current_vs_state = V_FRONT_PORCH or current_vs_state = V_SYNC or current_vs_state = V_BACK_PORCH then
					pixel_data <= black;
					next_x_pos <= 0;
					next_y_pos <= 0;
					next_row_counter <= 0;
				else
					next_y_pos <= y_pos;
					next_x_pos <= x_pos + 1;
					
					
					
					if (y_pos < 240) then
						if x_pos >= ball_x and x_pos < ball_x + 10 then
							if y_pos >= ball_y and y_pos < ball_y + 10 then
								pixel_data <= grey; 
							end if;
						elsif brick(cur_brick) = '0' then
								pixel_data <= black;
						else
							if (y_pos mod 8 = 0) then
								pixel_data <= grey;
							elsif layer mod 2 = 0 then
								pixel_data <= full_bricks(x_pos);
							else
								pixel_data <= staggered(x_pos);
							end if;
						end if;	
					end if;
																
					if y_pos >= 240 and y_pos <= 475 then
						if x_pos >= ball_x and x_pos < ball_x + 10 then
							if y_pos >= ball_y and y_pos < ball_y + 10 then
								pixel_data <= grey;
							else
								pixel_data <= black;
							end if;	
						else
							pixel_data <= black;
						end if;	
						next_row_counter <= 0;
					end if;
				
					if y_pos < 481 and y_pos > 475 then  -- not sure the y_pos and x_pos perfectly match the displays x and y coordinates 
						next_row_counter <= 0;
						if x_pos >= pad_pos and x_pos < pad_pos + 40 then
							pixel_data <= brown;
						else
							pixel_data <= black;
						end if;
					end if;
					
				end if;
		end case;
	end process;
	
	process(x_pos, layer) begin
		if layer mod 2 = 1 then	-- even row numbers, staggered start
			brick_x <= (x_pos+8)/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		else
			brick_x <= x_pos/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		end if;
	end process;
	
	process(y_pos) begin
		if(y_pos < 240) then
			layer <= y_pos/8;
		else 
			layer <= 0;
		end if;
	end process;
	
	process(pot_sig) begin
			if pot_sig > 2400 then
				pad_pos <= 600;
			else
				pad_pos <= 6+pot_sig/4;			
			end if;
	end process;
	
	brick(40) <= '0';
	brick(120) <= '0';
	brick(162) <= '0';
	brick(81) <= '0';
	brick(684) <= '0';
	brick(273) <= '0';
	brick(235) <= '0';
	
--	process(clk, ball_counter) begin
--		if (rising_edge(clk)) then
--			if ball_counter < 500000 then
--				ball_counter <= ball_counter + 1;
--				ball_move_enable <= '0';
--			else
--				ball_counter <= 0;
--				ball_move_enable <= '1';
--				ball_x <= ball_X + x_move;
--				ball_y <= ball_y + y_move;
--			end if;	
--		end if;
--	end process;
	
--	process(ball_x, ball_y) begin
--		if ball_x <= 0 or ball_x >= 630 then
--			x_move <= 0-x_move;
--		end if;
--		if ball_y <= 240 or ball_y >= 470 then
--			y_move <= 0-x_move;
--		end if;
--	end process;
		
	pot_sig <= to_integer(unsigned(pot));
end architecture behavioral;