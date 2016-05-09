-- Btrace 448
-- VGA Sync Test Bench
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_sync_TB is
end vga_sync_TB;

architecture testbench of vga_sync_TB is
	constant clkPd: time := 20 ns;
	signal clk: std_logic;
	signal rst: std_logic;
	signal p_tick: std_logic;
begin

	uut: entity work.vga_sync port map(clk, rst, open, open, open, p_tick, open, open);

	clk_proc: process
	begin
		clk <= '1';
		wait for clkPd/2;
		clk <= '0';
		wait for clkPd/2;
	end process clk_proc;

	main_TB: process
	begin
		rst <= '1';
		wait for clkPd/3;
		rst <= '0';
		wait;
	end process main_TB;
end testbench;
