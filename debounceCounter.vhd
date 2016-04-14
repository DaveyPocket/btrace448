library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounceCounter is
	generic(k: integer);
	port(en, rst, clk: in std_logic;
		Q: out std_logic_vector(k-1 downto 0));
end debounceCounter;

architecture yeayea of debounceCounter is
	signal Qbuf: std_logic_vector(k-1 downto 0);
begin
	Q <= Qbuf;
	process(clk, rst)
	begin
		if (rst = '1') then
			Qbuf <= (others => '0');
		elsif rising_edge(clk) then
			if (en = '1') then
				Qbuf <= Qbuf + 1;
			end if;
		end if;
	end process;
end yeayea;
