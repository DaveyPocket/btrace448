library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.btrace_pack.all;


entity spheregen_TB is
end spheregen_TB;

architecture arch of spheregen_TB is
	constant clkPd: time := 20 ns;
	signal clk, rst: std_logic;

	signal d_vect: vector := (x"00000000", x"00000000", x"03E80000");
	signal origin_point: point := (x"00000000", x"00000000", x"00000000");
	-- should be positioned at z = 16, x = 0, y = 0
	-- size 2
	signal myObject: object := ((x"00000000", x"00000000", x"01900000"), x"00500000", x"F00");
	
	signal obj_hit: std_logic;
	signal result: std_logic_vector(31 downto 0);
begin
	uut: entity work.sphere_gen port map(clk, d_vect, origin_point, myObject, result, obj_hit);

	clkProc: process
	begin
		clk <= '1';
		wait for clkPd/2;
		clk <= '0';
		wait for clkPd/2;
	end process clkProc;

	mainProc: process
	begin
		rst <= '1';
		wait for clkPd/3;
		wait for clkPd;
		rst <= '0';
		wait;
	end process mainProc;
end arch;
