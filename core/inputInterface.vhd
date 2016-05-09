-- Btrace 448
-- Input Interface
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;

entity inputInterface is
	port(clk, rst: in std_logic;
		BTNS, BTNU, BTND, BTNL, BTNR: in std_logic; -- Raw inputs from dev. board
		BTNSd, BTNUd, BTNDd, BTNLd, BTNRd: out std_logic); -- Debounced/buffered buttons
end inputInterface;

architecture arch of inputInterface is
	signal d: std_logic_vector(4 downto 0);	-- Debouncer outputs
	signal bi, bo: std_logic_vector(0 to 4);	-- Vectors mapping to inputs and outputs, used in generation of rising edge detectors and debouncers.
begin
	bi <= BTNS & BTNU & BTND & BTNL & BTNR;
	BTNSd <= bo(0);
	BTNUd <= bo(1);
	BTNDd <= bo(2);
	BTNLd <= bo(3);
	BTNRd <= bo(4);

	genInputInterface:
	for i in 0 to 4 generate
		debx: entity work.debouncer generic map(30, 11) port map (bi(i), clk, rst, d(i));
		redx: entity work.red port map(d(i), rst, clk, bo(i));
	end generate genInputInterface;

end arch;
