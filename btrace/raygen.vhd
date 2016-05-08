-- Btrace 448
-- Ray Generator
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_unsigned.all;
use work.btrace_pack.all;

entity raygenn is
	generic(int, fraction: integer := 16);
	port(clk, rst: in std_logic;
		set_cam: in std_logic;
		inc_x, inc_y: in std_logic;
		clr_x, clr_y: in std_logic;
		direction: out vector;
		origin: out point;
		--mv_x, mv_y, mv_z: out std_logic_vector((int+fraction)-1 downto 0);
		--	TODO: remove fudge values for below pixel x and y coordinates
		p_x, p_y: out std_logic_vector(9 downto 0);
		last_x, last_y: out std_logic);
end raygenn;

architecture arch of raygenn is
	--- Constant declarations
	-- Integers
	constant hsize: integer := 9;
	constant vsize: integer := 8;
	constant hsize_cat: integer := 32;
	constant vsize_cat: integer := 32;

	-- Other types
	constant camera_point: point := (x"00000000", x"00000000", x"FF000000");
	constant h_init: std_logic_vector(hsize-1 downto 0) := (others => '0');
	constant v_init: std_logic_vector(vsize-1 downto 0) := (others => '0');

	-- Signal declarations (do not change these)
	signal camera_reg_out: point;
	signal houtput: std_logic_vector(hsize-1 downto 0);
	signal voutput: std_logic_vector(vsize-1 downto 0);

	signal hout_cat: std_logic_vector(hsize_cat-1 downto 0);
	signal vout_cat: std_logic_vector(vsize_cat-1 downto 0);
	signal vector_x: std_logic_vector(hsize_cat-1 downto 0);
	signal vector_y: std_logic_vector(vsize_cat-1 downto 0);

	-- TODO fix this
	signal vector_z: std_logic_vector(31 downto 0);
	signal vvx, vvy: std_logic_vector(31 downto 0);
	constant zeros: sfixed(15 downto -16) := (others => '0');
	signal sub16: sfixed(16 downto -16) := (others => '0');
begin
	--
	--- Component instantiation
	--
	
	-- Camera coordinate register (input: point_type, output: point_type)
	camera_coord: entity work.point_reg port map(clk, rst, set_cam, camera_point, camera_reg_out);

	-- Horizontal counter (X) (initializes to zero, output std_logic_vector(hsize-1 downto 0))
	hc: entity work.counter generic map(hsize) port map(clk, rst, clr_x, inc_x, '0', h_init, houtput);

	-- Vertical counter (Y) (initializes to zero, output std_logic_vector(vsize-1 downto 0))
	vc: entity work.counter generic map(vsize) port map(clk, rst, clr_y, inc_y, '0', v_init, voutput);

	--- Subtractors
	-- Horizontal coordinate subractor ()
	subx: entity work.sub generic map(hsize_cat) port map(hout_cat, std_logic_vector(camera_reg_out.x), vector_x);

	-- Vertical coordinate subtractor ()
	suby: entity work.sub generic map(vsize_cat) port map(vout_cat, std_logic_vector(camera_reg_out.y), vector_y);

	subz: entity work.sub generic map(32) port map(x"00000000", std_logic_vector(camera_reg_out.z), vector_z);
	--
	---	Concurrent statements
	--

	-- TODO remove fudge values
	-- hout_cat (Concatenates 'integer' houtput with zero fractional portion)
	hout_cat <= "0000000"&houtput&x"0000";
	-- vout_cat (Concatenates 'integer' voutput with zero fractional portion)
	vout_cat <= "00000000"&voutput&x"0000";
	direction.m_x <= to_sfixed(vector_x, 15, -16);
	direction.m_y <= to_sfixed(vector_y, 15, -16);
	sub16 <= zeros - camera_point.z;
	direction.m_z <= sub16(15 downto -16);
	-- Unbounded issue below
	--origin.x <= "010100000" - to_ufixed(hout_cat, 15, -16);
	--origin.y <= "01111000" - to_ufixed(vout_cat, 15, -16);
	origin.x <= to_sfixed(hout_cat, 15, -16);
	origin.y <= to_sfixed(vout_cat, 15, -16);
	origin.z <= x"00000000";

	-- Pixel coordinates
	p_x <= '0' & houtput;
	p_y <= "00" & voutput;

	last_x <= '1' when houtput = "100111111" else '0';
	last_y <= '1' when voutput = x"EF" else '0';

end arch;
