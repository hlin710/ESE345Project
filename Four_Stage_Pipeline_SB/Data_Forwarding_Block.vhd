-------------------------------------------------------------------------------
--
-- Title       : Data_Forwarding_Block
-- Design      : FourStagePipeline
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Design/FourStagePipeline/FourStagePipeline/src/Data_Forwarding_Block.vhd
-- Generated   : Thu Nov 27 19:30:18 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : The block detects the hazards between the previous instruction and the current one by comparing source registers in
-- ID/EX with the destination register in EX/WB. If a match exists and write-back is enabled, it asserts a select line to forward the
-- newer ALU result instead of using stale data.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Data_Forwarding_Block is
	port(
		idex_rs1 : in unsigned(4 downto 0);
		idex_rs2 : in unsigned(4 downto 0);
		idex_rs3 : in unsigned(4 downto 0);
		idex_uses_rs3 : in STD_LOGIC; -- only used for R4 instructions
		
		-- Inputs from the EX/WB stage
		ex_wb_rd : in unsigned(4 downto 0);
		ex_wb_regWrite : in STD_LOGIC;
		
		-- Outputs driving into the forwarding mux
		sel_rs1 : out STD_LOGIC;
		sel_rs2 : out STD_LOGIC;
		sel_rs3 : out STD_LOGIC
	);
end Data_Forwarding_Block;

architecture behavioral of Data_Forwarding_Block is
begin
	process(idex_rs1, idex_rs2, idex_rs3, ex_wb_rd, ex_wb_regWrite, idex_uses_rs3)
	begin
		-- Forward to rs1
		if ex_wb_regWrite = '1' and ex_wb_rd = idex_rs1 and ex_wb_rd /= "00000" then
			sel_rs1 <= '1';
		else
			sel_rs1 <= '0';
		end if;
		
		-- Forward to rs2
		if ex_wb_regWrite = '1' and ex_wb_rd = idex_rs2 and ex_wb_rd /= "00000" then
			sel_rs2 <= '1';
		else
			sel_rs2 <= '0';
		end if;
		
		-- Forward to rs3 but only if r4 uses rs3
		if idex_uses_rs3 = '1' and ex_wb_regWrite = '1' and ex_wb_rd = idex_rs3 and ex_wb_rd /= "00000" then
			sel_rs3 <= '1';
		else
			sel_rs3 <= '0';
		end if;
	end process;
end behavioral;