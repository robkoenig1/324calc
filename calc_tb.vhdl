library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity calc_tb is
end calc_tb;

architecture tb of calc_tb is

    -- Component declaration for the Calculator
    component calc
    port(
        clk:          in std_logic;
        reset:        in std_logic;
        instruction:  in std_logic_vector(7 downto 0);
        printout:     out std_logic_vector(15 downto 0)
    );
    end component;
    
    -- Test bench signals
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal instruction_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal printout_tb : std_logic_vector(15 downto 0);
    
    -- Clock period definition
    constant clk_period : time := 100 ns;
    
    -- Instruction format helpers
    -- opcode: 2 bits (bits 7-6)
    -- rs: 2 bits (bits 5-4)
    -- rt: 2 bits (bits 3-2)
    -- rd: 2 bits (bits 1-0)
    -- imm: 4 bits (bits 3-0)
    
    -- Opcodes
    constant OP_ADD  : std_logic_vector(1 downto 0) := "00";
    constant OP_SWAP : std_logic_vector(1 downto 0) := "01";
    constant OP_LOAD : std_logic_vector(1 downto 0) := "10";
    constant OP_CMP  : std_logic_vector(1 downto 0) := "11";
    
    -- Registers
    constant R0 : std_logic_vector(1 downto 0) := "00";
    constant R1 : std_logic_vector(1 downto 0) := "01";
    constant R2 : std_logic_vector(1 downto 0) := "10";
    constant R3 : std_logic_vector(1 downto 0) := "11";
    
    -- Special RT value for display
    constant RT_DISPLAY : std_logic_vector(1 downto 0) := "11";
    
    -- Function to create an instruction
    function make_instruction(
        opcode: std_logic_vector(1 downto 0);
        rd: std_logic_vector(1 downto 0);
        rt_or_imm: std_logic_vector(3 downto 0)
    ) return std_logic_vector is
        variable instruction: std_logic_vector(7 downto 0);
    begin
        instruction(7 downto 6) := opcode;
        instruction(5 downto 4) := rd;
        instruction(3 downto 0) := rt_or_imm;
        return instruction;
    end function;
    
    -- Procedure to display a register
    procedure display_register(
        signal instr: out std_logic_vector(7 downto 0);
        reg: std_logic_vector(1 downto 0)
    ) is
    begin
        -- Create a display instruction for the specified register
        instr <= OP_CMP & reg & RT_DISPLAY & "00";
    end procedure;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: calc port map (
        clk => clk_tb,
        reset => reset_tb,
        instruction => instruction_tb,
        printout => printout_tb
    );

    -- Clock process
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
        -- Helper procedures and variables
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
                report "PASS: Output matches expected value " & integer'image(expected);
            else
                report "FAIL: Expected " & integer'image(expected) & " but got " & integer'image(printout_int) severity error;
            end if;
        end procedure;
        
        variable l: line;
    begin
        -- Initialize
        wait for clk_period;
        reset_tb <= '1';
        wait_cycles(2);
        
        -- Release reset
        reset_tb <= '0';
        wait_cycles(2);

        -- Use report statements instead of writeline for console output
        report "Starting Calculator Test";
        
        -- Test 1: Load immediate values into registers
        report "Test 1: Loading immediate values into registers";
        
        -- Load R0 with immediate value 5
        instruction_tb <= make_instruction(OP_LOAD, R0, "0101");  -- Load 5 into R0
        wait_cycles(5);
        
        -- Display R0
        display_register(instruction_tb, R0);
        wait_cycles(5);
        -- Check output
        check_output(5);
        
        -- Load R1 with immediate value -3 (signed 4-bit value)
        instruction_tb <= make_instruction(OP_LOAD, R1, "1101");  -- Load -3 into R1
        wait_cycles(5);

        -- Display R1
        display_register(instruction_tb, R1);
        wait_cycles(5);
        -- Check output
        check_output(-3);
        
        -- Test 2: Addition
        report "Test 2: Testing addition";
        
        -- Add R0 and R1, store in R0 (5 + (-3) = 2)
        instruction_tb <= make_instruction(OP_ADD, R0, R1 & "00");
        wait_cycles(1);
        
        -- Display R0
        display_register(instruction_tb, R0);
        wait_cycles(1);
        -- Check output
        check_output(2);
        
        -- Test 3: Swap operation
        report "Test 3: Testing swap operation";
        
        -- Load R2 with value 0x0004 (low byte=0x04)
        instruction_tb <= make_instruction(OP_LOAD, R2, "0100");  -- Load 4 (lower byte)
        wait_cycles(1);
        
        -- Load R3 with value 0x0008 (lower byte=0x08)
        instruction_tb <= make_instruction(OP_LOAD, R3, "1000");  -- Load 8 (lower byte)
        wait_cycles(1);
        
        -- Now perform swap on R2 (assuming swap exchanges lower and upper bytes)
        instruction_tb <= make_instruction(OP_SWAP, R0, R2 & "00");  -- Swap bytes in R2, store in R0
        wait_cycles(1);
        
        -- Display R0
        display_register(instruction_tb, R0);
        wait_cycles(1);
        -- Value would depend on how swap is implemented - can't check exact value without knowing implementation
        
        -- Test 4: Compare operation
        report "Test 4: Testing compare operation";
        
        -- Reset R0 to 5
        instruction_tb <= make_instruction(OP_LOAD, R0, "0101");  -- Load 5 into R0
        wait_cycles(1);
        
        -- Reset R1 to 5 (same as R0)
        instruction_tb <= make_instruction(OP_LOAD, R1, "0101");  -- Load 5 into R1
        wait_cycles(1);
        
        -- Compare R0 and R1 (they should be equal)
        instruction_tb <= make_instruction(OP_CMP, R0, R1 & "00");  -- Compare R0 and R1
        wait_cycles(1);
        
        -- The comparison result would typically set a flag, which we can't test directly in this testbench
        -- But we can load different values and try again
        
        -- Set R1 to a different value
        instruction_tb <= make_instruction(OP_LOAD, R1, "0110");  -- Load 6 into R1
        wait_cycles(1);
        
        -- Compare R0 and R1 (they should not be equal)
        instruction_tb <= make_instruction(OP_CMP, R0, R1 & "00");  -- Compare R0 and R1
        wait_cycles(1);
        
        -- Display R0 and R1 to confirm values
        display_register(instruction_tb, R0);
        wait_cycles(1);
        check_output(5);
        
        display_register(instruction_tb, R1);
        wait_cycles(1);
        check_output(6);
        
        -- Test 5: Complex sequence
        report "Test 5: Complex sequence";
        
        -- Load values
        instruction_tb <= make_instruction(OP_LOAD, R0, "0111");  -- Load 7 into R0
        wait_cycles(1);
        
        instruction_tb <= make_instruction(OP_LOAD, R1, "0010");  -- Load 2 into R1
        wait_cycles(1);
        
        -- Add R0 and R1, store in R2
        instruction_tb <= make_instruction(OP_ADD, R2, R0 & "00");
        wait_cycles(1);
        
        instruction_tb <= make_instruction(OP_ADD, R2, R1 & "00");
        wait_cycles(1);
        
        -- Display R2
        display_register(instruction_tb, R2);
        wait_cycles(1);
        check_output(9);  -- Should be 7 + 2 = 9
        
        -- Complete test
        report "Calculator Test Completed";
        
        wait_cycles(10);
        assert false report "Simulation Finished" severity note;
        wait;
    end process;

end tb;