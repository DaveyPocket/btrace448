-- Btrace 448
--
-- TESTBENCH for
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all; -- Synopsys package
use work.btrace_pack.all;

entity datapath_TB is
end datapath_TB;

architecture test_bench of datapath_TB is
	constant numInputs: integer := 13;
	signal clk, rst: std_logic;
	-- Datapath inputs (control)
	signal init_x, init_y, inc_x, inc_y: std_logic;
	signal set_vector, set_org: std_logic;
	signal next_obj, start_search: std_logic;
	signal clr_z_reg, clr_hit: std_logic;
	signal store: std_logic;
	signal paint: std_logic;

	-- External inputs
	signal e_set_camera: std_logic;
	signal e_camera_point: point;
	signal e_set_obj: std_logic;
	signal e_obj_addr: std_logic_vector(3 downto 0);
	signal e_obj_data: object;

	-- Status outputs
	signal last_x, last_y, last_obj, obj_valid: std_logic;

	-- For debugging only, do not include in top level
	signal d_rgb: std_logic_vector(11 downto 0);
	signal d_px, d_py: std_logic_vector(8 downto 0);


	-- Controller states

	type states_t is (s_idle, s_start, s_set, s_wait, s_next, s_done);
	signal controller_state: states_t := s_idle;

	-- Test bench
	constant clkPd: time := 20 ns;
	--file testStimFile: text open read_mode is "microprogram.prog"
	file testResults: text open write_mode is "results.resl";
	
	signal start, done: std_logic := '0';
	constant my_z: sfixed(15 downto -16) := to_sfixed(-1000, 15, -16);
	constant obj_z: sfixed(15 downto -16) := to_sfixed(100, 15, -16);
	constant obj_size: sfixed(15 downto -16) := to_sfixed(80, 15, -16);
	constant my_point: point := ((others => '0'), (others => '0'), my_z);
	
	
	constant my_object_point: point := (obj_z, obj_z, obj_z);
	constant my_object: object := (my_object_point, obj_size, x"FFF");
	constant no_object: point := ((others => '0'), (others => '0'), my_z);
begin
	uut: entity work.datapath port map(clk, rst,
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

					-- Status outputs
					last_x, last_y, last_obj, obj_valid,

					-- External outputs
					open, open, open,

					-- Debug
					d_rgb, d_px, d_py);

	clkProc: process
	begin
		clk <= '1';
		wait for clkPd/2;
		clk <= '0';
		wait for clkPd/2;
	end process clkProc;

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

	testProc: process
		variable stimLine: line;
		variable reportLine: line;
		variable valid: boolean;
		variable dataIn: std_logic_vector(numInputs-1 downto 0);
		--variable i: integer := 0;
		-- Index n corresponds to a address of micro program
		variable n: integer := 0;
	begin
		e_set_camera <= '0';
		e_set_obj <= '0';
		wait for clkPd/3;
		rst <= '1';
		wait for clkPd;
		rst <= '0';
		
		wait for clkPd;
		e_camera_point <= my_point;
		e_set_camera <= '1';
		wait for clkPd;
		e_set_camera <= '0';
		e_obj_addr <= (others => '0');
		e_obj_data <= my_object;
		e_set_obj <= '1';
		wait for clkPd;
		e_set_obj <= '0';
		wait for 10*clkPd;
		start <= '1';
		wait for 2*clkPd;
		start <= '0';

		-- Begin test bench
		--while not(endfile(testStimFile)) loop
		--	readline(testStimFile, stimLine);
		--	read(l => stimLine, value => dataIn, good => valid);
		--	next when valid = false;
		--	micro_program(i) <= dataIn;
		--	i := i + 1;
		--end loop;
		wait until clk = '0'; -- Change stimuli on falling edge, active on rising edge

		while done /= '1' loop
			 -- Change stimuli on the falling edge of the clock.

			-- Controller outputs (Datapath control)
			
			--	done <= mp_control(10);
			-- Microprogram sets 'done' output to signal external microcontroller/machine
			-- Datapath should have a 'last_pixel' signal rather than a done signal.
			
			-- Controller inputs (Next state and datapath status)
			wait until (clk'event and clk = '0');
			if (paint = '1') then 
				write(reportLine, d_rgb);
				writeLine(testResults, reportLine);
			end if;
		end loop;
		report "Done testing." severity error;
		wait;
	end process testProc;
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

	-- Concurrent statement assignment go here.
end test_bench;
