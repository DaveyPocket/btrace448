-- Btrace 448
-- Core
-- - Register
--
-- Bradley Boccuzzi
-- 2016
library ieee;
use ieee.std_logic_1164.all;

entity reg is
	generic(N: integer := 8);
	port(clk, rst: in std_logic;
		en, clr: in std_logic;
		D: in std_logic_vector(N-1 downto 0);
		Q: out std_logic_vector(N-1 downto 0) := (others => '0'));
end reg;

architecture arch of reg is
	constant zeros: std_logic_vector(N-1 downto 0) := (others => '0');
begin
	process(clk, rst)
	begin
		if rst = '1' then
			Q <= zeros;
		elsif rising_edge(clk) then
			if clr = '1' then
				Q <= zeros;
			else
				Q <= D;
			end if;
		end if;
	end process;
end arch;
