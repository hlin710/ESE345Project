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

-- Local LI signals


constant period : time := 10ns;

begin
	UUT : entity MALU
		port map(
		rs1 => rs1, 
		rs2 => rs2, 
		rs3 => rs3, 
		instruction_format => instruction_format, 
		rd => rd
		);
		
	stim : process
		variable expected : STD_LOGIC_VECTOR(127 downto 0);
	begin
		report "=== STARTING MALU TESTBENCH ===";
		report "=== STARTING LOAD IMMEDIATE TESTBENCH ===";
		-- TEST 1
		rs1 <= x"00001111222233334444555566667777";
		-- Format ID: "00", Load Index = "011", Immediate = x"F00D", rd = "00000"
		instruction_format <= "0" & "011" & x"F00D" & "00000";
		wait for period; -- 10ns
		
		expected := x"0000111122223333F00D555566667777";
		assert (rd = expected)
			report "Test 1 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
			
		-- TEST 2
		rs1 <= x"FFFFEEEEDDDDCCCCBBBBAAAA99998888";
		-- Format ID: "01", Load Index = "101", Immediate = x"BEEF", rd = "01010"
		instruction_format <= "0" & "101" & x"BEEF" & "01010";
		wait for period; -- 20ns
		
		expected := x"FFFFEEEEBEEFCCCCBBBBAAAA99998888";
		assert (rd = expected)
			report "Test 2 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
			
		-- TEST 3
		rs1 <= x"AAAABBBBCCCCDDDDEEEE000011112222";
		-- Format ID: "01", Load Index = "111", Immediate = x"0000", rd = "11011"
		instruction_format <= "0" & "111" & x"0000" & "11011";
		wait for period; -- 30ns
		
		expected := x"0000BBBBCCCCDDDDEEEE000011112222";
		assert (rd = expected)
			report "Test 3 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
		
		report "All load immediate test cases passed!" severity note;
		----------------------------------------------------------------
		-- SIMALWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - ADD LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; -- 40ns
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; -- 50ns
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; -- 60ns
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"0000FFFF0000FFFE0000FFFD0000FFFC";
		rs3 <= x"00000001000000020000000300000004";
		instruction_format <= "10" & "000" & "00000000000000000000";
		wait for period; -- 70ns
	
		report "All signed integer multiply - add low with saturation tests complete!";
		----------------------------------------------------------------
		-- SIMAHWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - ADD HIGH WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "001" & "00000100000010000100";
		wait for period; -- 80ns
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		instruction_format <= "10" & "001" & "00000000000000000000";
		wait for period; -- 90ns
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "001" & "00000001000010000000";
		wait for period; -- 100ns
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"7FFF80007FFF80007FFF80007FFF8000";  
		rs3 <= x"00010001000100010001000100010001";
		instruction_format <= "10" & "001" & "00000000000000000000";
		wait for period; -- 110ns
		
		report "All signed integer multiply - add high with saturation tests complete!";
		---------------------------------------------------------------- 
		-- SIMSLWS -- 
		report "=== STARTING SIGNED INTEGER MULTIPLY - SUBTRACT LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "010" & "00000000000000000000";
		wait for period; -- 120ns
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		instruction_format <= "10" & "010" & "00001000000001000100";
		wait for period; -- 130ns
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		instruction_format <= "10" & "010" & "00000000010000101100";
		wait for period; -- 140ns 
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"0000FFFF0000FFFE0000FFFD0000FFFC";
		rs3 <= x"00000001000000020000000300000004";
		instruction_format <= "10" & "010" & "00001001000000001000";
		wait for period; -- 150ns
		
		report "All signed integer multiply - subtract low with saturation tests complete!";
		---------------------------------------------------------------- 
		-- SIMSHWS --
		report "=== STARTING SIGNED INTEGER MULTIPLY - SUBTRACT HIGH WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00020003000400050006000700080009"; 
		rs3 <= x"00010002000300040005000600070008";
		instruction_format <= "10" & "011" & "00000000000000000000";
		wait for period; -- 160ns
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF"; 
		rs2 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		rs3 <= x"FFFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF";
		instruction_format <= "10" & "011" & "00000000010000000010"; 
		wait for period; -- 170ns
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000"; 
		rs2 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 
		rs3 <= x"7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF"; 		
		instruction_format <= "10" & "011" & "00010000000100000000";  
		wait for period; -- 180ns 
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"7FFF80007FFF80007FFF80007FFF8000"; 
		rs3 <= x"80007FFF80007FFF80007FFF80007FFF";
		instruction_format <= "10" & "011" & "00000011000000001000";
		wait for period; -- 190ns                                                                                         
		
		report "All signed integer multiply - subtract high with saturation tests complete!";
		----------------------------------------------------------------                         
		-- LONG PRINTS ALL FFFFFs so try later
	
	
		-- NOP -- 
		report "=== STARTING NOP TESTBENCH ===";
	
		-- TEST 1
		rs1 <= x"11112222333344445555666677778888";
		rs2 <= x"9999AAAAFFFFEEEE7777555544443333";
		rs3 <= x"00000000000000000000000000000000"; -- no longer needed for R3 instructions
		instruction_format <= "11" & "00000000" & "000000000000000";
		wait for period;
		
		report "All nop tests complete!";
		----------------------------------------------------------------
		-- SHRHI --
		report "=== STARTING SHRHI TESTBENCH ===";
		
		-- TEST 1 
		rs1 <= x"FFFF0001FFF10010ABCD98765432FEDC";
		rs2 <= x"00000000000000000000000000000004";  
		instruction_format <= "11" & "00010001" & "000000000000000";
		wait for period;
		
		report "All shrhi tests complete!";
		----------------------------------------------------------------
		-- AU --
		report "=== STARTING AU TESTBENCH ===";
		
		-- TEST 1 (no overflow)
		rs1 <= x"FFFF0001FFF10010ABCD98765432FEDC";
		rs2 <= x"00000000000000000000000000000004";  
		instruction_format <= "11" & "01100010" & "000000000000000";
		wait for period;
		
		-- TEST 2 (overflow)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000001000000010000000100000001";
		instruction_format <= "11" & "00000010" & "000000000000000";
		wait for period;
		
		report "All au tests complete!";
		----------------------------------------------------------------
		-- CNT1H --
		report "=== STARTING CNT1H TESTBENCH ===";
		
		-- TEST 1 (all ones)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000000000000000000000000000000"; -- not needed so reset  
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period; 
		
		-- TEST 2 (alternating)
		rs1 <= x"AAAA5555AAAA5555AAAA5555AAAA5555"; 
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period;
		
		report "All cnt1h tests complete!";
		----------------------------------------------------------------
		-- AHS --
		report "=== STARTING CNT1H TESTBENCH ===";
		
		-- TEST 1 (all ones)
		rs1 <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		rs2 <= x"00000000000000000000000000000000"; -- not needed so reset  
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period; 
		
		-- TEST 2 (alternating)
		rs1 <= x"AAAA5555AAAA5555AAAA5555AAAA5555"; 
		instruction_format <= "11" & "00000011" & "000000000000000";
		wait for period;
		
		report "All cnt1h tests complete!";
		
		
		
		
	
































		
		
		
		
		
		
		
		
		
		
		

		
	------------------------------------------------

	 --  -- Test 1 (AHS)
	--	rs1 <= x"00010002000300040005000600070008";  -- Halfwords: 0001, 0002, 0003, 0004, 0005, 0006, 0007, 0008
	--	rs2 <= x"00010001000100010001000100010001";  -- Halfwords: eight 0001
	--	instruction_format <= "11" & "01010100000000001001101"; 
	--	wait for period;
		


		
				
		
		
		
		
	
  	std.env.finish;
  end process;
end tb_architecture;
