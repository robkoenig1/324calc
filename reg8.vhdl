library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8 is
port(    
    I:      in std_logic_vector(3 downto 0);   -- 4-bit input data
    clock:  in std_logic;                      -- rising-edge triggering 
    enable: in std_logic;                      -- 0: don't do anything; 1: register file is enabled
    addr:   in std_logic_vector(2 downto 0);   -- 3-bit address to select one register
    O:      out std_logic_vector(3 downto 0)   -- 4-bit output from selected register
);
end reg8;

architecture structural of reg8 is
    -- component declaration for the register
    component reg
    generic (
        WIDTH : natural 
    );
    port(    
        I:      in std_logic_vector(WIDTH-1 downto 0);  -- for loading
        clock:  in std_logic;                           -- rising-edge triggering 
        enable: in std_logic;                           -- 0: don't do anything; 1: reg is enabled
        O:      out std_logic_vector(WIDTH-1 downto 0)  -- output current register content
    );
    end component;
    
    signal reg_enables: std_logic_vector(7 downto 0); -- 8 register enable signals
    type reg_outputs_type is array (0 to 7) of std_logic_vector(3 downto 0); -- 8 register outputs
    signal reg_outputs: reg_outputs_type;
    
begin
    -- generate 8 registers
    gen_registers: for index in 0 to 7 generate
        reg_i: reg
        generic map (
            WIDTH => 4
        )
        port map (
            I => I,
            clock => clock,
            enable => reg_enables(index),
            O => reg_outputs(index)
        );
    end generate;
    
    -- address decoder for write operations
    process(addr, enable)
    begin
 
        reg_enables <= (others => '0'); -- default disable all registers
        
        if enable = '1' then -- enable only selected register when global enable is '1'
            case addr is
                when "000" => reg_enables(0) <= '1';
                when "001" => reg_enables(1) <= '1';
                when "010" => reg_enables(2) <= '1';
                when "011" => reg_enables(3) <= '1';
                when "100" => reg_enables(4) <= '1';
                when "101" => reg_enables(5) <= '1';
                when "110" => reg_enables(6) <= '1';
                when "111" => reg_enables(7) <= '1';
                when others => reg_enables <= (others => '0');
            end case;
        end if;
    end process;
    
    -- multiplexer for read operations
    process(addr, reg_outputs)
    begin

        case addr is
            when "000" => O <= reg_outputs(0);
            when "001" => O <= reg_outputs(1);
            when "010" => O <= reg_outputs(2);
            when "011" => O <= reg_outputs(3);
            when "100" => O <= reg_outputs(4);
            when "101" => O <= reg_outputs(5);
            when "110" => O <= reg_outputs(6);
            when "111" => O <= reg_outputs(7);
            when others => O <= (others => '0');
        end case;
    end process;
    
end structural;
