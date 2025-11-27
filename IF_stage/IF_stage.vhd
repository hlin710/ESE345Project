-------------------------------------------------------------------------------
--
-- Title       : IF_stage
-- Design      : ese345proj1part1
-- Author      : harry.lin@stonybrook.com
-- Company     : Stony Brook
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/ese345proj1/ese345proj1part1/src/IF_stage.vhd
-- Generated   : Wed Nov 26 19:01:22 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;


entity IF_Stage is
    port(
        clk : in std_logic;
        rst : in std_logic;
        freeze : in std_logic;

        -- Outputs to ID stage
        IFID_instruction : out std_logic_vector(24 downto 0);
        IFID_pc          : out unsigned(5 downto 0);

        -- Testbench loader
        load_enable : in std_logic;
        load_addr   : in unsigned(5 downto 0);
        load_data   : in std_logic_vector(24 downto 0)
    );
end entity IF_Stage;

architecture structural of IF_Stage is

    -- internal wires
    signal pc_addr_sig : unsigned(5 downto 0);
    signal instr_sig   : std_logic_vector(24 downto 0);

    -- IF/ID pipeline registers
    signal reg_instr : std_logic_vector(24 downto 0);
    signal reg_pc    : unsigned(5 downto 0);

begin

    -- ===================PROGRAM COUNTER ================================
    PC0 : entity work.PC_Register
        port map(
            clk => clk,
            rst => rst,
            pc_freeze => freeze,
            pc_out => pc_addr_sig
        );
	
	-- ================= Instruction Buffer =========================
    IB0 : entity work.InstructionBuffer
        port map(
            clk => clk,
            pc_addr => pc_addr_sig,
            instruction => instr_sig,
            load_enable => load_enable,
            load_addr   => load_addr,
            load_data   => load_data
        );

    ---------------------------------------------------------
    -- IF/ID Pipeline Register
    ---------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_instr <= (others => '0');
                reg_pc    <= (others => '0');
            elsif freeze = '0' then
                reg_instr <= instr_sig;
                reg_pc    <= pc_addr_sig;
            end if;
        end if;
    end process;

    IFID_instruction <= reg_instr;
    IFID_pc <= reg_pc;

end architecture structural;
