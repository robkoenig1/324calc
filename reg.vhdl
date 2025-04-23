library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg is
generic (
    WIDTH : natural := 8  -- Default width is 8 bits, can be overridden at instantiation.
  );
port(	
	I:	in std_logic_vector (WIDTH-1 downto 0); -- for loading
 	clock:		in std_logic; -- rising-edge triggering 
	enable:		in std_logic; -- 0: don't do anything; 1: reg is enabled
	O:	out std_logic_vector(WIDTH-1 downto 0) -- output the current register content. 
);
end reg;

architecture behavioral of reg is
    signal reg_content: std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- initialize register content to zeros
begin

    process(clock)
    begin

	if rising_edge(clock) then -- rising-edge triggering
	    if enable = '1' then -- check if register is enabled
              reg_content <= I; -- load input into register
            end if;
        end if;
    end process;

    O <= reg_content; -- output the current register content
end behavioral;
