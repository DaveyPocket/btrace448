library ieee;
use ieee.std_logic_1164.all;

entity sphere_gen is
	port(clk, rst: in std_logic;
		ray: in (vector_type?);
		origin: in (point_type?);
		
		);
end sphere_gen;

-- Attributes of sphere needed
-- Sphere center (position)
-- Sphere radius (constant)
-- Shade (shade_type)
-- Non-normalized t-value (one sided)

-- Other attributes needed
-- ray origin
-- direction vector (no unit vector)


architecture arch of sphere_gen is
begin
end arch;
