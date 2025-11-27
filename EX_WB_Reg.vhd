library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EX_WB_Reg is
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;

        -- stall control
        exwb_freeze : in STD_LOGIC := '0';

        -- inputs from Execute stage
        rd_result_in : in STD_LOGIC_VECTOR(127 downto 0);
        rd_index_in  : in unsigned(4 downto 0);
        reg_write_in : in STD_LOGIC;

        -- tutputs to Write Back stage
        rd_result_out : out STD_LOGIC_VECTOR(127 downto 0);
        rd_index_out  : out unsigned(4 downto 0);
        reg_write_out : out STD_LOGIC
    );
end EX_WB_Reg;

architecture behavioral of EX_WB_Reg is

    signal rd_result_reg : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal rd_index_reg  : unsigned(4 downto 0) := (others => '0');
    signal reg_write_reg : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then -- reset
                rd_result_reg <= (others => '0');
                rd_index_reg  <= (others => '0');
                reg_write_reg <= '0';

            elsif exwb_freeze = '0' then
                rd_result_reg <= rd_result_in;
                rd_index_reg  <= rd_index_in;
                reg_write_reg <= reg_write_in;
            end if;
        end if;
    end process;

    -- outputs
    rd_result_out <= rd_result_reg;
    rd_index_out  <= rd_index_reg;
    reg_write_out <= reg_write_reg;

end architecture behavioral;
