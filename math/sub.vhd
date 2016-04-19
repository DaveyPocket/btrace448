library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sub is
	generic(N: integer := 8);
	port(a: in std_logic_vector(N-1 downto 0);
		 b: in std_logic_vector(N-1 downto 0);
		c: out std_logic_vector(N-1 downto 0));
end sub;

architecture arch of sub is
	signal cc: std_logic_vector(N downto 0);
begin
	cc <= a + not(b) + 1;
	c <= cc(N-1 downto 0);
end arch;
