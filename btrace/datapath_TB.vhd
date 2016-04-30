-- Btrace 448
--
-- TESTBENCH for
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all; -- Synopsys package

entity datapath_TB is
end datapath_TB;


architecture test_bench of datapath_TB is
	constant: numInputs: integer := 13;
	signal clk, rst: std_logic;

	-- Datapath inputs (control)
	signal next_obj, clr_obj_count: std_logic := '0';
	signal clr_z_reg, en_z_reg: std_logic := '0';
	signal clr_x, clr_y, inc_x, inc_y: std_logic := '0';
	signal z_to_buf: std_logic := '0';
	signal table_sel: std_logic_vector(1 downto 0) := "00";
	signal controlInputs: std_logic_vector(3 downto 0);

	-- Datapath outputs (status)
	signal last_obj, obj_hit, p_tick_out, done: std_logic;
	signal RGB: std_logic_vector(11 downto 0);
	signal px_x, px_y: std_logic_vector(9 downto 0);

	-- External devices (MCU)
	signal e_num_obj: std_logic_vector(7 downto 0) := (others => 'L');
	signal e_set_cam, e_set_max, e_set_x, e_set_y: std_logic := '0';


	-- Test bench
	constant clkPd: time := 20 ns;
	file testStimFile: text open read_mode is "microprogram.prog"
	file testResults: text open write_mode is "results.resl"

	-- Controller simulation
	type micro_program_t is array(0 to 1023) of std_logic_vector(13 downto 0); -- Size of this
	signal micro_program: micro_program_t;
	signal mp_addr: std_logic_vector(7 downto 0);
begin
	uut: entity work.datapath port map(clk, rst, next_obj, clr_obj_count, clr_z_reg, en_z_reg, clr_x, clr_y, inc_x, inc_y, z_to_buf, table_sel, last_obj, obj_hit, p_tick_out, done, e_num_obj, e_set_cam, e_set_max, e_set_x, e_set_y, RGB, open, open, px_x, px_y);

	clkProc: process
	begin
		clk <= '1';
		wait for clkPd/2;
		clk <= '0';
		wait for clkPd/2;
	end process clkProc;

	testProc: process
		variable stimLine: line;
		variable reportLine: line;
		variable valid: boolean;
		variable dataIn: std_logic_vector(numInputs-1 downto 0);
		variable i: integer := 0;
		-- Index n corresponds to a address of micro program
		variable n: integer := 0;
	begin
		rst <= '1';
		wait for 5*clkPd;
		rst <= '0';
		wait for 5*clkPd;

		-- Begin test bench
		while not(endfile(testStimFile)) loop
			readline(testStimFile, stimLine);
			read(l => stimLine, value => dataIn, good => valid);
			next when valid = false;
			micro_program(i) <= dataIn;
			i := i + 1;
		end loop;
		wait until clk = '0'; -- Change stimuli on falling edge, active on rising edge

		while not(done) loop
			wait until (clk'event and clk = '0'); -- Change stimuli on the falling edge of the clock.

			-- Controller outputs (Datapath control)
			table_sel <= micro_program(n)(0);
			z_to_buf <= micro_program(n)(1);
			inc_y <= micro_program(n)(2);
			inc_x <= micro_program(n)(3);
			clr_y <= micro_program(n)(4);
			clr_x <= micro_program(n)(5);
			en_z_reg <= micro_program(n)(6);
			clr_z_reg <= micro_program(n)(7);
			clr_obj_count <= micro_program(n)(8);
			next_obj <= micro_program(n)(9);
			-- Microprogram sets 'done' output to signal external microcontroller/machine
			-- Datapath should have a 'last_pixel' signal rather than a done signal.
			
			-- Controller inputs (Next state and datapath status)
			mp_addr <= micro_program(n)(13 downto 10) & last_obj & obj_hit & p_tick_out & done;
			n <= to_integer(mp_addr);
			if z_to_buf = '1' then 
				write(reportLine, to_integer(RGB));
				writeLine(testResults, reportLine);
			end if;
		end loop;
		report "Done testing." severity note;
		wait;
	end process testProc;
end test_bench;
