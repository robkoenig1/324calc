library ieee;
use ieee.std_logic_1164.all;

entity addsub_tb is
end addsub_tb;

architecture behavioral of addsub_tb is
    -- component declaration for the adder/subtractor
    component addsub
    port(
        A:          in std_logic_vector(3 downto 0);  -- 4-bit signed input A
        B:          in std_logic_vector(3 downto 0);  -- 4-bit signed input B
        sub:        in std_logic;                     -- 0: add, 1: subtract
        result:     out std_logic_vector(3 downto 0); -- 4-bit signed result
        overflow:   out std_logic                     -- overflow/underflow indicator
    );
    end component;
    
    -- signals to connect to the adder/subtractor
    signal a_in: std_logic_vector(3 downto 0) := "0000";
    signal b_in: std_logic_vector(3 downto 0) := "0000";
    signal sub_mode: std_logic := '0';
    signal res: std_logic_vector(3 downto 0);
    signal ovf: std_logic;
begin

    -- instantiate the adder/subtractor
    addsub_inst: addsub
    port map (
        A => a_in,
        B => b_in,
        sub => sub_mode,
        result => res,
        overflow => ovf
    );
    
    -- process to stimulate adder/subtractor
    process
        -- procedure to test specific case
        procedure test_case(
            a_value: in std_logic_vector(3 downto 0);
            b_value: in std_logic_vector(3 downto 0);
            subtract: in std_logic
        ) is
        begin

            a_in <= a_value;
            b_in <= b_value;
            sub_mode <= subtract;
            wait for 10 ns;
        end procedure;
        
    begin
        
        -- simple addition with positive numbers
        test_case("0011", "0010", '0');  -- 3 + 2 = 5
        
        -- addition with negative number
        test_case("0101", "1110", '0');  -- 5 + (-2) = 3
        
        -- addition of two negative numbers
        test_case("1110", "1101", '0');  -- (-2) + (-3) = -5
        
        -- addition causing positive overflow
        test_case("0111", "0001", '0');  -- 7 + 1 = -8 (overflow)
        
        -- addition causing negative overflow
        test_case("1000", "1000", '0');  -- (-8) + (-8) = 0 (overflow)
        
        -- simple subtraction with positive numbers
        test_case("0110", "0011", '1');  -- 6 - 3 = 3
        
        -- subtraction resulting in negative number
        test_case("0010", "0011", '1');  -- 2 - 3 = -1
        
        -- subtraction of negative number
        test_case("0011", "1110", '1');  -- 3 - (-2) = 5
        
        -- subtraction causing positive overflow
        test_case("0111", "1000", '1');  -- 7 - (-8) = 15 -> -1 (overflow)
        
        -- subtraction causing negative overflow
        test_case("1000", "0001", '1');  -- (-8) - 1 = -9 -> 7 (overflow)
        
        assert false report "End of test" severity note;
        wait;
    end process;
    
end behavioral;
