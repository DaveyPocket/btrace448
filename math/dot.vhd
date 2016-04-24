library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dot is
	generic(int, frac: integer := 16);
	port(vx0, vy0, vz0: in std_logic_vector((int+frac)-1 downto 0);
		vx1, vy1, vz1: in std_logic_vector((int+frac)-1 downto 0);
		result: out std_logic_vector((2*(int+frac))-1 downto 0));
end dot;

architecture arch of dot is
	signal r1, r2, r3: std_logic_vector((2*(int+frac))-1 downto 0);
begin
	r1 <= vx0 * vx1;
	r2 <= vy0 * vy1;
	r3 <= vz0 * vz1;
	result <= r1 + r2 + r3;
end arch;
