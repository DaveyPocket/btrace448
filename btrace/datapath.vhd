-- Btrace 448
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use work.btrace_pack.all;

entity datapath is
	port(clk, rst: in std_logic;

		-- Datapath inputs (control)
		next_obj, clr_obj_count: in std_logic;
		clr_z_reg, en_z_reg: in std_logic;
		clr_x, clr_y, inc_x, inc_y: in std_logic;
		z_to_buf: in std_logic;
		table_sel: in std_logic_vector(1 downto 0);

		-- Datapath outputs (status)
		last_obj, obj_hit, p_tick_out, done: out std_logic;

		-- External devices (MCU)
		e_num_obj: in std_logic_vector(7 downto 0);
		e_set_cam, e_set_max, e_set_x, e_set_y: in std_logic;

		-- RGB interface
		-- TODO: Move output interface external to datapath, to help with debugging and testing...
		RGB: out std_logic_vector(11 downto 0);
		hsync, vsync: out std_logic;

		-- For debugging, LEAVE OPEN on top level...
		d_rgb: out std_logic_vector(11 downto 0);
		px_x, px_y: out std_logic_vector(9 downto 0));
end datapath;

architecture arch of datapath is
	-- Bus width constants
	constant w_t_val: integer := 10;
	constant w_int, w_frac: integer := 16;
	constant w_data: integer := 9;
	constant w_obj_tab: integer := 8;

	-- Internal datapath signals
	signal s_t_val, s_z_reg_out: std_logic_vector(w_t_val-1 downto 0);
	signal s_obj_num, s_max_obj, s_tab_addr, s_obj_sel: std_logic_vector(w_obj_tab-1 downto 0);
	signal s_compare_t, s_store: std_logic;
	signal s_gen_px, s_gen_py, s_pixel_x, s_pixel_y, s_addr_buf_x, s_addr_buf_y: std_logic_vector(9 downto 0);
	signal s_frame_buf_rgb: std_logic_vector(11 downto 0);
	signal s_arbitrate: std_logic;

	-- VGA sync/output interface
	signal p_tick: std_logic;
	-- (TODO - REMOVE, TEMPORARY)
	signal e_obj_addr: std_logic_vector(7 downto 0) := (others => '0');
begin
	-- TEMPORARY
	obj_hit <= '1';
	--Not using done, using last_x and last_y from comparators and registers
	--TEMPORARY
	done <= '0';

	-- Object counter
	obj_counter: entity work.counter generic map(w_obj_tab) port map(clk, rst, clr_obj_count, next_obj, '0', x"00", s_obj_num);

	-- Maximum objects register
	max_obj_reg: entity work.reg generic map(w_obj_tab) port map(clk, rst, e_set_max, '0', e_num_obj, s_max_obj);

	-- Object index comparison
	comp_obj_index: entity work.compare(arch_unsigned) generic map(8, eq) port map(s_obj_num, s_max_obj, last_obj);

-- Object record table
	--

	-- Ray generator
	--
	--ray_generator: entity work.raygen generic map(w_int, w_frac) port map(clk, rst, e_set_cam, inc_x, inc_y, clr_x, clr_y, mv_x?, mv_y?, mv_z?, gen_px, gen_py);
	ray_generator: entity work.raygen generic map(w_int, w_frac) port map(clk, rst, e_set_cam, inc_x, inc_y, clr_x, clr_y, open, open, open, s_gen_px, s_gen_py);


	-- Depth (Z) register
	z_reg: entity work.reg generic map(w_t_val) port map(clk, rst, s_store, clr_z_reg, s_t_val, s_z_reg_out);

	-- Object proximity register
	obj_prox_reg: entity work.reg generic map(w_obj_tab) port map(clk, rst, s_store, '0', s_obj_num, s_obj_sel);

	-- Z-register comparator
	z_compare: entity work.compare(arch_signed) generic map(w_t_val, gte) port map(s_z_reg_out, s_t_val, s_compare_t);

	-- Output interface (VGA sync + pixel buffer & overlay)
	-- Use correct signalling from output interface and not vga_sync
	out_interface: entity work.outputInterface port map(clk, rst, p_tick, s_pixel_x, s_pixel_y, s_frame_buf_rgb, x"000", '0', hsync, vsync, RGB);

	-- Frame buffer
	-- TODO Adjust 
	-- Address selection inside of frame buffer
	--frame_buffer: entity work.frame_buf generic map(9, 8) port map(clk, s_arbitrate, ?from_shader?, s_frame_buf_rgb, s_addr_buf_x, s_addr_buf_y);
	frame_buffer: entity work.frame_buf generic map(9, 8) port map(clk, s_arbitrate, x"000", s_frame_buf_rgb, s_addr_buf_x(8 downto 0), s_addr_buf_y(7 downto 0));


--- Combinational logic
	s_store <= en_z_reg and s_compare_t;

	-- Frame buffer address arbiters
	s_addr_buf_x <= s_gen_px when p_tick = '0' else s_pixel_x;
	s_addr_buf_y <= s_gen_py when p_tick = '0' else s_pixel_y;

	-- Frame buffer arbitration
	s_arbitrate <= z_to_buf and not(p_tick);

	-- p_tick_output
	p_tick_out <= p_tick;

	-- Record table index mux.
	with table_sel select
		s_tab_addr <= e_obj_addr when "00",
					  s_obj_num when "01",
					  s_obj_sel when others;

end arch;