-- Btrace 448
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed.all;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.btrace_pack.all;

entity datapath is
	port(clk, rst: in std_logic;
	e_set_camera: in std_logic;
	init_x, init_y, inc_x, inc_y: in std_logic;
	set_vector, set_org: in std_logic;
	last_x, last_y: out std_logic;
end datapath;

architecture arch of datapath is
	constant int, frac: integer := 16;
	constant w_px: integer := 8;
	constant w_py: integer := 9;
	constant screen_z: sfixed := to_sfixed(0, 15, -16);
	constant screen_width: std_logic_vector(8 downto 0) := x"140";
	constant screen_height: std_logic_vector(7 downto 0) := x"F0";
	signal px, x: std_logic_vector(w_px-1 downto 0);
	signal py, y: std_logic_vector(w_py-1 downto 0);
	signal camera_point, pre_point, origin: point;
	signal subx, suby, subz: sfixed(int downto -frac); -- No int-1 due to carry bit
	signal pre_vector, direction_vector: vector;
begin 
-- Ray generator--
	-- x_counter
	x_counter: entity work.counter generic map(w_px) port map(clk, rst, init_x, inc_x, '0', x"00", px);
	-- y_counter
	y_counter: entity work.counter generic map(w_py) port map(clk, rst, init_y, inc_y, '0', x"00", py);
	
	-- comp_x
	last_x <= '1' when (px = screen_width - 1) else '0';
	
	-- comp_y
	last_y <= '1' when (py = screen_height - 1) else '0';

	-- x
	x <= px - ('0' & screen_width(8 downto 1));

	-- y
	y <= ('0' & screen_height(7 downto 1)) - py;

	-- camera_reg
	camera_reg: entity work.reg port map(clk, rst, e_set_camera, ?e_camera_point, camera_point);

	-- subx
	subx <= to_sfixed(x, 15, -16) - camera_point.x;

	-- suby
	suby <= to_sfixed(y, 15, -16) - camera_point.y;
	
	-- subz
	subz <=  screen_z - camera_point.z;

	-- pre_vector
	pre_vector.x <= subx(15 downto -16);
	pre_vector.y <= suby(15 downto -16);
	pre_vector.z <= subz(15 downto -16);

	-- vector_reg
	vect_reg: entity work.vector_reg port map(clk, rst, set_vector, pre_vector, direction_vector);

	-- pre_point
	pre_point.x <= x;
	pre_point.y <= y;
	pre_point.z <= screen_z;

	-- origin_reg
	origin_reg: entity work.point_reg port map(clk, rst, set_org, pre_point, origin);




end arch;
