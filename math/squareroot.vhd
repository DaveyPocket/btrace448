library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;

entity squareroot is
	port(clk: in std_logic;
		input: in ufixed(15 downto -16);
		dout: out ufixed(15 downto -16));
end squareroot;

architecture arch of squareroot is
	signal p_integer: std_logic_vector(15 downto 0);
begin
	p_integer <= std_logic_vector(input(15 downto 0));
	squarelut: entity work.squarelut port map(clk, p_integer, dout);
end arch;
