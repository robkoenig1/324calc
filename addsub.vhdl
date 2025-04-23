library ieee;
use ieee.std_logic_1164.all;

entity addsub is
port(
    A:          in std_logic_vector(3 downto 0);  -- 4-bit signed input A
    B:          in std_logic_vector(3 downto 0);  -- 4-bit signed input B
    sub:        in std_logic;                     -- 0: add, 1: subtract
    result:     out std_logic_vector(3 downto 0); -- 4-bit signed result
    overflow:   out std_logic                     -- overflow/underflow indicator
);
end addsub;

architecture rtl of addsub is
    signal B_complement : std_logic_vector(3 downto 0); -- B or its two's complement
    signal carry : std_logic_vector(3 downto 0);        -- carry bits
    signal sum : std_logic_vector(3 downto 0);          -- result
begin

    -- calculate two's complement of B if subtraction
    process(B, sub)
        variable inverted_B : std_logic_vector(3 downto 0);
    begin

        if sub = '1' then
            -- invert bits for two's complement
            for i in 0 to 3 loop
                inverted_B(i) := not B(i);
            end loop;
            
            -- add 1 to inverted_B
            if inverted_B(0) = '0' then
                B_complement(0) <= '1';
                B_complement(1) <= inverted_B(1);
                B_complement(2) <= inverted_B(2);
                B_complement(3) <= inverted_B(3);
            elsif inverted_B(1) = '0' then
                B_complement(0) <= '0';
                B_complement(1) <= '1';
                B_complement(2) <= inverted_B(2);
                B_complement(3) <= inverted_B(3);
            elsif inverted_B(2) = '0' then
                B_complement(0) <= '0';
                B_complement(1) <= '0';
                B_complement(2) <= '1';
                B_complement(3) <= inverted_B(3);
            elsif inverted_B(3) = '0' then
                B_complement(0) <= '0';
                B_complement(1) <= '0';
                B_complement(2) <= '0';
                B_complement(3) <= '1';
            else
                B_complement(0) <= '0';
                B_complement(1) <= '0';
                B_complement(2) <= '0';
                B_complement(3) <= '0';
            end if;
        else
            -- if addition, use B
            B_complement <= B;
        end if;
    end process;
    
    -- 4-bit adder with carry chain
    carry(0) <= '0'; -- initial carry
    
    -- generate sum and carry for each bit
    sum(0) <= A(0) xor B_complement(0) xor carry(0);
    carry(1) <= (A(0) and B_complement(0)) or (A(0) and carry(0)) or (B_complement(0) and carry(0));
    
    sum(1) <= A(1) xor B_complement(1) xor carry(1);
    carry(2) <= (A(1) and B_complement(1)) or (A(1) and carry(1)) or (B_complement(1) and carry(1));
    
    sum(2) <= A(2) xor B_complement(2) xor carry(2);
    carry(3) <= (A(2) and B_complement(2)) or (A(2) and carry(2)) or (B_complement(2) and carry(2));
    
    sum(3) <= A(3) xor B_complement(3) xor carry(3);
    
    -- connect sum to result
    result <= sum;
    
    -- detect overflow/underflow
    overflow <= (A(3) and B_complement(3) and not sum(3)) or (not A(3) and not B_complement(3) and sum(3));
    
end rtl;
