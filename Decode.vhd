-------------------------------------------------------------------------------
--
-- Title       : Decode
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/Decode.vhd
-- Generated   : Thu Nov 27 02:39:04 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Identify instruction format (LI, R4, R3) and extract fields required for Register File read 
-- and Execute stage.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all; 
use work.all;

entity Decode is
	port(
		instruction : in STD_LOGIC_VECTOR(24 downto 0);
		
		-- Register indexes extracted from instructionuction
		rs1_index : out unsigned(4 downto 0);
		rs2_index : out unsigned(4 downto 0);
		rs3_index : out unsigned(4 downto 0);
		rd_index : out unsigned(4 downto 0);
		
		-- Immediate and ALU selection
		immediate16_out : out STD_LOGIC_VECTOR(15 downto 0);
		opcode_out : out STD_LOGIC_VECTOR(7 downto 0);
		
		-- Control signals passed forward into the pipeline
		is_li: out STD_LOGIC;
		reg_write : out STD_LOGIC
	);
end Decode;

architecture behavioral of Decode is
begin
	process(instruction)
	begin
		-- Default values
		rs1_index <= (others => '0');
        rs2_index <= (others => '0');
        rs3_index <= (others => '0');
        rd_index <= (others => '0');
        immediate16_out <= (others => '0');
        opcode_out <= (others => '0');
        is_li <= '0';
        reg_write <= '0';
		
		-- Format: LI
		if instruction(24) = '0' then
			is_li <= '1';
			reg_write <= '1';
			
			rd_index <= unsigned(instruction(4 downto 0));
			rs1_index <= unsigned(instruction(4 downto 0)); -- rd is a source and destination register
			immediate16_out <= instruction(20 downto 5);
			
		-- Format: R4
		elsif instruction(24) = '1' and instruction(23) = '0' then
			reg_write <= '1';    

            rs3_index <= unsigned(instruction(19 downto 15));
            rs2_index <= unsigned(instruction(14 downto 10));
            rs1_index <= unsigned(instruction(9 downto 5));
            rd_index <= unsigned(instruction(4 downto 0));

            opcode_out(7) <= instruction(22); -- Long/Int (LI)   
            opcode_out(6) <= instruction(21); -- Subtract/Add (SA) 
            opcode_out(5) <= instruction(20); -- High/Low (HL)
		
		-- Format: R3
		else
			reg_write <= '1';
			
			opcode_out <= instruction(22 downto 15);
			rs2_index <= unsigned(instruction(14 downto 10));
			rs1_index <= unsigned(instruction(9 downto 5));
			rd_index <= unsigned(instruction(4 downto 0));
		end if;
	end process;
end behavioral;