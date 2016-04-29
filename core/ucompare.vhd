library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.btrace_pack.all;

entity ucompare is
	generic(N: integer := 8;
		   	op: comp_op);
	port(a, b: in std_logic_vector(N-1 downto 0);
		c: out std_logic);
end ucompare;

architecture arch of ucompare is
	signal comparison: boolean;
begin
	with op select
		comparison <= A > B when gt,
					  A >= B when gte,
					  A = B when others;
	c <= '1' when comparison = true else '0';
end arch;
