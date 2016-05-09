library ieee;
use ieee.std_logic_1164.all;

entity top is
	port(clk, rst: in std_logic;
	btns, btnr, btnu: in std_logic;
	rgb: out std_logic_vector(11 downto 0);
	hsync, vsync, led: out std_logic);
end top;

architecture arch of top is
	constant my_z: sfixed(15 downto -16) := to_sfixed(-1000, 15, -16);
	constant obj_z: sfixed(15 downto -16) := to_sfixed(100, 15, -16);
	constant obj_size: sfixed(15 downto -16) := to_sfixed(80, 15, -16);
	constant my_point: point := ((others => '0'), (others => '0'), my_z);
	
	
	constant my_object_point: point := (obj_z, obj_z, obj_z);
	constant my_object: object := (my_object_point, obj_size, x"FFF");
	constant no_object: point := ((others => '0'), (others => '0'), my_z);
	-- Control signals
	signal init_x, init_y, inc_x, inc_y: std_logic;
	signal set_vector, set_org: std_logic;
	signal next_obj, start_search: std_logic;
	signal clr_z_reg, clr_hit: std_logic;
	signal store: std_logic;
	signal paint: std_logic;
	signal done: std_logic;

	-- External inputs
	signal e_set_camera: std_logic;
	signal e_camera_point: point;
	signal e_set_obj: std_logic;
	signal e_obj_addr: std_logic_vector(3 downto 0);
	signal e_obj_data: object;
	signal e_set_max: std_logic;
	signal e_max_objects: std_logic_vector(3 downto 0);

	-- Status signals
	signal last_x, last_y, last_obj, obj_valid, start: std_logic;
begin
	dpath: entity work.datapath port map(clk, rst,
					-- Control inputs
					init_x, init_y, inc_x, inc_y,
				  	set_vector, set_org,
					next_obj, start_search,
					clr_z_reg, clr_hit,
					store,
					paint,

					-- External inputs
					e_set_camera,
					e_camera_point,
					e_set_obj,
					e_obj_addr, e_obj_data,
					e_set_max, e_max_objects,

					-- Status outputs
					last_x, last_y, last_obj, obj_valid,

					-- External outputs
					hsync, vsync, rgb

					-- Debug
					open, open, open);
	controller_thing: entity work.controller port map(clk, rst, 
					-- Control
					init_x, init_y, inc_x, inc_y,
				  	set_vector, set_org,
					next_obj, start_search,
					clr_z_reg, clr_hit,
					store,
					paint,
					done,

					-- Status
					last_x, last_y, last_obj, obj_valid, start);

		e_max_objects <= x"0";
		e_set_camera <= btns;
		e_set_obj <= btnr;
		e_obj_data <= my_object;
		e_obj_addr <= (others => '0');
		e_camera_point <= my_point;
		led <= done;
		start <= btnu;
end arch;
