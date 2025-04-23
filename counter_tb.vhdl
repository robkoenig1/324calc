library ieee;
use ieee.std_logic_1164.all;

entity counter_tb is
end counter_tb;

architecture behavioral of counter_tb is
    -- component declaration for the counter
    component counter
    port(
        clock:      in std_logic;  -- rising-edge triggering
        reset:      in std_logic;  -- synchronous reset, active high
        incdec:     in std_logic;  -- 1: increment, 0: decrement
        count:      out std_logic_vector(3 downto 0)  -- 4-bit counter output
    );
    end component;
    
    -- signals to connect to the counter
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal inc_dec: std_logic := '1'; -- default to increment
    signal count_value: std_logic_vector(3 downto 0);
    
begin
    -- instantiate the counter
    counter_inst: counter
    port map (
        clock => clk,
        reset => rst,
        incdec => inc_dec,
        count => count_value
    );
    
    -- process to generate the clock signal
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    -- process to stimulate the counter
    process
    begin
        -- initial reset to ensure known state
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        
        -- test increment operation count from 0 to 15 and overflow back to 0
        inc_dec <= '1';
        wait for 170 ns;
        
        -- reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        
        -- test decrement operation count from 0, underflow to 15, then count down to 10
        inc_dec <= '0';
        wait for 60 ns;
        
        -- test reset during counting
        inc_dec <= '1';
        wait for 30 ns;
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        
        -- test switching between increment and decrement
        inc_dec <= '1';
        wait for 40 ns;
        inc_dec <= '0';
        wait for 40 ns;
        inc_dec <= '1';
        wait for 40 ns;
        
        assert false report "End of test" severity note;
        wait;
    end process;
    
end behavioral;
