library ieee;
library ieee_proposed.all;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use work.btrace_pack.all;

entity raygen is
	port(clk, rst: in std_logic;
		set_cam: in std_logic;
		inc_x, inc_y: in std_logic;
		clr: in std_logic);
end raygen;

architecture arch of raygen is
	-- Constant declarations
	constant hsize: integer := 9;
	constant vsize: integer := 8;
	constant camera_point: point := ((others => '0'), (others => '0'), (others => '0'));

	-- Signal declarations (do not change these)
	signal camera_reg_out: point;
	signal houtput: std_logic_vector(hsize-1 downto 0);
	signal voutput: std_logic_vector(vsize-1 downto 0);
begin
	-- Camera coordinate register
	camera_coord: entity work.point_reg port map(clk, rst, set_cam, camera_point, camera_reg_out);

	-- Horizontal counter (X)
	hc: entity work.counter generic map(hsize) port map(clk, rst: ?, ?, ?, zeros, houtput);

	-- Vertical counter (Y)
	vc: entity work.counter generic map(vsize) port map(clk, rst: ?, ?, ?, zeros, voutput);

	-- Subtractors
	subx: entity work.sub port map(houtput, camera_reg_out.x, ?);
	suby: entity work.sub port map(voutput, camera_reg_out.y, ?);

end arch;

