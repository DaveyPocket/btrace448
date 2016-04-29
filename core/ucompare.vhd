-- Btrace 448
-- Core
-- - Unsigned Comparison
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.btrace_pack.all;

entity compare is
	generic(N: integer := 8;
		   	op: comp_op);
	port(a, b: in std_logic_vector(N-1 downto 0);
		c: out std_logic);
end compare;

architecture arch_unsigned of compare is
	signal comparison: boolean;
begin
	with op select
		comparison <= unsigned(su_A) > unsigned(su_B) when gt,
					  unsigned(su_A) >= unsigned(su_B) when gte,
					  unsigned(su_A) = unsigned(su_B) when others;
	c <= '1' when comparison = true else '0';
end arch;

architecture arch_signed of compare is
	signal comparison: boolean;
begin
	with op select
		comparison <= signed(su_A) > signed(su_B) when gt,
					  signed(su_A) >= signed(su_B) when gte,
					  signed(su_A) = signed(su_B) when others;
	c <= '1' when comparison = true else '0';
end arch;
