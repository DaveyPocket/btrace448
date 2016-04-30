-- Btrace 448
--
-- TESTBENCH for
-- Datapath
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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

	-- Datapath outputs (status)
	signal last_obj, obj_hit, p_tick_out: std_logic;

	-- External devices (MCU)
	signal e_num_obj: std_logic_vector(7 downto 0) := (others => 'L');
	signal e_set_cam, e_set_max: std_logic := (others => '0');


	-- Test bench
	type micro_program_t is array(0 to 1023) of std_logic_vector(20 downto 0); -- Size of this
	signal micro_program: micro_program_t;
	constant clkPd: time := 20 ns;

	file testStimFile: text open read_mode is "microprogram.prog"
	file testResults: text open write_mode is "results.resl"
begin
	uut: entity work.datapath port map(clk, rst, next_obj, clr_obj_count, clr_z_reg, en_z_reg, clr_x, clr_y, inc_x, inc_y, z_to_buf, table_sel, last_obj, obj_hit, p_tick_out, e_num_obj, e_set_cam, e_set_max);

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
			-- Assigning stimulus data to input files
			table_sel <= dataIn(0);
			z_to_buf <= dataIn(1);
			inc_y <= dataIn(2);
			inc_x <= dataIn(3);
			clr_y <= dataIn(4);
			clr_x <= dataIn(5);
			en_z_reg <= dataIn(6);
			clr_z_reg <= dataIn(7);
			clr_obj_count <= dataIn(8);
			next_obj <= dataIn(9)
		wait;
	end process testProc;
end test_bench;
