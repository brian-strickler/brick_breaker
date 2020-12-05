library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	port (
		clk 				: in std_logic;
		reset				: in std_logic;
		new_ball			: in std_logic;
		vs_sig 			: out std_logic;
		hs_sig 			: out std_logic;
		pixel_data 	: out std_logic_vector(11 downto 0);
		pot : in std_logic_vector(11 downto 0);
		sound_fx : out std_logic_vector(2 downto 0)
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
	signal difference : integer := 0; -- difference between pad_pos and ball_x
	signal collision : std_logic_Vector(3 downto 0) := "1010"; -- 0000 PAD_C / 0001 PAD_R1 / 0010 PAD_R2 / 0011 PAD_L1 / 0100 PAD_L2 / 0101 RIG / 0110 LEF / 0111 TOP / 1000 DIE / 1001 BRICK_BELOW / 1010 NONE
	
	signal brick_above : std_logic := '0';
	signal brick_left : std_logic := '0';
	signal brick_right : std_logic := '0';
	signal brick_below : std_logic := '0';
	
	signal layer_above : integer := 0;
	signal layer_left : integer := 0;
	signal layer_right : integer := 0;
	signal layer_below : integer := 0;
	
	signal cur_brick_above : integer := 0;
	signal cur_brick_left : integer := 0;
	signal cur_brick_right : integer := 0;
	signal cur_brick_below : integer := 0;
	
	signal brick_above_x : integer := 0;
	signal brick_left_x : integer := 0;
	signal brick_right_x : integer := 0;
	signal brick_below_x : integer := 0;	
	
	component ball_movement is
		port (
			clk				: in std_logic; 
			reset				: in std_logic; -- KEY(0)
			new_ball			: in std_logic; -- KEY(1)
			collision		: in std_logic_vector(3 downto 0); -- from detection process
			ball_x			: out integer;
			ball_y 			: out integer
		);
	end component ball_movement;
	
begin

	u0 : component ball_movement
		port map (
			clk => clk,
			reset => reset,
			new_ball => new_ball,
			collision => collision,
			ball_x => ball_x,
			ball_y => ball_y
		);


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
			else
				x_pos <= next_x_pos;
				y_pos <= next_y_pos;
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
	
	process(count2,count2_mod, x_pos, y_pos, current_hs_state, current_vs_state, pad_pos, ball_x, ball_y, brick, cur_brick)
	begin
		count2_mod <= count2 mod 800;
		case current_hs_state is
			when H_FRONT_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
				next_y_pos <= y_pos; 
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
				if count2_mod < 112 then 
					next_hs_state <= H_SYNC;
				else	
					next_hs_state <= H_BACK_PORCH;
				end if;
				
			when H_BACK_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
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
				else	
					next_hs_state <= H_FRONT_PORCH;
					next_y_pos <= y_pos;
					next_x_pos <= x_pos;
				end if;
				if current_vs_state = V_FRONT_PORCH or current_vs_state = V_SYNC or current_vs_state = V_BACK_PORCH then
					pixel_data <= black;
					next_x_pos <= 0;
					next_y_pos <= 0;
				else
					next_y_pos <= y_pos;
					next_x_pos <= x_pos + 1;

					if (y_pos < 240) then
						if x_pos >= ball_x and x_pos < (ball_x + 10) and y_pos >= ball_y and y_pos < (ball_y + 10) then
								pixel_data <= grey; 
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
					end if;
				
					if y_pos < 481 and y_pos > 475 then  -- not sure the y_pos and x_pos perfectly match the displays x and y coordinates 
						if x_pos >= ball_x and x_pos < (ball_x + 10) and y_pos >= ball_y and y_pos < (ball_y + 10) then
								pixel_data <= grey; 
						elsif x_pos >= pad_pos and x_pos < pad_pos + 40 then
							pixel_data <= brown;
						else
							pixel_data <= black;
						end if;
					end if;
					
				end if;
		end case;
	end process;
	
	CURRENT_BRICK : process(x_pos, layer, brick_x) begin
		if layer mod 2 = 1 then	
			brick_x <= (x_pos+8)/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		else
			brick_x <= x_pos/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		end if;
	end process;
	
	BRICK_LAYER : process(y_pos) begin
		if(y_pos < 240) then
			layer <= y_pos/8;
		else 
			layer <= 0;
		end if;
	end process;
	
	PADDLE_POSITION : process(m, pot_sig) begin
		if m = '1' then
			if pot_sig > 2400 then
				pad_pos <= 600;
			else
				pad_pos <= pot_sig/4;			
			end if;
		end if;
	end process;
	
	-- 0000 PAD_C / 0001 PAD_R1 / 0010 PAD_R2 / 0011 PAD_L1 / 0100 PAD_L2 / 0101 RIG / 0110 LEF / 0111 TOP / 1000 DIE / 1001 BOT / 1010 NONE
	-- b"000"/no sound, b"001"/ball paddle, b"010"/walls+ceiling, b"011"/dead ball, b"100"/brick break
	COLLISION_DETECTION : process(ball_x, ball_y, pad_pos, brick, current_vs_state, difference) begin
			if ball_x <= 0 then
				collision <= "0110"; --hit left wall
				sound_fx <= "010"; 
			elsif ball_x >= 630 then
				collision <= "0101"; -- hit right wall
				sound_fx <= "010";
			elsif ball_y <= 1 then
				collision <= "0111"; -- hit top wall
				sound_fx <= "010";
			elsif ball_y >= 479 then
				collision <= "1000"; -- ball dead
				sound_fx <= "011";
			elsif ball_y >= 465 and ball_y <= 467 then
				if difference <= 9 and difference >= 0 then
					collision <= "0100";	-- PAD_L2
					sound_fx <= "001";
				elsif difference <= -1 and difference >= -10 then
					collision <= "0011"; -- PAD_L1
					sound_fx <= "001";
				elsif difference <= -11 and difference >= -20 then
					collision <= "0000"; -- PAD_C
					sound_fx <= "001";
				elsif difference <= -21 and difference >= -30 then
					collision <= "0001"; -- PAD_R1
					sound_fx <= "001";
				elsif difference <= -31 and difference >= -39 then
					collision <= "0010"; -- PAD_R2
					sound_fx <= "001";
				elsif brick_above = '1' then
					collision <= "0111"; -- ball hit bottom of brick
					sound_fx <= "100";
					if(cur_brick_above <= 1214) and (cur_brick_above >= 0) then
						brick(cur_brick_above) <= '0';
					end if;	
				elsif brick_right = '1' then
					collision <= "0110";	-- ball hit right side of brick
					sound_fx <= "100";
					--brick(cur_brick_right) <= '0';
				elsif brick_left = '1' then
					collision <= "0101"; -- ball hit left side of brick
					sound_fx <= "100";
					--brick(cur_brick_left) <= '0';
				elsif brick_below = '1' then
					collision <= "1001";	-- ball hit top of brick
					sound_fx <= "100";						
				else
					collision <= "1010";
					sound_fx <= "000";
				end if;
			else
				collision <= "1010"; --no collision
				sound_fx <= "000";
			end if;		
	end process;
	
	DIFFERENCE_PAD_BALL : process(m, ball_x, pad_pos) begin
			difference <= pad_pos - ball_x;
	end process;
	
	BRICK_ABOVE_DETECTION : process(ball_x, ball_y, cur_brick_above, layer_above, brick, m) begin
		if m = '1' then
			layer_above <= (ball_y-1)/8;
			if layer_above mod 2 = 1 then	
				brick_above_x <= (ball_x+12)/16;
				cur_brick_above <= (layer_above*40) + layer_above/2 + brick_above_x;
			else
				brick_above_x <= (ball_x +4)/16;
				cur_brick_above <= (layer_above*40) + layer_above/2 + brick_above_x;
			end if;
			
			if brick(cur_brick_above) = '1' then
				brick_above <= '1';
			else
				brick_above <= '0';
			end if;	
		end if;	
	end process;
	
	BRICK_LEFT_DETECTION : process(ball_x, ball_y) begin
	
	end process;
	
	BRICK_RIGHT_DETECTION : process(ball_x, ball_y) begin
	
	end process;
	
	BRICK_BELOW_DETECTION : process(ball_x, ball_y) begin
		if ball_y <= 241 then
			layer_below <= (ball_y+10)/8;
			if layer_below mod 2 = 1 then
				brick_below_x <= (ball_x+12)/16;
				cur_brick_below <= (layer_below*40) + layer_below/2 + brick_below_x;
			else
				brick_below_x <= (ball_x+4)/16;
				cur_brick_below <= (layer_below*40) + layer_below/2 + brick_below_x;
			end if;
			
			if brick(cur_brick_below) = '1' then
				brick_below <= '1';
			else
				brick_below <= '0';
			end if;
		end if;	
	end process;	
	
	brick(40) <= '0';
	brick(120) <= '0';
	brick(162) <= '0';
	brick(81) <= '0';
	brick(684) <= '0';
	brick(273) <= '0';
	brick(235) <= '0';
		
	pot_sig <= to_integer(unsigned(pot));
end architecture behavioral;