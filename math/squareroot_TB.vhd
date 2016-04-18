library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity squareroot_TB is
end entity;


architecture arch of squareroot_TB is
	constant clkPd: time := 20 ns;
	signal clk: std_logic;
	signal din: ufixed(15 downto -16) := (others => '0');
	signal dout: ufixed(15 downto -16);
begin
	uut: entity work.squareroot port map(clk, din, dout);
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
		din <= x"00040000"; -- 4
		wait for 3*clkPd;
		din <= x"00100000"; -- 16
		wait for 3*clkPd;
		din <= x"00018000"; -- 1.5
		wait for 3*clkPd;
		din <= x"0FF00000";
		wait;
	end process mainTB;

end arch;
