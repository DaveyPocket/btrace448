-- Btrace 448
-- Math
-- -Square root
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee_proposed.fixed_pkg.all;

entity squareroot is
	generic(int, frac: integer := 16);
	port(clk: in std_logic;
		input: in std_logic_vector((int+frac)-1 downto 0);
		dout: out std_logic_vector((int+frac)-1 downto 0));
end squareroot;

architecture arch of squareroot is
	signal p_integer: std_logic_vector(15 downto 0);
	signal lut_out: ufixed(15 downto -16);
begin
	p_integer <= input((int+frac) - 1 downto frac);
	squarelut: entity work.squarelut port map(clk, p_integer, lut_out);
	dout <= std_logic_vector(lut_out);
end arch;
