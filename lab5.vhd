library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity twos_complementor is
port(	din 	: in std_logic_vector(7 downto 0);
	reset 	: in std_logic ;
	clk	: in std_logic ;
	done_out: out std_logic ;
	reg_out : out std_logic_vector(7 downto 0));
end twos_complementor ;

architecture two_arch of twos_complementor is 

-- signal definition

signal D, shift, load, inc, clr, id_done, clr_done: std_logic;
signal counter  : std_logic_vector (3 downto 0);
signal shift_reg : std_logic_vector (7 downto 0);
signal first: std_logic;	-- swicth to being inverting bits

-- state definition

type state_type is (
	insert,		-- put din onto shift_reg (only happens at the beginning)
	test, 		-- verify if the number is 0 or 1 and verify count
	first_1, 	-- first encounter with bit 1, will begin inverting the following bits
	still_zero, 	-- will simply perform shifting without inverting
	test_0,		-- will choose to either invert or keep 0
	test_1, 	-- will choose to either invert or keep 1
	shift_bit, 	-- move the shift_reg from LSD to MSD
	flip_0, 	-- flip bit from 0 to 1
	flip_1, 	-- flip bit from 1 to 0
	finish);	-- indicate that the inital number has been converterted to two's complement
signal state: state_type;

begin -- arch

-- done register

process (clk)
begin
	if (clk'event and clk='1') then
		if clr_done = '1' then done_out <= '0';
		end if;
		if id_done = '1' then done_out <= '1';
		end if;
	end if;
end process;

-- count register

process (clk)
begin
	if (clk'event and clk='1') then
		if clr = '1' then counter <= "0000";
		end if;
		if inc = '1' then counter <= std_logic_vector (unsigned(counter) +1);
		end if;
	end if;
end process;

-- shift register

process (clk)
begin

	if (clk'event and clk='1') then
		if load = '1' then shift_reg <= din;
		else if shift = '1' then
			shift_reg <= d & shift_reg(7 downto 1);
		end if;
		end if;
	end if;
end process;

-- state specifications

process (reset, clk)

begin

	if (reset = '1') then state <= insert;
	elsif (clk'event and clk='1') then
	
	case state is 

		when insert =>
			state <= test;
		
		when test =>
			if counter = "1000" then
				state <= finish;			
			elsif shift_reg(0) = '0' then
				state <= test_0;
			else state <= test_1;
			end if;

		when test_0 =>
			if first = '1' then
				state <= shift_bit;
			else state <= still_zero;
			end if;

		when still_zero =>
			state <= test;

		when test_1 =>
			if first = '1' then
				state <= shift_bit;
			else state <= first_1;
			end if;

		when first_1 =>
			state <= test;

		when shift_bit =>
			if counter = "1000" then
				state <= finish;
			elsif shift_reg(0) = '0' then
				state <= flip_0;
			else state <= flip_1;
			end if;

		when flip_0 =>
			if counter = "1000" then
				state <= finish;
			else state <= test;
			end if;

		when flip_1 =>
			if counter = "1000" then
				state <= finish;
			else state <= test;
			end if;
		
		when finish =>
			state <= finish;

	end case;
	end if;
end process;

-- signal specifications

process (state)
begin

	case state is

		when insert =>
			d <= '0';
			shift <= '0';
			id_done <= '0';
			clr_done <= '1';
			clr <= '1';
			inc <= '0';
			load <= '1';
			first <= '0';

		when test =>
			shift <= '0';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '0';
			load <= '0';

		when test_0 =>
			shift <= '0';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '0';
			load <= '0';

		when test_1 =>
			shift <= '0';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '0';
			load <= '0';

		when still_zero =>
			d <= '0';
			shift <= '1';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '1';
			load <= '0';
			first <= '0';

		when first_1 =>
			d <= '1';
			shift <= '1';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '1';
			load <= '0';
			first <= '1';	

		when shift_bit=> 
			shift <= '0';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '0';
			load <= '0';
			first <= '1';

		when flip_0 =>
			d <= '1';
			shift <= '1';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '1';
			load <= '0';
			first <= '1';

		when flip_1 =>
			d <= '0';
			shift <= '1';
			id_done <= '0';
			clr_done <= '1';
			clr <= '0';
			inc <= '1';
			load <= '0';
			first <= '1';

		when finish =>
			shift <= '0';
			id_done <= '1';
			clr_done <= '0';
			clr <= '0';
			inc <= '0';
			load <= '0';

	end case;
end process;

end two_arch;
