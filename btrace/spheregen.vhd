library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.btrace_pack.all;
-- This is used to test the intersection of a sphere with a ray.

entity sphere_gen is
	generic(int, frac: integer := 16);
	port(clk, rst: in std_logic;
		direction_vector: in vector;
		ray_origin: in point;
		obj: in object_t;
		result: out std_logic_vector((int+frac)-1 downto 0);

	-- Status
		obj_hit: out std_logic);
end sphere_gen;

architecture arch of sphere_gen is
	signal v: vector;
	signal q, dot_self, vv, subr: sfixed((2*int)-1 downto -(2*frac));
	signal mul, q_sq, disc: sfixed((4*int)-1 downto -(2*frac));
begin
	-- Could be replaced with something more compact.
	v.m_x <= (ray_origin.x - obj.position.x);
	v.m_y <= (ray_origin.y - obj.position.y);
	v.m_z <= (ray_origin.z - obj.position.z);
	q_dot: entity work.dot generic map(int, frac) port map(v, direction_vector, q);
	dot_self_dot: entity work.dot generic map(int, frac) port map(direction_vector, direction_vector, dot_self);
	vv_dt: entity work.dot generic map(int, frac) port map(v, v, vv);

	subr <= vv-obj.size;
	mul <= subr*dot_self;
	q_sq <= q*q;

	disc <= q_sq - mul;
	obj_hit <= '1' when disc(127) = '0' else '0';

	result <= x"00000000";
	--Square root unit....
end arch;
