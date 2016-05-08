library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;

package btrace_pack is
	type color_t is (black, red, green, yellow, blue, magenta, cyan, white);
	type comp_op is (gt, gte, eq);
	type point is
		record
			-- Point coordinates, three dimensions
			x, y, z: sfixed(15 downto -16);
		end record;
	type vector is
		record
			-- Vector component magnitudes
			m_x, m_y, m_z: sfixed(15 downto -16);
		end record;

	type object is
		record
			position: point;
			size: sfixed(15 downto -16);
			color: std_logic_vector(11 downto 0);
		end record;
end btrace_pack;
