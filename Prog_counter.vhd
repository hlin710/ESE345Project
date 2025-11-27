library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_Register is
    port(
        clk : in  std_logic;
        rst : in  std_logic; 
        
        -- Control input to prevent PC from updating (for stalls/bubbles)
        pc_freeze : in std_logic; 
        
        -- Outputs the current instruction address
        pc_out : out unsigned(5 downto 0) 
        -- Note: pc_out connects to the 'pc_addr' input of your InstructionBuffer
    );
end entity PC_Register;

architecture behavioral of PC_Register is
    -- Internal signal to hold the PC value
    signal pc_current : unsigned(5 downto 0) := (others => '0'); 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset to the first instruction address (0)
                pc_current <= (others => '0'); 
            elsif pc_freeze = '0' then
                -- Increment PC if not frozen (i.e., not stalling)
                -- We only use the lower 6 bits, effectively handling the 64-instruction wrapping
                pc_current <= pc_current + 1; 
            end if;
        end if;
    end process;

    -- Output the current PC value
    pc_out <= pc_current;

end architecture behavioral;