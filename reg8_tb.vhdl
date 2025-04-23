library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8_tb is
end reg8_tb;

architecture behavioral of reg8_tb is
    -- component declaration for register file
    component reg8
    port(    
        I:      in std_logic_vector(3 downto 0);   -- 4-bit input data
        clock:  in std_logic;                      -- rising-edge triggering 
        enable: in std_logic;                      -- 0: don't do anything; 1: register file is enabled
        addr:   in std_logic_vector(2 downto 0);   -- 3-bit address to select one of 8 registers
        O:      out std_logic_vector(3 downto 0)   -- 4-bit output from selected register
    );
    end component;
    
    -- signals to connect to register file
    signal data_in: std_logic_vector(3 downto 0) := "0000";
    signal clk: std_logic := '0';
    signal en: std_logic := '0';
    signal address: std_logic_vector(2 downto 0) := "000";
    signal data_out: std_logic_vector(3 downto 0);
    
begin
    -- instantiate register file
    reg8_inst: reg8
    port map (
        I => data_in,
        clock => clk,
        enable => en,
        addr => address,
        O => data_out
    );
    
    -- process to generate clock signal
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    -- process to stimulate register file
    process
    begin
        -- initial values
        data_in <= "0000";
        en <= '0';
        address <= "000";
        wait for 10 ns;
        
        -- test 1: write to register 0
        data_in <= "0101";  -- data to write
        address <= "000";   -- register 0
        en <= '1';          -- enable writing
        wait for 10 ns;     -- one clock cycle
        en <= '0';          -- disable writing
        wait for 10 ns;     -- one clock cycle to observe output
        
        -- test 2: write to register 1
        data_in <= "1010";
        address <= "001";
        en <= '1';
        wait for 10 ns;
        en <= '0';
        wait for 10 ns;
        
        -- test 3: write to register 2
        data_in <= "1100";
        address <= "010";
        en <= '1';
        wait for 10 ns;
        en <= '0';
        wait for 10 ns;
        
        -- test 4: write to register 7
        data_in <= "0011";
        address <= "111";
        en <= '1';
        wait for 10 ns;
        en <= '0';
        wait for 10 ns;
        
        -- test 5: read from all registers
        address <= "000"; -- register 0 should be "0101"
        wait for 10 ns;
        address <= "001"; -- register 1 should be "1010"
        wait for 10 ns;
        address <= "010"; -- register 2 should be "1100"
        wait for 10 ns;
        address <= "011"; -- register 3 should be "0000" - default
        wait for 10 ns;
        address <= "111"; -- register 7 (should be "0011"
        wait for 10 ns;
        
        -- test 6: write to register 3 with enable=0
        data_in <= "1111";
        address <= "011";
        en <= '0';
        wait for 10 ns;
        wait for 10 ns; -- register 3 should still be "0000"
        
        -- test 7: write and immediately read
        data_in <= "1110";
        address <= "100";
        en <= '1';
        wait for 10 ns;
        en <= '0';
        wait for 10 ns;
        
        -- end simulation
        assert false report "End of test" severity note;
        wait;
    end process;
    
end behavioral;
