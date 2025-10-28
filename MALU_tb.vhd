-------------------------------------------------------------------------------
--
-- Title       : MALU_tb
-- Design      : MALU
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/ESE345Project/MALU/src/MALU_tb.vhd
-- Generated   : Tue Oct 28 15:28:59 2025
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

entity MALU_tb is
end MALU_tb;

architecture tb_architecture of MALU_tb is

signal rs1, rs2, rs3, rd : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal instruction_format : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');

constant period : time := 20ns;

begin
	UUT : entity MALU
		port map(
		rs1 => rs1, 
		rs2 => rs2, 
		rs3 => rs3, 
		instruction_format => instruction_format, 
		rd => rd
		);
		
	li_tb : process
		variable expected : STD_LOGIC_VECTOR(127 downto 0);
	begin
		-- TEST 1
		rs1 <= x"00001111222233334444555566667777";
		-- Format ID: "00", Load_Index = "011", Immediate = x"FOOD"
		instruction_format <= "0" & "011" & x"F00D" & "00000";
		wait for period;
		
		expected := x"0000111122223333F00D555566667777";
		assert (rd = expected)
			report "Test 1 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
			
		report "All test cases passed!" severity note;
	
  	std.env.finish;
  end process;
end tb_architecture;
