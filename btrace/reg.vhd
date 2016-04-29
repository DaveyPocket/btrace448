library ieee;
use ieee.std_logic_1164.all;

entity reg is
	generic(N: integer := 8);
	port(clk, rst: in std_logic;
		en: in std_logic;
		D, Q: std_logic_vector(N-1 downto 0));
end reg;

architecture arch is
	constant zeros: std_logic_vector(N-1 downto 0) := (others => '0');
begin
	process(clk, rst)
	begin
		if rst <= '1' then
			D <= zeros;
		elsif rising_edge(clk) then
			D <= Q;
		end if;
	end process;
end arch;
