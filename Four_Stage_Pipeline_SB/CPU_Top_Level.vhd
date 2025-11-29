-------------------------------------------------------------------------------
--
-- Title       : CPU_Top_Level
-- Design      : FourStagePipeline
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Design/FourStagePipeline/FourStagePipeline/src/CPU_Top_Level.vhd
-- Generated   : Fri Nov 28 16:41:17 2025
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

entity CPU_Top_Level is
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC
	);
end CPU_Top_Level;

architecture structural of CPU_Top_Level is
	-- IF stage signals
	signal pc : unsigned(5 downto 0); -- PC address
	signal instr_if : std_logic_vector(24 downto 0); -- Instruction from IF
	-- IF/ID going into ID
	signal instr_id : std_logic_vector(24 downto 0);
	
	-- Decode + Regfile signals
	signal rs1_idx : unsigned(4 downto 0);
	signal rs2_idx : unsigned(4 downto 0);
	signal rs3_idx : unsigned(4 downto 0);
	signal rd_idx : std_logic_vector(4 downto 0);
	signal imm16 : std_logic_vector(15 downto 0);
	signal opcode : std_logic_vector(7 downto 0);
	signal is_li_sig : std_logic;
	signal reg_write_sig : std_logic;
	
	signal rs1_data : std_logic_vector(127 downto 0);
	signal rs2_data : std_logic_vector(127 downto 0);
	signal rs3_data : std_logic_vector(127 downto 0);
	
	-- WB connection
	signal wb_rd_idx : unsigned(4 downto 0);
	signal wb_result : std_logic_vector(127 downto 0);
	signal wb_regWrite : std_logic;
	
	-- ID/EX register file
	signal id_ex_rs1_data : std_logic_vector(127 downto 0);
	signal id_ex_rs2_data : std_logic_vector(127 downto 0);
	signal id_ex_rs3_data : std_logic_vector(127 downto 0);
	
	signal id_ex_imm16 : std_logic_vector(15 downto 0);
	signal id_ex_opcode : std_logic_vector(7 downto 0);
	
	signal id_ex_rd_idx : unsigned(4 downto 0);
	signal id_ex_opcode : std_logic_vector(7 downto 0);
	signal id_ex_regWrite : std_logic;
	
	-- Forwarding + Ex stage signals
	signal sel_rs1 : std_logic;
	signal sel_rs2 : std_logic;
	signal sel_rs3 : std_logic;
	signal id_ex_uses_rs3 : std_logic; -- 1 only for R4 instructions
	
	signal opA : std_logic_vector(127 downto 0);
	signal opB : std_logic_vector(127 downto 0);
	signal opC : std_logic_vector(127 downto 0);
	
	signal alu_result : std_logic_vector(127 downto 0);
	
	-- EX/WB Stage Signals (used for WB + forwarding)
	signal ex_wb_rd_idx : unsigned(4 downto 0);
	signal ex_wb_result : unsigned(4 downto 0);
	signal ex_wb_we : std_logic;
	
	begin
		-- IF Stage
		Program_Counter : entity work.Program_Counter
			port map(
				clk => clk,
				rst => rst,
				pc_freeze => '0',
				pc_out => pc -- feeds Instruction Buffer address
			);
		
		Instruction_Buffer: entity work.Instruction_Buffer
			port map(
				clk => clk,
				pc_addr => pc, -- from Program Counter
				instruction => instr_if, -- fetched instruction into IF/ID
				load_enable => '0',	-- TB will override
				load_addr => (others => '0'), -- ignored
				load_data => (others => '0') -- ignored
			);
			
		IF_ID_Reg : entity work.IF_ID_Reg
			port map(
				clk => clk,
				rst => rst,
				ifid_freeze => '0', -- stall
				instruction_in => instr_if, -- output from Instruction Buffer
				instruction_out => instr_id- -- goes into Decode stage
			);
			
		-- Decode Stage
		Decoder : entity work.Decode
			port map(
				instruction => instr_id, -- from IF/ID register
				rs1_index => rs1_idx,
				rs2_index => rs2_idx,
				rs3_index => rs3_idx,
				rd_index => rd_idx,
				immediate16_out => imm16,
				opcode_out => opcode,
				is_li => is_li_sig,
				reg_write => reg_write_sig
			);
			
		Register_File : entity work.Register_File
			port map(
				clk => clk,
				rst => rst,
				-- Read ports
				rs1_index => rs1_idx,
				rs2_index => rs2_idx,
				rs3_index => rs3_idx,
				
				-- Output to ID/EX
				rs1_data => rs1_data,
				rs2_data => rs2_data,
				rs3_data => rs3_data,
				
				-- Write port (WB stage feedback)
				rd_index => wb_rd_idx,
				rd_data => wb_result,
				reg_write => wb_regWrite
			);
			
		ID_EX_Reg : entity work.ID_EX_Reg
			port map(
				clk => clk,
				rst => rst,
				id_ex_freeze => '0',
				
				rs1_in => rs1_data,
				rs2_in => rs2_data,
				rs3_in => rs3_data,
				immediate16_in <= imm16,
				opcode_in => opcode,
				rd_index_in => rd_idx,
				is_li_in => is_li,
				reg_write_in => reg_write, -- from Decode
				
				rs1_out => id_ex_rs1_data,
				rs2_out => id_ex_rs2_data,
				rs3_out => id_ex_rs3_data,
				immediate16_out => id_ex_imm16,
				opcode_out => id_ex_opcode,
				rd_index_out => id_ex_rd_idx,
				is_li_out => id_ex_is_li,
				reg_write_out => id_ex_regWrite
			);
			
		Data_Forwarding_Block : entity work.Data_Forwarding_Block
			port map(
				id_ex_rs1 => id_ex_rs1_idx, -- from ID/EX reg
			    id_ex_rs2 => id_ex_rs2_idx,
				id_ex_rs3 => id_ex_rs3_idx,
				id_ex_uses_rs3 => id_ex_is_li,
				
				ex_wb_rd => ex_wb_rd_idx, -- from EX/WB register
				ex_wb_regWrite => ex_wb_we,
				
				sel_rs1 => sel_rs1,
				sel_rs1 => sel_rs2,
				sel_rs3 => sel_rs3
			);
			
		Forwarding_Muxs : entity work.Forwarding_Muxs
			port map(
				rs1_in => id_ex_rs1_data,
				rs2_in => id_ex_rs2_data,
				rs3_in => id_ex_rs3_data,
				opcode => id_ex_opcode,
				
				EX_WB_res => ex_wb_result, -- value to forward to WB
				rd_EX_WB_index => ex_wb_rd_idx,
				
				sel_rs1 => sel_rs1,
				sel_rs2 => sel_rs2,
				sel_rs3 => sel_rs3,
				
				rs1_res => opA,
				rs2_res => opB,
				rs3_res => opC
			);
			
		MALU : entity work.MALU
			port map(
				rs1 => opA;
				rs2 => opB,
				rs3 => opC,
				opcode => opcode, -- from Decode/IDEX
				result => alu_result
			);
			
		EX_WB_Reg : entity work.EX_WB_Reg
			port map(
				clk => clk,
				rst => rst,
				ex_wb_freeze => '0',
				rd_result_in => alu_result,
				rd_index_in => id_ex_rs1_idx, -- actual rd index from ID/EX
				reg_write_in => id_ex_reg_write, -- from Decode
				
				rd_result_in => ex_wb_result,
				rd_index_out => ex_wb_rd_idx,
				reg_write_out => ex_wb_we
			);	
end structural;
