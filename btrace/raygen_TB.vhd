library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity raygen_TB is
end raygen_TB;


architecture arch of raygen_TB is
	constant clkPd: time := 20 ns;
	constant int, fraction: integer := 16;
	signal clk, rst: std_logic := '0';
	signal set_cam: std_logic := '0';
	signal inc_x, inc_y: std_logic := '0';
	signal clr_x, clr_y: std_logic := '0';
	signal mv_x, mv_y, mv_z: std_logic_vector((int+fraction)-1 downto 0);
begin
	uut: entity work.raygen generic map(int, fraction) port map(clk, rst, set_cam, inc_x, inc_y, clr_x, clr_y, mv_x, mv_y, mv_z);

	clkProc: process
	begin
		wait for clkPd/2;
		clk <= '1';
		wait for clkPd/2;
		clk <= '0';
	end process clkProc;

	mainTB: process
	begin
		wait for clkPd/3;
		rst <= '1';
		wait for clkPd/2;
		rst <= '0';
		wait for clkPd/2;
		rst <= '0';
		set_cam <= '1';
		wait for clkPd;
		set_cam <= '0';
		for i in 0 to 3 loop
			inc_x <= '1';
			wait for clkPd;
			inc_x <= '0';
			wait for clkPd;
		end loop;
		inc_y <= '1';
		clr_x <= '1';
		wait for clkPd;
		inc_y <= '0';
		clr_x <= '0';
		wait;
	end process mainTB;
end arch;
