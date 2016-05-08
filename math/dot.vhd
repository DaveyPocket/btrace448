library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_signed.all;
use work.btrace_pack.all;

entity dot is
	generic(int, frac: integer := 16);
	port(v1, v2: in vector;
		result: out sfixed((2*int)-1 downto -(2*frac)));
end dot;

architecture arch of dot is
	signal r1, r2, r3: sfixed((2*int)-1 downto -(2*frac));
begin
	r1 <= v1.m_x * v2.m_x;
	r2 <= v1.m_y * v2.m_y;
	r3 <= v1.m_z * v2.m_z;
	result <= r1 + r2 + r3;
end arch;
