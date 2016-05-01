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
		direction: in vector;
		origin: in point;
		in_object: in object_t;
		sqrt_result: out std_logic_vector((int+frac)-1 downto 0);

	-- Status
		obj_hit: out std_logic);
end sphere_gen;

architecture arch of sphere_gen is
	signal v: vector;
	signal m_xc, m_yc, m_zc: ufixed(16 downto -16);
	signal dd, q, qq, vv, b, mula, mulb, result, disc: std_logic_vector((int+frac)-1 downto 0);
	signal mul1, mul2, qmul: std_logic_vector((2*(int+frac))-1 downto 0);
begin
	m_xc <= origin.x - in_object.position.x;
	m_yc <= origin.y - in_object.position.y;
	m_zc <= origin.z - in_object.position.z;
	v.m_x <= m_xc(15 downto -16);
	v.m_y <= m_yc(15 downto -16);
	v.m_z <= m_zc(15 downto -16);


	-- Dot products, good
	dot1: entity work.dot port map(v, direction, q);
	dot2: entity work.dot port map(direction, direction, dd);
	dot3: entity work.dot port map(v, v, vv);
	b <= std_logic_vector(in_object.size);
	
	-- Multiplication, good
	mul1 <= b*dd;
	mul2 <= vv*dd;
	qmul <= q*q;
	mula <= mul1(47 downto 32) & mul1(31 downto 16);
	mulb <= mul2(47 downto 32) & mul2(31 downto 16);
	qq <= qmul(47 downto 32) & qmul(31 downto 16);

	-- Discriminant, good
	disc <= qq - mulb + mula;
	-- Object hit if discriminant is positive
	obj_hit <= '1' when disc(31) = '0' else '0';

	-- Square root unit
	sqrt: entity work.squareroot port map(clk, disc, sqrt_result);
	
end arch;

-- Attributes of sphere needed
-- Sphere center (position)
-- Sphere radius (constant)
-- Shade (shade_type)
-- Non-normalized t-value (one sided)

-- Other attributes needed
-- ray origin
-- direction vector (no unit vector)
