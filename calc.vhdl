library ieee;
use ieee.std_logic_1164.all;

entity calc is
port(
    clk:          in std_logic;
    reset:        in std_logic;
    instruction:  in std_logic_vector(7 downto 0);
    printout:     out std_logic_vector(15 downto 0)
);
end calc;

architecture rtl of calc is

    component reg
    generic (
        WIDTH : natural
    );
    port(
        I:   in std_logic_vector(WIDTH-1 downto 0);
        clk: in std_logic;
        en:  in std_logic;
        O:   out std_logic_vector(WIDTH-1 downto 0)
    );
    end component;

    component alu
    port(
        A:      in std_logic_vector(15 downto 0);
        B:      in std_logic_vector(15 downto 0);
        op:     in std_logic_vector(1 downto 0);
        result: out std_logic_vector(15 downto 0);
        equal:  out std_logic
    );
    end component;

    signal opcode : std_logic_vector(1 downto 0);
    signal rs : std_logic_vector(1 downto 0);
    signal rt : std_logic_vector(1 downto 0);
    signal rd : std_logic_vector(1 downto 0);
    signal imm : std_logic_vector(3 downto 0);
    signal sign_ext_imm : std_logic_vector(15 downto 0);
    signal reg_wr : std_logic;
    signal reg_dst : std_logic;
    signal alu_op : std_logic_vector(1 downto 0);
    signal alu_src : std_logic;
    signal equ : std_logic;
    signal print_en : std_logic;

    -- reg file and signals
    type reg_file_type is array (0 to 3) of std_logic_vector(15 downto 0);
    signal reg_file : reg_file_type := (others => (others => '0'));
    signal rf_wr_addr : std_logic_vector(1 downto 0);
    signal rf_wr_data : std_logic_vector(15 downto 0);
    signal rf_wr_en : std_logic;
    signal rf_rd_addr1 : std_logic_vector(1 downto 0);
    signal rf_rd_addr2 : std_logic_vector(1 downto 0);
    signal rf_rd_data1 : std_logic_vector(15 downto 0);
    signal rf_rd_data2 : std_logic_vector(15 downto 0);

    -- alu signals
    signal alu_in_a : std_logic_vector(15 downto 0);
    signal alu_in_b : std_logic_vector(15 downto 0);
    signal alu_result : std_logic_vector(15 downto 0);
    signal alu_equal : std_logic;


begin    

    -- instruction
    opcode <= instruction(7 downto 6);
    rs <= instruction(5 downto 4);
    rt <= instruction(3 downto 2);
    rd <= instruction(1 downto 0);
    imm <= instruction(3 downto 0);
    
    -- control
    process(opcode, alu_equal)
    begin
        -- default
        reg_wr <= '0';
        reg_dst <= '0';
        alu_op <= "00";
        alu_src <= '0';
        equ <= '0';
        print_en <= '0';
        
        case opcode is
            when "00" => -- add
                reg_wr <= '1';
                reg_dst <= '0';
                alu_op <= "11";
                alu_src <= '0';
                equ <= '0';
            when "01" => -- sawp
                reg_wr <= '1';
                reg_dst <= '1';
                alu_op <= "01";
                alu_src <= '0';
                equ <= '0';
            when "10" => -- load
                reg_wr <= '1';
                reg_dst <= '0';
                alu_op <= "10";
                alu_src <= '1';
                equ <= '0';
            when "11" => -- cmp and display
                if rt = "11" then -- display
                    reg_wr <= '0';
                    print_en <= '1';
                else -- cmp
                    reg_wr <= '0';
                    alu_op <= "00";
                    alu_src <= '0';
                    equ <= alu_equal;
                end if;
            when others => -- else
                null;
        end case;
    end process;
    
    -- sign extension
    sign_ext_imm(3 downto 0) <= imm;
    sign_ext_gen: for i in 4 to 15 generate
        sign_ext_imm(i) <= imm(3);
    end generate;
    
    -- register file read addressing
    rf_rd_addr1 <= rs;
    rf_rd_addr2 <= rt;
    
    -- register file write addressing mux
    rf_wr_addr <= rd when reg_dst = '1' else rs;
    rf_wr_en <= reg_wr;
    
    -- register file read
    process(rf_rd_addr1, rf_rd_addr2, reg_file)
    begin
        -- read port 1
        case rf_rd_addr1 is
            when "00" => rf_rd_data1 <= reg_file(0);
            when "01" => rf_rd_data1 <= reg_file(1);
            when "10" => rf_rd_data1 <= reg_file(2);
            when others => rf_rd_data1 <= reg_file(3);
        end case;
        
        -- read port 2
        case rf_rd_addr2 is
            when "00" => rf_rd_data2 <= reg_file(0);
            when "01" => rf_rd_data2 <= reg_file(1);
            when "10" => rf_rd_data2 <= reg_file(2);
            when others => rf_rd_data2 <= reg_file(3);
        end case;
    end process;
    
    -- register file write
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg_file(0) <= (others => '0');
                reg_file(1) <= (others => '0');
                reg_file(2) <= (others => '0');
                reg_file(3) <= (others => '0');
            elsif rf_wr_en = '1' then
                case rf_wr_addr is
                    when "00" => reg_file(0) <= rf_wr_data;
                    when "01" => reg_file(1) <= rf_wr_data;
                    when "10" => reg_file(2) <= rf_wr_data;
                    when others => reg_file(3) <= rf_wr_data;
                end case;
            end if;
        end if;
    end process;
    
    -- alu inputs
    alu_in_a <= rf_rd_data1;
    alu_in_b <= sign_ext_imm when alu_src = '1' else rf_rd_data2;
    
    -- alu instantiation
    alu_inst: alu
    port map(
        A => alu_in_a,
        B => alu_in_b,
        op => alu_op,
        result => alu_result,
        equal => alu_equal
    );
    
    -- write back to register file
    rf_wr_data <= alu_result;
    
    -- print output
    process(clk)
    begin
        if rising_edge(clk) then
            if print_en = '1' then
                printout <= rf_rd_data1;
            end if;
        end if;
    end process;
    
end rtl;
