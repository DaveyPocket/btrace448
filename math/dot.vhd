library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_unsigned.all;
use work.btrace_pack.all;

entity dot is
	generic(int, frac: integer := 16);
	port(v1, v2: in vector;
		result: out std_logic_vector((int+frac)-1 downto 0));
end dot;

architecture arch of dot is
	signal r1, r2, r3, resulta: std_logic_vector((2*(int+frac))-1 downto 0);
	signal frac_v, int_v: std_logic_vector(15 downto 0);
begin
	r1 <= std_logic_vector(v1.m_x * v2.m_x);
	r2 <= std_logic_vector(v1.m_y * v2.m_y);
	r3 <= std_logic_vector(v1.m_z * v2.m_z);
	resulta <= r1 + r2 + r3;
	-- Fudge values below
	frac_v <= resulta(31 downto 16);
	int_v <= resulta(47 downto 32);
	result <= int_v & frac_v;
end arch;
