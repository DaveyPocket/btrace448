library ieee;
use ieee.std_logic_1164.all;
use work.btrace_pack.all;

entity datapath is
	port(clk, rst: in std_logic;
		next_obj, clr_obj_count: in std_logic;
		s_mux, clr_z_reg, en_z_reg: in std_logic;
		clr_x, clr_y, inc_x, inc_y: in std_logic;
		last_obj, obj_hit: out std_logic;
		e_num_obj: in std_logic_vector(7 downto 0);
		e_set_cam, e_set_max: in std_logic;
		-- RGB output
		RGB: out std_logic_vector(11 downto 0);
		hsync, vsync: out std_logic);
end datapath;

architecture arch of datapath is
	constant w_t_val: integer := 10;
	constant int, frac: integer := 16;
	constant w_data: integer := ?;
	signal s_t_val, s_z_reg_out: std_logic_vector(w_t_val-1 downto 0);
	signal s_obj_num, s_max_obj, s_tab_addr: std_logic_vector(7 downto 0);
	signal s_compare_t, s_store: std_logic;

	-- VGA sync/output interface
	signal p_tick: std_logic;
begin
	-- Object counter
	obj_counter: entity work.counter generic map(8) port map(clk, rst, clr_obj_count, next_obj, '0', x"00", s_obj_num);

	-- Maximum objects register
	max_obj_reg: entity work.reg generic map(8) port map(clk, rst, e_set_max, '0', e_num_obj, s_max_obj);

	-- Object index comparison
	comp_obj_index: entity work.ucompare generic map(8, eq) port map(s_obj_num, s_max_obj, last_obj);

-- Object record table
	--

	-- Ray generator
	--
	ray_generator: entity work.raygen generic map(int, frac) port map(clk, rst, e_set_cam, inc_x, inc_y, clr_x, clr_y, mv_x?, mv_y?, mv_z?, p_x?, p_y?);


	-- Depth (Z) register
	z_reg: entity work.reg generic map(w_t_val) port map(clk, rst, s_store, clr_z_reg, s_t_val, s_z_reg_out);

	-- Z-register comparator
	-- TODO Need signed comparison
	z_compare: entity work.ucompare

	-- Output interface (VGA sync + pixel buffer & overlay)
	--
	out_interface: entity work.outputInteface(clk, rst, hsync?, vsync?, video_on?, p_tick, pixel_x?, pixel_y?);


--- Combinational logic

	s_store <= en_zreg and s_compare_t?;

end arch;
