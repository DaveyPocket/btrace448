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
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all; -- Synopsys package

entity datapath_TB is
end datapath_TB;


architecture test_bench of datapath_TB is
	constant numInputs: integer := 13;
	signal clk, rst: std_logic;

	-- Datapath inputs (control)
	init_x, init_y, inc_x, inc_y: std_logic;
	set_vector, set_org: std_logic;
	next_obj, start_search: std_logic;
	clr_z_reg, clr_hit: std_logic;
	paint: std_logic;

	-- External inputs
	e_set_camera: std_logic;
	e_camera_point: point;
	e_set_obj: std_logic;
	e_obj_addr: std_logic_vector(3 downto 0);
	e_obj_data: object;

	-- Status outputs
	last_x, last_y, last_obj: std_logic 

	-- For debugging only, do not include in top level
	d_rgb: std_logic_vector(11 downto 0)
	d_px, d_py: std_logic_vector(8 downto 0));

	-- Controller states

	type states_t is ();
	signal controller_state: states_t := s_idle;

	-- Test bench
	constant clkPd: time := 20 ns;
	--file testStimFile: text open read_mode is "microprogram.prog"
	file testResults: text open write_mode is "results.resl";
begin
	uut: entity work.datapath port map(clk, rst,
					-- Control inputs
					init_x, init_y, inc_x, inc_y,
				  	set_vector, set_org,
					next_obj, start_search,
					clr_z_reg, clr_hit,
					paint,

					-- External inputs
					e_set_camera,
					e_camera_point,
					e_set_obj,
					e_obj_addr, e_obj_data,

					-- Status outputs
					last_x, last_y, last_obj,

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
						controller_state <= s_clear;
					end if;
				when s_compute =>
					controller_state <= s_cycle;
				when s_clear =>
					if obj_hit = '1' then
						controller_state <= s_compute;
					else
						controller_state <= s_cycle;
					end if;
				when s_wait =>
					if p_tick_out = '1' then
						controller_state <= s_wait;
					else
						controller_state <= s_clear_z_reg;
					end if;
				when s_clear_z_reg =>
					if (last_y and last_x) = '1' then
						controller_state <= s_idle;
					else
						if obj_hit = '1' then
							controller_state <= s_compute;
						else
							controller_state <= s_cycle;
						end if;
					end if;
				when others =>
					if last_obj = '0' then
						if obj_hit = '1' then
							controller_state <= s_compute;
						else
							controller_state <= s_cycle;
						end if;
					else
						if p_tick_out = '1' then
							controller_state <= s_wait;
						else
							controller_state <= s_clear_z_reg;
						end if;
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
		wait for clkPd/3;
		rst <= '1';
		wait for clkPd;
		rst <= '0';
		e_num_obj <= x"01";
		e_set_max <= '1';
		e_set_cam <= '1';
		wait for clkPd;
		e_set_cam <= '0';
		e_set_max <= '0';
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
			if (z_to_buf = '1') and (controller_state = s_cycle) then 
				write(reportLine, RGB);
				writeLine(testResults, reportLine);
			end if;
		end loop;
		report "Done testing." severity note;
		wait;
	end process testProc;


	-- Concurrent statement assignment go here.
end test_bench;
