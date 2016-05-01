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

	signal d_vect: vector := (x"00000000", x"00000000", x"00010000");
	signal origin_point: point := (x"00200000", x"00000000", x"00000000");
	-- should be positioned at z = 16, x = 0, y = 0
	-- size 2
	signal myObject: object_t := ((x"00000000", x"00000000", x"00100000"), x"00040000", red, '0');
	
	signal obj_hit: std_logic;
begin
	uut: entity work.sphere_gen port map(clk, rst, d_vect, origin_point, myObject, obj_hit);

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
	end process mainProc;
end arch;
