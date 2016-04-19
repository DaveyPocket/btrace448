library ieee;
library ieee_proposed.all;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use work.btrace_pack.all;

entity raygen is
	generic(int, fraction: integer := 16);
	port(clk, rst: in std_logic;
		set_cam: in std_logic;
		inc_x, inc_y: in std_logic;
		clr_x, clr_y: in std_logic;
		mv_x, mv_y, mv_z: out std_logic_vector((int+fraction)-1 downto 0));
end raygen;

architecture arch of raygen is
	--- Constant declarations
	-- Integers
	constant hsize: integer := 9;
	constant vsize: integer := 8;
	constant hsize_cat: integer := camera_reg_out.x'length;
	constant vsize_cat: integer := camera_reg_out.y'length;

	-- Other types
	constant camera_point: point := ((others => '0'), (others => '0'), (others => '0'));
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
begin
	--
	--- Component instantiation
	--
	
	-- Camera coordinate register
	camera_coord: entity work.point_reg port map(clk, rst, set_cam, camera_point, camera_reg_out);

	-- Horizontal counter (X)
	hc: entity work.counter generic map(hsize) port map(clk, rst, clr_x, inc_x, '0', h_init, houtput);

	-- Vertical counter (Y)
	vc: entity work.counter generic map(vsize) port map(clk, rst, clr_y, inc_y, '0', v_init, voutput);

	-- Subtractors
	subx: entity work.sub generic map(hsize_cat) port map(hout_cat, camera_reg_out.x, vector_x);
	suby: entity work.sub generic map(vsize_cat) port map(vout_cat, camera_reg_out.y, vector_y);

	--
	---	Concatenation and additional concurrent statements
	--

	-- hout_cat
	-- vout_cat
end arch;

