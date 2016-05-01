-- Btrace 448
-- Math
-- -Square root
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;

entity squareroot is
	generic(int, frac: integer := 16);
	port(clk: in std_logic;
		input: in std_logic_vector((int+frac)-1 downto 0);
		dout: out (int+frac)-1 downto 0));
end squareroot;

architecture arch of squareroot is
	signal p_integer: std_logic_vector(15 downto 0);
begin
	p_integer <= input((int+frac) - 1 downto frac);
	squarelut: entity work.squarelut port map(clk, p_integer, dout);
end arch;
