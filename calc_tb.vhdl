library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_tb is

end calc_tb;

architecture tb of calc_tb is

    --component declaration for calc
    component calc
    port(
        clk:          in std_logic;
        reset:        in std_logic;
        instruction:  in std_logic_vector(7 downto 0);
        pc_out:       out std_logic_vector(3 downto 0);
        printout:     out std_logic_vector(15 downto 0)
    );
    end component;
    
    --signals
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal instruction_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal printout_tb : std_logic_vector(15 downto 0);
    
    --clk period
    constant clk_period : time := 10 ns;

begin

    --instantiate tb
    tb: calc port map (
        clk => clk_tb,
        reset => reset_tb,
        instruction => instruction_tb,
        printout => printout_tb
    );

    --clk process
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;
    
    --test time
    test: process
        procedure wait_cycles(n: integer) is
        begin
            for i in 1 to n loop
                wait until rising_edge(clk_tb);
            end loop;
        end procedure;
        
        procedure check_output(expected: integer) is
            variable printout_int: integer;
        begin
            printout_int := to_integer(signed(printout_tb));
            if printout_int = expected then
                report "PASS - " & integer'image(expected) & " == " & integer'image(printout_int);
            else
                report "FAIL - " & integer'image(expected) & " != " & integer'image(printout_int) severity error;
            end if;
        end procedure;

    begin

        wait for clk_period;
        reset_tb <= '1';
        wait_cycles(2);
        
        reset_tb <= '0';
        wait_cycles(2);

        report "Test 1: Loading immediate values into registers";
        
        instruction_tb <= "10000101"; --load 5 into r0
        wait_cycles(2);
        check_output(5);
        wait_cycles(2);
  
        instruction_tb <= "10011101"; --load -3 into r1
        wait_cycles(2);
        check_output(-3);
        wait_cycles(2);
        
        report "Test 2: Testing addition";
        
        instruction_tb <= "00000100"; --r0 = r0 + r1
        wait_cycles(2);
        check_output(2);
        wait_cycles(2);

        instruction_tb <= "10000111"; --load 7 into r0
        wait_cycles(2);
        instruction_tb <= "10010010"; --load 2 into r1
        wait_cycles(2);
        
        instruction_tb <= "00110001"; --r2 = r0 + r1
        wait_cycles(2);
        check_output(9);
        wait_cycles(2);
        
        report "Test 3: Testing swap operation";

        instruction_tb <= "10110100"; --load 4 into r3
        wait_cycles(2);
        check_output(4);
        wait_cycles(2);

        instruction_tb <= "01110000"; --swap in r3
        wait_cycles(2);
        check_output(1024);
        wait_cycles(2);
        
        report "Test 4: Testing compare operation";
        
        instruction_tb <= "10000101"; --load 5 into r0
        wait_cycles(5);
        
        instruction_tb <= "10010101"; --load 5 into r1
        wait_cycles(5);
        
        instruction_tb <= "11000100"; --cmp r0 r1
        wait_cycles(2);
        check_output(1);
        wait_cycles(2);

        instruction_tb <= "10010110"; --load 6 into r1
        wait_cycles(5);

        instruction_tb <= "11000100"; --cmp r0 r1
        wait_cycles(2);
        check_output(0);
        wait_cycles(2);
        
        wait_cycles(10);
        assert false report "End of Tests" severity note;
        wait;
    end process;

end tb;
