library ieee;
use ieee.std_logic_1164.all;
use work.btrace_pack.all;

entity datapath is
	port(clk, rst: in std_logic;
		next_obj, clr_obj_count: in std_logic;
		s_mux, clr_z_reg, en_z_reg: in std_logic;
		clr_x, clr_y, inc_x, inc_y: in std_logic;
		last_obj, obj_hit: out std_logic;
		e_num_obj: in std_logic_vector(7 downto 0));
end datapath;

architecture arch of datapath is
	signal s_obj_num, s_max_obj: std_logic_vector(7 downto 0);
begin
	-- Object counter
	obj_counter: entity work.counter generic map(8) port map(clk, rst, clr_obj_count, next_obj, '0', x"00", s_obj_num);

	-- Maximum objects register
	--
	max_obj_reg: entity work.reg generic map(8) port map(clk, rst, ?, e_num_obj, s_max_obj);

	-- Object index comparison
	comp_obj_index: entity work.ucompare generic map(8, eq) port map(s_obj_num, s_max_obj, last_obj);


end arch;
