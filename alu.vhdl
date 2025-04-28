library ieee;
use ieee.std_logic_1164.all;

entity alu is
port(
    A:          in std_logic_vector(15 downto 0);
    B:          in std_logic_vector(15 downto 0);
    op:         in std_logic_vector(1 downto 0);
    result:     out std_logic_vector(15 downto 0);
    equal:      out std_logic
);
end alu;

architecture rtl of alu is

    signal A_lower : std_logic_vector(7 downto 0);
    signal B_lower : std_logic_vector(7 downto 0);
    signal swapped_A : std_logic_vector(15 downto 0);
    signal add_result : std_logic_vector(15 downto 0);
    signal carry : std_logic_vector(15 downto 0);
    signal compare_result : std_logic;
    
begin

    A_lower <= A(7 downto 0);
    B_lower <= B(7 downto 0);

    swapped_A <= A(7 downto 0) & A(15 downto 8);
    
    --compare_proc: process(A_lower, B_lower)
    --    variable temp : std_logic;
    --begin
    --    temp := '1'; --assume equal
    --    for i in 0 to 7 loop
     --       if A_lower(i) /= B_lower(i) then
     --           temp := '0'; --not equal
     --       end if;
    --    end loop;
    --    compare_result <= temp;
    --end process;
    compare_result <= '1' when (A_lower = B_lower) else '0';
    
    carry(0) <= '0'; --no initial carry
    
    add_gen: for i in 0 to 15 generate --add operation using ripple carry adder
        add_result(i) <= A(i) xor B(i) xor carry(i);
        carry_gen: if i < 15 generate
            carry(i+1) <= (A(i) and B(i)) or (A(i) and carry(i)) or (B(i) and carry(i));
        end generate;
    end generate;
    
    process(op, A, B, swapped_A, add_result, compare_result)
    begin
        case op is
            when "00" => --compare
                result <= (others => '0'); --not used for compare
                equal <= compare_result;
                
            when "01" => --swap
                result <= swapped_A;
                equal <= '0';
                
            when "10" => --load
                result <= B;
                equal <= '0';
                
            when "11" => --add
                result <= add_result;
                equal <= '0';
                
            when others =>
                result <= (others => '0');
                equal <= '0';
        end case;
    end process;
    
end rtl;
