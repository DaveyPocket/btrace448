-- Btrace 448
-- Up/down counter
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic(n: integer := 5);
	port(clk, reset: in std_logic;
		ld, up, down: in std_logic;
		d: in std_logic_vector(n-1 downto 0);
		q: out std_logic_vector(n-1 downto 0) := (others => '0'));
end counter;

architecture arch of counter is
	signal q_next: std_logic_vector(n-1 downto 0);
begin
	process(clk, reset)
	begin
		if (reset = '1') then
			q_next <= (others => '0');
		elsif rising_edge(clk) then
			if (ld = '1') then
				q_next <= d;
			elsif (up = '1') then
				q_next <= std_logic_vector(unsigned(q_next) + 1);
			elsif (down = '1') then
				q_next <= std_logic_vector(unsigned(q_next) - 1);
			end if;
		end if;
	end process;
	q <= q_next;
end arch;
