library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity reg_tb is
end reg_tb;

architecture behavioral of reg_tb is
  component reg --  Declaration of the component that will be instantiated.
  generic (
    WIDTH : natural 
  );
  port(	
	  I:	in std_logic_vector (WIDTH-1 downto 0); -- for loading
 	  clock:		in std_logic; -- rising-edge triggering 
	  enable:		in std_logic; -- 0: don't do anything; 1: reg is enabled
	  O:	out std_logic_vector(WIDTH-1 downto 0) -- output the current register content. 
  );
  end component;

  constant WIDTH : natural := 4; -- Test with 4-bit width
  signal i, o : std_logic_vector(WIDTH-1 downto 0);
  signal clk, enable : std_logic;

begin
  reg0: reg
  generic map (
    WIDTH => WIDTH 
  )
  port map (I => i, clock => clk, enable => enable, O => o);

  process --  This process does the real job.
  type pattern_type is record
	i: std_logic_vector (WIDTH-1 downto 0); --  The inputs of the reg.
	clock, enable: std_logic;
	o: std_logic_vector (WIDTH-1 downto 0); --  The expected outputs of the reg.
  end record;

  type pattern_array is array (natural range <>) of pattern_type; --  The patterns to apply.
  constant patterns : pattern_array := 
  (
    -- initial state
    ("0101", '0', '0', "0000"),
    
    -- test 1: enable=0, clock rising edge - register should not change
    ("0101", '1', '0', "0000"),
    ("0101", '0', '0', "0000"),
    
    -- test 2: enable=1, clock rising edge - register should load "0101"
    ("0101", '0', '1', "0000"),
    ("0101", '1', '1', "0101"),
    ("0101", '0', '1', "0101"),

    -- test 3: new value with enable=1, clock rising edge - register should load "1010"
    ("1010", '0', '1', "0101"),
    ("1010", '1', '1', "1010"),
    ("1010", '0', '1', "1010"),
    
    -- test 4: enable=0, clock rising edge - register should not change
    ("1100", '0', '0', "1010"),
    ("1100", '1', '0', "1010"),
    ("1100", '0', '0', "1010")
  );
  begin

    for n in patterns'range loop --  check each pattern.
      i <= patterns(n).i; --  set the inputs
      clk <= patterns(n).clock;
      enable <= patterns(n).enable;
      wait for 1 ns; --  wait for the results.
      assert o = patterns(n).o --  check the outputs.
      report "bad output value at pattern " & integer'image(n) severity error;
    end loop;

    assert false report "end of test" severity note;
    wait; --  end
    end process;

  end behavioral;
