-- Btrace 448
-- Rising Edge Detector
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;

entity red is
	port(input, rst, clk: in std_logic;
		output: out std_logic);
end red;

architecture behavior of red is
	signal qBuf: std_logic;
begin
	process(clk, rst)
	begin
		if rst = '1' then
			qBuf <= '0';
		elsif rising_edge(clk) then
			qBuf <= input;
		end if;
	end process;
	output <= not(qBuf) and input;
end behavior;
