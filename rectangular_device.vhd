library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pongpack.all;

entity rectangular_device is
	port(addr_x, addr_y: in std_logic_vector(9 downto 0);
		px1, py1, px2, py2: in std_logic_vector(9 downto 0);
		dev_on: out std_logic;
		color: color_t;
		rgb: out std_logic_vector(2 downto 0));
end rectangular_device;


architecture arch of rectangular_device is
	signal ipx1, ipy1, ipx2, ipy2: integer;
	signal ia_x, ia_y: integer;
	signal inx, iny: std_logic;
begin
	ipx1 <= to_integer(unsigned(px1));
	ipy1 <= to_integer(unsigned(py1));
	ipx2 <= to_integer(unsigned(px2));
	ipy2 <= to_integer(unsigned(py2));
	ia_x <= to_integer(unsigned(addr_x));
	ia_y <= to_integer(unsigned(addr_y));

	inx <= '1' when (ia_x >= ipx1) and (ipx2 >= ia_x) else '0';
	iny <= '1' when (ia_y >= ipy1) and (ipy2 >= ia_y) else '0';

	with color select
		rgb <= "000" when black,
		       "100" when red,
		       "010" when green,
		       "110" when yellow,
		       "001" when blue,
		       "101" when magenta,
		       "011" when cyan,
		       "111" when others;
	
	dev_on <= inx and iny;

end arch;
