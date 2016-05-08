library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.btrace_pack.all;

entity object_table is
	port(clk: in std_logic;
		en: in std_logic;
		address: in std_logic_vector(3 downto 0);
		address_in: in std_logic_vector(3 downto 0);
		object_in: in object_t;
		object_out: out object_t);
end object_table;

architecture arch of object_table is
	type data_t is array(0 to 15) of object_t;
	signal data: data_t;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data(integer(to_unsigned(address_in))) <= object_in;
		end if;
	end process;
	object_out <= data(integer(to_unsigned(address)));
end arch;
