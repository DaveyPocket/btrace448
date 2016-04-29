library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity object_table is
	generic(int, frac: integer := 16;
		   	entries: integer := 8);
	port(clk: in std_logic;
		en: in std_logic;
		address: in std_logic_vector(entries-1 downto 0);
		ip_x, ip_y, ip_z: in std_logic_vector((int+frac)-1 downto 0);
		isize: in std_logic_vector((int+frac)-1 downto 0);
		icolor: in std_logic_vector(11 downto 0);
		io_type: in std_logic;
		op_x, op_y, op_z: on std_logic_vector((int+frac)-1 downto 0);
		osize: on std_logic_vector((int+frac)-1 downto 0);
		ocolor: on std_logic_vector(11 downto 0);
		oo_type: on std_logic);
end object_table;

architecture arch of object_table is
	constant pointsize: integer := int+frac;
	constant colordepth: integer := 12;
	constant objecttype: integer := 1;

	constant buswidth: integer := (4*(pointsize) + colordepth + objecttype);

	type data_t is array(0 to entries-1) of std_logic_vector(buswidth-1 downto 0);
	signal data: data_t;
	signal inData, outData: std_logic_vector(buswidth-1 downto 0);
begin
	inData <= ip_x & ip_y & ip_z & isize & icolor & io_type;
	oo_type <= outData(0);
	ocolor <= outData(12 downto 1);
	osize <= outData((pointsize+13)-1 downto 13);
	ip_x <= outData(buswidth-1 downto buswidth-pointsize);
	ip_y <= outData(buswidth-pointsize-1 downto buswidth-(2*pointsize));
	ip_z <= outData(buswidth-(2*pointsize)-1 downto buswidth-(3*pointsize));

	process(clk)
	begin
		if rising_edge(clk) then
			data(integer(to_unsigned(address))) <= inData;
		end if;
	end process;


end arch;
