-- Btrace 448
-- D Flip-Flop
--
-- Bradley Boccuzzi
-- 2016

-- TODO Make set/reset
library ieee;
use ieee.std_logic_1164.all;

entity dff is
	port(D, clk, set, rst, clr: in std_logic;
		Q: out std_logic);
end dff;

architecture sequential of dff is
begin
	process(clk, set, rst)
	begin
		if rst = '1' then
			Q <= '0';
		elsif rising_edge(clk) then
			if set = '1' then
				Q <= '1';
			else
				Q <= D;
			end if;
		end if;
	end process;
end sequential;
