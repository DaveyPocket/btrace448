library ieee;
use ieee.std_logic_1164.all;

entity microprogram is
	port(addr: in std_logic_vector(9 downto 0);
		next_state: out std_logic_vector(3 downto 0);
		control: out std_logic_vector(10 downto 0));
end microprogram;

architecture arch of microprogram is
begin
	with addr select
		next_state <= "0000" when "0000--0---",
					  "0001" when "0000--1---",
					  "0011" when "0001---0--",
					  "0010" when "0001---1--",
					  "0011" when "0010------",
					  "0011" when "0011-0-0-0",
					  "0010" when "0011-0-1-0",
					  "0100" when "0011----11",
					  "0000" when "001111--10",
					  "0100" when "0100-----1",
					  "0000" when "010011---0",
					  "0010" when "0100-0-0-0",
					  "0011" when "0100-0-1-0",
					  "0000" when others;
	control <= "00000000000";
end arch;
