-- Btrace 448
-- Controller
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.btrace_pack.all;

entity controller is
	port(clk, rst: in std_logic;
	-- Control outputs
	init_x, init_y, inc_x, inc_y: out std_logic;
	set_vector, set_org: out std_logic;
	next_obj, start_search: out std_logic;
	clr_z_reg, clr_hit: out std_logic;
	store: out std_logic;
	paint: out std_logic;
	done: out std_logic;

	-- Status inputs
	last_x, last_y, last_obj, obj_valid, start: in std_logic);

end controller;

architecture arch of controller is
	-- Controller states
	type states_t is (s_idle, s_start, s_set, s_wait, s_next, s_done);
	signal controller_state: states_t := s_idle;
begin 
	process(clk, rst)
	begin
		if rst = '1' then
			controller_state <= s_idle;
		elsif rising_edge(clk) then
			case controller_state is
				when s_idle =>
					if start = '1' then
						controller_state <= s_start;
					end if;
				when s_start =>
					controller_state <= s_set;
				when s_set =>
					controller_state <= s_wait;
				when s_wait => 
					controller_state <= s_next;
				when s_next =>
					if last_obj = '0' then
						controller_state <= s_wait;
					else
						if last_x = '0' then
							controller_state <= s_start;
						else
							if last_y = '0' then
								controller_state <= s_start;
							else
								controller_state <= s_done;
							end if;
						end if;
					end if;
				when others =>
					if start = '1' then
						controller_state <= s_done;
					else
						controller_state <= s_idle;
					end if;
			end case;
		end if;
	end process;

	clr_hit <= '1' when controller_state = s_start else '0';
	clr_z_reg <= '1' when controller_state = s_start else '0';
	init_x <= '1' when (controller_state = s_idle) or ((controller_state = s_next) and ((last_obj and last_x) = '1') and (last_y = '0')) else '0';
	inc_y <= '1' when ((controller_state = s_next) and ((last_obj and last_x) = '1') and (last_y = '0')) else '0';
	inc_x <= '1' when ((controller_state = s_next) and (last_obj = '1') and (last_x = '0')) else '0';
	init_y <= '1' when (controller_state = s_idle) else '0';
	set_vector <= '1' when controller_state = s_set else '0';
	set_org <= '1' when controller_state = s_set else '0';
	store <= '1' when (controller_state = s_wait) and (obj_valid = '1') else '0';
	paint <= '1' when (controller_state = s_next) and (last_obj = '1') else '0';
	next_obj <= '1' when (controller_state = s_next) else '0';
	start_search <= '1' when (controller_state = s_start) else '0';
	done <= '1' when (controller_state = s_done) else '0';
end arch;
