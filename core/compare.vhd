-- !Remove this from project...
-- Btrace 448
-- Core
-- - Comparison 
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
		comparison <= unsigned(a) > unsigned(b) when gt,
					  unsigned(a) >= unsigned(b) when gte,
					  unsigned(a) = unsigned(b) when others;
	c <= '1' when comparison = true else '0';
end arch_unsigned;

architecture arch_signed of compare is
	signal comparison: boolean;
begin
	with op select
		comparison <= signed(a) > signed(b) when gt,
					  signed(a) >= signed(b) when gte,
					  signed(a) = signed(b) when others;
	c <= '1' when comparison = true else '0';
end arch_signed;
