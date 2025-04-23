library ieee;
use ieee.std_logic_1164.all;

entity calc is
port(
    clk:        in std_logic;
    reset:      in std_logic;
);
end calc;

architecture rtl of calc is
    signal temp : std_logic_vector(3 downto 0);
begin
    process()
        variable temp2 : std_logic_vector(3 downto 0);
    begin
	
    end process;
end rtl;
