-- Btrace 448
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.btrace_pack.all;

entity datapath is
	port(clk, rst: in std_logic;
	-- Control inputs
	init_x, init_y, inc_x, inc_y: in std_logic;
	set_vector, set_org: in std_logic;
	next_obj, start_search: in std_logic;
	clr_z_reg, clr_hit: in std_logic;
	store: in std_logic;
	paint: in std_logic;

	-- External inputs
	e_set_camera: in std_logic;
	e_camera_point: in point;
	e_set_obj: in std_logic;
	e_obj_addr: in std_logic_vector(3 downto 0);
	e_obj_data: in object;
	e_set_max: in std_logic;
	e_max_objects: in std_logic_vector(3 downto 0);

	-- Status outputs
	last_x, last_y, last_obj, obj_valid: out std_logic;

	-- External outputs
	hsync, vsync: out std_logic;
	rgb: out std_logic_vector(11 downto 0);
	-- For debugging only, do not include in top level
	d_rgb: out std_logic_vector(11 downto 0);
	d_px, d_py: out std_logic_vector(8 downto 0));
end datapath;

architecture arch of datapath is
	constant int, frac: integer := 16;
	constant w_px: integer := 9;
	constant w_py: integer := 8;
	constant w_obj_count: integer := 4;
	constant w_t: integer := 32;
	constant screen_z: sfixed := to_sfixed(0, 15, -16);
	constant screen_width: std_logic_vector(8 downto 0) := '1' & x"40";
	constant screen_height: std_logic_vector(7 downto 0) := x"F0";
	constant max_distance: std_logic_vector(w_t-1 downto 0) := std_logic_vector(to_unsigned(500000, w_t));
	constant pre_cat_x: std_logic_vector(15 - w_px downto 0) := (others => '0');
	constant post_cat: std_logic_vector(15 downto 0) := (others => '0');
	constant pre_cat_y: std_logic_vector(15 - w_py downto 0) := (others => '0');

	signal px, x: std_logic_vector(w_px-1 downto 0);
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal py, y: std_logic_vector(w_py-1 downto 0);
	signal camera_point, pre_point, origin: point;
	signal subx, suby, subz: sfixed(int downto -frac); -- No int-1 due to carry bit
	signal pre_vector, direction_vector: vector;
	signal i: std_logic_vector(w_obj_count-1 downto 0);
	signal obj_close, obj_hit, and_out: std_logic;
	signal z_temp, t_std: std_logic_vector(31 downto 0);
	signal obj_temp, object_records: object;
	--signal t: sfixed(15 downto -16);
	signal hit_something, video_on, p_tick, overlay_on: std_logic;
	signal color_mux, buf_out, overlay_out, rgb_overlay: std_logic_vector(11 downto 0);
	signal cat_x, cat_y: std_logic_vector(31 downto 0);
	signal max_objects: std_logic_vector(w_obj_count-1 downto 0);
begin
-- Ray generator--
	-- x_counter
	x_counter: entity work.counter generic map(w_px) port map(clk, rst, init_x, inc_x, '0', "000000000", px);
	-- y_counter
	y_counter: entity work.counter generic map(w_py) port map(clk, rst, init_y, inc_y, '0', x"00", py);
	
	-- comp_x
	last_x <= '1' when (px = std_logic_vector(unsigned(screen_width) - 1)) else '0';
	
	-- comp_y
	last_y <= '1' when (py = std_logic_vector(unsigned(screen_height) - 1)) else '0';

	-- x
	x <= std_logic_vector(unsigned(px) - unsigned(('0' & screen_width(8 downto 1))));

	-- y
	y <= std_logic_vector(unsigned(py) - unsigned(('0' & screen_height(7 downto 1))));

	-- camera_reg
	camera_reg: entity work.point_reg port map(clk, rst, e_set_camera, e_camera_point, camera_point);

	-- subx
	cat_x <= pre_cat_x & x & post_cat;
	subx <= to_sfixed(cat_x, 15, -16) - camera_point.x;

	-- suby
	cat_y <= pre_cat_y & y & post_cat;
	suby <= to_sfixed(cat_y, 15, -16) - camera_point.y;
	
	-- subz
	subz <=  screen_z - camera_point.z;

	-- pre_vector
	pre_vector.m_x <= subx(15 downto -16);
	pre_vector.m_y <= suby(15 downto -16);
	pre_vector.m_z <= subz(15 downto -16);

	-- vector_reg
	vect_reg: entity work.vector_reg port map(clk, rst, set_vector, pre_vector, direction_vector);

	-- pre_point
	pre_point.x <= to_sfixed(cat_x, 15, -16);
	pre_point.y <= to_sfixed(cat_y, 15, -16);
	pre_point.z <= screen_z;

	-- origin_reg
	origin_reg: entity work.point_reg port map(clk, rst, set_org, pre_point, origin);

	-- i_reg
	i_counter: entity work.counter generic map (w_obj_count) port map(clk, rst, start_search, next_obj, '0', x"0", i);

	-- comp_i
	last_obj <= '1' when (i = max_objects) else '0';

	-- z_temp_reg
	z_temp_reg: entity work.reg generic map(32) port map(clk, rst, store, clr_z_reg, t_std, z_temp, max_distance);

	-- comp_t
	obj_close <= '1' when (signed(t_std) < signed(z_temp)) else '0';

	-- store
	and_out <= obj_hit and obj_close;
	obj_valid <= and_out;

	-- hit_reg
	hit_reg: entity work.dff port map(hit_something, clk, and_out, rst, clr_hit, hit_something);

	-- obj_temp_reg
	obj_temp_reg: entity work.object_reg port map(clk, rst, store, object_records, obj_temp);

	-- Sphere generator
	sphere_generator: entity work.sphere_gen generic map(16, 16) port map(clk, direction_vector, origin, object_records, t_std, obj_hit);

	-- Object record table
	object_record_tab: entity work.object_table port map(clk, e_set_obj, i, e_obj_addr, e_obj_data, object_records);

	-- screen
	screen: entity work.frame_buf port map (clk, paint, color_mux, buf_out, px, py, pixel_x(9 downto 1), pixel_y(8 downto 1));

	-- vga_sync
	vga_device: entity work.vga_sync port map(clk, rst, hsync, vsync, video_on, p_tick, pixel_x, pixel_y);

	-- Multiplexers
	color_mux <= obj_temp.color when hit_something = '1' else x"00F";
	overlay_out <= buf_out when overlay_on = '0' else rgb_overlay;
	rgb <= overlay_out when video_on = '1' else x"000";

	-- Max object register
	max_obj: entity work.reg generic map(4) port map(clk, rst, e_set_max, '0', e_max_objects, max_objects, x"0");

	-- Temporary
	overlay_on <= '0';
	d_rgb <= color_mux;
	d_px <= px;
	d_py <= '0' & py;
end arch;
